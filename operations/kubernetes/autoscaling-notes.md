# Kubernetes autoscaling notes

Helm chart: `cxr-ops-lab/helm/cxr-ui` — tune `replicaCount` and resources in `values.yaml`.

HPA requires metrics server and realistic requests/limits — add evidence after SW.3+ load tests.
