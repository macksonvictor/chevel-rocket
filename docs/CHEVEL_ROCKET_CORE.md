# CHEVEL ROCKET Core

## Purpose

CHEVEL ROCKET is the native control center screen for CHEVEL. It is designed to
look and behave like a machine control panel, not like a web dashboard.

This first version is intentionally simulation-only.

## Safety Rules In This Version

- `EMERGENCY STOP` is always visible.
- Critical actions require a modal and typed confirmation with `CONFIRMAR`.
- `ARM ROBOT`, `START MISSION`, `REBOOT SYSTEM` and `EMERGENCY STOP` are critical.
- When emergency is active, commands are blocked except clearing emergency.
- The UI talks to `RobotController`; it does not talk directly to hardware.
- `RobotCommandInterface` is the future hardware boundary and is simulated now.
- Every action creates a timestamped log.

## Visual Direction

Current visual target:

- Neutral dark steel base.
- Cold cyan/ice-blue operational lighting.
- Amber warnings.
- Red emergency states.
- Physical machine-style buttons.
- Mission-control layout with gauges, health, telemetry, commands, camera/map
  placeholder and log console.

Future asset direction:

- Subtle brushed metal or carbon texture.
- Physical button caps with bevel maps.
- Cold light strips and panel edge glows.
- Icon set for arm, gripper, lidar, camera, power, link and emergency.

## Integration Note

The browser entry point (`index.html`) is a CHEVEL portal/splash. It does not run
the control center itself because browsers do not safely launch native robot
control executables.

The native control center runs from `build/ChevelRobotControlCenter.exe` or
`run-chevel-rocket.bat`.

The current repository does not contain another CHEVEL AI application to embed
this screen into. For now CHEVEL ROCKET runs as its own native Qt executable.

When the CHEVEL AI app/repo is available, this screen should be integrated as a
core module or launched as a native companion process.
