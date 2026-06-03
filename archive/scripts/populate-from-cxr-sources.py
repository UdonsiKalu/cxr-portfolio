#!/usr/bin/env python3
"""One-shot population of portfolio outline from CXR vault, ops-lab, and existing portfolio docs."""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
VAULT_C4 = Path("/home/udonsi-kalu/staging/cxr_architecture_vault/CXR-Meta/CXR-C4-Architecture.md")


def w(rel: str, text: str) -> None:
    p = ROOT / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text.strip() + "\n", encoding="utf-8")


def split_incident(inc_dir: str, title: str, summary: str, root: str, resolution: str, extra: str = "") -> None:
    base = f"reliability/incidents/{inc_dir}"
    w(f"{base}/timeline.md", f"# {title} — Timeline\n\n| When | What |\n|------|------|\n| Investigation | {summary} |\n| Resolution | {resolution} |\n\nFull record: [postmortem.md](./postmortem.md)")
    w(f"{base}/root-cause.md", f"# {title} — Root cause\n\n{root}\n\nFull record: [postmortem.md](./postmortem.md)")
    w(f"{base}/resolution.md", f"# {title} — Resolution\n\n{resolution}\n\n{extra}\n\nFull record: [postmortem.md](./postmortem.md)")


def main() -> None:
    # Remove outline-only duplicate incident folder
    dup = ROOT / "reliability/incidents/INC-002-missing-llm-spans"
    if dup.exists():
        shutil.rmtree(dup)

    # Architecture — component + derived docs from vault narrative
    vault = VAULT_C4.read_text(encoding="utf-8") if VAULT_C4.exists() else ""
    w(
        "archive/architecture-supplemental/c4-component.md",
        """# C4 — Component view (Web application)

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

Source: CXR architecture vault C4 Level 3 (adapted for public portfolio).""",
    )
    w(
        "archive/architecture-supplemental/dependency-map.md",
        """# Dependency map (local dev stack)

| Dependency | Port | Required for analyze? | Notes |
|------------|------|------------------------|-------|
| Next.js Claim Studio | 8251 | Yes | `cxr-ui-rehearsal` / rehearsal dev |
| FastAPI analyzer | 8766 | Yes (warm path) | `cxr-analyzer-service` |
| SQL Server | 1433 | Yes | Archetypes, thresholds |
| Qdrant | 6333 | Optional | WARN if down; retrieval features |
| Ollama / LLM | varies | Optional | Policy recommendation |
| OTel Collector | 4318 | For traces | OTLP HTTP |
| Jaeger UI | 16686 | For traces | Search + waterfall |
| Prometheus | 9090 | Bootcamp metrics | Observe compose |
| Grafana | 3001 | Bootcamp dashboards | Observe compose |
| Locust | 8089 | Load tests only | Targets :8251 |

Companion repos: `cxr-ui-rehearsal`, `cxr-ops-lab`, `claim_analysis_tools`.""",
    )
    w(
        "archive/architecture-supplemental/blast-radius-analysis.md",
        """# Blast radius analysis

## Failure domains

| Failure | Blast radius | Mitigation |
|---------|--------------|------------|
| Analyzer :8766 down | Analyze API slow or subprocess fallback | `cxr up`; health check :8766 |
| Jaeger / OTLP down | No new traces; app may still work | `cxr up` observe stack |
| SQL unreachable | Terminal + analyze rules fail | Fix connection string / VPN |
| Qdrant down | Retrieval degraded; core analyze may continue | Documented WARN in logs |
| Next.js :8251 down | UI unavailable | Restart `run-rehearsal-dev.sh` |

## What we do not claim

This is a **local engineering stack**, not multi-tenant SaaS isolation. Blast radius for production K8 is tracked in [future-state-architecture.md](../../architecture/future-state-architecture.md) and [ADR-005](../../architecture/adrs/ADR-005-kubernetes-roadmap.md).""",
    )
    w(
        "architecture/future-state-architecture.md",
        """# Future state architecture

## Target (bootcamp / portfolio roadmap)

1. **Today:** `:8251` dev UI + `:8766` warm analyzer + observe stack (`cxr up`).
2. **SW.3 K8:** `kind` cluster `cxr-lab`; Deployment + Service for SW.1 image; port-forward **:8081**.
3. **SW.4 Helm:** `cxr-ops-lab/helm/cxr-ui` — image tag, env, replicas.
4. **SW.5 Terraform:** reproducible kind cluster (`cxr-ops-lab/terraform`).
5. **SW.8 Argo CD:** Application → Helm from Git.

Pods may reach **SQL/Qdrant on host** (syllabus-allowed out-of-cluster).

## Diagram

See K8 deploy intent in companion ops-lab and [operations/kubernetes/](../operations/kubernetes/).

## Not in scope unless requested

Production `cxrlabs-dev/platform/infra` gateway/analysis spine.""",
    )

    # Platform thinking
    w(
        "platform-thinking/design-principles.md",
        """# Design principles

1. **Evidence over claims** — traces, ADRs, load tests beat tool lists.
2. **Measure before optimize** — Jaeger + Locust before tuning `context_builder`.
3. **Operability** — `cxr up` so any engineer can reproduce investigations.
4. **Honest scope** — label bootcamp labs vs daily dev path.
5. **Detailed observability by default** — reject “minimal” trace profiles that hide startup/import cost.

See [engineering-philosophy.md](./engineering-philosophy.md).""",
    )
    w(
        "platform-thinking/tradeoffs.md",
        """# Tradeoffs

| Decision | Chosen | Alternative | Why |
|----------|--------|-------------|-----|
| Analyze runtime | Warm FastAPI :8766 | Subprocess per request | ~7–8s import/init removed from hot path |
| Trace profile | `detailed` | `minimal` | Fewer confusing Operations; ~21 useful spans |
| Daily UI | :8251 rehearsal | :3000 compose only | Faster iteration + OTel on dev route |
| Qdrant | Optional in dev | Hard dependency | Local laptops may skip vector stack |
| Portfolio repo | Private until ready | Public + scaffolds | Full outline filled before promotion |""",
    )
    w(
        "platform-thinking/engineering-evolution.md",
        """# Engineering evolution

1. **Subprocess analyze** — worked but hid cost in new Python each request.
2. **OTel + Jaeger** — made subprocess vs kernel time visible (INC-001, INC-003).
3. **Warm analyzer** — ADR-004; Locust p95 ~1.5s, Jaeger traces ~154–708ms.
4. **Trace UX rollback** — INC-002; detailed profile + `flush_tracing()`.
5. **One-command stack** — `cxr up` + optional `cxr lab` for syllabus.
6. **Next** — K8/Helm/Terraform/Argo evidence in ops-lab; portfolio documents, does not duplicate prod infra.""",
    )
    w(
        "platform-thinking/future-vision.md",
        """# Future vision

- **Platform anchor:** CXR Claim Studio + analyzer + observe stack as the portfolio story.
- **Capstone patterns** (study plan L304): SLO/alert, idempotency, GitOps, eval hooks — applied as lenses on CXR, not separate toy apps.
- **Publication:** private portfolio repo → populate all outline sections → pin + resume when reviewer fast-path is Complete.

See [platform-model/platform-roadmap.md](./platform-model/platform-roadmap.md).""",
    )

    journey = {
        "v1-monolith.md": ("v1 — Subprocess / monolith path", "Analyze via spawned Python per HTTP request. Simple mental model; terrible p95 under load."),
        "v2-observability.md": ("v2 — Observability", "OTel on Next.js + Python; Jaeger at :16686; discovered import/init dominance."),
        "v3-load-testing.md": ("v3 — Load testing", "Locust on :8251; correlated p95 with trace waterfalls."),
        "v4-reliability.md": ("v4 — Reliability", "Warm analyzer, runbooks, `cxr` CLI, incidents INC-001–003."),
        "future-state.md": ("Future state", "K8 lab, Helm, Terraform, Argo; optional in-cluster OTel env."),
    }
    for fn, (title, body) in journey.items():
        w(f"platform-thinking/architecture-journey/{fn}", f"# {title}\n\n{body}\n\nEvidence: [observability/latency-investigation.md](../../observability/latency-investigation.md) · [reliability/incidents/](../../reliability/incidents/)")

    for fn, title, body in [
        ("users.md", "Users", "Claims analysts and engineers using Claim Studio on :8251."),
        ("operators.md", "Operators", "Engineers running `cxr up`, Jaeger, Locust, optional `cxr lab`."),
        ("dependencies.md", "Dependencies", "SQL, Qdrant, LLM, OTLP, Jaeger — see [architecture/dependency-map.md](../../architecture/dependency-map.md)."),
        ("service-boundaries.md", "Service boundaries", "Browser → Next.js (`cxr-ui-rehearsal`) → analyzer (`cxr-analyzer-service`) → kernel/Python libs."),
        ("platform-roadmap.md", "Platform roadmap", "Populate portfolio → K8 evidence (SW.3–8) → optional M1.1 Solutions Atlas (deferred)."),
    ]:
        w(f"platform-thinking/platform-model/{fn}", f"# {title}\n\n{body}")

    # Observability extras
    w(
        "observability/prometheus.md",
        """# Prometheus

Part of **`cxr-ops-lab` observe compose** (with Jaeger, Grafana).

| URL | Role |
|-----|------|
| http://localhost:9090 | Prometheus UI |

Wiring: `observe/prometheus.yml` scrapes configured targets (including compose :3000 when enabled).

Start: `cxr up` or `./scripts/07-observe-up.sh` in ops-lab.

See [observability-overview.md](./observability-overview.md) · companion `cxr-ops-lab/docs/OBSERVE-WIRING.md`.""",
    )
    w(
        "observability/grafana.md",
        """# Grafana

| URL | Role |
|-----|------|
| http://localhost:3001 | Grafana (bootcamp dashboards) |

Provisioning: `cxr-ops-lab/observe/grafana/provisioning/` (datasources + dashboards).

Use during Locust runs alongside Jaeger (:16686).

See [load-testing-results.md](./load-testing-results.md).""",
    )
    w(
        "observability/promql-examples.md",
        """# PromQL examples (bootcamp)

```promql
# Example: scrape-up (adjust job name to your prometheus.yml)
up{job="cxr-ui"}
```

Add project-specific queries here when you export dashboard JSON into [dashboards/](./dashboards/).

Evidence path: `cxr-ops-lab/evidence/SW11-otel-verify-*.md`.""",
    )
    w(
        "observability/dashboards/README.md",
        """# Dashboards

Export Grafana dashboard JSON from bootcamp runs into this folder.

Until exported, use live Grafana at http://localhost:3001 after `cxr up`.""",
    )

    # Reliability
    w(
        "reliability/slos-and-slis.md",
        """# SLOs and SLIs (local dev)

| SLI | Target (dev) | How measured |
|-----|--------------|--------------|
| Warm analyze latency | p95 < 5s | Locust + Jaeger |
| Trace completeness | ~21 spans on steady POST | Jaeger waterfall |
| Analyzer availability | `/health` warmed | curl :8766 |

Formal production SLOs are **not** claimed in this portfolio; document here when bootcamp SLO lab is evidenced.""",
    )
    w(
        "reliability/service-health.md",
        """# Service health

| Service | Check |
|---------|--------|
| Claim Studio | http://127.0.0.1:8251/claim-studio |
| Analyzer | `curl http://127.0.0.1:8766/health` |
| Jaeger | http://127.0.0.1:16686 |
| OTLP | http://127.0.0.1:4318 (collector) |

`~/staging/cxr-dev.sh status` aggregates process state.""",
    )
    w(
        "reliability/risk-register.md",
        """# Risk register

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|------------|--------|------------|
| R1 | Subprocess fallback reintroduced | Med | High p95 | ADR-004; check `analyzer_mode` |
| R2 | Qdrant optional down | High | Low–Med | WARN documented; retrieval degraded |
| R3 | Trace profile “minimal” | Low | High debug cost | Default `detailed` |
| R4 | Docker observe hang | Med | No traces | Restart Docker; `cxr down --observe-down` |""",
    )

    split_incident(
        "INC-001-high-latency",
        "INC-001 — High API latency",
        "Locust showed p95 ~10–12s on analyze API.",
        "Per-request Python subprocess re-imported heavy deps; not Next.js alone.",
        "Warm analyzer on :8766; `ANALYZER_URL`; re-run Locust.",
    )
    split_incident(
        "INC-002-jaeger-trace-ux",
        "INC-002 — Jaeger trace UX",
        "Minimal trace profile attempted after OTel enable.",
        "`CXR_TRACE_PROFILE=minimal` collapsed spans; ~7 ops; lost startup visibility.",
        "Default `detailed`; `flush_tracing()` after analyzer lifespan.",
        "See [jaeger.md](../../observability/jaeger.md).",
    )
    split_incident(
        "INC-003-python-import-bottleneck",
        "INC-003 — Python import bottleneck",
        "Wall clock >> kernel spans in Jaeger.",
        "Subprocess per request paid ~7–8s import + `corrector.initialize`.",
        "FastAPI analyzer :8766; W3C propagation; ~21 spans warm path.",
        "See [ADR-004](../../adrs/ADR-004-long-running-analyzer.md).",
    )

    w(
        "reliability/runbooks/restart-stack.md",
        (ROOT / "operations/restart-stack.md").read_text(encoding="utf-8"),
    )
    w(
        "reliability/runbooks/qdrant-down.md",
        """# Runbook — Qdrant down

## Symptom

Logs: Qdrant connection refused :6333.

## Impact

Retrieval/policy anchor features degraded; warm analyze may still return 200.

## Action

Start Qdrant if needed for RAG demos; otherwise ignore for latency-only work.""",
    )
    w(
        "reliability/runbooks/ollama-down.md",
        """# Runbook — Ollama / LLM down

## Symptom

Policy recommendation or LLM step fails.

## Action

Start local Ollama or configure API keys per env; Compliant-only paths may not need LLM.""",
    )

    chaos = {
        "EXP-001-qdrant-failure.md": "Stop Qdrant container; verify analyze behavior and logs.",
        "EXP-002-ollama-failure.md": "Stop LLM; verify recommendation path errors gracefully.",
        "EXP-003-network-latency.md": "Inject latency (tc/compose) between UI and analyzer.",
        "EXP-004-container-kill-test.md": "Kill analyzer pod/container; verify recovery via `cxr up`.",
        "game-day.md": "Combine failures; document in postmortem template.",
    }
    for fn, step in chaos.items():
        w(
            f"reliability/chaos-experiments/{fn}",
            f"# {fn.replace('.md', '').replace('-', ' ')}\n\n**Status:** Planned — run before marking Complete.\n\n## Procedure (draft)\n\n{step}\n\n## Record results in\n\n`cxr-ops-lab/evidence/` and link here.",
        )

    # Operations
    w(
        "operations/github-actions.md",
        """# GitHub Actions

Canonical bootcamp CI on **`cxr-ui-rehearsal`**:

- SW.6 — build
- SW.6a — Playwright smoke
- SW.7 — Trivy policy scan

Workflow: `.github/workflows/ci.yml` in the UI repo.

This portfolio repo is **documentation**; CI YAML stays with application code.""",
    )
    w(
        "operations/deployment-strategy.md",
        """# Deployment strategy

| Layer | Path | Purpose |
|-------|------|---------|
| Daily dev | `:8251` + `:8766` | Claim Studio + warm analyzer |
| Compose | `:3000` SW.2 | Full stack with mounts |
| K8 lab | `:8081` port-forward | SW.3 image in kind |
| GitOps | Argo + Helm | SW.8 (planned evidence) |

See [docker.md](./docker.md) · [kubernetes/](./kubernetes/).""",
    )
    w(
        "operations/scaling-strategy.md",
        """# Scaling strategy

- **Analyzer:** scale replicas only after single warm instance p95 is understood; bottleneck was import-not-CPU.
- **UI:** Next.js dev is single-process; production K8 uses Helm `replicaCount`.
- **Load tests:** Locust users ↑ until p95 degrades; use Jaeger to see kernel vs queue time.""",
    )
    w(
        "operations/capacity-planning.md",
        """# Capacity planning

Local Locust runs established that **process spawn + import** dominated before warm analyzer.

Document CPU/memory per analyzer instance here after K8 load tests.""",
    )
    w(
        "operations/cost-analysis.md",
        """# Cost analysis

Bootcamp stack is **local-first** (Docker, kind). Cloud cost notes apply when Terraform targets a cloud cluster — see [terraform/infrastructure-overview.md](./terraform/infrastructure-overview.md).""",
    )
    w(
        "operations/backup-and-recovery.md",
        """# Backup and recovery

- **SQL / archetypes:** production backup policies are out of portfolio scope.
- **Dev artifacts:** claim-studio paths and `public/commons/cases` per env — copy before destructive tests.
- **Observe data:** Jaeger/Prometheus volumes in ops-lab compose; ephemeral for labs.""",
    )
    w(
        "operations/disaster-recovery.md",
        """# Disaster recovery

For local lab: `cxr down --observe-down` then `cxr up`; rebuild kind with `cxr-ops-lab/scripts/01-kind-cluster.sh` if cluster corrupt.

Production DR is not documented in this private portfolio.""",
    )
    w(
        "operations/kubernetes/autoscaling-notes.md",
        """# Kubernetes autoscaling notes

Helm chart: `cxr-ops-lab/helm/cxr-ui` — tune `replicaCount` and resources in `values.yaml`.

HPA requires metrics server and realistic requests/limits — add evidence after SW.3+ load tests.""",
    )

    # Security
    for fn, body in [
        ("security-architecture.md", "Local dev: secrets in `.env.local` (not committed); Vault lab optional via `cxr lab up vault`."),
        ("secrets-management.md", "Never commit `.env`, keys, or tokens. Bootcamp Vault uses dev token on :8200."),
        ("data-lifecycle.md", "Portfolio uses **synthetic** claims only. See [DISCLAIMER.md](../DISCLAIMER.md)."),
        ("risk-assessment.md", "Primary risks: accidental secret commit, treating lab stack as production."),
        ("dependency-scanning.md", "SW.7 Trivy in UI CI; evidence in `cxr-ops-lab/evidence/SW7-trivy-verify.md`."),
    ]:
        w(f"security-compliance/{fn}", f"# {fn.replace('.md', '').replace('-', ' ').title()}\n\n{body}")

    # ADRs
    w(
        "adrs/ADR-005-kubernetes-roadmap.md",
        """# ADR-005 — Kubernetes roadmap (bootcamp)

## Status

Accepted for **lab** path; not production CXR infra.

## Context

Syllabus SW.3–SW.8: kind cluster, Helm chart, Terraform for reproducibility, Argo CD GitOps.

## Decision

- Deploy SW.1 image to `cxr-lab` via `cxr-ops-lab/k8s` + Helm.
- SQL/Qdrant may stay **out of cluster** for bootcamp.
- Daily dev remains :8251 rehearsal unless user pivots.

## Consequences

- Portfolio references `operations/kubernetes/` copies; canonical YAML in `cxr-ops-lab`.""",
    )
    w(
        "adrs/ADR-006-monolith-vs-microservices.md",
        """# ADR-006 — Monolith vs microservices (CXR dev)

## Status

Accepted for current portfolio scope.

## Decision

- **Monolith UI + warm analyzer service** for dev and evidence (not full platform gateway spine in daily path).
- Optional platform containers (gateway, analysis, kernel) documented in C4 Level 2 as **when deployed**, not required for Jaeger/latency story.

## Consequences

- Simpler reviewer path; microservice split deferred to K8/GitOps milestones.""",
    )

    # Demo
    w(
        "demo/README.md",
        """# Demo

Technical reviewers: start with **[RUN.md](./RUN.md)**.

Walkthroughs:

- [submit-claim.md](./walkthrough/submit-claim.md)
- [trace-request.md](./walkthrough/trace-request.md)
- [investigate-latency.md](./walkthrough/investigate-latency.md)

Single-clone `docker-compose.yml` — planned; today use `cxr up` in ops-lab.""",
    )
    w(
        "demo/walkthrough/submit-claim.md",
        """# Walkthrough — submit claim

1. `cxr up`
2. Open http://127.0.0.1:8251/claim-studio
3. Paste or load synthetic claim JSON from [sample-data/claims.json](../sample-data/claims.json)
4. Submit for analysis

Next: [trace-request.md](./trace-request.md).""",
    )
    w(
        "demo/walkthrough/investigate-latency.md",
        """# Walkthrough — investigate latency

1. Run Locust at http://127.0.0.1:8089 (swarm :8251)
2. Open Jaeger http://127.0.0.1:16686
3. Service `cxr-ui-rehearsal` → `POST /api/claim-studio/analyze`
4. Compare `analyzer_service.startup` (once) vs `context_builder` (steady)

Full write-up: [latency-investigation.md](../../observability/latency-investigation.md).""",
    )

    # Templates
    w(
        "templates/how-to-use-templates.md",
        """# How to use templates

1. Copy `incident-template.md` or `postmortem-template.md` into `reliability/incidents/INC-NNN-*/`.
2. Copy `runbook-template.md` into `reliability/runbooks/`.
3. Copy `adr-template.md` into `adrs/`.
4. Use `chaos-test-template.md` before marking chaos experiments Complete.""",
    )
    for t in ["incident-template.md", "runbook-template.md", "chaos-test-template.md", "risk-register-template.md"]:
        p = ROOT / "templates" / t
        if p.exists() and "Scaffold (portfolio outline)" in p.read_text(encoding="utf-8"):
            base = p.read_text(encoding="utf-8").split("## What will go here")[0]
            p.write_text(base + "## What will go here\n\nSee `postmortem-template.md` / `adr-template.md` for starting content.\n", encoding="utf-8")

    # Archive readmes
    for d, note in [
        ("linux-notes", "Linux setup notes for CXR dev host."),
        ("networking-notes", "Ports, OTLP, Jaeger wiring."),
        ("weekly-journal", "Weekly engineering journal entries."),
        ("learning-notes", "Bootcamp and study notes."),
        ("old-experiments", "Superseded experiments — link to incidents instead when possible."),
    ]:
        w(f"archive/{d}/README.md", f"# {d}\n\n{note}\n\nOptional personal archive; not required for portfolio reviewers.")

    w(
        "architecture/diagrams/README.md",
        """# Architecture diagrams

Add PNG exports here (same names as outline):

- `c4-context.png`
- `c4-container.png`
- `c4-component.png`
- `request-flow.png`
- `dependency-map.png`
- `blast-radius-map.png`

Markdown sources live in [../](../) until exported from vault or draw.io.""",
    )

    print("populate complete")


if __name__ == "__main__":
    main()
