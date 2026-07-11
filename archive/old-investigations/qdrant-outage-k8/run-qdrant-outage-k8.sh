#!/usr/bin/env bash
# REL-002-K8: Qdrant stop/start with K8 :8081 analyze probes.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OPS="${CXR_OPS_LAB:-$HOME/staging/cxr-ops-lab}"
UI_URL="${CXR_K8_UI_URL:-http://127.0.0.1:8081}"
QDRANT_CONTAINER="${CXR_QDRANT_CONTAINER:-cxr-qdrant-outage-lab}"
RESULTS="$ROOT/investigations/qdrant-outage-k8/results"
mkdir -p "$RESULTS"
OUT="$RESULTS/qdrant-k8-$(date +%Y%m%d-%H%M%S).log"

probe() {
  local label="$1"
  local t0=$(date +%s%3N)
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$UI_URL/api/claim-studio/analyze" \
    -H "Content-Type: application/json" \
    -d '{"claim_id":"k8-qdrant-test","raw_text":"office visit"}' || echo "000")
  local t1=$(date +%s%3N)
  local ms=$((t1 - t0))
  echo "$label http=$code latency_ms=$ms" | tee -a "$OUT"
}

kubectl config use-context docker-desktop >/dev/null
"$OPS/scripts/16-k8-stack-verify.sh" 2>&1 | tee -a "$OUT" || true

docker start "$QDRANT_CONTAINER" 2>/dev/null || true
sleep 2
probe "baseline_qdrant_up"
docker stop "$QDRANT_CONTAINER" 2>&1 | tee -a "$OUT"
sleep 2
probe "test_mid_outage"
docker start "$QDRANT_CONTAINER" 2>&1 | tee -a "$OUT"
sleep 3
probe "recovery_qdrant_up"
echo "Done — $OUT"
