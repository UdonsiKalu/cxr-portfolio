# Terraform — infrastructure overview

**Status:** Reference — Kind cluster provisioner in companion **`cxr-ops-lab`**.

Local lab Terraform uses `null_resource` + `01-kind-cluster.sh`; not cloud IaC for production.

- Annotated copies: [main.tf](./main.tf), [variables.tf](./variables.tf)
- Deploy path: `cxr-ops-lab/scripts/03-k8-up.sh`
