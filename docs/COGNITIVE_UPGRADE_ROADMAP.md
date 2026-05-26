# CHEVEL AI Cognitive Upgrade Roadmap

This file tracks the advanced CHEVEL AI / Dum-E/U requirements as roadmap.
These modules are not implemented in this Qt/C++ demo yet.

## Target Modules

1. Decision Engine
   - Choose actions from candidate actions.
   - Score priority, risk, urgency and resource cost.
   - Critical risk always asks for human confirmation.

2. World Model
   - Store objects, people, system state, environment state and history.
   - Detect what changed and predict simple action effects.

3. Advanced Memory
   - Procedural memory for learned task steps.
   - Episodic records of past events.
   - Intelligent forgetting and consolidation.

4. Learning System
   - Register every action/result episode.
   - Learn from success/failure rewards.
   - Recommend actions from historical performance.

5. Task Reasoning
   - Break goals into subtasks.
   - Execute step by step.
   - Replan after repeated failure.

6. Fast Thinking
   - High-frequency safety loop.
   - React to people in danger zones, overheating, overcurrent, low battery and
     heartbeat loss without waiting for an LLM.

7. Self Monitoring
   - Estimate confidence.
   - Detect task failures.
   - Ask for human help when uncertainty or repeated failure is high.

8. Goal System
   - Keep persistent goals such as safety, battery management and learning.
   - Suggest proactive actions when goals are at risk.

## Recommended Integration Flow

```text
Sensor/voice/event input
  -> Fast Thinking safety gate
  -> World Model update
  -> Self Monitoring confidence check
  -> Goal System proactive check
  -> Task Reasoning plan
  -> Decision Engine action selection
  -> LLM natural response when needed
  -> Learning System episode record
  -> Robot command interface
```

## Implementation Boundary

The Qt app should remain a native control surface. Real cognition should live in
a separate CHEVEL AI service/core, then expose safe state and commands to this UI
through a controlled API. The UI must never bypass the safety layer to command
hardware directly.
