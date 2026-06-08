# Screenshots — LOAD-003 K8 HPA autoscale

Embedded in [../README.md](../README.md) for GitHub folder view.

| File | Description |
|------|-------------|
| `load-test-autoscaling.png` | Four-panel chart from `plot_load_test.py` (200-user Desktop run) |
| `locust-hpa-mid-50users.png` | `k8-hpa-watch` + Locust ~50 users — analyzer **8/8** |
| `locust-hpa-final-200users.png` | `k8-hpa-watch` + Locust **200** users — analyzer **8/8**, UI **5/5** |

Regenerate chart: `python3 ../plot_load_test.py ../results/load-YYYYMMDD-HHMMSS.csv -o ../results/charts`
