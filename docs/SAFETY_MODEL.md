# Safety Model

Chevel Rocket must be designed around supervised robotic operation.

The safety model starts simple and should become stricter as real hardware is added.

## Current rule

Simulation mode and hardware mode must be visibly different.

The operator should always know whether a command is only changing simulated state or reaching a physical device.

## Safety states

Suggested states:

```text
DISCONNECTED
READY
ARMED
MOVING
WARNING
EMERGENCY
MAINTENANCE
```

## Emergency stop

Emergency stop should always be visible in the interface.

When hardware is connected, emergency stop should:

- stop command emission
- notify the hardware bridge
- put the interface into emergency state
- require explicit user recovery

## Confirmation gate

Critical actions should require confirmation.

Examples:

- arm robot
- disarm robot
- start mission
- execute hardware movement
- clear emergency state

## Hardware bridge rules

The hardware bridge should reject unsafe commands before they reach the device.

Validation should include:

- command known
- robot connected
- emergency not active
- angle within range
- power state acceptable
- movement mode allowed

## Firmware rules

The firmware should also validate commands.

Never trust the desktop app alone.

The first firmware should apply safe servo limits and reject unknown commands.
