# What happened — REL-004 in plain language

**Folder:** `investigations/database-unavailable/`  
**Question:** If the database (SQL Server on port 1433) cannot be reached, what breaks?

---

## One-sentence answer

When SQL is unreachable, **claim analysis fails hard** (HTTP 500). The Claim Studio web pages still load, but you cannot successfully analyze a claim or run the Terminal database check.

---

## What we did

1. Confirmed the stack was healthy (UI, warm analyzer, SQL listening).
2. Ran a normal Analyze + a Terminal “is the DB up?” check — both succeeded.
3. Temporarily blocked port **1433** with firewall rules (we did **not** shut down SQL Server itself).
4. Tried Analyze and the Terminal check again — both failed.
5. Removed the firewall rules — both succeeded again.

Script used: [`run-database-unavailable-check.sh`](./run-database-unavailable-check.sh)

---

## Results in plain English

### Before the outage (SQL reachable)

| Check | What the user would see | Result |
|-------|-------------------------|--------|
| Analyze a simple “office visit” claim | Analysis completes; claim looks **Compliant** | Success (~9 seconds) |
| Terminal database check | “DB is OK” | Success (~0.2 seconds) |

### During the outage (SQL blocked)

| Check | What the user would see | Result |
|-------|-------------------------|--------|
| Analyze the same kind of claim | Error: **Failed to analyze claim** | Failure after ~23 seconds (waiting on a login that never succeeds) |
| Terminal database check | Error: **could not connect** to `127.0.0.1:1433` | Failure almost immediately (~0.05 seconds) |

Under the hood, Analyze hits Microsoft’s ODBC driver error **`HYT00` — Login timeout expired**. That means: “I tried to log in to SQL Server and gave up.”

### After recovery (SQL unblocked)

| Check | Result |
|-------|--------|
| Analyze | Works again (~9 seconds, Compliant) |
| Terminal check | Works again |

No analyzer restart was required for this mid-outage test.

---

## Blast radius (who gets hurt?)

**Hurt (in the blast radius)**

- Anyone running **Analyze** in Claim Studio
- Anyone using **Terminal** database diagnostics
- Any other feature that needs SQL on this host

**Not hurt (outside the blast radius)**

- Opening Claim Studio pages in the browser (the UI shell still loads)
- Ollama / Qdrant (different services; this test did not take them down)

More detail: [README — Blast radius](./README.md#blast-radius)

---

## How this compares to other outages

| If this is down… | Does Compliant Analyze still work? |
|------------------|-------------------------------------|
| Qdrant (vector DB) | Often **yes** (soft / fallback) |
| Ollama (LLM) | Often **yes** (LLM skipped on Compliant claims) |
| **SQL Server** | **No** — hard failure |

So SQL is more critical for day-to-day Analyze than Ollama is.

---

## Where the raw numbers live

| File | What it is |
|------|------------|
| [results/database-unavailable-summary.txt](./results/database-unavailable-summary.txt) | Short machine summary of your run |
| [results/database-unavailable-probes.csv](./results/database-unavailable-probes.csv) | Spreadsheet-friendly rows |
| [results/database-unavailable-timeline.log](./results/database-unavailable-timeline.log) | Timestamped log |
| [results/*.json](./results/) | Full API responses (for debugging) |
| [screenshots/results-table-database-unavailable.png](./screenshots/results-table-database-unavailable.png) | Visual table of the probes |

---

## Bottom line for operations

- Treat SQL as **required** for Analyze readiness — not optional.
- A fast SQL connectivity check (like Terminal diag) is a better early warning than waiting ~20s for Analyze to time out.
- Unblocking the network path restores service quickly in this lab scenario.
