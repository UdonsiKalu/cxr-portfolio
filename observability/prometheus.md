# Prometheus

Part of **`cxr-ops-lab` observe compose** (with Jaeger, Grafana).

| URL | Role |
|-----|------|
| http://localhost:9090 | Prometheus UI |

Wiring: `observe/prometheus.yml` scrapes configured targets (including compose :3000 when enabled).

Start: `cxr up` or `./scripts/07-observe-up.sh` in ops-lab.

See [observability-overview.md](./observability-overview.md) · companion `cxr-ops-lab/docs/OBSERVE-WIRING.md`.
