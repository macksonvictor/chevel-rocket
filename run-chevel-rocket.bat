@echo off
setlocal
cd /d "%~dp0"

if not exist "build\ChevelRobotControlCenter.exe" (
  echo CHEVEL ROCKET executable was not found.
  echo Build it first:
  echo cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:\Qt\6.11.1\msvc2022_64" -DCMAKE_MAKE_PROGRAM="C:\Qt\Tools\Ninja\ninja.exe"
  echo cmake --build build
  pause
  exit /b 1
)

start "" "%~dp0build\ChevelRobotControlCenter.exe"
