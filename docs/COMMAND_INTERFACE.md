# Command Interface

The command interface is the boundary between the Chevel Rocket UI and any future robot action.

It should remain explicit, testable and safe.

## Current responsibility

The command interface should:

- receive UI actions
- validate allowed operations
- update logs
- update robot state
- keep simulation and hardware behavior separated

## Future responsibility

When hardware mode is added, the command interface should also:

- validate robot connection
- check safety state
- reject movement during emergency
- forward safe commands to the hardware bridge
- record responses from the device

## Initial command set

```text
ARM
DISARM
HOME
STOP
STATUS
SET BASE <angle>
SET SHOULDER <angle>
SET ELBOW <angle>
SET GRIPPER <angle>
```

## Command flow

```text
QML button
  -> RobotController
  -> RobotCommandInterface
  -> simulation update or hardware bridge
  -> log event
  -> UI state update
```

## Safety rule

No UI component should talk directly to hardware.

Every hardware action should pass through the command interface and safety model.
