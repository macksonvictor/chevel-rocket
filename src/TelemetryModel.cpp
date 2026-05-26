#include "TelemetryModel.h"

#include <QtGlobal>

TelemetryModel::TelemetryModel(QObject *parent)
    : QObject(parent)
{
}

double TelemetryModel::positionX() const
{
    return m_positionX;
}

double TelemetryModel::positionY() const
{
    return m_positionY;
}

double TelemetryModel::positionZ() const
{
    return m_positionZ;
}

double TelemetryModel::roll() const
{
    return m_roll;
}

double TelemetryModel::pitch() const
{
    return m_pitch;
}

double TelemetryModel::yaw() const
{
    return m_yaw;
}

double TelemetryModel::linearVelocity() const
{
    return m_linearVelocity;
}

double TelemetryModel::angularVelocity() const
{
    return m_angularVelocity;
}

double TelemetryModel::temperature() const
{
    return m_temperature;
}

double TelemetryModel::voltage() const
{
    return m_voltage;
}

double TelemetryModel::current() const
{
    return m_current;
}

double TelemetryModel::latency() const
{
    return m_latency;
}

void TelemetryModel::setPosition(double x, double y, double z)
{
    if (updateValue(m_positionX, x)) {
        emit positionXChanged();
    }
    if (updateValue(m_positionY, y)) {
        emit positionYChanged();
    }
    if (updateValue(m_positionZ, z)) {
        emit positionZChanged();
    }
}

void TelemetryModel::setOrientation(double roll, double pitch, double yaw)
{
    if (updateValue(m_roll, roll)) {
        emit rollChanged();
    }
    if (updateValue(m_pitch, pitch)) {
        emit pitchChanged();
    }
    if (updateValue(m_yaw, yaw)) {
        emit yawChanged();
    }
}

void TelemetryModel::setMotion(double linearVelocity, double angularVelocity)
{
    if (updateValue(m_linearVelocity, linearVelocity)) {
        emit linearVelocityChanged();
    }
    if (updateValue(m_angularVelocity, angularVelocity)) {
        emit angularVelocityChanged();
    }
}

void TelemetryModel::setTemperature(double temperature)
{
    if (updateValue(m_temperature, temperature)) {
        emit temperatureChanged();
    }
}

void TelemetryModel::setElectrical(double voltage, double current)
{
    if (updateValue(m_voltage, voltage)) {
        emit voltageChanged();
    }
    if (updateValue(m_current, current)) {
        emit currentChanged();
    }
}

void TelemetryModel::setLatency(double latency)
{
    if (updateValue(m_latency, latency)) {
        emit latencyChanged();
    }
}

bool TelemetryModel::updateValue(double &field, double value)
{
    if (qAbs(field - value) < 0.001) {
        return false;
    }

    field = value;
    return true;
}
