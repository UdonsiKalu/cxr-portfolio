# Game day — for a first-time DevOps learner

**Start here if you are new.** No jargon required.

This folder is a **practice fire drill** for a small claims app (CXR). We purposely break parts of the system, watch what users would feel, then fix each break before the next one.

---

## Words you need (30 seconds)

| Word | Plain meaning |
|------|----------------|
| **Analyze** | The app’s main “check this claim” button / API call |
| **HTTP 200** | “It worked” |
| **HTTP 500** | “It failed on the server” — user sees an error |
| **Health check** | A tiny “are you alive?” ping to a service |
| **Hard failure** | The main user action stops working |
| **Soft failure** | The main action still works; something else is degraded |
| **Game day** | A planned practice outage — like a fire drill for computers |

---

## What we were trying to learn

When something breaks, does the user still get an answer — or do they get an error?

Different broken parts behave differently. That matters for **alerts**: you wake someone up for hard failures; you open a ticket for soft ones.

---

## The tiny system we poked

```text
You / browser
    → Claim Studio UI  (:8251)
        → Analyzer     (:8766)   does the heavy claim work
        → SQL database (:1433)   stores claim data
        → Ollama       (LLM)     optional AI helper
```

We did **not** break everything at once. We broke **one thing**, measured, **fixed it**, then broke the next.

---

## What happened (the story)

### Step 0 — Everything fine (baseline)

Analyze worked. It took about **15 seconds**. That is our “normal.”

![Baseline / overview](screenshots/00-overview-matrix.png)

### Step 1 — We stopped the analyzer

The analyzer’s **health** check failed (it was dead).

But Analyze still returned **200** (success). Why? The UI can sometimes use a **backup path** when the warm analyzer is gone. So the user might not notice — but ops should still care that the main service is down.

**Lesson:** “User still works” ≠ “system is healthy.”

![S1 card](screenshots/s1-card.png)

### Step 2 — We blocked the database (SQL)

Analyze returned **HTTP 500** — failed. Took about **24 seconds** then errored.

**Lesson:** No database → claim analysis **hard fails**. This is a wake-someone-up problem.

![S2 card](screenshots/s2-card.png)

### Step 3 — We stopped Ollama (the LLM)

Analyze still returned **200**. The optional AI piece was down; the main path kept going.

**Lesson:** Soft dependency — ticket, not a full outage page (for this lab).

![S3 card](screenshots/s3-card.png)

### Step 4 — We burned the CPU (made the machine busy)

Analyze still returned **200**, a little slower.

**Lesson:** Busy CPUs hurt **speed**, not “is it up?”

![S4 card](screenshots/s4-card.png)

### Step 5 — Final check

Everything healthy again. Analyze **200**.

![S5 card](screenshots/s5-card.png)

---

## One table to remember

| What we broke | Did Analyze work? | Hard or soft? |
|---------------|-------------------|---------------|
| Analyzer process | Yes (200) but health failed | Soft for user / still serious for ops |
| SQL database | No (500) | **Hard** |
| Ollama | Yes (200) | Soft |
| CPU busy | Yes (200), slower | Soft |

---

## Where to look next

| File | For whom |
|------|----------|
| **This page** (`LEARNER.md`) | First DevOps learner |
| [STUDY.md](./STUDY.md) | Formal study write-up (interview / portfolio) |
| [RESULTS.md](./RESULTS.md) | Short results summary |
| [screenshots/](./screenshots/) | Pictures |
| [results/game-day-probes.csv](./results/game-day-probes.csv) | Exact numbers |

You do **not** need to read the `.sh` scripts to understand the lesson.
