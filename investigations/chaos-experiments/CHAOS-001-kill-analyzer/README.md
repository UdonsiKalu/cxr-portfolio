# CHAOS-001 — Kill analyzer

**Status:** Planned (Phase 1)

## Question

What happens when the analyzer process dies during or between analyze requests?

## Method (draft)

1. Start stack: `cxr up`
2. Run Locust swarm (3–5 users) against `POST /api/claim-studio/analyze`
3. Kill analyzer process (or stop :8766 container)
4. Observe Locust errors, UI behavior, logs
5. Restart analyzer; measure time to recovery

## Related

Recovery framing: [REL-003 — analyzer crash](../../reliability/REL-003-analyzer-crash/) (same run, document both).

## Record results in

Folder `screenshots/` here and update this README when run.
