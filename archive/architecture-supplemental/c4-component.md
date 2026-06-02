# C4 — Component view (Web application)

Inside **Next.js `cxr-ui`**: App Router pages, `app/api/*` routes, and `lib/*` shared libraries.

## Components

| Component | Location | Role |
|-----------|----------|------|
| **Terminal API** | `app/api/terminal/*` | Executive Terminal dashboards (SQL + snapshots) |
| **Admin API** | `app/api/admin/*` | Commons publishing, maintenance |
| **Claim studio API** | `app/api/claim-studio/*` | Ingest, **analyze**, audit |
| **Sandbox API** | `app/api/sandbox/*` | Local Docker stack control |
| **Shared libraries** | `lib/*` | `db.ts`, `resolve-analyzer-script`, Qdrant helpers |

## Analyze path (portfolio focus)

`POST /api/claim-studio/analyze` → `claim_studio.analyze.handler` → HTTP to **`cxr-analyzer-service` :8766** (warm) or subprocess fallback → kernel spans (`context_builder`, `claim_analysis`, …).

See [request-flow.md](./request-flow.md) · [c4-container.md](./c4-container.md).

Source: CXR architecture vault C4 Level 3 (adapted for public portfolio).
