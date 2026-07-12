# Game day — Runbook

## Prereq

- UI `:8251`, warm analyzer `:8766`, SQL `:1433`, Ollama (for S3)
- Passwordless sudo for `iptables` and `systemctl` ollama

## Run

```bash
cd ~/staging/cxr-portfolio
./investigations/game-day/run-game-day.sh
python3 ./investigations/game-day/render-game-day-screenshots.py
```

Skip optional legs:

```bash
CXR_GAME_DAY_SKIP_CPU=1 CXR_GAME_DAY_SKIP_OLLAMA=1 ./investigations/game-day/run-game-day.sh
```

## Outputs

| Path | Role |
|------|------|
| `results/game-day-probes.csv` | All checks |
| `results/game-day-summary.txt` | Readable summary |
| `results/game-day-timeline.log` | Timeline |
| `results/alert-probes-*.txt` | OBS-003 one-shots |
| `screenshots/*.png` | Portfolio pictures |

## Scenarios

1. **S0** baseline  
2. **S1** kill `:8766` → restart warm analyzer  
3. **S2** iptables REJECT `:1433` → unblock  
4. **S3** stop Ollama → start  
5. **S4** CPU hog (CHAOS-004) → stop  
6. **S5** final healthy check  

Cleanup trap always tries to unblock SQL, start Ollama, restart analyzer.
