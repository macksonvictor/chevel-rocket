#ifndef ROBOTCONTROLLER_H
#define ROBOTCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QStringList>

#include "RobotCommandInterface.h"
#include "TelemetryModel.h"
#include "VoiceSynthesisService.h"
#include "VoiceTranscriptionService.h"

class RobotController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(double motorTemperature READ motorTemperature NOTIFY motorTemperatureChanged)
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double signalStrength READ signalStrength NOTIFY signalStrengthChanged)
    Q_PROPERTY(double cpuLoad READ cpuLoad NOTIFY cpuLoadChanged)
    Q_PROPERTY(double missionRisk READ missionRisk NOTIFY missionRiskChanged)
    Q_PROPERTY(QString missionStatus READ missionStatus NOTIFY missionStatusChanged)
    Q_PROPERTY(int missionElapsedSeconds READ missionElapsedSeconds NOTIFY missionElapsedSecondsChanged)
    Q_PROPERTY(QString missionElapsedText READ missionElapsedText NOTIFY missionElapsedSecondsChanged)
    Q_PROPERTY(double missionProgress READ missionProgress NOTIFY missionProgressChanged)
    Q_PROPERTY(double missionDistance READ missionDistance NOTIFY missionDistanceChanged)
    Q_PROPERTY(int completedObjectives READ completedObjectives NOTIFY completedObjectivesChanged)
    Q_PROPERTY(int totalObjectives READ totalObjectives NOTIFY totalObjectivesChanged)
    Q_PROPERTY(bool safeMode READ safeMode NOTIFY safeModeChanged)
    Q_PROPERTY(bool simulationMode READ simulationMode NOTIFY simulationModeChanged)
    Q_PROPERTY(bool virtualFencesActive READ virtualFencesActive NOTIFY virtualFencesActiveChanged)
    Q_PROPERTY(QString voiceStatus READ voiceStatus NOTIFY voiceStatusChanged)
    Q_PROPERTY(QString lastVoiceCommand READ lastVoiceCommand NOTIFY lastVoiceCommandChanged)
    Q_PROPERTY(QString aiModelName READ aiModelName CONSTANT)
    Q_PROPERTY(QString sttEngineName READ sttEngineName CONSTANT)
    Q_PROPERTY(QString ttsEngineName READ ttsEngineName CONSTANT)
    Q_PROPERTY(QString voicePipeline READ voicePipeline CONSTANT)
    Q_PROPERTY(QString whisperStatus READ whisperStatus NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString ffmpegStatus READ ffmpegStatus NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString piperStatus READ piperStatus NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString piperModelStatus READ piperModelStatus NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString whisperPath READ whisperPath NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString ffmpegPath READ ffmpegPath NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString piperPath READ piperPath NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString piperModelPath READ piperModelPath NOTIFY voiceDiagnosticsChanged)
    Q_PROPERTY(QString voiceOutputDir READ voiceOutputDir CONSTANT)
    Q_PROPERTY(QString aiModelsDir READ aiModelsDir CONSTANT)
    Q_PROPERTY(QString voiceDiagnosticsOutput READ voiceDiagnosticsOutput NOTIFY voiceDiagnosticsOutputChanged)
    Q_PROPERTY(double memoryUsage READ memoryUsage NOTIFY memoryUsageChanged)
    Q_PROPERTY(double storageUsage READ storageUsage NOTIFY storageUsageChanged)
    Q_PROPERTY(QString terminalTranscript READ terminalTranscript NOTIFY terminalTranscriptChanged)
    Q_PROPERTY(QString robotState READ robotState NOTIFY robotStateChanged)
    Q_PROPERTY(QString connectionState READ connectionState NOTIFY connectionStateChanged)
    Q_PROPERTY(bool liveBridgeAvailable READ liveBridgeAvailable NOTIFY connectionStateChanged)
    Q_PROPERTY(QString liveBridgePath READ liveBridgePath NOTIFY connectionStateChanged)
    Q_PROPERTY(QString serialPortName READ serialPortName NOTIFY connectionStateChanged)
    Q_PROPERTY(int serialBaudRate READ serialBaudRate NOTIFY connectionStateChanged)
    Q_PROPERTY(bool serialConfigured READ serialConfigured NOTIFY connectionStateChanged)
    Q_PROPERTY(QString outboxPath READ outboxPath NOTIFY connectionStateChanged)
    Q_PROPERTY(bool emergencyActive READ emergencyActive NOTIFY emergencyActiveChanged)
    Q_PROPERTY(bool armed READ armed NOTIFY armedChanged)
    Q_PROPERTY(QStringList logs READ logs NOTIFY logsChanged)
    Q_PROPERTY(TelemetryModel *telemetry READ telemetry CONSTANT)

public:
    explicit RobotController(QObject *parent = nullptr);

    double batteryLevel() const;
    double motorTemperature() const;
    double speed() const;
    double signalStrength() const;
    double cpuLoad() const;
    double missionRisk() const;
    QString missionStatus() const;
    int missionElapsedSeconds() const;
    QString missionElapsedText() const;
    double missionProgress() const;
    double missionDistance() const;
    int completedObjectives() const;
    int totalObjectives() const;
    bool safeMode() const;
    bool simulationMode() const;
    bool virtualFencesActive() const;
    QString voiceStatus() const;
    QString lastVoiceCommand() const;
    QString aiModelName() const;
    QString sttEngineName() const;
    QString ttsEngineName() const;
    QString voicePipeline() const;
    QString whisperStatus() const;
    QString ffmpegStatus() const;
    QString piperStatus() const;
    QString piperModelStatus() const;
    QString whisperPath() const;
    QString ffmpegPath() const;
    QString piperPath() const;
    QString piperModelPath() const;
    QString voiceOutputDir() const;
    QString aiModelsDir() const;
    QString voiceDiagnosticsOutput() const;
    double memoryUsage() const;
    double storageUsage() const;
    QString terminalTranscript() const;
    QString robotState() const;
    QString connectionState() const;
    bool liveBridgeAvailable() const;
    QString liveBridgePath() const;
    QString serialPortName() const;
    int serialBaudRate() const;
    bool serialConfigured() const;
    QString outboxPath() const;
    bool emergencyActive() const;
    bool armed() const;
    QStringList logs() const;
    TelemetryModel *telemetry();

    Q_INVOKABLE bool armRobot();
    Q_INVOKABLE bool disarmRobot();
    Q_INVOKABLE bool startMission();
    Q_INVOKABLE bool pauseMission();
    Q_INVOKABLE bool returnHome();
    Q_INVOKABLE bool calibrateSensors();
    Q_INVOKABLE bool rebootSystem();
    Q_INVOKABLE bool emergencyStop();
    Q_INVOKABLE bool clearEmergency();
    Q_INVOKABLE bool confirmAction();
    Q_INVOKABLE bool cancelAction();
    Q_INVOKABLE bool setSimulationMode(bool enabled);
    Q_INVOKABLE bool toggleSafeMode();
    Q_INVOKABLE bool toggleVirtualFences();
    Q_INVOKABLE bool testVoice();
    Q_INVOKABLE bool runVoiceDiagnostics();
    Q_INVOKABLE bool testMicrophone();
    Q_INVOKABLE bool testWhisper();
    Q_INVOKABLE bool testPiper();
    Q_INVOKABLE bool speakText(const QString &text);
    Q_INVOKABLE bool transcribeAudioFile(const QString &audioPath);
    Q_INVOKABLE bool openVoiceOutputFolder();
    Q_INVOKABLE bool simulateVoiceCommand(const QString &command);
    Q_INVOKABLE bool moveRobot(const QString &direction);
    Q_INVOKABLE bool openGripper();
    Q_INVOKABLE bool closeGripper();
    Q_INVOKABLE QString runTerminalCommand(const QString &command);
    Q_INVOKABLE void addLog(const QString &level, const QString &message);

signals:
    void batteryLevelChanged();
    void motorTemperatureChanged();
    void speedChanged();
    void signalStrengthChanged();
    void cpuLoadChanged();
    void missionRiskChanged();
    void missionStatusChanged();
    void missionElapsedSecondsChanged();
    void missionProgressChanged();
    void missionDistanceChanged();
    void completedObjectivesChanged();
    void totalObjectivesChanged();
    void safeModeChanged();
    void simulationModeChanged();
    void virtualFencesActiveChanged();
    void voiceStatusChanged();
    void lastVoiceCommandChanged();
    void voiceDiagnosticsChanged();
    void voiceDiagnosticsOutputChanged();
    void memoryUsageChanged();
    void storageUsageChanged();
    void terminalTranscriptChanged();
    void robotStateChanged();
    void connectionStateChanged();
    void emergencyActiveChanged();
    void armedChanged();
    void logsChanged();

private slots:
    void updateSimulation();

private:
    bool commandAllowed(const QString &commandName);
    double smooth(double current, double target, double factor) const;
    void setBatteryLevel(double value);
    void setMotorTemperature(double value);
    void setSpeed(double value);
    void setSignalStrength(double value);
    void setCpuLoad(double value);
    void setMissionRisk(double value);
    void setMissionStatus(const QString &status);
    void setMissionElapsedSeconds(int seconds);
    void setMissionProgress(double value);
    void setMissionDistance(double value);
    void setCompletedObjectives(int value);
    void setTotalObjectives(int value);
    void setSafeMode(bool enabled);
    void setVirtualFencesActive(bool enabled);
    void setVoiceStatus(const QString &status);
    void setLastVoiceCommand(const QString &command);
    void setMemoryUsage(double value);
    void setStorageUsage(double value);
    void appendTerminal(const QString &line);
    void setRobotState(const QString &state);
    void setConnectionState(const QString &state);
    void setEmergencyActive(bool active);
    void setArmed(bool armed);
    void appendVoiceDiagnostics(const QString &line);
    QString toolStatus(bool available) const;
    void updateVoiceStatusFromTools();
    void refreshConnectionState();
    bool reportCommandInterfaceFailure(const QString &commandName);

    RobotCommandInterface m_commandInterface;
    TelemetryModel m_telemetry;
    VoiceTranscriptionService m_transcriptionService;
    VoiceSynthesisService m_synthesisService;
    QTimer m_simulationTimer;
    QStringList m_logs;

    double m_batteryLevel = 96.0;
    double m_motorTemperature = 38.0;
    double m_speed = 0.0;
    double m_signalStrength = 87.0;
    double m_cpuLoad = 21.0;
    double m_missionRisk = 8.0;
    QString m_missionStatus = "READY";
    int m_missionElapsedSeconds = 28 * 60 + 15;
    double m_missionProgress = 62.0;
    double m_missionDistance = 1.42;
    int m_completedObjectives = 5;
    int m_totalObjectives = 8;
    bool m_missionRunning = false;
    bool m_safeMode = true;
    bool m_virtualFencesActive = true;
    QString m_voiceStatus = "ONLINE";
    QString m_lastVoiceCommand = "start mission";
    QStringList m_voiceDiagnosticsLines;
    double m_memoryUsage = 68.0;
    double m_storageUsage = 54.0;
    QStringList m_terminalLines;
    QString m_robotState = "IDLE";
    QString m_connectionState = "LIVE STANDBY";
    bool m_emergencyActive = false;
    bool m_armed = false;
    bool m_simulationMode = false;
    double m_phase = 0.0;
    bool m_temperatureWarningLogged = false;
    bool m_signalWarningLogged = false;
    bool m_batteryWarningLogged = false;
};

#endif
