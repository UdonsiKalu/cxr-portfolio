# CHAOS-001 — Kill analyzer

**Status:** Planned

## Question

What happens when the analyzer process dies during or between analyze requests?

## Method (draft)

Kill analyzer pod/container; verify recovery via `cxr up`.

## Record results in

`cxr-ops-lab/evidence/` and update this file when run.
