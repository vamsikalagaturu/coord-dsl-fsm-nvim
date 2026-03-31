#!/usr/bin/env bash
set -e
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$PLUGIN_DIR/.venv"
REQS="$PLUGIN_DIR/server/requirements.txt"

if command -v uv >/dev/null 2>&1; then
    uv venv "$VENV" --quiet
    uv pip install --python "$VENV/bin/python3" -r "$REQS" --quiet
elif command -v python3 >/dev/null 2>&1; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install --quiet -r "$REQS"
else
    echo "fsm-nvim: python3 not found; LSP support will be unavailable" >&2
    exit 1
fi

echo "fsm-nvim: server dependencies installed into $VENV"
