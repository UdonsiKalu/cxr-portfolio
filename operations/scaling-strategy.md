# Scaling strategy

- **Analyzer:** scale replicas only after single warm instance p95 is understood; bottleneck was import-not-CPU.
- **UI:** Next.js dev is single-process; production K8 uses Helm `replicaCount`.
- **Load tests:** Locust users ↑ until p95 degrades; use Jaeger to see kernel vs queue time.
