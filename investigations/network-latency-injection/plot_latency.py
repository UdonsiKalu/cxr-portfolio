#!/usr/bin/env python3
"""Bar chart: median Analyze ms by phase from network-latency-probes.csv."""
from __future__ import annotations

import csv
import statistics
from pathlib import Path

HERE = Path(__file__).resolve().parent
CSV = HERE / "results" / "network-latency-probes.csv"
OUT = HERE / "screenshots" / "latency-by-tier.png"


def main() -> int:
    rows = list(csv.DictReader(CSV.open()))
    order = ["baseline", "latency-100", "latency-500", "latency-2000", "recovery"]
    labels, medians, delays = [], [], []
    for phase in order:
        phase_rows = [r for r in rows if r["phase"] == phase]
        ms = [int(r["ms"]) for r in phase_rows]
        if not ms:
            continue
        labels.append(phase)
        medians.append(statistics.median(ms))
        delays.append(int(phase_rows[0]["delay_ms"]))

    try:
        import matplotlib.pyplot as plt
    except ImportError:
        # Fallback SVG-free: write a simple text table PNG via PIL if available
        raise SystemExit("matplotlib required for chart")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(8, 4.5))
    colors = ["#4a7c59", "#c4a35a", "#d97706", "#b45309", "#4a7c59"]
    bars = ax.bar(labels, [m / 1000 for m in medians], color=colors[: len(labels)])
    ax.set_ylabel("Analyze median (seconds)")
    ax.set_title("CHAOS-002 — Analyze latency by injected network delay")
    ax.set_xlabel("Phase (injected delay on UI→analyzer hop)")
    for bar, m, d in zip(bars, medians, delays):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height(),
            f"{m/1000:.1f}s\n(+{d}ms)",
            ha="center",
            va="bottom",
            fontsize=8,
        )
    fig.tight_layout()
    fig.savefig(OUT, dpi=140)
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
