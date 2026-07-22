# RUNBOOK — CHAOS-002 network latency

## Prereqs

- Warm analyzer: `curl -s http://127.0.0.1:8766/health` → `"warmed": true`
- Python 3 (stdlib enough for proxy; matplotlib optional for chart)

## Full run

```bash
cd investigations/network-latency-injection
CXR_NET_PROBES=2 ./run-network-latency-check.sh
python3 plot_latency.py
```

## Single phase (screenshots)

```bash
./run-network-latency-check.sh --phase baseline
./run-network-latency-check.sh --phase latency-2000
./run-network-latency-check.sh --phase recovery
./run-network-latency-check.sh --phase stop-proxy
```

## Proxy control

```bash
curl -s http://127.0.0.1:8767/__cxr_proxy/status

# delay (CHAOS-002)
curl -s -X POST http://127.0.0.1:8767/__cxr_proxy/delay \
  -H 'Content-Type: application/json' -d '{"ms":500}'

# packet loss % (CHAOS-003 — see ../packet-loss-injection/)
curl -s -X POST http://127.0.0.1:8767/__cxr_proxy/loss \
  -H 'Content-Type: application/json' -d '{"pct":10}'
```

## Env

| Var | Default | Meaning |
|-----|---------|---------|
| `CXR_NET_PROBES` | `2` | Samples per tier |
| `CXR_PROXY_URL` | `http://127.0.0.1:8767` | Delay proxy |
| `CXR_ANALYZER_URL` | `http://127.0.0.1:8766` | Real analyzer (upstream) |
