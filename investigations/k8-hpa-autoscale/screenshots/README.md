# Screenshots — copy from load run (Locust + k8-hpa-watch + Jaeger)

| File | Source |
|------|--------|
| `locust-final-195users.png` | Locust UI Charts at stop |
| `hpa-watch-4-replicas.png` | `k8-hpa-watch.sh` terminal |
| `jaeger-peak-optional.png` | http://127.0.0.1:16686 `cxr-analyzer-service` |

Regenerate charts from CSV: `python3 plot_load_test.py results/<run>.csv`
