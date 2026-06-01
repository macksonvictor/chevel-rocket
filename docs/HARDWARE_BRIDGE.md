# Hardware Bridge

The hardware bridge is the future layer between Chevel Rocket and physical devices.

The first bridge target is WIESEL Mini.

## First transport

The first transport should be USB serial because it is simple to debug.

Later options can include:

- local Wi-Fi API
- WebSocket
- ROS 2 bridge
- microcontroller gateway

## Bridge responsibilities

- open and close the device connection
- send commands
- read responses
- parse telemetry
- surface errors to the UI
- respect the safety model
- prevent raw UI-to-device access

## First device target

```text
ESP32 DevKit V1
PCA9685 servo driver
MG90S servos
emergency button
status LEDs
```

## Initial protocol

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

## Response examples

```text
OK PONG
STATE READY BASE 90 SHOULDER 80 ELBOW 120 GRIPPER 35
ERR UNKNOWN_COMMAND
ERR LIMIT
```

## Bridge rule

The hardware bridge should never be treated as trusted blindly.

The desktop app validates commands before sending them.
The firmware validates commands again before moving anything.
