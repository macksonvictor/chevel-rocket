# Product Vision

Chevel Rocket is the native robotics control center of the Chevel ecosystem.

It is designed to become the operational module that allows Chevel AI to interact with physical robotic systems through a supervised, visual and safety-aware cockpit.

## Core idea

Chevel AI should think, interpret and plan.

Chevel Rocket should supervise, validate and execute robotic operations.

WIESEL Mini should be the first small physical body where the control architecture can be tested safely and cheaply.

## Product pillars

### 1. Native control

Chevel Rocket should remain a native desktop application for serious robot control workflows.

The first implementation uses C++, Qt 6 and QML.

### 2. Safety-first operation

Every future hardware action should pass through explicit state checks, clear visual feedback and emergency stop logic.

The interface should never hide whether it is in simulation mode or hardware mode.

### 3. Modular robotics stack

The project should grow through modules:

- cockpit UI
- command interface
- telemetry model
- hardware bridge
- safety layer
- AI intent bridge
- prototype firmware

### 4. Honest prototyping

Chevel Rocket should present simulation as simulation and hardware as hardware.

A serious repository must document what exists, what is planned and what is not implemented yet.

## Long-term direction

Chevel Rocket can evolve into the robotics layer for a larger Chevel platform:

```text
Chevel AI
  -> intent, reasoning, planning
Chevel Rocket
  -> operation, safety, telemetry, supervision
Robotic platforms
  -> physical movement, sensors, actuators
```

## First target

The first target is WIESEL Mini, a small robotic arm prototype based on:

- ESP32
- PCA9685
- MG90S servos
- emergency stop
- LEDs
- external 5V servo power

This target is intentionally small so the software architecture can be validated before expensive hardware is introduced.
