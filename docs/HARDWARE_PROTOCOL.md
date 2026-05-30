# Hardware Protocol Draft

This document defines the first communication idea between Chevel Rocket and WIESEL Mini.

The first version should be simple, readable and easy to debug.

## Transport Options

Initial options:

- USB serial
- local Wi-Fi API

Recommended first option:

```text
USB serial
```

USB serial is easier to debug before adding Wi-Fi.

## Message Style

Use simple line-based commands at first.

Example:

```text
PING
STATUS
SET BASE 90
SET SHOULDER 80
SET ELBOW 120
SET GRIPPER 35
HOME
STOP
```

## Suggested Responses

```text
OK
ERR UNKNOWN_COMMAND
ERR LIMIT
STATE READY
STATE EMERGENCY
SERVO BASE 90
```

## Safety Rules

The firmware should apply limits before moving any servo.

Example limits:

```text
BASE: 0..180
SHOULDER: 20..160
ELBOW: 20..160
GRIPPER: 20..100
```

## First Integration Goal

Chevel Rocket sends one command.

ESP32 receives it.

ESP32 confirms it.

Chevel Rocket shows the result in the log console.

## Future JSON Mode

After the simple protocol works, a JSON format can be added.

Example:

```json
{
  "type": "set_servo",
  "target": "base",
  "angle": 90
}
```
