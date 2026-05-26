#ifndef ROBOTCONTROLLER_H
#define ROBOTCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QStringList>

#include "RobotCommandInterface.h"
#include "TelemetryModel.h"

class RobotController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(double motorTemperature READ motorTemperature NOTIFY motorTemperatureChanged)
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double signalStrength READ signalStrength NOTIFY signalStrengthChanged)
    Q_PROPERTY(double cpuLoad READ cpuLoad NOTIFY cpuLoadChanged)
    Q_PROPERTY(double missionRisk READ missionRisk NOTIFY missionRiskChanged)
    Q_PROPERTY(QString robotState READ robotState NOTIFY robotStateChanged)
    Q_PROPERTY(QString connectionState READ connectionState NOTIFY connectionStateChanged)
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
    QString robotState() const;
    QString connectionState() const;
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
    Q_INVOKABLE void addLog(const QString &level, const QString &message);

signals:
    void batteryLevelChanged();
    void motorTemperatureChanged();
    void speedChanged();
    void signalStrengthChanged();
    void cpuLoadChanged();
    void missionRiskChanged();
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
    void setRobotState(const QString &state);
    void setConnectionState(const QString &state);
    void setEmergencyActive(bool active);
    void setArmed(bool armed);

    RobotCommandInterface m_commandInterface;
    TelemetryModel m_telemetry;
    QTimer m_simulationTimer;
    QStringList m_logs;

    double m_batteryLevel = 96.0;
    double m_motorTemperature = 38.0;
    double m_speed = 0.0;
    double m_signalStrength = 87.0;
    double m_cpuLoad = 21.0;
    double m_missionRisk = 8.0;
    QString m_robotState = "IDLE";
    QString m_connectionState = "SIMULATED";
    bool m_emergencyActive = false;
    bool m_armed = false;
    double m_phase = 0.0;
    bool m_temperatureWarningLogged = false;
    bool m_signalWarningLogged = false;
    bool m_batteryWarningLogged = false;
};

#endif
