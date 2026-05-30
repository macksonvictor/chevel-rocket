# Chevel AI Integration

Chevel AI and Chevel Rocket should remain separate modules.

## Chevel AI Role

Chevel AI handles:

- interpretation
- reasoning
- memory
- planning
- natural language
- task decomposition

## Chevel Rocket Role

Chevel Rocket handles:

- robot workspace
- telemetry
- state visualization
- supervised commands
- hardware bridge

## Integration Principle

Chevel AI should send high-level intent.

Chevel Rocket should validate and translate that intent into supervised robot actions.

Example:

```text
User: move the arm to the home position
Chevel AI: intent = HOME_POSITION
Chevel Rocket: validates state and sends HOME to hardware bridge
WIESEL Mini: moves to safe preset
```

## Do Not Mix Responsibilities

Chevel AI should not become a raw servo controller.

Chevel Rocket should not become the general AI brain.

The ecosystem is stronger when each module has a clear job.
