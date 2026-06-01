# Roadmap

This roadmap describes the planned evolution of Chevel Rocket.

## Phase 0 — Native cockpit

Goal: make the desktop interface stable, clear and presentable.

Tasks:

- stabilize Qt/QML startup
- keep `--test-window` available for diagnostics
- improve dashboard layout
- organize QML components
- document build steps
- separate simulation mode from hardware mode

## Phase 1 — Simulation layer

Goal: make the cockpit useful before hardware is connected.

Tasks:

- simulated telemetry
- system state indicators
- command panel
- logs
- safety status
- emergency stop UI
- robot preview area

## Phase 2 — WIESEL Mini prototype

Goal: build a small physical prototype.

Target hardware:

- ESP32
- PCA9685
- MG90S servos
- external 5V servo power
- emergency stop
- LEDs
- small robotic arm structure

## Phase 3 — Hardware bridge

Goal: connect Chevel Rocket to WIESEL Mini.

First transport:

```text
USB serial
```

Initial commands:

```text
PING
STATUS
HOME
STOP
SET BASE 90
SET SHOULDER 80
SET ELBOW 120
SET GRIPPER 35
```

## Phase 4 — Chevel AI integration

Goal: connect high-level AI intent to supervised robotic commands.

Rule:

```text
Chevel AI sends intent.
Chevel Rocket validates action.
WIESEL Mini executes movement.
```

## Phase 5 — Sensor expansion

Possible additions:

- current sensor
- OLED display
- camera
- distance sensor
- IMU
- limit switches

## Phase 6 — Larger robotic platform

Goal: prepare the architecture for future WIESEL-E/U hardware.

This phase should not start until the small prototype validates the control stack.
