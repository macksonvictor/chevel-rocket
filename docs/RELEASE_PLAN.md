# Release Plan

This document describes how Chevel Rocket should move from prototype to usable Windows builds.

## Release goals

A release should give testers a clear package, clear instructions and a known status.

Chevel Rocket releases should never hide whether the app is running in simulation mode or hardware mode.

## Version stages

### v0.1 — Native cockpit prototype

Goal:

- open the Qt/QML cockpit reliably
- keep diagnostics available
- document Windows build steps
- show the official interface direction

### v0.2 — Stable simulation build

Goal:

- improve simulated telemetry
- improve logs
- improve UI module navigation
- keep safety controls visible
- package a Windows test build

### v0.3 — WIESEL Mini bridge preview

Goal:

- add USB serial bridge experiment
- send basic commands to ESP32
- read basic device responses
- keep simulation and hardware modes separate

### v0.4 — Hardware-supervised prototype

Goal:

- connect WIESEL Mini with supervised commands
- add telemetry feedback
- validate emergency stop state
- document wiring and firmware versions

### v0.5 — Chevel AI intent bridge

Goal:

- receive high-level intent from Chevel AI
- validate commands in Chevel Rocket
- forward only safe operations to hardware bridge

## Release checklist

Before any release:

```text
Build passes
Test window opens
Main window opens
README is current
Docs are current
Simulation mode is clear
Known limitations are listed
No fake hardware support is claimed
```

## Windows package checklist

A Windows package should include:

```text
ChevelRobotControlCenter.exe
Qt runtime files from windeployqt
README or release notes
known limitations
version tag
```

## Release naming

Suggested naming:

```text
chevel-rocket-v0.1.0-windows-x64.zip
```

## Current status

The project is still an active prototype. The first real release should happen only after the Qt/QML startup is stable on a clean Windows machine.
