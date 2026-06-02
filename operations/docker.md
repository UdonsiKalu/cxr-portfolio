# Docker in CXR platform work

## Observe stack (daily)

`compose.observe.yaml` in **cxr-ops-lab**:

- Jaeger **16686**
- OTel Collector **4318**
- Prometheus **9090**
- Grafana **3001**

Started via `cxr up` or `./scripts/07-observe-up.sh`.

## CXR UI in Docker (:3000)

Separate path: `04-compose-up.sh` mounts analyzers for containerized Claim Studio. Used for SW.2 bootcamp verify—not the same as **:8251** host dev.

## Optional labs

See [bootcamp-labs.md](../archive/learning-notes/bootcamp-labs.md).

## Lessons

Docker Desktop health affects Jaeger responsiveness; document restart procedures when `docker ps` hangs.
