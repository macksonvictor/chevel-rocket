#include "RobotController.h"

#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QRandomGenerator>
#include <QTime>
#include <QUrl>
#include <QtMath>
#include <cmath>

namespace {
constexpr double kPi = 3.14159265358979323846;

double clamp(double value, double minValue, double maxValue)
{
    return qBound(minValue, value, maxValue);
}
}

RobotController::RobotController(QObject *parent)
    : QObject(parent)
    , m_commandInterface(this)
    , m_telemetry(this)
    , m_transcriptionService(this)
    , m_synthesisService(this)
    , m_simulationTimer(this)
{
    connect(&m_transcriptionService, &VoiceTranscriptionService::processStarted, this, [this](const QString &label, const QString &commandLine) {
        appendVoiceDiagnostics(QStringLiteral("%1 started\n%2").arg(label, commandLine));
        appendTerminal(QStringLiteral("VOICE: %1").arg(commandLine));
    });
    connect(&m_transcriptionService,
            &VoiceTranscriptionService::processFinished,
            this,
            [this](const QString &label,
                   bool ok,
                   const QString &stdoutText,
                   const QString &stderrText,
                   const QString &outputFile,
                   const QString &transcriptionText) {
                appendVoiceDiagnostics(QStringLiteral("%1 %2").arg(label, ok ? QStringLiteral("READY") : QStringLiteral("ERROR")));
                if (!outputFile.isEmpty()) {
                    appendVoiceDiagnostics(QStringLiteral("Output: %1").arg(QDir::toNativeSeparators(outputFile)));
                }
                if (!transcriptionText.isEmpty()) {
                    setLastVoiceCommand(transcriptionText);
                    appendVoiceDiagnostics(QStringLiteral("Transcription: %1").arg(transcriptionText));
                    simulateVoiceCommand(transcriptionText);
                }
                if (!stdoutText.trimmed().isEmpty()) {
                    appendVoiceDiagnostics(QStringLiteral("stdout:\n%1").arg(stdoutText.trimmed().left(1600)));
                }
                if (!stderrText.trimmed().isEmpty()) {
                    appendVoiceDiagnostics(QStringLiteral("stderr:\n%1").arg(stderrText.trimmed().left(1600)));
                }
                addLog(ok ? QStringLiteral("INFO") : QStringLiteral("ERROR"),
                       QStringLiteral("[VOICE] %1 %2").arg(label, ok ? QStringLiteral("completed") : QStringLiteral("failed")));
                updateVoiceStatusFromTools();
            });
    connect(&m_synthesisService, &VoiceSynthesisService::processStarted, this, [this](const QString &label, const QString &commandLine) {
        appendVoiceDiagnostics(QStringLiteral("%1 started\n%2").arg(label, commandLine));
        appendTerminal(QStringLiteral("TTS: %1").arg(commandLine));
    });
    connect(&m_synthesisService, &VoiceSynthesisService::processFinished, this, [this](const QString &label, bool ok, const QString &stdoutText, const QString &stderrText, const QString &outputFile) {
        appendVoiceDiagnostics(QStringLiteral("%1 %2").arg(label, ok ? QStringLiteral("READY") : QStringLiteral("ERROR")));
        if (!outputFile.isEmpty()) {
            appendVoiceDiagnostics(QStringLiteral("Output: %1").arg(QDir::toNativeSeparators(outputFile)));
        }
        if (!stdoutText.trimmed().isEmpty()) {
            appendVoiceDiagnostics(QStringLiteral("stdout:\n%1").arg(stdoutText.trimmed().left(1600)));
        }
        if (!stderrText.trimmed().isEmpty()) {
            appendVoiceDiagnostics(QStringLiteral("stderr:\n%1").arg(stderrText.trimmed().left(1600)));
        }
        addLog(ok ? QStringLiteral("INFO") : QStringLiteral("WARNING"),
               ok ? QStringLiteral("[VOICE] TTS audio spoken/generated") : QStringLiteral("[VOICE] TTS nao configurado ainda"));
        updateVoiceStatusFromTools();
    });

    connect(&m_simulationTimer, &QTimer::timeout, this, &RobotController::updateSimulation);
    m_simulationTimer.setInterval(500);
    m_simulationTimer.start();
    m_commandInterface.setSimulationMode(m_simulationMode);
    refreshConnectionState();

    addLog("INFO", "System initialized");
    addLog("INFO", "LIVE control surface initialized");
    addLog("INFO", "Telemetry estimator started");
    addLog("INFO", "Local AI profile: Qwen3 8B via Ollama");
    addLog("INFO", "Voice stack target: faster-whisper STT + Piper/Windows SAPI TTS");
    addLog("INFO", "LIVE USB target: WIESEL Mini / ESP32 / PCA9685");
    addLog(m_commandInterface.liveBridgeAvailable() ? "INFO" : "WARNING",
           m_commandInterface.liveBridgeAvailable()
               ? QStringLiteral("LIVE USB serial ready: %1").arg(m_commandInterface.liveBridgePath())
               : QStringLiteral("LIVE USB serial missing: set CHEVEL_ROBOT_SERIAL_PORT"));
    appendTerminal("chevel@rocket:~$ status");
    appendTerminal(m_commandInterface.liveBridgeAvailable()
                       ? QStringLiteral("LIVE READY / USB SERIAL %1 / SAFE MODE ACTIVE").arg(m_commandInterface.liveBridgePath())
                       : QStringLiteral("LIVE STANDBY / SERIAL PORT MISSING / SAFE MODE ACTIVE"));
    appendTerminal(QStringLiteral("AI: QWEN3 8B / STT: FASTER-WHISPER / TTS: ") + m_synthesisService.activeEngineName());
    runVoiceDiagnostics();
}

double RobotController::batteryLevel() const
{
    return m_batteryLevel;
}

double RobotController::motorTemperature() const
{
    return m_motorTemperature;
}

double RobotController::speed() const
{
    return m_speed;
}

double RobotController::signalStrength() const
{
    return m_signalStrength;
}

double RobotController::cpuLoad() const
{
    return m_cpuLoad;
}

double RobotController::missionRisk() const
{
    return m_missionRisk;
}

QString RobotController::missionStatus() const
{
    return m_missionStatus;
}

int RobotController::missionElapsedSeconds() const
{
    return m_missionElapsedSeconds;
}

QString RobotController::missionElapsedText() const
{
    const int hours = m_missionElapsedSeconds / 3600;
    const int minutes = (m_missionElapsedSeconds % 3600) / 60;
    const int seconds = m_missionElapsedSeconds % 60;
    return QStringLiteral("%1:%2:%3")
        .arg(hours, 2, 10, QLatin1Char('0'))
        .arg(minutes, 2, 10, QLatin1Char('0'))
        .arg(seconds, 2, 10, QLatin1Char('0'));
}

double RobotController::missionProgress() const
{
    return m_missionProgress;
}

double RobotController::missionDistance() const
{
    return m_missionDistance;
}

int RobotController::completedObjectives() const
{
    return m_completedObjectives;
}

int RobotController::totalObjectives() const
{
    return m_totalObjectives;
}

bool RobotController::safeMode() const
{
    return m_safeMode;
}

bool RobotController::simulationMode() const
{
    return m_simulationMode;
}

bool RobotController::virtualFencesActive() const
{
    return m_virtualFencesActive;
}

QString RobotController::voiceStatus() const
{
    return m_voiceStatus;
}

QString RobotController::lastVoiceCommand() const
{
    return m_lastVoiceCommand;
}

QString RobotController::aiModelName() const
{
    return QStringLiteral("QWEN3 8B (OLLAMA)");
}

QString RobotController::sttEngineName() const
{
    return QStringLiteral("FASTER-WHISPER");
}

QString RobotController::ttsEngineName() const
{
    return m_synthesisService.activeEngineName();
}

QString RobotController::voicePipeline() const
{
    return QStringLiteral("MIC -> WHISPER -> QWEN3 -> TTS");
}

QString RobotController::whisperStatus() const
{
    return toolStatus(m_transcriptionService.whisperAvailable());
}

QString RobotController::ffmpegStatus() const
{
    return toolStatus(m_transcriptionService.ffmpegAvailable());
}

QString RobotController::piperStatus() const
{
    return toolStatus(m_synthesisService.piperAvailable() || m_synthesisService.fallbackTtsAvailable());
}

QString RobotController::piperModelStatus() const
{
    if (!m_synthesisService.piperModelAvailable() && m_synthesisService.fallbackTtsAvailable()) {
        return QStringLiteral("OPTIONAL");
    }
    return toolStatus(m_synthesisService.piperModelAvailable());
}

QString RobotController::whisperPath() const
{
    const QString path = m_transcriptionService.whisperPath();
    return path.isEmpty() ? QStringLiteral("Nao encontrado") : QDir::toNativeSeparators(path);
}

QString RobotController::ffmpegPath() const
{
    const QString path = m_transcriptionService.ffmpegPath();
    return path.isEmpty() ? QStringLiteral("Nao encontrado no PATH") : QDir::toNativeSeparators(path);
}

QString RobotController::piperPath() const
{
    const QString path = m_synthesisService.piperPath();
    if (path.isEmpty() && m_synthesisService.fallbackTtsAvailable()) {
        return QStringLiteral("Windows SAPI via powershell.exe");
    }
    return path.isEmpty() ? QStringLiteral("Configure CHEVEL_PIPER_EXE") : QDir::toNativeSeparators(path);
}

QString RobotController::piperModelPath() const
{
    const QString path = m_synthesisService.piperModelPath();
    if (path.isEmpty() && m_synthesisService.fallbackTtsAvailable()) {
        return QStringLiteral("Opcional: configure Piper .onnx; usando Windows SAPI agora");
    }
    return path.isEmpty() ? QStringLiteral("Configure CHEVEL_PIPER_MODEL ou coloque .onnx em CHEVEL_AI_MODELS_DIR") : QDir::toNativeSeparators(path);
}

QString RobotController::voiceOutputDir() const
{
    return QDir::toNativeSeparators(m_transcriptionService.outputDir());
}

QString RobotController::aiModelsDir() const
{
    return QDir::toNativeSeparators(m_synthesisService.modelsDir());
}

QString RobotController::voiceDiagnosticsOutput() const
{
    return m_voiceDiagnosticsLines.join(QLatin1Char('\n'));
}

double RobotController::memoryUsage() const
{
    return m_memoryUsage;
}

double RobotController::storageUsage() const
{
    return m_storageUsage;
}

QString RobotController::terminalTranscript() const
{
    return m_terminalLines.join(QLatin1Char('\n'));
}

QString RobotController::robotState() const
{
    return m_robotState;
}

QString RobotController::connectionState() const
{
    return m_connectionState;
}

bool RobotController::liveBridgeAvailable() const
{
    return m_commandInterface.liveBridgeAvailable();
}

QString RobotController::liveBridgePath() const
{
    return QDir::toNativeSeparators(m_commandInterface.liveBridgePath());
}

QString RobotController::serialPortName() const
{
    const QString port = m_commandInterface.serialPortName();
    return port.isEmpty() ? QStringLiteral("CHEVEL_ROBOT_SERIAL_PORT nao configurado") : port;
}

int RobotController::serialBaudRate() const
{
    return m_commandInterface.serialBaudRate();
}

bool RobotController::serialConfigured() const
{
    return m_commandInterface.serialConfigured();
}

QString RobotController::outboxPath() const
{
    const QString path = m_commandInterface.outboxPath();
    return path.isEmpty() ? QStringLiteral("CHEVEL_ROBOT_COMMAND_OUTBOX nao configurado") : QDir::toNativeSeparators(path);
}

bool RobotController::emergencyActive() const
{
    return m_emergencyActive;
}

bool RobotController::armed() const
{
    return m_armed;
}

QStringList RobotController::logs() const
{
    return m_logs;
}

TelemetryModel *RobotController::telemetry()
{
    return &m_telemetry;
}

bool RobotController::armRobot()
{
    if (!commandAllowed("ARM ROBOT")) {
        return false;
    }
    if (m_armed) {
        addLog("WARNING", "ARM ROBOT ignored: robot is already armed");
        return false;
    }

    if (!m_commandInterface.arm()) {
        return reportCommandInterfaceFailure("ARM ROBOT");
    }

    setArmed(true);
    setRobotState("ARMED");
    addLog("INFO", m_simulationMode ? "Robot armed in simulation fallback" : "ARM ROBOT sent to USB serial");
    return true;
}

bool RobotController::disarmRobot()
{
    if (!commandAllowed("DISARM ROBOT")) {
        return false;
    }
    if (!m_armed) {
        addLog("WARNING", "DISARM ROBOT ignored: robot is already disarmed");
        return false;
    }

    if (!m_commandInterface.disarm()) {
        return reportCommandInterfaceFailure("DISARM ROBOT");
    }

    setArmed(false);
    setRobotState("IDLE");
    addLog("INFO", m_simulationMode ? "Robot disarmed in simulation fallback" : "DISARM ROBOT sent to USB serial");
    return true;
}

bool RobotController::startMission()
{
    if (!commandAllowed("START MISSION")) {
        return false;
    }
    if (!m_armed) {
        if (!m_simulationMode) {
            addLog("ERROR", "START MISSION blocked: arm the robot before LIVE motion");
            return false;
        }
        setArmed(true);
        addLog("INFO", "Robot auto-armed for simulation fallback");
    }

    if (!m_commandInterface.startMission()) {
        return reportCommandInterfaceFailure("START MISSION");
    }

    setRobotState("MOVING");
    setMissionStatus("EM ANDAMENTO");
    m_missionRunning = true;
    addLog("INFO", m_simulationMode ? "Mission started in simulation fallback" : "START MISSION sent to USB serial");
    return true;
}

bool RobotController::pauseMission()
{
    if (!commandAllowed("PAUSE MISSION")) {
        return false;
    }
    if (m_robotState != "MOVING") {
        addLog("WARNING", "PAUSE MISSION ignored: mission is not moving");
        return false;
    }

    if (!m_commandInterface.pauseMission()) {
        return reportCommandInterfaceFailure("PAUSE MISSION");
    }

    setRobotState("PAUSED");
    setMissionStatus("PAUSADA");
    m_missionRunning = false;
    addLog("INFO", m_simulationMode ? "Mission paused in simulation fallback" : "PAUSE MISSION sent to USB serial");
    return true;
}

bool RobotController::returnHome()
{
    if (!commandAllowed("RETURN HOME")) {
        return false;
    }
    if (!m_armed) {
        if (!m_simulationMode) {
            addLog("ERROR", "RETURN HOME blocked: arm the robot before LIVE motion");
            return false;
        }
        setArmed(true);
        addLog("INFO", "Robot auto-armed for simulation fallback return home");
    }

    if (!m_commandInterface.returnHome()) {
        return reportCommandInterfaceFailure("RETURN HOME");
    }

    setRobotState("MOVING");
    setMissionStatus("RETORNANDO PARA BASE");
    m_missionRunning = true;
    addLog(m_simulationMode ? "WARNING" : "INFO",
           m_simulationMode ? "Return home sequence simulated" : "RETURN HOME sent to USB serial");
    return true;
}

bool RobotController::calibrateSensors()
{
    if (!commandAllowed("CALIBRATE SENSORS")) {
        return false;
    }

    if (!m_commandInterface.calibrateSensors()) {
        return reportCommandInterfaceFailure("CALIBRATE SENSORS");
    }

    addLog("INFO", m_simulationMode ? "Sensor calibration completed in simulation fallback" : "CALIBRATE SENSORS sent to USB serial");
    return true;
}

bool RobotController::rebootSystem()
{
    if (!commandAllowed("REBOOT SYSTEM")) {
        return false;
    }

    if (!m_simulationMode) {
        addLog("WARNING", "REBOOT SYSTEM is diagnostics-only in WIESEL Mini v1; no physical reboot was sent");
        appendTerminal("REBOOT: blocked by v1 safety policy; use manual ESP32 reset/diagnostics");
        refreshConnectionState();
        return true;
    }

    if (!m_commandInterface.rebootSystem()) {
        return reportCommandInterfaceFailure("REBOOT SYSTEM");
    }

    setArmed(false);
    setRobotState("IDLE");
    setMissionStatus("READY");
    m_missionRunning = false;
    setSpeed(0.0);
    setCpuLoad(18.0);
    setMemoryUsage(58.0);
    addLog("WARNING", m_simulationMode ? "Simulated system reboot completed" : "REBOOT SYSTEM sent to USB serial");
    return true;
}

bool RobotController::emergencyStop()
{
    if (m_emergencyActive) {
        addLog("CRITICAL", "Emergency stop is already active");
        return false;
    }

    const bool bridgeOk = m_commandInterface.emergencyStop();

    setEmergencyActive(true);
    setArmed(false);
    setRobotState("EMERGENCY");
    setMissionStatus("EMERGENCY");
    m_missionRunning = false;
    setSpeed(0.0);
    setMissionRisk(100.0);
    refreshConnectionState();
    addLog("CRITICAL",
           bridgeOk
               ? (m_simulationMode ? QStringLiteral("Emergency stop engaged locally") : QStringLiteral("EMERGENCY STOP sent to USB serial"))
               : QStringLiteral("Local emergency latched; USB serial unavailable, use physical E-stop too"));
    return true;
}

bool RobotController::clearEmergency()
{
    if (!m_emergencyActive) {
        addLog("WARNING", "CLEAR EMERGENCY ignored: no emergency is active");
        return false;
    }

    const bool bridgeOk = m_commandInterface.clearEmergency();

    setEmergencyActive(false);
    setRobotState("IDLE");
    setArmed(false);
    setMissionStatus("READY");
    m_missionRunning = false;
    setMissionRisk(18.0);
    refreshConnectionState();
    addLog("WARNING",
           bridgeOk
               ? QStringLiteral("Emergency cleared; robot remains disarmed")
               : QStringLiteral("Local emergency cleared; USB serial unavailable, verify physical robot manually"));
    return true;
}

bool RobotController::confirmAction()
{
    addLog("INFO", "Pending cockpit action confirmed");
    appendTerminal("CONFIRM: operator accepted the pending cockpit action");
    return true;
}

bool RobotController::cancelAction()
{
    addLog("WARNING", "Pending cockpit action cancelled");
    appendTerminal("CANCEL: pending action discarded");
    return true;
}

bool RobotController::setSimulationMode(bool enabled)
{
    if (!enabled && m_emergencyActive) {
        addLog("ERROR", "LIVE mode blocked while emergency stop is active");
        return false;
    }

    if (m_simulationMode == enabled) {
        addLog("INFO", enabled ? "Simulation fallback is already active" : "LIVE mode is already selected");
        return true;
    }

    m_simulationMode = enabled;
    m_commandInterface.setSimulationMode(enabled);
    refreshConnectionState();
    addLog(enabled ? "WARNING" : "INFO",
           enabled
               ? QStringLiteral("Simulation fallback enabled; LIVE commands are paused")
               : QStringLiteral("LIVE mode selected; commands require CHEVEL_ROBOT_SERIAL_PORT"));
    emit simulationModeChanged();
    return true;
}

bool RobotController::toggleSafeMode()
{
    if (m_emergencyActive && m_safeMode) {
        addLog("ERROR", "Safe mode cannot be disabled during emergency");
        return false;
    }

    setSafeMode(!m_safeMode);
    addLog(m_safeMode ? "INFO" : "WARNING", m_safeMode ? "Safe mode enabled" : "Safe mode disabled");
    return true;
}

bool RobotController::toggleVirtualFences()
{
    if (m_emergencyActive && m_virtualFencesActive) {
        addLog("ERROR", "Virtual fences cannot be disabled during emergency");
        return false;
    }

    setVirtualFencesActive(!m_virtualFencesActive);
    addLog(m_virtualFencesActive ? "INFO" : "WARNING",
           m_virtualFencesActive ? "Virtual fences enabled" : "Virtual fences disabled");
    return true;
}

bool RobotController::testVoice()
{
    setVoiceStatus("TESTING");
    setLastVoiceCommand("testar voz");
    addLog("INFO", "[VOICE] Voice diagnostics started: Whisper -> Qwen3 8B -> TTS");
    runVoiceDiagnostics();
    const bool whisperStarted = testWhisper();
    const bool speechStarted = testPiper();
    updateVoiceStatusFromTools();
    return whisperStarted || speechStarted;
}

bool RobotController::runVoiceDiagnostics()
{
    QDir().mkpath(m_transcriptionService.outputDir());
    m_voiceDiagnosticsLines.clear();
    appendVoiceDiagnostics("CHEVEL ROCKET AI / VOICE DIAGNOSTICS");
    appendVoiceDiagnostics(QStringLiteral("AI Model: %1").arg(aiModelName()));
    appendVoiceDiagnostics(QStringLiteral("Pipeline: %1").arg(voicePipeline()));
    appendVoiceDiagnostics(QStringLiteral("LIVE USB: %1 | %2").arg(liveBridgeAvailable() ? QStringLiteral("READY") : QStringLiteral("STANDBY"),
                                                                   liveBridgePath()));
    appendVoiceDiagnostics(QStringLiteral("Serial baud: %1").arg(serialBaudRate()));
    appendVoiceDiagnostics(QStringLiteral("Debug outbox: %1").arg(outboxPath()));
    appendVoiceDiagnostics(QStringLiteral("FFmpeg: %1 | %2").arg(ffmpegStatus(), ffmpegPath()));
    appendVoiceDiagnostics(QStringLiteral("Whisper: %1 | %2").arg(whisperStatus(), whisperPath()));
    appendVoiceDiagnostics(QStringLiteral("TTS engine: %1").arg(ttsEngineName()));
    appendVoiceDiagnostics(QStringLiteral("TTS tool: %1 | %2").arg(piperStatus(), piperPath()));
    appendVoiceDiagnostics(QStringLiteral("Piper model: %1 | %2").arg(piperModelStatus(), piperModelPath()));
    appendVoiceDiagnostics(QStringLiteral("Windows SAPI fallback: %1").arg(toolStatus(m_synthesisService.fallbackTtsAvailable())));
    appendVoiceDiagnostics(QStringLiteral("Voice output: %1").arg(voiceOutputDir()));
    appendVoiceDiagnostics(QStringLiteral("AI models dir: %1").arg(aiModelsDir()));
    updateVoiceStatusFromTools();
    addLog("INFO", "[VOICE] Diagnostics refreshed");
    emit voiceDiagnosticsChanged();
    return true;
}

bool RobotController::testWhisper()
{
    if (!m_transcriptionService.whisperAvailable()) {
        appendVoiceDiagnostics("Whisper executable missing. Configure CHEVEL_WHISPER_EXE or install whisper in PATH.");
        addLog("ERROR", "[VOICE] Whisper executable missing");
        updateVoiceStatusFromTools();
        return false;
    }

    setVoiceStatus("TESTING");
    addLog("INFO", "[VOICE] Whisper probe requested");
    return m_transcriptionService.runProbe();
}

bool RobotController::testMicrophone()
{
    setVoiceStatus("TESTING");
    addLog("INFO", "[VOICE] Microphone capture requested");
    appendVoiceDiagnostics("Microphone: recording 4 seconds, then Whisper transcription.");
    return m_transcriptionService.recordAndTranscribe(4);
}

bool RobotController::testPiper()
{
    setVoiceStatus("TESTING");
    addLog("INFO", "[VOICE] TTS probe requested");
    return m_synthesisService.speak(QStringLiteral("Chevel Rocket voice diagnostics online."));
}

bool RobotController::speakText(const QString &text)
{
    const QString cleanText = text.trimmed();
    if (cleanText.isEmpty()) {
        appendVoiceDiagnostics("TTS ignored: empty text.");
        return false;
    }

    setVoiceStatus("TESTING");
    addLog("INFO", "[VOICE] TTS requested");
    return m_synthesisService.speak(cleanText);
}

bool RobotController::transcribeAudioFile(const QString &audioPath)
{
    const QString cleanPath = audioPath.trimmed();
    if (cleanPath.isEmpty()) {
        appendVoiceDiagnostics("Whisper transcription ignored: no audio file selected.");
        addLog("WARNING", "[VOICE] Whisper transcription ignored: no audio file selected");
        return false;
    }

    setVoiceStatus("TESTING");
    addLog("INFO", "[VOICE] Whisper transcription requested");
    return m_transcriptionService.transcribeFile(cleanPath);
}

bool RobotController::openVoiceOutputFolder()
{
    QDir().mkpath(m_transcriptionService.outputDir());
    addLog("INFO", "[VOICE] Opening voice output folder");
    return QDesktopServices::openUrl(QUrl::fromLocalFile(m_transcriptionService.outputDir()));
}

bool RobotController::simulateVoiceCommand(const QString &command)
{
    const QString normalized = command.trimmed().toLower();
    if (normalized.isEmpty()) {
        addLog("WARNING", "Voice command ignored: empty command");
        return false;
    }

    setLastVoiceCommand(normalized);
    addLog("INFO", QString("Voice command recognized: %1").arg(normalized));

    if (normalized.contains("emergency") || normalized.contains("parada")) {
        return emergencyStop();
    }
    if (normalized.contains("start") || normalized.contains("iniciar")) {
        return startMission();
    }
    if (normalized.contains("pause") || normalized.contains("pausar")) {
        return pauseMission();
    }
    if (normalized.contains("home") || normalized.contains("base")) {
        return returnHome();
    }

        addLog("WARNING", "Voice command has no mapped cockpit action");
    return true;
}

bool RobotController::moveRobot(const QString &direction)
{
    if (!commandAllowed(QString("MOVE ROBOT %1").arg(direction.toUpper()))) {
        return false;
    }

    const QString normalized = direction.trimmed().toLower();
    if (normalized == "stop") {
        setSpeed(0.0);
        setRobotState(m_armed ? "ARMED" : "IDLE");
        addLog("INFO", "Robot movement stopped");
        return true;
    }

    if (!m_armed) {
        setArmed(true);
        addLog("INFO", "Robot auto-armed for local manual movement");
    }

    setRobotState("MOVING");
    setMissionStatus("MANUAL CONTROL");
    setSpeed(normalized == "backward" ? 0.85 : 1.15);
    addLog("INFO", QString("Robot manual move requested locally: %1").arg(normalized));
    return true;
}

bool RobotController::openGripper()
{
    if (!commandAllowed("OPEN GRIPPER")) {
        return false;
    }

    addLog("INFO", "Gripper open requested locally");
    return true;
}

bool RobotController::closeGripper()
{
    if (!commandAllowed("CLOSE GRIPPER")) {
        return false;
    }

    addLog("INFO", "Gripper close requested locally");
    return true;
}

QString RobotController::runTerminalCommand(const QString &command)
{
    const QString normalized = command.trimmed().toLower();
    if (normalized.isEmpty()) {
        return QString();
    }

    appendTerminal(QString("chevel@rocket:~$ %1").arg(command.trimmed()));

    QString response;
    if (normalized == "status") {
        response = QString("state=%1 mission=%2 safe=%3 mode=%4 serial=%5 bridge=%6")
            .arg(m_robotState,
                 m_missionStatus,
                 m_safeMode ? "on" : "off",
                 simulationMode() ? "simulation-fallback" : "live",
                 serialConfigured() ? serialPortName() : QStringLiteral("missing"),
                 liveBridgeAvailable() ? "ready" : "missing");
    } else if (normalized == "battery") {
        response = QString("battery=%1% voltage=%2V")
            .arg(QString::number(m_batteryLevel, 'f', 0), QString::number(m_telemetry.voltage(), 'f', 1));
    } else if (normalized == "sensors") {
        response = QString("sensors=OK signal=%1% latency=%2ms")
            .arg(QString::number(m_signalStrength, 'f', 0), QString::number(m_telemetry.latency(), 'f', 0));
    } else if (normalized == "start") {
        startMission();
        response = "mission start requested";
    } else if (normalized == "pause") {
        pauseMission();
        response = "mission pause requested";
    } else if (normalized == "stop") {
        emergencyStop();
        response = "emergency stop requested";
    } else if (normalized == "home") {
        returnHome();
        response = "return home requested";
    } else if (normalized == "clear") {
        clearEmergency();
        response = "emergency clear requested";
    } else {
        response = QString("unknown command: %1").arg(command.trimmed());
    }

    appendTerminal(response);
    addLog("INFO", QString("Terminal command executed: %1").arg(command.trimmed()));
    return response;
}

void RobotController::addLog(const QString &level, const QString &message)
{
    const QString stamp = QTime::currentTime().toString("HH:mm:ss");
    m_logs.append(QString("[%1] %2: %3").arg(stamp, level.toUpper(), message));

    while (m_logs.size() > 180) {
        m_logs.removeFirst();
    }

    emit logsChanged();
}

void RobotController::updateSimulation()
{
    m_phase += 0.08;

    const bool moving = m_robotState == "MOVING";
    const bool paused = m_robotState == "PAUSED";
    const bool active = m_armed || moving || paused;

    const double randomJitter = (QRandomGenerator::global()->bounded(1000) / 1000.0 - 0.5);
    double targetSpeed = 0.0;
    double targetTemperature = 36.5 + qSin(m_phase * 0.7) * 1.2;
    double targetCurrent = 1.2;
    double targetCpu = 19.0 + qSin(m_phase * 1.3) * 4.0;

    if (m_emergencyActive) {
        targetSpeed = 0.0;
        targetTemperature = 40.0;
        targetCurrent = 0.7;
        targetCpu = 14.0;
    } else if (moving) {
        targetSpeed = 2.25 + qSin(m_phase * 1.8) * 0.42 + randomJitter * 0.12;
        targetTemperature = 58.0 + qSin(m_phase * 1.1) * 4.5;
        targetCurrent = 11.5 + m_speed * 2.2 + qAbs(qSin(m_phase)) * 2.0;
        targetCpu = 48.0 + qSin(m_phase * 1.5) * 9.0;
    } else if (paused) {
        targetSpeed = 0.0;
        targetTemperature = 47.0 + qSin(m_phase) * 2.0;
        targetCurrent = 4.5;
        targetCpu = 30.0 + qSin(m_phase * 0.9) * 5.0;
    } else if (active) {
        targetSpeed = 0.05 + qAbs(qSin(m_phase)) * 0.08;
        targetTemperature = 44.0 + qSin(m_phase * 0.8) * 2.0;
        targetCurrent = 4.0 + qAbs(qSin(m_phase * 1.4)) * 1.5;
        targetCpu = 31.0 + qSin(m_phase * 1.1) * 5.0;
    }

    setSpeed(smooth(m_speed, clamp(targetSpeed, 0.0, 4.0), m_emergencyActive ? 0.45 : 0.13));
    setMotorTemperature(smooth(m_motorTemperature, targetTemperature, 0.08));
    setCpuLoad(smooth(m_cpuLoad, clamp(targetCpu, 0.0, 100.0), 0.1));

    const double targetSignal = clamp(84.0 + qSin(m_phase * 0.45) * 10.0 + randomJitter * 4.0, 0.0, 100.0);
    setSignalStrength(smooth(m_signalStrength, targetSignal, 0.08));

    const double batteryDelta = moving ? -0.024 : (active ? -0.008 : -0.0015);
    setBatteryLevel(m_batteryLevel + batteryDelta);

    if (m_missionRunning && !m_emergencyActive) {
        setMissionElapsedSeconds(m_missionElapsedSeconds + 1);
        setMissionDistance(m_missionDistance + qMax(0.0, m_speed) * 0.0005);
        setMissionProgress(m_missionProgress + (m_missionStatus == "RETORNANDO PARA BASE" ? 0.10 : 0.06));
        setCompletedObjectives(qMin(m_totalObjectives, 1 + static_cast<int>(m_missionProgress / 12.5)));
        if (m_missionProgress >= 100.0) {
            setMissionStatus("COMPLETA");
            setRobotState("IDLE");
            m_missionRunning = false;
            addLog("INFO", "Mission profile completed");
        }
    }

    setMemoryUsage(smooth(m_memoryUsage, clamp(64.0 + qSin(m_phase * 0.37) * 7.0 + (moving ? 5.0 : 0.0), 0.0, 100.0), 0.08));
    setStorageUsage(smooth(m_storageUsage, clamp(54.0 + qSin(m_phase * 0.19) * 2.5, 0.0, 100.0), 0.04));

    double targetRisk = 8.0;
    targetRisk += moving ? 18.0 : 0.0;
    targetRisk += qMax(0.0, m_motorTemperature - 55.0) * 1.6;
    targetRisk += qMax(0.0, 45.0 - m_signalStrength) * 1.2;
    targetRisk += qMax(0.0, 25.0 - m_batteryLevel) * 1.1;
    if (m_emergencyActive) {
        targetRisk = 100.0;
    }
    setMissionRisk(smooth(m_missionRisk, clamp(targetRisk, 0.0, 100.0), m_emergencyActive ? 0.5 : 0.1));

    const double dt = 0.5;
    const double angularVelocity = moving ? qSin(m_phase * 1.2) * 0.34 : 0.0;
    const double yaw = std::fmod(m_telemetry.yaw() + angularVelocity * dt * 18.0 + 360.0, 360.0);
    const double yawRadians = yaw * kPi / 180.0;
    const double nextX = m_telemetry.positionX() + qCos(yawRadians) * m_speed * dt;
    const double nextY = m_telemetry.positionY() + qSin(yawRadians) * m_speed * dt;
    const double nextZ = moving ? 0.45 + qSin(m_phase * 0.9) * 0.06 : smooth(m_telemetry.positionZ(), 0.0, 0.12);
    const double roll = moving ? qSin(m_phase * 2.2) * 3.5 : smooth(m_telemetry.roll(), 0.0, 0.2);
    const double pitch = moving ? qCos(m_phase * 1.6) * 2.6 : smooth(m_telemetry.pitch(), 0.0, 0.2);

    m_telemetry.setPosition(nextX, nextY, nextZ);
    m_telemetry.setOrientation(roll, pitch, yaw);
    m_telemetry.setMotion(m_speed, angularVelocity);
    m_telemetry.setTemperature(m_motorTemperature);

    const double targetVoltage = 19.8 + (m_batteryLevel / 100.0) * 5.2;
    const double targetLatency = clamp(24.0 + (100.0 - m_signalStrength) * 0.55 + qAbs(randomJitter) * 8.0, 18.0, 130.0);
    m_telemetry.setElectrical(smooth(m_telemetry.voltage(), targetVoltage, 0.06),
                              smooth(m_telemetry.current(), targetCurrent, 0.1));
    m_telemetry.setLatency(smooth(m_telemetry.latency(), targetLatency, 0.16));

    if (m_motorTemperature > 68.0 && !m_temperatureWarningLogged) {
        addLog("WARNING", "Motor temperature rising");
        m_temperatureWarningLogged = true;
    } else if (m_motorTemperature < 62.0) {
        m_temperatureWarningLogged = false;
    }

    if (m_signalStrength < 35.0 && !m_signalWarningLogged) {
        addLog("ERROR", "Control link signal is degraded");
        m_signalWarningLogged = true;
    } else if (m_signalStrength > 48.0) {
        m_signalWarningLogged = false;
    }

    if (m_batteryLevel < 20.0 && !m_batteryWarningLogged) {
        addLog("WARNING", "Battery level below 20 percent");
        m_batteryWarningLogged = true;
    }
}

bool RobotController::commandAllowed(const QString &commandName)
{
    if (!m_emergencyActive) {
        return true;
    }

    addLog("ERROR", QString("%1 blocked: emergency stop is active").arg(commandName));
    return false;
}

void RobotController::refreshConnectionState()
{
    if (m_emergencyActive) {
        setConnectionState("OFFLINE");
    } else if (m_simulationMode) {
        setConnectionState("SIM FALLBACK");
    } else if (m_commandInterface.liveBridgeAvailable()) {
        setConnectionState("LIVE READY");
    } else {
        setConnectionState("LIVE STANDBY");
    }
}

bool RobotController::reportCommandInterfaceFailure(const QString &commandName)
{
    if (!m_simulationMode && !m_commandInterface.serialConfigured()) {
        addLog("ERROR",
               QString("%1 blocked: USB serial port missing. Set CHEVEL_ROBOT_SERIAL_PORT.")
                   .arg(commandName));
        appendTerminal(QString("LIVE USB SERIAL MISSING: %1 not sent").arg(commandName));
        refreshConnectionState();
        return false;
    }

    if (!m_simulationMode && !m_commandInterface.liveBridgeAvailable()) {
        addLog("ERROR",
               QString("%1 blocked: configured serial port is not available (%2).")
                   .arg(commandName, m_commandInterface.serialPortName()));
        appendTerminal(QString("LIVE USB SERIAL UNAVAILABLE: %1 not sent").arg(commandName));
        refreshConnectionState();
        return false;
    }

    addLog("ERROR", QString("%1 failed in USB serial command interface; check ESP32 firmware and wiring").arg(commandName));
    refreshConnectionState();
    return false;
}

double RobotController::smooth(double current, double target, double factor) const
{
    return current + (target - current) * factor;
}

void RobotController::setBatteryLevel(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_batteryLevel - value) < 0.001) {
        return;
    }

    m_batteryLevel = value;
    emit batteryLevelChanged();
}

void RobotController::setMotorTemperature(double value)
{
    value = clamp(value, 0.0, 120.0);
    if (qAbs(m_motorTemperature - value) < 0.001) {
        return;
    }

    m_motorTemperature = value;
    emit motorTemperatureChanged();
}

void RobotController::setSpeed(double value)
{
    value = clamp(value, 0.0, 5.0);
    if (qAbs(m_speed - value) < 0.001) {
        return;
    }

    m_speed = value;
    emit speedChanged();
}

void RobotController::setSignalStrength(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_signalStrength - value) < 0.001) {
        return;
    }

    m_signalStrength = value;
    emit signalStrengthChanged();
}

void RobotController::setCpuLoad(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_cpuLoad - value) < 0.001) {
        return;
    }

    m_cpuLoad = value;
    emit cpuLoadChanged();
}

void RobotController::setMissionRisk(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_missionRisk - value) < 0.001) {
        return;
    }

    m_missionRisk = value;
    emit missionRiskChanged();
}

void RobotController::setMissionStatus(const QString &status)
{
    if (m_missionStatus == status) {
        return;
    }

    m_missionStatus = status;
    emit missionStatusChanged();
}

void RobotController::setMissionElapsedSeconds(int seconds)
{
    seconds = qMax(0, seconds);
    if (m_missionElapsedSeconds == seconds) {
        return;
    }

    m_missionElapsedSeconds = seconds;
    emit missionElapsedSecondsChanged();
}

void RobotController::setMissionProgress(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_missionProgress - value) < 0.001) {
        return;
    }

    m_missionProgress = value;
    emit missionProgressChanged();
}

void RobotController::setMissionDistance(double value)
{
    value = qMax(0.0, value);
    if (qAbs(m_missionDistance - value) < 0.001) {
        return;
    }

    m_missionDistance = value;
    emit missionDistanceChanged();
}

void RobotController::setCompletedObjectives(int value)
{
    value = qBound(0, value, m_totalObjectives);
    if (m_completedObjectives == value) {
        return;
    }

    m_completedObjectives = value;
    emit completedObjectivesChanged();
}

void RobotController::setTotalObjectives(int value)
{
    value = qMax(1, value);
    if (m_totalObjectives == value) {
        return;
    }

    m_totalObjectives = value;
    if (m_completedObjectives > m_totalObjectives) {
        m_completedObjectives = m_totalObjectives;
        emit completedObjectivesChanged();
    }
    emit totalObjectivesChanged();
}

void RobotController::setSafeMode(bool enabled)
{
    if (m_safeMode == enabled) {
        return;
    }

    m_safeMode = enabled;
    emit safeModeChanged();
}

void RobotController::setVirtualFencesActive(bool enabled)
{
    if (m_virtualFencesActive == enabled) {
        return;
    }

    m_virtualFencesActive = enabled;
    emit virtualFencesActiveChanged();
}

void RobotController::setVoiceStatus(const QString &status)
{
    if (m_voiceStatus == status) {
        return;
    }

    m_voiceStatus = status;
    emit voiceStatusChanged();
}

void RobotController::setLastVoiceCommand(const QString &command)
{
    if (m_lastVoiceCommand == command) {
        return;
    }

    m_lastVoiceCommand = command;
    emit lastVoiceCommandChanged();
}

void RobotController::setMemoryUsage(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_memoryUsage - value) < 0.001) {
        return;
    }

    m_memoryUsage = value;
    emit memoryUsageChanged();
}

void RobotController::setStorageUsage(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_storageUsage - value) < 0.001) {
        return;
    }

    m_storageUsage = value;
    emit storageUsageChanged();
}

void RobotController::appendTerminal(const QString &line)
{
    m_terminalLines.append(line);
    while (m_terminalLines.size() > 80) {
        m_terminalLines.removeFirst();
    }
    emit terminalTranscriptChanged();
}

void RobotController::setRobotState(const QString &state)
{
    if (m_robotState == state) {
        return;
    }

    m_robotState = state;
    emit robotStateChanged();
}

void RobotController::setConnectionState(const QString &state)
{
    if (m_connectionState == state) {
        return;
    }

    m_connectionState = state;
    emit connectionStateChanged();
}

void RobotController::setEmergencyActive(bool active)
{
    if (m_emergencyActive == active) {
        return;
    }

    m_emergencyActive = active;
    emit emergencyActiveChanged();
}

void RobotController::setArmed(bool armed)
{
    if (m_armed == armed) {
        return;
    }

    m_armed = armed;
    emit armedChanged();
}

void RobotController::appendVoiceDiagnostics(const QString &line)
{
    const QString stamp = QTime::currentTime().toString(QStringLiteral("HH:mm:ss"));
    m_voiceDiagnosticsLines.append(QStringLiteral("[%1] %2").arg(stamp, line));
    while (m_voiceDiagnosticsLines.size() > 80) {
        m_voiceDiagnosticsLines.removeFirst();
    }
    emit voiceDiagnosticsOutputChanged();
}

QString RobotController::toolStatus(bool available) const
{
    return available ? QStringLiteral("READY") : QStringLiteral("MISSING");
}

void RobotController::updateVoiceStatusFromTools()
{
    const bool speechToTextReady = m_transcriptionService.whisperAvailable() && m_transcriptionService.ffmpegAvailable();
    const bool textToSpeechReady = (m_synthesisService.piperAvailable() && m_synthesisService.piperModelAvailable())
        || m_synthesisService.fallbackTtsAvailable();

    if (speechToTextReady && textToSpeechReady) {
        setVoiceStatus("ONLINE");
    } else if (speechToTextReady || m_transcriptionService.whisperAvailable()) {
        setVoiceStatus("PARTIAL");
    } else {
        setVoiceStatus("OFFLINE");
    }

    emit voiceDiagnosticsChanged();
}
