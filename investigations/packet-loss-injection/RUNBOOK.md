# RUNBOOK — CHAOS-003 packet loss

## Prereqs

- Warm analyzer: `curl -s http://127.0.0.1:8766/health` → `"warmed": true`
- Sibling proxy script: `../network-latency-injection/delay_proxy.py`

## Full run

```bash
cd investigations/packet-loss-injection
CXR_NET_PROBES=20 ./run-packet-loss-check.sh
python3 plot_success.py
```

## Proxy control

```bash
curl -s -X POST http://127.0.0.1:8767/__cxr_proxy/loss \
  -H 'Content-Type: application/json' -d '{"pct":10}'
curl -s http://127.0.0.1:8767/__cxr_proxy/status
```
