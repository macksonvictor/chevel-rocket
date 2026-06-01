#ifndef VOICETRANSCRIPTIONSERVICE_H
#define VOICETRANSCRIPTIONSERVICE_H

#include <QObject>
#include <QString>

class QProcess;

class VoiceTranscriptionService : public QObject
{
    Q_OBJECT

public:
    explicit VoiceTranscriptionService(QObject *parent = nullptr);

    QString whisperPath() const;
    QString ffmpegPath() const;
    QString outputDir() const;
    bool whisperAvailable() const;
    bool ffmpegAvailable() const;

    bool runProbe();
    bool transcribeFile(const QString &audioPath);

signals:
    void processStarted(const QString &label, const QString &commandLine);
    void processFinished(const QString &label,
                         bool ok,
                         const QString &stdoutText,
                         const QString &stderrText,
                         const QString &outputFile,
                         const QString &transcriptionText);

private:
    QString findExecutable(const QString &fileName, const QString &environmentVariable, const QString &fallbackPath = QString()) const;
    void startWhisper(const QString &label, const QStringList &arguments, const QString &expectedOutputFile = QString());

    QProcess *m_process = nullptr;
};

#endif
