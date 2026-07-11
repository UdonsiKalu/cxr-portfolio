# OBS-003 — Shared SQL connection evidence

Screenshots from the PERF-009 review window (2026-06-22) where Jaeger showed **“2 Errors”** on policy SQL spans.

Full write-up: [OBS-003 study](../../studies/OBS-003-shared-sql-connection.md) · failures [Arc 6](../../../../failures/README.md#arc-6--shared-sql-connection-under-load-obs-003-jun-22).

| File | What it shows |
|------|----------------|
| [jaeger-search-2-errors-slow-posts-20260622.png](jaeger-search-2-errors-slow-posts-20260622.png) | Search: long POSTs (~700–824 ms) each with red **2 Errors** |
| [jaeger-search-2-errors-mixed-20260622.png](jaeger-search-2-errors-mixed-20260622.png) | Same session — mixed durations still showing **2 Errors** |
| [jaeger-waterfall-policy-sql-errors-f541546-20260622.png](jaeger-waterfall-policy-sql-errors-f541546-20260622.png) | Slow trace `f541546`: red errors on **`context.7_policy`** / **`context.7_policy.sql`** |

Source: `~/Pictures/Screenshots/` (Jun 22 11:27–11:31 and Jun 23 02:37 review of the same traces).
