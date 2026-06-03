# Latency investigation — screenshots

Jaeger traces and combined Jaeger+Locust views for the subprocess → warm-analyzer story.

| File | Phase | What it shows |
|------|-------|----------------|
| [before-jaeger-search-2026-05-30.png](./before-jaeger-search-2026-05-30.png) | Before | Jaeger scatter — POST **~5.6s / ~11s** |
| [before-jaeger-waterfall-11s-5spans-2026-05-30.png](./before-jaeger-waterfall-11s-5spans-2026-05-30.png) | Before | **11s** trace, **`executing api route` ~10.6s**, **5 spans** |
| [before-jaeger-python-module-import-7s-2026-06-01.png](./before-jaeger-python-module-import-7s-2026-06-01.png) | Before | **`python.module_import` ~7.66s** + **`context_builder` ~1.5s** |
| [before-jaeger-locust-combined-10s-2026-06-01.png](./before-jaeger-locust-combined-10s-2026-06-01.png) | Before | Side-by-side Jaeger **10.8s** + Locust p95 **~12s** |
| [after-jaeger-locust-154ms-22spans-2026-06-02.png](./after-jaeger-locust-154ms-22spans-2026-06-02.png) | After | **~154ms**, **22 spans**, UI → **:8766** analyzer |
| [after-jaeger-locust-warm-708ms-2026-06-02.png](./after-jaeger-locust-warm-708ms-2026-06-02.png) | After | Warm path **~708ms**, kernel spans under analyzer |
| [after-analyzer-startup-imports-8s-2026-06-02.png](./after-analyzer-startup-imports-8s-2026-06-02.png) | After | One-time **`analyzer_service.startup` ~8.2s** |

Legacy aliases: `SW11-jaeger-*.png` (same as first two before images).

Locust-only stats: [../../load-testing/screenshots/](../../load-testing/screenshots/).
