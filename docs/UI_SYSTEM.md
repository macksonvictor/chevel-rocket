# UI System

Chevel Rocket should use a consistent visual language across the cockpit.

The interface direction is industrial, dark, technical and readable.

## Visual goals

- clear status hierarchy
- strong contrast
- readable telemetry
- visible emergency state
- cockpit-style panels
- minimal decorative noise

## Core areas

```text
Mission Control
Robot Control
Computer Control
Safety
Voice
Logs
UI Kit
```

## Suggested component types

- status light
- telemetry card
- command button
- confirmation modal
- gauge
- log row
- event detail panel
- safety banner
- mode pill
- connection indicator

## Color roles

```text
background: dark neutral
panel: slightly lighter dark
border: muted technical gray
success: green
warning: amber
danger: red
info: blue/cyan
text: off-white
muted text: gray-blue
```

## Interface rule

The UI should never make a dangerous action look casual.

Emergency, hardware movement, mission start and command execution should be visually separated from regular navigation.
