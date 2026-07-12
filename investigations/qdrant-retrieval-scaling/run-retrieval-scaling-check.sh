#!/usr/bin/env bash
# PERF-003 — Qdrant retrieval scaling: concurrent Analyze while Qdrant has real claims__* data.
# Measures wall-clock Analyze latency + policy_support count; optional Jaeger retrieval spans.
# Prereq: :8251, warm :8766 (booted with Qdrant up), Qdrant :6333 with collections.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${HERE}/results"
mkdir -p "${OUT}"
HOST="${CXR_LOAD_URL:-http://127.0.0.1:8251}"
JAEGER="${CXR_JAEGER_URL:-http://127.0.0.1:16686}"
CSV="${OUT}/retrieval-scaling-probes.csv"
SUMMARY="${OUT}/retrieval-scaling-summary.txt"
TIMELINE="${OUT}/retrieval-scaling-timeline.log"

: > "${TIMELINE}"
echo "tier,concurrency,req,http,ms,policy_n,semantic,note" > "${CSV}"

log() { echo "$(date -Iseconds)  $*" | tee -a "${TIMELINE}"; }

qdrant_ok() {
  curl -sf -m 3 http://127.0.0.1:6333/collections >/dev/null
}

echo "== PERF-003 Qdrant retrieval scaling =="
curl -sf -m 5 http://127.0.0.1:8766/health | tee "${OUT}/analyzer-health.json"
echo
qdrant_ok || { echo "ERROR: Qdrant :6333 down" >&2; exit 1; }
curl -sf -m 5 http://127.0.0.1:6333/collections > "${OUT}/qdrant-collections.json"
python3 - <<'PY' | tee "${OUT}/qdrant-sizes.txt"
import json,urllib.request
cols=json.load(urllib.request.urlopen("http://127.0.0.1:6333/collections",timeout=5))["result"]["collections"]
total=0
for c in cols:
  name=c["name"]
  info=json.load(urllib.request.urlopen(f"http://127.0.0.1:6333/collections/{name}",timeout=15))["result"]
  n=info.get("points_count") or 0
  total+=n
  print(f"{name}\t{n}")
print(f"TOTAL_POINTS\t{total}")
PY

# Concurrency tiers (keep modest on single analyzer)
TIERS="${CXR_RETRIEVAL_TIERS:-1 3 5 8}"

run_one() {
  local tier="$1" conc="$2" i="$3"
  local out="${OUT}/analyze-c${conc}-r${i}.json"
  local claim="perf003-c${conc}-r${i}-$(date +%s%N)"
  local t0 t1 ms code
  t0=$(date +%s%3N)
  code=$(curl -sS -m 180 -X POST "${HOST}/api/claim-studio/analyze" \
    -H 'Content-Type: application/json' \
    -d "{\"input\":{\"content\":\"{\\\"claim_id\\\":\\\"${claim}\\\",\\\"description\\\":\\\"office visit diabetes follow up evaluation\\\"}\"}}" \
    -o "${out}" -w '%{http_code}' || echo 000)
  t1=$(date +%s%3N)
  ms=$((t1 - t0))
  python3 - <<PY
import json
d=json.load(open("${out}"))
r=d.get("result") or {}
ps=r.get("policy_support") or []
n=len(ps) if isinstance(ps,list) else 0
sig=r.get("signals") or {}
sem=sig.get("semantic") if isinstance(sig,dict) else ""
note=(r.get("archetype") or d.get("error") or "ok")
note=str(note)[:60].replace(",",";")
print(f"${tier},${conc},${i},${code},${ms},{n},{sem},{note}")
PY
}

log "sweep_begin tiers=${TIERS}"
for c in ${TIERS}; do
  log "tier_begin concurrency=${c}"
  # launch c parallel requests
  pids=()
  for i in $(seq 1 "${c}"); do
    (
      run_one "c${c}" "${c}" "${i}" >> "${CSV}.part.$$"
    ) &
    pids+=($!)
  done
  for p in "${pids[@]}"; do wait "$p" || true; done
  if [[ -f "${CSV}.part.$$" ]]; then
    cat "${CSV}.part.$$" >> "${CSV}"
    while IFS= read -r line; do log "probe ${line}"; done < "${CSV}.part.$$"
    rm -f "${CSV}.part.$$"
  fi
  sleep 2
done

# Jaeger: recent retrieval spans
python3 - <<PY | tee "${OUT}/jaeger-retrieval-spans.txt"
import json, urllib.request, statistics
url = "${JAEGER}/api/traces?service=cxr-analyzer-service&operation=retrieval&limit=40&lookback=30m"
try:
  raw = urllib.request.urlopen(url, timeout=20).read()
  data = json.loads(raw).get("data") or []
except Exception as e:
  print("jaeger_error", e)
  raise SystemExit
durs_ms = []
for t in data:
  for s in t.get("spans") or []:
    if s.get("operationName") == "retrieval":
      durs_ms.append((s.get("duration") or 0) / 1000.0)  # Jaeger us -> ms
print(f"retrieval_spans={len(durs_ms)}")
if durs_ms:
  durs_ms.sort()
  def pct(p):
    i = min(len(durs_ms)-1, int(round((p/100)*(len(durs_ms)-1))))
    return durs_ms[i]
  print(f"retrieval_ms_min={min(durs_ms):.1f}")
  print(f"retrieval_ms_p50={pct(50):.1f}")
  print(f"retrieval_ms_p95={pct(95):.1f}")
  print(f"retrieval_ms_max={max(durs_ms):.1f}")
PY

{
  echo "PERF-003 Qdrant retrieval scaling — summary"
  echo "generated=$(date -Iseconds)"
  echo ""
  echo "== collection sizes =="
  cat "${OUT}/qdrant-sizes.txt"
  echo ""
  echo "== probes =="
  cat "${CSV}"
  echo ""
  echo "== jaeger retrieval =="
  cat "${OUT}/jaeger-retrieval-spans.txt"
} | tee "${SUMMARY}"

log "done"
echo "Results: ${OUT}"
