#include "RobotCommandInterface.h"

#include <QDateTime>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QScopeGuard>
#include <QTextStream>
#include <QThread>

#ifdef Q_OS_WIN
#  include <windows.h>
#else
#  include <cerrno>
#  include <fcntl.h>
#  include <sys/select.h>
#  include <termios.h>
#  include <unistd.h>
#endif

namespace {
constexpr int kDefaultBaudRate = 115200;
constexpr int kReadTimeoutMs = 900;

QString normalizedSerialName(const QString &name)
{
    return name.trimmed();
}

#ifdef Q_OS_WIN
QString windowsDeviceName(const QString &portName)
{
    const QString port = portName.trimmed();
    if (port.startsWith(QStringLiteral("\\\\.\\"))) {
        return port;
    }
    if (port.startsWith(QStringLiteral("COM"), Qt::CaseInsensitive)) {
        return QStringLiteral("\\\\.\\") + port;
    }
    return port;
}

bool configureWindowsSerial(HANDLE handle, int baudRate)
{
    DCB dcb = {};
    dcb.DCBlength = sizeof(DCB);
    if (!GetCommState(handle, &dcb)) {
        return false;
    }

    dcb.BaudRate = static_cast<DWORD>(baudRate);
    dcb.ByteSize = 8;
    dcb.Parity = NOPARITY;
    dcb.StopBits = ONESTOPBIT;
    dcb.fBinary = TRUE;
    dcb.fDtrControl = DTR_CONTROL_ENABLE;
    dcb.fRtsControl = RTS_CONTROL_ENABLE;
    dcb.fOutxCtsFlow = FALSE;
    dcb.fOutxDsrFlow = FALSE;
    dcb.fOutX = FALSE;
    dcb.fInX = FALSE;

    if (!SetCommState(handle, &dcb)) {
        return false;
    }

    COMMTIMEOUTS timeouts = {};
    timeouts.ReadIntervalTimeout = 35;
    timeouts.ReadTotalTimeoutConstant = 80;
    timeouts.ReadTotalTimeoutMultiplier = 2;
    timeouts.WriteTotalTimeoutConstant = 250;
    timeouts.WriteTotalTimeoutMultiplier = 2;
    return SetCommTimeouts(handle, &timeouts);
}

bool writeWindowsLine(HANDLE handle, const QByteArray &payload)
{
    DWORD bytesWritten = 0;
    if (!WriteFile(handle, payload.constData(), static_cast<DWORD>(payload.size()), &bytesWritten, nullptr)) {
        return false;
    }
    return bytesWritten == static_cast<DWORD>(payload.size());
}

QString readWindowsResponse(HANDLE handle)
{
    QByteArray response;
    QElapsedTimer timer;
    timer.start();

    while (timer.elapsed() < kReadTimeoutMs) {
        char buffer[128] = {};
        DWORD bytesRead = 0;
        if (!ReadFile(handle, buffer, sizeof(buffer), &bytesRead, nullptr)) {
            return QString();
        }
        if (bytesRead > 0) {
            response.append(buffer, static_cast<int>(bytesRead));
            if (response.contains('\n')) {
                break;
            }
        } else {
            QThread::msleep(20);
        }
    }

    return QString::fromUtf8(response).trimmed();
}
#else
speed_t baudToSpeed(int baudRate)
{
    switch (baudRate) {
    case 9600: return B9600;
    case 19200: return B19200;
    case 38400: return B38400;
    case 57600: return B57600;
    case 115200: return B115200;
#ifdef B230400
    case 230400: return B230400;
#endif
    default: return B115200;
    }
}

bool configurePosixSerial(int fd, int baudRate)
{
    termios tty = {};
    if (tcgetattr(fd, &tty) != 0) {
        return false;
    }

    cfmakeraw(&tty);
    const speed_t speed = baudToSpeed(baudRate);
    cfsetispeed(&tty, speed);
    cfsetospeed(&tty, speed);

    tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;
    tty.c_cflag |= CLOCAL | CREAD;
    tty.c_cflag &= ~(PARENB | PARODD);
    tty.c_cflag &= ~CSTOPB;
    tty.c_cflag &= ~CRTSCTS;
    tty.c_cc[VMIN] = 0;
    tty.c_cc[VTIME] = 1;

    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        return false;
    }

    tcflush(fd, TCIOFLUSH);
    return true;
}

bool writePosixLine(int fd, const QByteArray &payload)
{
    const char *data = payload.constData();
    ssize_t remaining = payload.size();
    while (remaining > 0) {
        const ssize_t written = ::write(fd, data, static_cast<size_t>(remaining));
        if (written < 0) {
            return false;
        }
        remaining -= written;
        data += written;
    }
    return tcdrain(fd) == 0;
}

QString readPosixResponse(int fd)
{
    QByteArray response;
    QElapsedTimer timer;
    timer.start();

    while (timer.elapsed() < kReadTimeoutMs) {
        fd_set readSet;
        FD_ZERO(&readSet);
        FD_SET(fd, &readSet);

        timeval timeout = {};
        timeout.tv_sec = 0;
        timeout.tv_usec = 80000;

        const int ready = select(fd + 1, &readSet, nullptr, nullptr, &timeout);
        if (ready < 0) {
            return QString();
        }
        if (ready == 0) {
            continue;
        }

        char buffer[128] = {};
        const ssize_t bytesRead = ::read(fd, buffer, sizeof(buffer));
        if (bytesRead < 0) {
            return QString();
        }
        if (bytesRead > 0) {
            response.append(buffer, static_cast<int>(bytesRead));
            if (response.contains('\n')) {
                break;
            }
        }
    }

    return QString::fromUtf8(response).trimmed();
}
#endif
}

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
    emit liveBridgeChanged();
}

bool RobotCommandInterface::liveBridgeAvailable() const
{
    const QString configuredPort = serialPortName();
    if (configuredPort.isEmpty()) {
        return false;
    }

#ifdef Q_OS_WIN
    return true;
#else
    return QFileInfo(configuredPort).exists();
#endif
}

QString RobotCommandInterface::liveBridgePath() const
{
    if (serialPortName().isEmpty()) {
        return QStringLiteral("CHEVEL_ROBOT_SERIAL_PORT nao configurado");
    }

    return QStringLiteral("USB Serial %1 @ %2").arg(serialPortName()).arg(serialBaudRate());
}

QString RobotCommandInterface::serialPortName() const
{
    return QProcessEnvironment::systemEnvironment()
        .value(QStringLiteral("CHEVEL_ROBOT_SERIAL_PORT"))
        .trimmed();
}

int RobotCommandInterface::serialBaudRate() const
{
    bool ok = false;
    const int configuredBaud = QProcessEnvironment::systemEnvironment()
                                  .value(QStringLiteral("CHEVEL_ROBOT_SERIAL_BAUD"))
                                  .trimmed()
                                  .toInt(&ok);
    if (!ok || configuredBaud <= 0) {
        return kDefaultBaudRate;
    }
    return configuredBaud;
}

bool RobotCommandInterface::serialConfigured() const
{
    return !serialPortName().isEmpty();
}

QString RobotCommandInterface::outboxPath() const
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

    const QStringList commands = serialCommandsForAction(action);
    if (commands.isEmpty()) {
        appendBridgeCommand(action);
        return true;
    }

    if (!serialConfigured()) {
        appendBridgeCommand(action);
        return false;
    }

    if (!liveBridgeAvailable()) {
        appendBridgeCommand(action);
        return false;
    }

    const bool serialOk = sendSerialCommands(commands);
    if (!serialOk) {
        appendBridgeCommand(action);
    }
    return serialOk;
}

QStringList RobotCommandInterface::serialCommandsForAction(const QString &action) const
{
    if (action == QLatin1String("ARM_ROBOT")) {
        return {QStringLiteral("PING"), QStringLiteral("STATUS")};
    }
    if (action == QLatin1String("DISARM_ROBOT")) {
        return {QStringLiteral("STOP")};
    }
    if (action == QLatin1String("START_MISSION")) {
        return {
            QStringLiteral("PING"),
            QStringLiteral("STATUS"),
            QStringLiteral("HOME"),
            QStringLiteral("SET BASE 60"),
            QStringLiteral("SET SHOULDER 75"),
            QStringLiteral("SET ELBOW 115"),
            QStringLiteral("SET GRIPPER 95"),
            QStringLiteral("SET BASE 120"),
            QStringLiteral("SET GRIPPER 60"),
            QStringLiteral("HOME"),
            QStringLiteral("STATUS")
        };
    }
    if (action == QLatin1String("PAUSE_MISSION")) {
        return {QStringLiteral("STOP")};
    }
    if (action == QLatin1String("RETURN_HOME")) {
        return {QStringLiteral("HOME"), QStringLiteral("STATUS")};
    }
    if (action == QLatin1String("CALIBRATE_SENSORS")) {
        return {QStringLiteral("HOME"), QStringLiteral("STATUS")};
    }
    if (action == QLatin1String("REBOOT_SYSTEM")) {
        return {};
    }
    if (action == QLatin1String("EMERGENCY_STOP")) {
        return {QStringLiteral("STOP")};
    }
    if (action == QLatin1String("CLEAR_EMERGENCY")) {
        return {QStringLiteral("STATUS")};
    }
    return {action};
}

bool RobotCommandInterface::sendSerialCommands(const QStringList &commands) const
{
    if (commands.isEmpty()) {
        return true;
    }

#ifdef Q_OS_WIN
    const QString deviceName = windowsDeviceName(serialPortName());
    HANDLE handle = CreateFileW(reinterpret_cast<LPCWSTR>(deviceName.utf16()),
                                GENERIC_READ | GENERIC_WRITE,
                                0,
                                nullptr,
                                OPEN_EXISTING,
                                FILE_ATTRIBUTE_NORMAL,
                                nullptr);
    if (handle == INVALID_HANDLE_VALUE) {
        return false;
    }

    const auto closeHandle = qScopeGuard([handle]() { CloseHandle(handle); });
    Q_UNUSED(closeHandle);

    if (!configureWindowsSerial(handle, serialBaudRate())) {
        return false;
    }
    PurgeComm(handle, PURGE_RXCLEAR | PURGE_TXCLEAR);

    for (const QString &command : commands) {
        const QByteArray payload = command.toUtf8() + '\n';
        if (!writeWindowsLine(handle, payload)) {
            return false;
        }
        const QString response = readWindowsResponse(handle);
        if (!serialResponseAccepted(command, response)) {
            return false;
        }
    }
    return true;
#else
    const QByteArray portBytes = normalizedSerialName(serialPortName()).toLocal8Bit();
    const int fd = ::open(portBytes.constData(), O_RDWR | O_NOCTTY | O_SYNC);
    if (fd < 0) {
        return false;
    }

    const auto closeFd = qScopeGuard([fd]() { ::close(fd); });
    Q_UNUSED(closeFd);

    if (!configurePosixSerial(fd, serialBaudRate())) {
        return false;
    }

    for (const QString &command : commands) {
        const QByteArray payload = command.toUtf8() + '\n';
        if (!writePosixLine(fd, payload)) {
            return false;
        }
        const QString response = readPosixResponse(fd);
        if (!serialResponseAccepted(command, response)) {
            return false;
        }
    }
    return true;
#endif
}

bool RobotCommandInterface::serialResponseAccepted(const QString &command, const QString &response) const
{
    const QString normalized = response.trimmed().toUpper();
    if (normalized.isEmpty()) {
        return false;
    }

    if (command == QLatin1String("PING")) {
        return normalized.contains(QStringLiteral("OK PONG"))
            || normalized.contains(QStringLiteral("PONG"))
            || normalized.contains(QStringLiteral("WIESEL MINI READY"));
    }
    if (command == QLatin1String("STATUS")) {
        return normalized.contains(QStringLiteral("STATE")) || normalized.contains(QStringLiteral("OK STATUS"));
    }
    if (command == QLatin1String("HOME")) {
        return normalized.contains(QStringLiteral("OK HOME")) || normalized.contains(QStringLiteral("HOME OK"));
    }
    if (command == QLatin1String("STOP")) {
        return normalized.contains(QStringLiteral("OK STOP")) || normalized.contains(QStringLiteral("STOP OK"));
    }
    if (command.startsWith(QStringLiteral("SET "))) {
        return normalized.contains(QStringLiteral("OK"));
    }

    return normalized.contains(QStringLiteral("OK"));
}

bool RobotCommandInterface::appendBridgeCommand(const QString &action) const
{
    const QString path = outboxPath();
    if (path.isEmpty()) {
        return false;
    }

    QFileInfo info(path);
    QDir dir = info.dir();
    if (!dir.exists() && !QDir().mkpath(dir.absolutePath())) {
        return false;
    }

    QFile outbox(path);
    if (!outbox.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        return false;
    }

    QTextStream stream(&outbox);
    stream << "{\"timestamp\":\""
           << QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs)
           << "\",\"source\":\"chevel-rocket\",\"mode\":\"live-usb-debug\",\"serialPort\":\""
           << serialPortName()
           << "\",\"baud\":"
           << serialBaudRate()
           << ",\"action\":\""
           << action
           << "\"}\n";
    return true;
}
