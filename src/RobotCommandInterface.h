#ifndef ROBOTCOMMANDINTERFACE_H
#define ROBOTCOMMANDINTERFACE_H

#include <QObject>

class RobotCommandInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool simulationMode READ simulationMode WRITE setSimulationMode NOTIFY simulationModeChanged)

public:
    explicit RobotCommandInterface(QObject *parent = nullptr);

    bool simulationMode() const;
    void setSimulationMode(bool enabled);

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

private:
    bool simulatedCommand();

    bool m_simulationMode = true;
};

#endif
