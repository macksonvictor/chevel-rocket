#ifndef ROBOTCOMMANDINTERFACE_H
#define ROBOTCOMMANDINTERFACE_H

#include <QObject>
#include <QString>
#include <QStringList>

class RobotCommandInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool simulationMode READ simulationMode WRITE setSimulationMode NOTIFY simulationModeChanged)
    Q_PROPERTY(bool liveBridgeAvailable READ liveBridgeAvailable NOTIFY liveBridgeChanged)
    Q_PROPERTY(QString liveBridgePath READ liveBridgePath NOTIFY liveBridgeChanged)
    Q_PROPERTY(QString serialPortName READ serialPortName NOTIFY liveBridgeChanged)
    Q_PROPERTY(int serialBaudRate READ serialBaudRate NOTIFY liveBridgeChanged)
    Q_PROPERTY(bool serialConfigured READ serialConfigured NOTIFY liveBridgeChanged)
    Q_PROPERTY(QString outboxPath READ outboxPath NOTIFY liveBridgeChanged)

public:
    explicit RobotCommandInterface(QObject *parent = nullptr);

    bool simulationMode() const;
    void setSimulationMode(bool enabled);
    bool liveBridgeAvailable() const;
    QString liveBridgePath() const;
    QString serialPortName() const;
    int serialBaudRate() const;
    bool serialConfigured() const;
    QString outboxPath() const;

    bool arm();
    bool disarm();
    bool startMission();
    bool pauseMission();
    bool returnHome();
    bool calibrateSensors();
    bool rebootSystem();
    bool emergencyStop();
    bool clearEmergency();

signals:
    void simulationModeChanged();
    void liveBridgeChanged();

private:
    bool dispatchCommand(const QString &action);
    QStringList serialCommandsForAction(const QString &action) const;
    bool sendSerialCommands(const QStringList &commands) const;
    bool serialResponseAccepted(const QString &command, const QString &response) const;
    bool appendBridgeCommand(const QString &action) const;

    bool m_simulationMode = false;
};

#endif
