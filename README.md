# CHEVEL ROCKET

**CHEVEL ROCKET** is the native robotics control center of the Chevel ecosystem.

Chevel AI is the intelligence layer. It handles reasoning, memory, language, planning and tool use.

Chevel Rocket is the robotics layer. It handles the cockpit interface, telemetry, supervision, safety states and future hardware integration.

The first physical target is **WIESEL Mini**, a small low-cost prototype used to validate movement, telemetry, emergency states and the hardware bridge before larger robotic platforms.

## Ecosystem

```text
Chevel AI
  -> goals, intent and planning
Chevel Rocket
  -> supervision, telemetry and safe robot commands
Hardware Bridge
  -> USB serial or local Wi-Fi integration
WIESEL Mini / WIESEL-E
  -> physical prototype and future robotic platform
```

## Current Status

Implemented now:

- Qt 6 + QML native desktop interface.
- C++ backend/controllers.
- CMake + Ninja build.
- Industrial/cockpit main screen.
- Simulated telemetry during runtime.
- Robot health, gauges, command panel, logs and camera/map placeholder.
- Safety boundary through `RobotCommandInterface`.
- Double confirmation for critical actions.
- Always-visible emergency state control.
- `--test-window` mode to validate Qt/QML startup.

Planned next:

- WIESEL Mini prototype documentation.
- Hardware bridge protocol.
- USB serial integration.
- ESP32 bridge experiment.
- Chevel AI high-level integration.

Not implemented yet:

- Production hardware support.
- ROS 2, SLAM or navigation stack.
- Real camera feed.
- Autonomous behavior inside Chevel Rocket.

The project separates simulation from physical integration so the repository stays honest and technically clear.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Windows Build Guide](docs/BUILD_WINDOWS.md)
- [WIESEL Mini Prototype](docs/WIESEL_MINI.md)
- [Hardware Protocol Draft](docs/HARDWARE_PROTOCOL.md)
- [Chevel AI Integration](docs/CHEVEL_AI_INTEGRATION.md)
- [WIESEL Mini Parts List](hardware/wiesel-mini/parts-list.md)
- [WIESEL Mini Wiring](hardware/wiesel-mini/wiring.md)
- [ESP32 Firmware Draft](hardware/wiesel-mini/firmware/esp32_wiesel_mini.ino)

## Build on Windows

Use **x64 Native Tools Command Prompt for VS 2022**.

Required tools:

- Visual Studio Build Tools 2022 / MSVC v143.
- Windows SDK.
- CMake.
- Ninja.
- Qt 6.11.1 MSVC 2022 64-bit.

Known working Qt path:

```text
C:\Qt\6.11.1\msvc2022_64
```

Configure and build:

```powershell
cd /d "C:\Users\mackson\OneDrive\Documentos\New project"
cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:\Qt\6.11.1\msvc2022_64"
cmake --build build
```

Deploy Qt DLLs for local execution:

```powershell
C:\Qt\6.11.1\msvc2022_64\bin\windeployqt.exe --debug --qmldir qml build\ChevelRobotControlCenter.exe
```

Run:

```powershell
.\build\ChevelRobotControlCenter.exe
```

Test minimal Qt/QML window:

```powershell
.\build\ChevelRobotControlCenter.exe --test-window
```

## Project Layout

```text
main.cpp                         Application bootstrap and QML diagnostics
CMakeLists.txt                   Qt executable and QML module packaging
src/RobotController.*            State, logs and simulated telemetry
src/TelemetryModel.*             Telemetry properties exposed to QML
src/RobotCommandInterface.*      Command boundary prepared for integration
qml/Main.qml                     CHEVEL ROCKET cockpit screen
qml/components/*.qml             Reusable dashboard components
docs/                            Architecture and implementation notes
hardware/wiesel-mini/            Prototype planning files
```

## Development Principle

Chevel Rocket should grow in phases:

1. Stable native cockpit.
2. Safe command boundary.
3. WIESEL Mini prototype plan.
4. Hardware bridge experiment.
5. Chevel AI integration.
6. Larger robotic platforms.

## Short Definition

```text
Chevel AI thinks.
Chevel Rocket supervises.
WIESEL Mini executes the prototype layer.
```
