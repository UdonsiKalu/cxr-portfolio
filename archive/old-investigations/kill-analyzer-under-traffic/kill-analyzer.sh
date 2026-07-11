#!/usr/bin/env bash
# Kill warm analyzer on :8766 (mid-chaos only).
set -euo pipefail

PORT="${CXR_ANALYZER_PORT:-8766}"
echo "Killing analyzer on :${PORT}..."
fuser -k "${PORT}/tcp" 2>/dev/null && echo "Sent SIGKILL to :${PORT}" || echo "Nothing listening on :${PORT}"
sleep 1
if curl -sf "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
  echo "WARN: analyzer still responding" >&2
  exit 1
fi
echo "Analyzer down."
