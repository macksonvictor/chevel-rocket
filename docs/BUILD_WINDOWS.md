# Build Chevel Rocket on Windows

Chevel Rocket uses C++17, Qt 6/QML, CMake, Ninja and MSVC 2022.

## Known Working Environment

```text
Visual Studio Build Tools 2022
MSVC v143
CMake 4.3.3
Ninja 1.13.2
Qt 6.11.1
Qt path: C:\Qt\6.11.1\msvc2022_64
```

## Terminal

Open:

```text
x64 Native Tools Command Prompt for VS 2022
```

Verify:

```cmd
where cl
where link
cmake --version
ninja --version
dir "C:\Qt\6.11.1\msvc2022_64"
```

## Configure

```cmd
cd /d "C:\Users\mackson\OneDrive\Documentos\New project"
cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:\Qt\6.11.1\msvc2022_64"
```

## Build

```cmd
cmake --build build
```

## Deploy Qt DLLs

```cmd
C:\Qt\6.11.1\msvc2022_64\bin\windeployqt.exe --debug --qmldir qml build\ChevelRobotControlCenter.exe
```

## Run

```cmd
set CHEVEL_ROBOT_SERIAL_PORT=COM3
set CHEVEL_ROBOT_SERIAL_BAUD=115200
.\build\ChevelRobotControlCenter.exe
```

If the ESP32 is not connected yet, leave `CHEVEL_ROBOT_SERIAL_PORT` unset. The
app will stay in `LIVE STANDBY` and physical motion commands will fail safely.

## Test Minimal Window

```cmd
.\build\ChevelRobotControlCenter.exe --test-window
```

## Common Issues

If Qt DLLs are missing, run `windeployqt`.

If `cl.exe` or `link.exe` is missing, use the Visual Studio x64 Native Tools terminal.

If the main QML window does not appear, run the test window first and inspect startup logs.
