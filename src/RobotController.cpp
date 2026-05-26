#include "RobotController.h"

#include <QDateTime>
#include <QRandomGenerator>
#include <QtMath>
#include <cmath>

namespace {
constexpr double kPi = 3.14159265358979323846;

double clamp(double value, double minValue, double maxValue)
{
    return qBound(minValue, value, maxValue);
}
}

RobotController::RobotController(QObject *parent)
    : QObject(parent)
    , m_commandInterface(this)
    , m_telemetry(this)
    , m_simulationTimer(this)
{
    connect(&m_simulationTimer, &QTimer::timeout, this, &RobotController::updateSimulation);
    m_simulationTimer.setInterval(500);
    m_simulationTimer.start();

    addLog("INFO", "System initialized");
    addLog("INFO", "Simulation telemetry started");
    addLog("WARNING", "DEMO mode active: no hardware commands will be sent");
}

double RobotController::batteryLevel() const
{
    return m_batteryLevel;
}

double RobotController::motorTemperature() const
{
    return m_motorTemperature;
}

double RobotController::speed() const
{
    return m_speed;
}

double RobotController::signalStrength() const
{
    return m_signalStrength;
}

double RobotController::cpuLoad() const
{
    return m_cpuLoad;
}

double RobotController::missionRisk() const
{
    return m_missionRisk;
}

QString RobotController::robotState() const
{
    return m_robotState;
}

QString RobotController::connectionState() const
{
    return m_connectionState;
}

bool RobotController::emergencyActive() const
{
    return m_emergencyActive;
}

bool RobotController::armed() const
{
    return m_armed;
}

QStringList RobotController::logs() const
{
    return m_logs;
}

TelemetryModel *RobotController::telemetry()
{
    return &m_telemetry;
}

bool RobotController::armRobot()
{
    if (!commandAllowed("ARM ROBOT")) {
        return false;
    }
    if (m_armed) {
        addLog("WARNING", "ARM ROBOT ignored: robot is already armed");
        return false;
    }

    if (!m_commandInterface.arm()) {
        addLog("ERROR", "ARM ROBOT failed in command interface");
        return false;
    }

    setArmed(true);
    setRobotState("ARMED");
    addLog("INFO", "Robot armed");
    return true;
}

bool RobotController::disarmRobot()
{
    if (!commandAllowed("DISARM ROBOT")) {
        return false;
    }
    if (!m_armed) {
        addLog("WARNING", "DISARM ROBOT ignored: robot is already disarmed");
        return false;
    }

    if (!m_commandInterface.disarm()) {
        addLog("ERROR", "DISARM ROBOT failed in command interface");
        return false;
    }

    setArmed(false);
    setRobotState("IDLE");
    addLog("INFO", "Robot disarmed");
    return true;
}

bool RobotController::startMission()
{
    if (!commandAllowed("START MISSION")) {
        return false;
    }
    if (!m_armed) {
        addLog("WARNING", "START MISSION blocked: robot must be armed first");
        return false;
    }

    if (!m_commandInterface.startMission()) {
        addLog("ERROR", "START MISSION failed in command interface");
        return false;
    }

    setRobotState("MOVING");
    addLog("INFO", "Mission started");
    return true;
}

bool RobotController::pauseMission()
{
    if (!commandAllowed("PAUSE MISSION")) {
        return false;
    }
    if (m_robotState != "MOVING") {
        addLog("WARNING", "PAUSE MISSION ignored: mission is not moving");
        return false;
    }

    if (!m_commandInterface.pauseMission()) {
        addLog("ERROR", "PAUSE MISSION failed in command interface");
        return false;
    }

    setRobotState("PAUSED");
    addLog("INFO", "Mission paused");
    return true;
}

bool RobotController::returnHome()
{
    if (!commandAllowed("RETURN HOME")) {
        return false;
    }
    if (!m_armed) {
        addLog("WARNING", "RETURN HOME blocked: robot must be armed first");
        return false;
    }

    if (!m_commandInterface.returnHome()) {
        addLog("ERROR", "RETURN HOME failed in command interface");
        return false;
    }

    setRobotState("MOVING");
    addLog("WARNING", "Return home sequence simulated");
    return true;
}

bool RobotController::calibrateSensors()
{
    if (!commandAllowed("CALIBRATE SENSORS")) {
        return false;
    }

    if (!m_commandInterface.calibrateSensors()) {
        addLog("ERROR", "CALIBRATE SENSORS failed in command interface");
        return false;
    }

    addLog("INFO", "Sensor calibration completed in simulation");
    return true;
}

bool RobotController::rebootSystem()
{
    if (!commandAllowed("REBOOT SYSTEM")) {
        return false;
    }

    if (!m_commandInterface.rebootSystem()) {
        addLog("ERROR", "REBOOT SYSTEM failed in command interface");
        return false;
    }

    setArmed(false);
    setRobotState("IDLE");
    setSpeed(0.0);
    setCpuLoad(18.0);
    addLog("WARNING", "Simulated system reboot completed");
    return true;
}

bool RobotController::emergencyStop()
{
    if (m_emergencyActive) {
        addLog("CRITICAL", "Emergency stop is already active");
        return false;
    }

    if (!m_commandInterface.emergencyStop()) {
        addLog("ERROR", "EMERGENCY STOP failed in command interface");
        return false;
    }

    setEmergencyActive(true);
    setArmed(false);
    setRobotState("EMERGENCY");
    setSpeed(0.0);
    setMissionRisk(100.0);
    addLog("CRITICAL", "Emergency stop engaged");
    return true;
}

bool RobotController::clearEmergency()
{
    if (!m_emergencyActive) {
        addLog("WARNING", "CLEAR EMERGENCY ignored: no emergency is active");
        return false;
    }

    if (!m_commandInterface.clearEmergency()) {
        addLog("ERROR", "CLEAR EMERGENCY failed in command interface");
        return false;
    }

    setEmergencyActive(false);
    setRobotState("IDLE");
    setArmed(false);
    setMissionRisk(18.0);
    addLog("WARNING", "Emergency cleared; robot remains disarmed");
    return true;
}

void RobotController::addLog(const QString &level, const QString &message)
{
    const QString stamp = QTime::currentTime().toString("HH:mm:ss");
    m_logs.append(QString("[%1] %2: %3").arg(stamp, level.toUpper(), message));

    while (m_logs.size() > 180) {
        m_logs.removeFirst();
    }

    emit logsChanged();
}

void RobotController::updateSimulation()
{
    m_phase += 0.08;

    const bool moving = m_robotState == "MOVING";
    const bool paused = m_robotState == "PAUSED";
    const bool active = m_armed || moving || paused;

    const double randomJitter = (QRandomGenerator::global()->bounded(1000) / 1000.0 - 0.5);
    double targetSpeed = 0.0;
    double targetTemperature = 36.5 + qSin(m_phase * 0.7) * 1.2;
    double targetCurrent = 1.2;
    double targetCpu = 19.0 + qSin(m_phase * 1.3) * 4.0;

    if (m_emergencyActive) {
        targetSpeed = 0.0;
        targetTemperature = 40.0;
        targetCurrent = 0.7;
        targetCpu = 14.0;
    } else if (moving) {
        targetSpeed = 2.25 + qSin(m_phase * 1.8) * 0.42 + randomJitter * 0.12;
        targetTemperature = 58.0 + qSin(m_phase * 1.1) * 4.5;
        targetCurrent = 11.5 + m_speed * 2.2 + qAbs(qSin(m_phase)) * 2.0;
        targetCpu = 48.0 + qSin(m_phase * 1.5) * 9.0;
    } else if (paused) {
        targetSpeed = 0.0;
        targetTemperature = 47.0 + qSin(m_phase) * 2.0;
        targetCurrent = 4.5;
        targetCpu = 30.0 + qSin(m_phase * 0.9) * 5.0;
    } else if (active) {
        targetSpeed = 0.05 + qAbs(qSin(m_phase)) * 0.08;
        targetTemperature = 44.0 + qSin(m_phase * 0.8) * 2.0;
        targetCurrent = 4.0 + qAbs(qSin(m_phase * 1.4)) * 1.5;
        targetCpu = 31.0 + qSin(m_phase * 1.1) * 5.0;
    }

    setSpeed(smooth(m_speed, clamp(targetSpeed, 0.0, 4.0), m_emergencyActive ? 0.45 : 0.13));
    setMotorTemperature(smooth(m_motorTemperature, targetTemperature, 0.08));
    setCpuLoad(smooth(m_cpuLoad, clamp(targetCpu, 0.0, 100.0), 0.1));

    const double targetSignal = clamp(84.0 + qSin(m_phase * 0.45) * 10.0 + randomJitter * 4.0, 0.0, 100.0);
    setSignalStrength(smooth(m_signalStrength, targetSignal, 0.08));

    const double batteryDelta = moving ? -0.024 : (active ? -0.008 : -0.0015);
    setBatteryLevel(m_batteryLevel + batteryDelta);

    double targetRisk = 8.0;
    targetRisk += moving ? 18.0 : 0.0;
    targetRisk += qMax(0.0, m_motorTemperature - 55.0) * 1.6;
    targetRisk += qMax(0.0, 45.0 - m_signalStrength) * 1.2;
    targetRisk += qMax(0.0, 25.0 - m_batteryLevel) * 1.1;
    if (m_emergencyActive) {
        targetRisk = 100.0;
    }
    setMissionRisk(smooth(m_missionRisk, clamp(targetRisk, 0.0, 100.0), m_emergencyActive ? 0.5 : 0.1));

    const double dt = 0.5;
    const double angularVelocity = moving ? qSin(m_phase * 1.2) * 0.34 : 0.0;
    const double yaw = std::fmod(m_telemetry.yaw() + angularVelocity * dt * 18.0 + 360.0, 360.0);
    const double yawRadians = yaw * kPi / 180.0;
    const double nextX = m_telemetry.positionX() + qCos(yawRadians) * m_speed * dt;
    const double nextY = m_telemetry.positionY() + qSin(yawRadians) * m_speed * dt;
    const double nextZ = moving ? 0.45 + qSin(m_phase * 0.9) * 0.06 : smooth(m_telemetry.positionZ(), 0.0, 0.12);
    const double roll = moving ? qSin(m_phase * 2.2) * 3.5 : smooth(m_telemetry.roll(), 0.0, 0.2);
    const double pitch = moving ? qCos(m_phase * 1.6) * 2.6 : smooth(m_telemetry.pitch(), 0.0, 0.2);

    m_telemetry.setPosition(nextX, nextY, nextZ);
    m_telemetry.setOrientation(roll, pitch, yaw);
    m_telemetry.setMotion(m_speed, angularVelocity);
    m_telemetry.setTemperature(m_motorTemperature);

    const double targetVoltage = 19.8 + (m_batteryLevel / 100.0) * 5.2;
    const double targetLatency = clamp(24.0 + (100.0 - m_signalStrength) * 0.55 + qAbs(randomJitter) * 8.0, 18.0, 130.0);
    m_telemetry.setElectrical(smooth(m_telemetry.voltage(), targetVoltage, 0.06),
                              smooth(m_telemetry.current(), targetCurrent, 0.1));
    m_telemetry.setLatency(smooth(m_telemetry.latency(), targetLatency, 0.16));

    if (m_motorTemperature > 68.0 && !m_temperatureWarningLogged) {
        addLog("WARNING", "Motor temperature rising");
        m_temperatureWarningLogged = true;
    } else if (m_motorTemperature < 62.0) {
        m_temperatureWarningLogged = false;
    }

    if (m_signalStrength < 35.0 && !m_signalWarningLogged) {
        addLog("ERROR", "Control link signal is degraded");
        m_signalWarningLogged = true;
    } else if (m_signalStrength > 48.0) {
        m_signalWarningLogged = false;
    }

    if (m_batteryLevel < 20.0 && !m_batteryWarningLogged) {
        addLog("WARNING", "Battery level below 20 percent");
        m_batteryWarningLogged = true;
    }
}

bool RobotController::commandAllowed(const QString &commandName)
{
    if (!m_emergencyActive) {
        return true;
    }

    addLog("ERROR", QString("%1 blocked: emergency stop is active").arg(commandName));
    return false;
}

double RobotController::smooth(double current, double target, double factor) const
{
    return current + (target - current) * factor;
}

void RobotController::setBatteryLevel(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_batteryLevel - value) < 0.001) {
        return;
    }

    m_batteryLevel = value;
    emit batteryLevelChanged();
}

void RobotController::setMotorTemperature(double value)
{
    value = clamp(value, 0.0, 120.0);
    if (qAbs(m_motorTemperature - value) < 0.001) {
        return;
    }

    m_motorTemperature = value;
    emit motorTemperatureChanged();
}

void RobotController::setSpeed(double value)
{
    value = clamp(value, 0.0, 5.0);
    if (qAbs(m_speed - value) < 0.001) {
        return;
    }

    m_speed = value;
    emit speedChanged();
}

void RobotController::setSignalStrength(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_signalStrength - value) < 0.001) {
        return;
    }

    m_signalStrength = value;
    emit signalStrengthChanged();
}

void RobotController::setCpuLoad(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_cpuLoad - value) < 0.001) {
        return;
    }

    m_cpuLoad = value;
    emit cpuLoadChanged();
}

void RobotController::setMissionRisk(double value)
{
    value = clamp(value, 0.0, 100.0);
    if (qAbs(m_missionRisk - value) < 0.001) {
        return;
    }

    m_missionRisk = value;
    emit missionRiskChanged();
}

void RobotController::setRobotState(const QString &state)
{
    if (m_robotState == state) {
        return;
    }

    m_robotState = state;
    emit robotStateChanged();
}

void RobotController::setConnectionState(const QString &state)
{
    if (m_connectionState == state) {
        return;
    }

    m_connectionState = state;
    emit connectionStateChanged();
}

void RobotController::setEmergencyActive(bool active)
{
    if (m_emergencyActive == active) {
        return;
    }

    m_emergencyActive = active;
    emit emergencyActiveChanged();
}

void RobotController::setArmed(bool armed)
{
    if (m_armed == armed) {
        return;
    }

    m_armed = armed;
    emit armedChanged();
}
