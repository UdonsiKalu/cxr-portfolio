#!/usr/bin/env bash
# REL-001-K8: delete one cxr-analyzer pod under Locust on :8081.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OPS="${CXR_OPS_LAB:-$HOME/staging/cxr-ops-lab}"
LOAD_URL="${CXR_LOAD_URL:-http://127.0.0.1:8081}"
USERS="${CXR_CHAOS_USERS:-20}"
DURATION="${CXR_CHAOS_DURATION:-180}"
RESULTS="$ROOT/investigations/kill-analyzer-k8/results"
mkdir -p "$RESULTS"
LOG="$RESULTS/kill-k8-timeline-$(date +%Y%m%d-%H%M%S).log"

kubectl config use-context docker-desktop >/dev/null
echo "=== REL-001-K8 kill analyzer pod ===" | tee "$LOG"
echo "load: $LOAD_URL users=$USERS duration=${DURATION}s" | tee -a "$LOG"

"$OPS/scripts/16-k8-stack-verify.sh" 2>&1 | tee -a "$LOG" || true

LOCUST_PID=""
cleanup() {
  [[ -n "$LOCUST_PID" ]] && kill "$LOCUST_PID" 2>/dev/null || true
}
trap cleanup EXIT

cd "$OPS"
CXR_LOAD_URL="$LOAD_URL" CXR_LOCUST_USERS="$USERS" CXR_LOCUST_TIME="${DURATION}s" \
  ./scripts/22-load-locust.sh --headless 2>&1 | tee -a "$LOG" &
LOCUST_PID=$!
sleep 30

POD="$(kubectl get pods -n cxr-ui -l app=cxr-analyzer --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')"
echo "T+30s killing pod: $POD" | tee -a "$LOG"
kubectl delete pod -n cxr-ui "$POD" --wait=false 2>&1 | tee -a "$LOG"
kubectl get hpa -n cxr-ui 2>&1 | tee -a "$LOG"

wait "$LOCUST_PID" || true
echo "Done — see $LOG"
