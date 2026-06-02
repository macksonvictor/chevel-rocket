#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if [[ -d ".venv" ]]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

export CHEVEL_AUDIO_BACKEND="${CHEVEL_AUDIO_BACKEND:-auto}"
export CHEVEL_VOICE_OUTPUT_DIR="${CHEVEL_VOICE_OUTPUT_DIR:-$HOME/.local/share/chevel-rocket/voice-output}"
export CHEVEL_AI_MODELS_DIR="${CHEVEL_AI_MODELS_DIR:-$HOME/.local/share/chevel-rocket/models}"
export CHEVEL_ROBOT_SERIAL_BAUD="${CHEVEL_ROBOT_SERIAL_BAUD:-115200}"
export CHEVEL_ROBOT_COMMAND_OUTBOX="${CHEVEL_ROBOT_COMMAND_OUTBOX:-$HOME/.local/share/chevel-rocket/live-command-outbox.jsonl}"

mkdir -p "$(dirname "$CHEVEL_VOICE_OUTPUT_DIR/.keep")"
mkdir -p "$(dirname "$CHEVEL_ROBOT_COMMAND_OUTBOX")"

exec ./build-linux/ChevelRobotControlCenter "$@"
