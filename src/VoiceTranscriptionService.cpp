#include "VoiceTranscriptionService.h"

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
    return configured.isEmpty() ? QStringLiteral("C:/AI/voice-output") : configured;
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

void VoiceTranscriptionService::startWhisper(const QString &label,
                                             const QStringList &arguments,
                                             const QString &expectedOutputFile)
{
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_process->kill();
        m_process->deleteLater();
    }

    m_process = new QProcess(this);
    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("PYTHONIOENCODING"), QStringLiteral("utf-8"));
    environment.insert(QStringLiteral("PYTHONUTF8"), QStringLiteral("1"));
    m_process->setProcessEnvironment(environment);

    connect(m_process, &QProcess::finished, this, [this, label, expectedOutputFile](int exitCode, QProcess::ExitStatus exitStatus) {
        const QString stdoutText = QString::fromUtf8(m_process->readAllStandardOutput());
        const QString stderrText = QString::fromUtf8(m_process->readAllStandardError());
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
        m_process->deleteLater();
        m_process = nullptr;
    });

    const QString program = whisperPath();
    QStringList printableArguments;
    printableArguments.reserve(arguments.size());
    for (const QString &arg : arguments) {
        printableArguments.append(arg.contains(QLatin1Char(' ')) || arg.contains(QLatin1Char('\\')) ? quotePath(arg) : arg);
    }
    emit processStarted(label, quotePath(program) + QLatin1Char(' ') + printableArguments.join(QLatin1Char(' ')));
    m_process->start(program, arguments);
}
