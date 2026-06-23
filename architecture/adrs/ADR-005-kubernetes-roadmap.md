# ADR-005 — Kubernetes roadmap (bootcamp)

## Status

Accepted for **lab** path; not production CXR infra.

## Context

Syllabus SW.3–SW.8: kind cluster, Helm chart, Terraform for reproducibility, Argo CD GitOps.

## Decision

- Deploy SW.1 image to `cxr-lab` via `cxr-ops-lab/k8s` + Helm.
- SQL/Qdrant may stay **out of cluster** for bootcamp.
- Daily dev remains :8251 rehearsal unless user pivots.

## Consequences

- Portfolio references `operations/kubernetes/` copies; canonical YAML in `cxr-ops-lab`.
