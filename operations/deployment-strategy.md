# Deployment strategy

| Layer | Path | Purpose |
|-------|------|---------|
| Daily dev | `:8251` + `:8766` | Claim Studio + warm analyzer |
| Compose | `:3000` SW.2 | Full stack with mounts |
| K8 lab | `:8081` port-forward | SW.3 image in kind |
| GitOps | Argo + Helm | SW.8 (planned evidence) |

See [docker.md](./docker.md) · [kubernetes/](./kubernetes/).
