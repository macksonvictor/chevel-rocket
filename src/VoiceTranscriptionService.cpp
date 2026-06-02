#include "VoiceTranscriptionService.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QProcessEnvironment>
#include <QRegularExpression>

namespace {
QString windowsExecutableName(const QString &fileName)
{
#ifdef Q_OS_WIN
    return fileName.endsWith(QStringLiteral(".exe"), Qt::CaseInsensitive) ? fileName : fileName + QStringLiteral(".exe");
#else
    return fileName;
#endif
}

QString quotePath(const QString &path)
{
    return QStringLiteral("\"%1\"").arg(QDir::toNativeSeparators(path));
}
}

VoiceTranscriptionService::VoiceTranscriptionService(QObject *parent)
    : QObject(parent)
{
}

QString VoiceTranscriptionService::whisperPath() const
{
    return findExecutable(QStringLiteral("whisper"),
                          QStringLiteral("CHEVEL_WHISPER_EXE"),
                          QStringLiteral("C:/Users/mackson/AppData/Roaming/Python/Python311/Scripts/whisper.exe"));
}

QString VoiceTranscriptionService::ffmpegPath() const
{
    return findExecutable(QStringLiteral("ffmpeg"), QStringLiteral("CHEVEL_FFMPEG_EXE"));
}

QString VoiceTranscriptionService::outputDir() const
{
    const QString configured = QProcessEnvironment::systemEnvironment().value(QStringLiteral("CHEVEL_VOICE_OUTPUT_DIR"));
    if (!configured.isEmpty()) {
        return configured;
    }
#ifdef Q_OS_WIN
    return QStringLiteral("C:/AI/voice-output");
#else
    return QDir::home().absoluteFilePath(QStringLiteral(".local/share/chevel-rocket/voice-output"));
#endif
}

bool VoiceTranscriptionService::whisperAvailable() const
{
    const QString path = whisperPath();
    return !path.isEmpty() && QFileInfo::exists(path);
}

bool VoiceTranscriptionService::ffmpegAvailable() const
{
    const QString path = ffmpegPath();
    return !path.isEmpty() && QFileInfo::exists(path);
}

bool VoiceTranscriptionService::runProbe()
{
    if (!whisperAvailable()) {
        emit processFinished(QStringLiteral("Whisper probe"),
                             false,
                             QString(),
                             QStringLiteral("Whisper executable was not found."),
                             QString(),
                             QString());
        return false;
    }

    startWhisper(QStringLiteral("Whisper probe"), {QStringLiteral("--help")});
    return true;
}

bool VoiceTranscriptionService::recordAndTranscribe(int seconds)
{
    if (!ffmpegAvailable()) {
        emit processFinished(QStringLiteral("Microphone capture"),
                             false,
                             QString(),
                             QStringLiteral("FFmpeg executable was not found."),
                             QString(),
                             QString());
        return false;
    }
    if (!whisperAvailable()) {
        emit processFinished(QStringLiteral("Microphone capture"),
                             false,
                             QString(),
                             QStringLiteral("Whisper executable was not found."),
                             QString(),
                             QString());
        return false;
    }

    QDir().mkpath(outputDir());
    const int clampedSeconds = qBound(2, seconds, 12);
    const QString outputFile = QDir(outputDir()).absoluteFilePath(
        QStringLiteral("chevel-mic-%1.wav").arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd-HHmmss"))));
    const QString backend = audioBackend();
    if (backend == QStringLiteral("auto")) {
#ifdef Q_OS_WIN
        return startMicrophoneCapture(QStringLiteral("dshow"), clampedSeconds, outputFile, false);
#else
        return startMicrophoneCapture(QStringLiteral("pulse"), clampedSeconds, outputFile, true);
#endif
    }

    return startMicrophoneCapture(backend, clampedSeconds, outputFile, false);
}

bool VoiceTranscriptionService::startMicrophoneCapture(const QString &backend,
                                                       int seconds,
                                                       const QString &outputFile,
                                                       bool allowAutoFallback)
{
    const QString audioInput = preferredAudioInputName(backend);
    if (audioInput.isEmpty() || captureArguments(backend, audioInput, seconds, outputFile).isEmpty()) {
        emit processFinished(QStringLiteral("Microphone capture"),
                             false,
                             QString(),
                             QStringLiteral("No audio input was found for backend '%1'. Configure CHEVEL_MIC_DEVICE or CHEVEL_AUDIO_BACKEND.")
                                 .arg(backend),
                             QString(),
                             QString());
        return false;
    }

    const QStringList arguments = captureArguments(backend, audioInput, seconds, outputFile);

    if (m_process && m_process->state() != QProcess::NotRunning) {
        disconnect(m_process, nullptr, this, nullptr);
        m_process->kill();
        m_process->deleteLater();
    }

    m_process = new QProcess(this);
    QProcess *process = m_process;
    connect(process, &QProcess::finished, this, [this, process, backend, seconds, outputFile, allowAutoFallback](int exitCode, QProcess::ExitStatus exitStatus) {
        const QString stdoutText = QString::fromUtf8(process->readAllStandardOutput());
        const QString stderrText = QString::fromUtf8(process->readAllStandardError());
        const bool ok = exitStatus == QProcess::NormalExit && exitCode == 0 && QFileInfo::exists(outputFile);
        emit processFinished(QStringLiteral("Microphone capture"), ok, stdoutText, stderrText, outputFile, QString());
        if (m_process == process) {
            m_process = nullptr;
        }
        process->deleteLater();
        if (ok) {
            transcribeFile(outputFile);
        } else if (allowAutoFallback && backend == QStringLiteral("pulse")) {
            startMicrophoneCapture(QStringLiteral("alsa"), seconds, outputFile, false);
        }
    });

    const QString program = ffmpegPath();
    emit processStarted(QStringLiteral("Microphone capture"),
                        quotePath(program)
                            + QStringLiteral(" backend=")
                            + backend
                            + QStringLiteral(" input=")
                            + quotePath(audioInput)
                            + QStringLiteral(" seconds=")
                            + QString::number(seconds)
                            + QStringLiteral(" ")
                            + quotePath(outputFile));
    process->start(program, arguments);
    return true;
}

bool VoiceTranscriptionService::transcribeFile(const QString &audioPath)
{
    const QFileInfo audioInfo(audioPath);
    if (!whisperAvailable()) {
        emit processFinished(QStringLiteral("Whisper transcription"),
                             false,
                             QString(),
                             QStringLiteral("Whisper executable was not found."),
                             QString(),
                             QString());
        return false;
    }
    if (!audioInfo.exists() || !audioInfo.isFile()) {
        emit processFinished(QStringLiteral("Whisper transcription"),
                             false,
                             QString(),
                             QStringLiteral("Audio file does not exist: ") + audioPath,
                             QString(),
                             QString());
        return false;
    }

    QDir().mkpath(outputDir());
    const QString expected = QDir(outputDir()).absoluteFilePath(audioInfo.completeBaseName() + QStringLiteral(".txt"));
    const QStringList args {
        audioInfo.absoluteFilePath(),
        QStringLiteral("--language"),
        QStringLiteral("Portuguese"),
        QStringLiteral("--model"),
        QStringLiteral("small"),
        QStringLiteral("--output_format"),
        QStringLiteral("txt"),
        QStringLiteral("--output_dir"),
        outputDir()
    };
    startWhisper(QStringLiteral("Whisper transcription"), args, expected);
    return true;
}

QString VoiceTranscriptionService::findExecutable(const QString &fileName,
                                                  const QString &environmentVariable,
                                                  const QString &fallbackPath) const
{
    const QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    const QString configured = env.value(environmentVariable).trimmed();
    if (!configured.isEmpty() && QFileInfo::exists(configured)) {
        return QFileInfo(configured).absoluteFilePath();
    }

    if (!fallbackPath.isEmpty() && QFileInfo::exists(fallbackPath)) {
        return QFileInfo(fallbackPath).absoluteFilePath();
    }

    const QString executable = windowsExecutableName(fileName);
    const QString pathVariable = env.value(QStringLiteral("PATH"));
#ifdef Q_OS_WIN
    const QChar separator = QLatin1Char(';');
#else
    const QChar separator = QLatin1Char(':');
#endif
    const QStringList paths = pathVariable.split(separator, Qt::SkipEmptyParts);
    for (const QString &path : paths) {
        const QString candidate = QDir(path).absoluteFilePath(executable);
        if (QFileInfo::exists(candidate)) {
            return QFileInfo(candidate).absoluteFilePath();
        }
    }

    return QString();
}

QString VoiceTranscriptionService::audioBackend() const
{
    const QString configured = QProcessEnvironment::systemEnvironment()
                                   .value(QStringLiteral("CHEVEL_AUDIO_BACKEND"))
                                   .trimmed()
                                   .toLower();
    if (configured == QStringLiteral("pulse") || configured == QStringLiteral("alsa") || configured == QStringLiteral("dshow")) {
        return configured;
    }
    return QStringLiteral("auto");
}

QString VoiceTranscriptionService::preferredAudioInputName(const QString &backend) const
{
    const QString configured = QProcessEnvironment::systemEnvironment().value(QStringLiteral("CHEVEL_MIC_DEVICE")).trimmed();
    if (!configured.isEmpty()) {
        return configured;
    }
    if (!ffmpegAvailable()) {
        return QString();
    }

    if (backend == QStringLiteral("pulse") || backend == QStringLiteral("alsa")) {
        return QStringLiteral("default");
    }

    if (backend != QStringLiteral("dshow")) {
        return QString();
    }

    QProcess probe;
    probe.start(ffmpegPath(), {
        QStringLiteral("-hide_banner"),
        QStringLiteral("-list_devices"),
        QStringLiteral("true"),
        QStringLiteral("-f"),
        QStringLiteral("dshow"),
        QStringLiteral("-i"),
        QStringLiteral("dummy")
    });
    probe.waitForFinished(3500);
    const QString output = QString::fromUtf8(probe.readAllStandardError()) + QString::fromUtf8(probe.readAllStandardOutput());
    const QRegularExpression audioPattern(QStringLiteral("\"([^\"]+)\"\\s+\\(audio\\)"));
    const QRegularExpressionMatch match = audioPattern.match(output);
    return match.hasMatch() ? match.captured(1).trimmed() : QString();
}

QStringList VoiceTranscriptionService::captureArguments(const QString &backend,
                                                        const QString &inputName,
                                                        int seconds,
                                                        const QString &outputFile) const
{
    if (backend == QStringLiteral("dshow")) {
        return {
            QStringLiteral("-y"),
            QStringLiteral("-hide_banner"),
            QStringLiteral("-loglevel"),
            QStringLiteral("warning"),
            QStringLiteral("-f"),
            QStringLiteral("dshow"),
            QStringLiteral("-t"),
            QString::number(seconds),
            QStringLiteral("-i"),
            QStringLiteral("audio=%1").arg(inputName),
            QStringLiteral("-ac"),
            QStringLiteral("1"),
            QStringLiteral("-ar"),
            QStringLiteral("16000"),
            outputFile
        };
    }

    if (backend == QStringLiteral("pulse") || backend == QStringLiteral("alsa")) {
        return {
            QStringLiteral("-y"),
            QStringLiteral("-hide_banner"),
            QStringLiteral("-loglevel"),
            QStringLiteral("warning"),
            QStringLiteral("-f"),
            backend,
            QStringLiteral("-t"),
            QString::number(seconds),
            QStringLiteral("-i"),
            inputName,
            QStringLiteral("-ac"),
            QStringLiteral("1"),
            QStringLiteral("-ar"),
            QStringLiteral("16000"),
            outputFile
        };
    }

    return {};
}

void VoiceTranscriptionService::startWhisper(const QString &label,
                                             const QStringList &arguments,
                                             const QString &expectedOutputFile)
{
    if (m_process && m_process->state() != QProcess::NotRunning) {
        disconnect(m_process, nullptr, this, nullptr);
        m_process->kill();
        m_process->deleteLater();
    }

    m_process = new QProcess(this);
    QProcess *process = m_process;
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("PYTHONIOENCODING"), QStringLiteral("utf-8"));
    environment.insert(QStringLiteral("PYTHONUTF8"), QStringLiteral("1"));
    process->setProcessEnvironment(environment);

    connect(process, &QProcess::finished, this, [this, process, label, expectedOutputFile](int exitCode, QProcess::ExitStatus exitStatus) {
        const QString stdoutText = QString::fromUtf8(process->readAllStandardOutput());
        const QString stderrText = QString::fromUtf8(process->readAllStandardError());
        QString outputText;
        if (!expectedOutputFile.isEmpty() && QFileInfo::exists(expectedOutputFile)) {
            QFile output(expectedOutputFile);
            if (output.open(QIODevice::ReadOnly | QIODevice::Text)) {
                outputText = QString::fromUtf8(output.readAll()).trimmed();
            }
        }

        const bool helpProbe = label.contains(QStringLiteral("probe"), Qt::CaseInsensitive);
        const bool ok = exitStatus == QProcess::NormalExit && (exitCode == 0 || (helpProbe && stdoutText.contains(QStringLiteral("usage:"), Qt::CaseInsensitive)));
        emit processFinished(label, ok, stdoutText, stderrText, expectedOutputFile, outputText);
        if (m_process == process) {
            m_process = nullptr;
        }
        process->deleteLater();
    });

    const QString program = whisperPath();
    QStringList printableArguments;
    printableArguments.reserve(arguments.size());
    for (const QString &arg : arguments) {
        printableArguments.append(arg.contains(QLatin1Char(' ')) || arg.contains(QLatin1Char('\\')) ? quotePath(arg) : arg);
    }
    emit processStarted(label, quotePath(program) + QLatin1Char(' ') + printableArguments.join(QLatin1Char(' ')));
    process->start(program, arguments);
}
