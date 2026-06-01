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
    return configured.isEmpty() ? QStringLiteral("C:/AI/models") : configured;
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
    return configured.isEmpty() ? QStringLiteral("C:/AI/voice-output") : configured;
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

bool VoiceSynthesisService::speak(const QString &text)
{
    if (!piperAvailable() || !piperModelAvailable()) {
        emit processFinished(QStringLiteral("Piper TTS"),
                             false,
                             QString(),
                             QStringLiteral("Piper/TTS nao configurado ainda. Configure CHEVEL_PIPER_EXE e CHEVEL_PIPER_MODEL."),
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
        m_process->kill();
        m_process->deleteLater();
    }

    m_process = new QProcess(this);
    connect(m_process, &QProcess::started, this, [this, text]() {
        m_process->write(text.toUtf8());
        m_process->write("\n");
        m_process->closeWriteChannel();
    });
    connect(m_process, &QProcess::finished, this, [this, outputFile](int exitCode, QProcess::ExitStatus exitStatus) {
        const QString stdoutText = QString::fromUtf8(m_process->readAllStandardOutput());
        const QString stderrText = QString::fromUtf8(m_process->readAllStandardError());
        const bool ok = exitStatus == QProcess::NormalExit && exitCode == 0 && QFileInfo::exists(outputFile);
        emit processFinished(QStringLiteral("Piper TTS"), ok, stdoutText, stderrText, outputFile);
        m_process->deleteLater();
        m_process = nullptr;
    });

    const QString program = piperPath();
    emit processStarted(QStringLiteral("Piper TTS"),
                        quotePath(program) + QStringLiteral(" --model ") + quotePath(piperModelPath())
                            + QStringLiteral(" --output_file ") + quotePath(outputFile));
    m_process->start(program, arguments);
    return true;
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
