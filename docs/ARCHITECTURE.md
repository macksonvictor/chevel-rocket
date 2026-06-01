# Chevel Rocket Architecture

Chevel Rocket is the native robotics control module of the Chevel ecosystem.

The project is organized around three layers:

- Chevel AI: intelligence, reasoning, memory, language and planning.
- Chevel Rocket: robot cockpit, telemetry, command supervision and safety states.
- WIESEL Mini / WIESEL-E: physical prototype and future robotic platforms.

## System Flow

```text
User
Chevel AI
Chevel Rocket
Hardware Bridge
WIESEL Mini / WIESEL-E
```

## Responsibilities

### Chevel AI

Chevel AI should handle interpretation, memory, planning and high-level decisions.

### Chevel Rocket

Chevel Rocket should handle the operator interface, telemetry, safety state, logs, commands and hardware integration.

### Hardware Bridge

The hardware bridge should translate supervised Rocket commands into a device protocol. The first version can use USB serial with an ESP32.

### WIESEL Mini

WIESEL Mini is the first physical demonstrator. It validates low-cost movement, telemetry and safety before larger robotic platforms.

## Development Phases

```text
Phase 0: Native Qt cockpit
Phase 1: Simulated telemetry
Phase 2: WIESEL Mini prototype
Phase 3: USB serial bridge
Phase 4: Chevel AI integration
Phase 5: larger robotic platforms
```

## Design Rule

Chevel Rocket must clearly separate simulation mode from hardware mode.
