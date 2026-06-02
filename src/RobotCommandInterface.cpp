#include "RobotCommandInterface.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QTextStream>

RobotCommandInterface::RobotCommandInterface(QObject *parent)
    : QObject(parent)
{
}

bool RobotCommandInterface::simulationMode() const
{
    return m_simulationMode;
}

void RobotCommandInterface::setSimulationMode(bool enabled)
{
    if (m_simulationMode == enabled) {
        return;
    }

    m_simulationMode = enabled;
    emit simulationModeChanged();
}

bool RobotCommandInterface::liveBridgeAvailable() const
{
    const QString path = liveBridgePath();
    if (path.isEmpty()) {
        return false;
    }

    QFileInfo info(path);
    QDir dir = info.dir();
    return dir.exists() || QDir().mkpath(dir.absolutePath());
}

QString RobotCommandInterface::liveBridgePath() const
{
    const QString configured = QProcessEnvironment::systemEnvironment()
                                   .value(QStringLiteral("CHEVEL_ROBOT_COMMAND_OUTBOX"))
                                   .trimmed();
    return configured.isEmpty() ? QString() : QFileInfo(configured).absoluteFilePath();
}

bool RobotCommandInterface::arm()
{
    return dispatchCommand(QStringLiteral("ARM_ROBOT"));
}

bool RobotCommandInterface::disarm()
{
    return dispatchCommand(QStringLiteral("DISARM_ROBOT"));
}

bool RobotCommandInterface::startMission()
{
    return dispatchCommand(QStringLiteral("START_MISSION"));
}

bool RobotCommandInterface::pauseMission()
{
    return dispatchCommand(QStringLiteral("PAUSE_MISSION"));
}

bool RobotCommandInterface::returnHome()
{
    return dispatchCommand(QStringLiteral("RETURN_HOME"));
}

bool RobotCommandInterface::calibrateSensors()
{
    return dispatchCommand(QStringLiteral("CALIBRATE_SENSORS"));
}

bool RobotCommandInterface::rebootSystem()
{
    return dispatchCommand(QStringLiteral("REBOOT_SYSTEM"));
}

bool RobotCommandInterface::emergencyStop()
{
    return dispatchCommand(QStringLiteral("EMERGENCY_STOP"));
}

bool RobotCommandInterface::clearEmergency()
{
    return dispatchCommand(QStringLiteral("CLEAR_EMERGENCY"));
}

bool RobotCommandInterface::dispatchCommand(const QString &action)
{
    if (m_simulationMode) {
        return true;
    }

    return appendBridgeCommand(action);
}

bool RobotCommandInterface::appendBridgeCommand(const QString &action) const
{
    if (!liveBridgeAvailable()) {
        return false;
    }

    QFile outbox(liveBridgePath());
    if (!outbox.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        return false;
    }

    QTextStream stream(&outbox);
    stream << "{\"timestamp\":\""
           << QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs)
           << "\",\"source\":\"chevel-rocket\",\"mode\":\"live\",\"action\":\""
           << action
           << "\"}\n";
    return true;
}
