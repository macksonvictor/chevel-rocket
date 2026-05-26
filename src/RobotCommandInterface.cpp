#include "RobotCommandInterface.h"

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

bool RobotCommandInterface::arm()
{
    return simulatedCommand();
}

bool RobotCommandInterface::disarm()
{
    return simulatedCommand();
}

bool RobotCommandInterface::startMission()
{
    return simulatedCommand();
}

bool RobotCommandInterface::pauseMission()
{
    return simulatedCommand();
}

bool RobotCommandInterface::returnHome()
{
    return simulatedCommand();
}

bool RobotCommandInterface::calibrateSensors()
{
    return simulatedCommand();
}

bool RobotCommandInterface::rebootSystem()
{
    return simulatedCommand();
}

bool RobotCommandInterface::emergencyStop()
{
    return simulatedCommand();
}

bool RobotCommandInterface::clearEmergency()
{
    return simulatedCommand();
}

bool RobotCommandInterface::simulatedCommand()
{
    return m_simulationMode;
}
