# Contributing to Chevel Rocket

Chevel Rocket is the robotics control module of the Chevel ecosystem.

Contributions should keep the project clear, honest and safe.

## Main rules

- Do not present simulation features as real hardware support.
- Do not add placeholder images as official screenshots.
- Keep Chevel AI and Chevel Rocket responsibilities separated.
- Keep safety states visible and documented.
- Prefer small, reviewable changes.

## Development focus

Good contributions include:

- QML interface improvements
- C++ controller improvements
- telemetry model improvements
- hardware bridge experiments
- documentation improvements
- WIESEL Mini prototype files
- safety model improvements

## Before changing hardware behavior

Any future hardware-control change should explain:

- what command is being added
- what safety checks exist
- how emergency stop is respected
- whether the behavior is simulation-only or hardware-enabled

## Build check

Before submitting larger changes, run:

```cmd
cmake -S . -B build -G "Ninja" -DCMAKE_PREFIX_PATH="C:\Qt\6.11.1\msvc2022_64"
cmake --build build
```

Then test:

```cmd
.\build\ChevelRobotControlCenter.exe --test-window
.\build\ChevelRobotControlCenter.exe
```
