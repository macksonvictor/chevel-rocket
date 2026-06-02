#include "VoiceSynthesisService.h"

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QProcessEnvironment>

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

VoiceSynthesisService::VoiceSynthesisService(QObject *parent)
    : QObject(parent)
{
}

QString VoiceSynthesisService::piperPath() const
{
    return findExecutable(QStringLiteral("piper"), QStringLiteral("CHEVEL_PIPER_EXE"));
}

QString VoiceSynthesisService::modelsDir() const
{
    const QString configured = QProcessEnvironment::systemEnvironment().value(QStringLiteral("CHEVEL_AI_MODELS_DIR"));
    if (!configured.isEmpty()) {
        return configured;
    }
#ifdef Q_OS_WIN
    return QStringLiteral("C:/AI/models");
#else
    return QDir::home().absoluteFilePath(QStringLiteral(".local/share/chevel-rocket/models"));
#endif
}

QString VoiceSynthesisService::piperModelPath() const
{
    const QString configured = QProcessEnvironment::systemEnvironment().value(QStringLiteral("CHEVEL_PIPER_MODEL")).trimmed();
    if (!configured.isEmpty() && QFileInfo::exists(configured)) {
        return QFileInfo(configured).absoluteFilePath();
    }

    return findFirstModel(modelsDir());
}

QString VoiceSynthesisService::outputDir() const
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

bool VoiceSynthesisService::piperAvailable() const
{
    const QString path = piperPath();
    return !path.isEmpty() && QFileInfo::exists(path);
}

bool VoiceSynthesisService::piperModelAvailable() const
{
    const QString path = piperModelPath();
    return !path.isEmpty() && QFileInfo::exists(path);
}

bool VoiceSynthesisService::fallbackTtsAvailable() const
{
#ifdef Q_OS_WIN
    const QString path = windowsSpeechPath();
    return !path.isEmpty() && QFileInfo::exists(path);
#else
    return false;
#endif
}

QString VoiceSynthesisService::activeEngineName() const
{
    if (piperAvailable() && piperModelAvailable()) {
        return QStringLiteral("PIPER TTS");
    }
    if (fallbackTtsAvailable()) {
        return QStringLiteral("WINDOWS SAPI");
    }
    return QStringLiteral("TTS MISSING");
}

bool VoiceSynthesisService::speak(const QString &text)
{
    if (!piperAvailable() || !piperModelAvailable()) {
        if (fallbackTtsAvailable()) {
            return speakWithWindowsSapi(text);
        }

        emit processFinished(QStringLiteral("TTS"),
                             false,
                             QString(),
                             QStringLiteral("TTS nao configurado ainda. Configure Piper ou use Windows com System.Speech disponivel."),
                             QString());
        return false;
    }

    QDir().mkpath(outputDir());
    const QString outputFile = QDir(outputDir()).absoluteFilePath(
        QStringLiteral("chevel-rocket-%1.wav").arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd-HHmmss"))));
    const QStringList arguments {
        QStringLiteral("--model"),
        piperModelPath(),
        QStringLiteral("--output_file"),
        outputFile
    };

    if (m_process && m_process->state() != QProcess::NotRunning) {
        disconnect(m_process, nullptr, this, nullptr);
        m_process->kill();
        m_process->deleteLater();
    }

    m_process = new QProcess(this);
    QProcess *process = m_process;
    connect(process, &QProcess::started, this, [process, text]() {
        process->write(text.toUtf8());
        process->write("\n");
        process->closeWriteChannel();
    });
    connect(process, &QProcess::finished, this, [this, process, outputFile](int exitCode, QProcess::ExitStatus exitStatus) {
        const QString stdoutText = QString::fromUtf8(process->readAllStandardOutput());
        const QString stderrText = QString::fromUtf8(process->readAllStandardError());
        const bool ok = exitStatus == QProcess::NormalExit && exitCode == 0 && QFileInfo::exists(outputFile);
        emit processFinished(QStringLiteral("Piper TTS"), ok, stdoutText, stderrText, outputFile);
        if (m_process == process) {
            m_process = nullptr;
        }
        process->deleteLater();
    });

    const QString program = piperPath();
    emit processStarted(QStringLiteral("Piper TTS"),
                        quotePath(program) + QStringLiteral(" --model ") + quotePath(piperModelPath())
                            + QStringLiteral(" --output_file ") + quotePath(outputFile));
    process->start(program, arguments);
    return true;
}

QString VoiceSynthesisService::windowsSpeechPath() const
{
#ifdef Q_OS_WIN
    const QString configured = QProcessEnvironment::systemEnvironment().value(QStringLiteral("CHEVEL_WINDOWS_TTS_EXE")).trimmed();
    if (!configured.isEmpty() && QFileInfo::exists(configured)) {
        return QFileInfo(configured).absoluteFilePath();
    }

    const QString fromPath = findExecutable(QStringLiteral("powershell"), QStringLiteral("CHEVEL_WINDOWS_TTS_EXE"));
    if (!fromPath.isEmpty()) {
        return fromPath;
    }

    const QString systemPath = QStringLiteral("C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe");
    return QFileInfo::exists(systemPath) ? QFileInfo(systemPath).absoluteFilePath() : QString();
#else
    return QString();
#endif
}

bool VoiceSynthesisService::speakWithWindowsSapi(const QString &text)
{
#ifdef Q_OS_WIN
    if (m_process && m_process->state() != QProcess::NotRunning) {
        disconnect(m_process, nullptr, this, nullptr);
        m_process->kill();
        m_process->deleteLater();
    }

    QString safeText = text;
    safeText.replace(QStringLiteral("'"), QStringLiteral("''"));
    safeText.replace(QStringLiteral("\r"), QStringLiteral(" "));
    safeText.replace(QStringLiteral("\n"), QStringLiteral(" "));

    const QString command = QStringLiteral(
        "Add-Type -AssemblyName System.Speech; "
        "$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; "
        "$s.Rate = 0; $s.Volume = 100; "
        "$s.Speak('%1');")
        .arg(safeText);
    const QStringList arguments {
        QStringLiteral("-NoLogo"),
        QStringLiteral("-NoProfile"),
        QStringLiteral("-ExecutionPolicy"),
        QStringLiteral("Bypass"),
        QStringLiteral("-Command"),
        command
    };

    m_process = new QProcess(this);
    QProcess *process = m_process;
    connect(process, &QProcess::finished, this, [this, process](int exitCode, QProcess::ExitStatus exitStatus) {
        const QString stdoutText = QString::fromUtf8(process->readAllStandardOutput());
        const QString stderrText = QString::fromUtf8(process->readAllStandardError());
        const bool ok = exitStatus == QProcess::NormalExit && exitCode == 0;
        emit processFinished(QStringLiteral("Windows SAPI TTS"), ok, stdoutText, stderrText, QString());
        if (m_process == process) {
            m_process = nullptr;
        }
        process->deleteLater();
    });

    const QString program = windowsSpeechPath();
    emit processStarted(QStringLiteral("Windows SAPI TTS"),
                        quotePath(program) + QStringLiteral(" -NoProfile -Command \"System.Speech Speak\""));
    process->start(program, arguments);
    return true;
#else
    Q_UNUSED(text)
    return false;
#endif
}

QString VoiceSynthesisService::findExecutable(const QString &fileName, const QString &environmentVariable) const
{
    const QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    const QString configured = env.value(environmentVariable).trimmed();
    if (!configured.isEmpty() && QFileInfo::exists(configured)) {
        return QFileInfo(configured).absoluteFilePath();
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

QString VoiceSynthesisService::findFirstModel(const QString &directory) const
{
    QDir dir(directory);
    if (!dir.exists()) {
        return QString();
    }

    const QFileInfoList models = dir.entryInfoList({QStringLiteral("*.onnx")}, QDir::Files, QDir::Name);
    return models.isEmpty() ? QString() : models.first().absoluteFilePath();
}
