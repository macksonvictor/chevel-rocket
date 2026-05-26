#ifndef TELEMETRYMODEL_H
#define TELEMETRYMODEL_H

#include <QObject>

class TelemetryModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double positionX READ positionX NOTIFY positionXChanged)
    Q_PROPERTY(double positionY READ positionY NOTIFY positionYChanged)
    Q_PROPERTY(double positionZ READ positionZ NOTIFY positionZChanged)
    Q_PROPERTY(double roll READ roll NOTIFY rollChanged)
    Q_PROPERTY(double pitch READ pitch NOTIFY pitchChanged)
    Q_PROPERTY(double yaw READ yaw NOTIFY yawChanged)
    Q_PROPERTY(double linearVelocity READ linearVelocity NOTIFY linearVelocityChanged)
    Q_PROPERTY(double angularVelocity READ angularVelocity NOTIFY angularVelocityChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(double voltage READ voltage NOTIFY voltageChanged)
    Q_PROPERTY(double current READ current NOTIFY currentChanged)
    Q_PROPERTY(double latency READ latency NOTIFY latencyChanged)

public:
    explicit TelemetryModel(QObject *parent = nullptr);

    double positionX() const;
    double positionY() const;
    double positionZ() const;
    double roll() const;
    double pitch() const;
    double yaw() const;
    double linearVelocity() const;
    double angularVelocity() const;
    double temperature() const;
    double voltage() const;
    double current() const;
    double latency() const;

    void setPosition(double x, double y, double z);
    void setOrientation(double roll, double pitch, double yaw);
    void setMotion(double linearVelocity, double angularVelocity);
    void setTemperature(double temperature);
    void setElectrical(double voltage, double current);
    void setLatency(double latency);

signals:
    void positionXChanged();
    void positionYChanged();
    void positionZChanged();
    void rollChanged();
    void pitchChanged();
    void yawChanged();
    void linearVelocityChanged();
    void angularVelocityChanged();
    void temperatureChanged();
    void voltageChanged();
    void currentChanged();
    void latencyChanged();

private:
    bool updateValue(double &field, double value);

    double m_positionX = 0.0;
    double m_positionY = 0.0;
    double m_positionZ = 0.0;
    double m_roll = 0.0;
    double m_pitch = 0.0;
    double m_yaw = 0.0;
    double m_linearVelocity = 0.0;
    double m_angularVelocity = 0.0;
    double m_temperature = 36.0;
    double m_voltage = 24.2;
    double m_current = 1.2;
    double m_latency = 28.0;
};

#endif
