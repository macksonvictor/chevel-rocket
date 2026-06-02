#!/usr/bin/env bash
set -euo pipefail

echo "[chevel] Installing Ubuntu 24.04 build and voice dependencies..."
sudo apt update
sudo apt install -y \
  build-essential \
  ca-certificates \
  cmake \
  ffmpeg \
  git \
  ninja-build \
  python3 \
  python3-pip \
  python3-venv \
  qt6-base-dev \
  qt6-declarative-dev \
  qml6-module-qtquick \
  qml6-module-qtquick-controls \
  qml6-module-qtquick-layouts \
  qml6-module-qtquick-window

python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install openai-whisper piper-tts

mkdir -p "$HOME/.local/share/chevel-rocket/models"
mkdir -p "$HOME/.local/share/chevel-rocket/voice-output"

cat <<'EOF'

[chevel] Bootstrap complete.

Recommended environment for LIVE-first local testing:
  export CHEVEL_AUDIO_BACKEND=auto
  export CHEVEL_VOICE_OUTPUT_DIR="$HOME/.local/share/chevel-rocket/voice-output"
  export CHEVEL_AI_MODELS_DIR="$HOME/.local/share/chevel-rocket/models"
  export CHEVEL_ROBOT_COMMAND_OUTBOX="$HOME/.local/share/chevel-rocket/live-command-outbox.jsonl"

Piper needs a .onnx voice model:
  export CHEVEL_PIPER_MODEL="$HOME/.local/share/chevel-rocket/models/<voice>.onnx"

Then run:
  scripts/linux/build.sh
  scripts/linux/run.sh
EOF
