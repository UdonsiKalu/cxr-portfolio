#!/usr/bin/env python3
"""Chart success rate and median OK latency by packet-loss tier."""
from __future__ import annotations

import csv
import statistics
from pathlib import Path

HERE = Path(__file__).resolve().parent
CSV = HERE / "results" / "packet-loss-probes.csv"
OUT = HERE / "screenshots" / "success-by-loss-tier.png"


def main() -> int:
    import matplotlib.pyplot as plt

    rows = list(csv.DictReader(CSV.open()))
    order = ["baseline", "loss-1", "loss-5", "loss-10", "loss-20", "recovery"]
    labels, rates, med_ms = [], [], []
    for phase in order:
        subset = [r for r in rows if r["phase"] == phase]
        if not subset:
            continue
        n = len(subset)
        ok = sum(1 for r in subset if r["http"] == "200")
        labels.append(f"{phase}\n({subset[0]['loss_pct']}%)")
        rates.append(100.0 * ok / n)
        ok_ms = [int(r["ms"]) for r in subset if r["http"] == "200"]
        med_ms.append(statistics.median(ok_ms) if ok_ms else 0)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig, ax1 = plt.subplots(figsize=(9, 4.8))
    bars = ax1.bar(labels, rates, color="#3d6b8c")
    ax1.set_ylabel("Success rate (%)")
    ax1.set_ylim(0, 110)
    ax1.set_title("CHAOS-003 — Analyze success vs injected packet loss")
    for bar, r in zip(bars, rates):
        ax1.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 1, f"{r:.0f}%", ha="center", fontsize=8)
    ax2 = ax1.twinx()
    ax2.plot(range(len(labels)), med_ms, color="#c45c26", marker="o", label="median ms (OK only)")
    ax2.set_ylabel("Median latency ms (successful only)")
    ax2.legend(loc="lower left")
    fig.tight_layout()
    fig.savefig(OUT, dpi=140)
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
