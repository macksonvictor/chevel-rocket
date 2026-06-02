#ifndef VOICESYNTHESISSERVICE_H
#define VOICESYNTHESISSERVICE_H

#include <QObject>
#include <QString>

class QProcess;

class VoiceSynthesisService : public QObject
{
    Q_OBJECT

public:
    explicit VoiceSynthesisService(QObject *parent = nullptr);

    QString piperPath() const;
    QString piperModelPath() const;
    QString modelsDir() const;
    QString outputDir() const;
    bool piperAvailable() const;
    bool piperModelAvailable() const;
    bool fallbackTtsAvailable() const;
    QString activeEngineName() const;

    bool speak(const QString &text);

signals:
    void processStarted(const QString &label, const QString &commandLine);
    void processFinished(const QString &label, bool ok, const QString &stdoutText, const QString &stderrText, const QString &outputFile);

private:
    QString findExecutable(const QString &fileName, const QString &environmentVariable) const;
    QString findFirstModel(const QString &directory) const;
    QString windowsSpeechPath() const;
    bool speakWithWindowsSapi(const QString &text);

    QProcess *m_process = nullptr;
};

#endif
