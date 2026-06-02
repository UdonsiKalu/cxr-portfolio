# Tradeoffs

| Decision | Chosen | Alternative | Why |
|----------|--------|-------------|-----|
| Analyze runtime | Warm FastAPI :8766 | Subprocess per request | ~7–8s import/init removed from hot path |
| Trace profile | `detailed` | `minimal` | Fewer confusing Operations; ~21 useful spans |
| Daily UI | :8251 rehearsal | :3000 compose only | Faster iteration + OTel on dev route |
| Qdrant | Optional in dev | Hard dependency | Local laptops may skip vector stack |
| Portfolio repo | Private until ready | Public + scaffolds | Full outline filled before promotion |
