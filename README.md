# CHEVEL ROCKET

CHEVEL ROCKET is the native Qt 6/QML core screen for the CHEVEL control stack.
It is currently a desktop DEMO/SIMULATION panel: telemetry is fake, commands only
change internal state, and no hardware command is sent.

## Current Status

Implemented now:

- Qt 6 + QML native interface.
- C++ backend/controllers.
- CMake build.
- Industrial/cockpit main screen.
- Simulated telemetry updated every 500 ms.
- Robot health, gauges, command panel, logs and camera/map placeholder.
- Safety layer through `RobotCommandInterface`.
- Double confirmation for critical commands.
- Always-visible emergency stop.
- `--test-window` mode to prove Qt/QML opens before loading the full cockpit.

Not implemented yet:

- Real robot hardware control.
- CHEVEL AI cognitive modules.
- ROS 2, REST API, camera feed, SLAM or robotic arm drivers.
- Real autonomy, learning, world model or voice control.

Those items are documented as roadmap so the project does not pretend a
simulation is already real hardware.

## Build

Open `x64 Native Tools Command Prompt for VS 2022` or run through `vcvars64.bat`.

```powershell
cd /d "C:\Users\mackson\OneDrive\Documentos\New project"
cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:\Qt\6.11.1\msvc2022_64" -DCMAKE_MAKE_PROGRAM="C:\Qt\Tools\Ninja\ninja.exe"
cmake --build build
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

- `main.cpp`: application bootstrap, QML module loading and diagnostics.
- `CMakeLists.txt`: Qt executable and QML module packaging.
- `src/RobotController.*`: state, logs and simulated telemetry.
- `src/TelemetryModel.*`: telemetry properties exposed to QML.
- `src/RobotCommandInterface.*`: simulation command boundary, prepared for real integration.
- `qml/Main.qml`: CHEVEL ROCKET core cockpit screen.
- `qml/components/*.qml`: reusable dashboard components.
- `docs/`: roadmap and implementation notes.
