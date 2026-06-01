# WIESEL Mini

WIESEL Mini is the first physical prototype for the Chevel robotics stack.

It is intentionally small, low-cost and modular. The goal is not strength. The goal is to validate control, telemetry, safety and integration.

## Purpose

WIESEL Mini proves that Chevel Rocket can interact with a real prototype.

It should demonstrate:

- simple robotic arm movement
- servo control
- supervised operation
- emergency state
- status LEDs
- telemetry feedback
- future Chevel AI integration

## Target Hardware

Recommended first build:

```text
1x ESP32 DevKit V1 ESP-WROOM-32
1x PCA9685 16-channel PWM servo driver
4x MG90S 180-degree micro servos
1x 5V 5A power supply for servos
1x 1000uF 16V capacitor
1x emergency mushroom button
LEDs and resistors
jumper wires
protoboard or perfboard
MDF, acrylic, PVC or reused material for structure
```

## Servo Layout

```text
Servo 1: base rotation
Servo 2: shoulder
Servo 3: elbow
Servo 4: gripper
```

Optional later:

```text
Servo 5: wrist pitch
Servo 6: wrist roll
```

## Power Rule

Do not power the servos directly from the ESP32.

Use the external 5V supply for the servos.

Keep common ground:

```text
5V supply GND -> PCA9685 GND
PCA9685 GND -> ESP32 GND
```

## Prototype States

Suggested states:

```text
DISCONNECTED
READY
ARMED
MOVING
WARNING
EMERGENCY
```

## Presentation Sentence

WIESEL Mini is a physical demonstrator for validating the Chevel Rocket control layer before scaling the WIESEL-E/U platform.
