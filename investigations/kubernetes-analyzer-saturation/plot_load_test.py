#!/usr/bin/env python3
"""Plot autoscaling + saturation charts from collect_load_metrics.py CSV."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import matplotlib.pyplot as plt
    import pandas as pd
except ImportError:
    print("Install: pip install pandas matplotlib", file=sys.stderr)
    raise SystemExit(1)


def load_csv(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    if "elapsed_s" not in df.columns:
        raise ValueError(f"Missing elapsed_s in {path}")
    return df


def plot_run(df: pd.DataFrame, out_dir: Path, title: str) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    t = df["elapsed_s"]

    fig, axes = plt.subplots(4, 1, figsize=(12, 14), sharex=True)
    fig.suptitle(title, fontsize=14)

    # 1 — load + throughput
    ax = axes[0]
    ax.plot(t, df["locust_users"], label="Users", color="#2563eb", linewidth=2)
    ax.set_ylabel("Users")
    ax2 = ax.twinx()
    ax2.plot(t, df["locust_rps"], label="RPS", color="#16a34a", linewidth=2)
    ax2.set_ylabel("RPS")
    ax.set_title("Load vs throughput")
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

    # 2 — latency
    ax = axes[1]
    ax.plot(t, df["locust_p50_ms"], label="p50", color="#ca8a04")
    ax.plot(t, df["locust_p95_ms"], label="p95", color="#dc2626", linewidth=2)
    ax.set_ylabel("ms")
    ax.set_title("Response time (Locust client)")
    ax.legend(loc="upper left")
    if df["locust_failures_per_s"].max() > 0:
        ax.axhline(0, color="gray", linewidth=0.5)

    # 3 — HPA CPU + replicas
    ax = axes[2]
    ax.plot(t, df["hpa_analyzer_current_cpu_pct"], label="analyzer CPU % (HPA)", color="#7c3aed")
    ax.plot(
        t,
        df["hpa_analyzer_target_cpu_pct"],
        label="analyzer target %",
        color="#7c3aed",
        linestyle="--",
        alpha=0.6,
    )
    ax.plot(t, df["hpa_ui_current_cpu_pct"], label="ui CPU % (HPA)", color="#0891b2")
    ax.set_ylabel("CPU %")
    ax2 = ax.twinx()
    ax2.plot(t, df["analyzer_replicas"], label="analyzer replicas", color="#9333ea", linewidth=2)
    ax2.plot(t, df["ui_replicas"], label="ui replicas", color="#0e7490", linewidth=2)
    ax2.set_ylabel("Replicas")
    ax.set_title("HPA signals + replica count")
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

    # 4 — node + pending
    ax = axes[3]
    ax.plot(t, df["node_cpu_pct"], label="node CPU %", color="#b45309")
    ax.plot(t, df["node_memory_pct"], label="node memory %", color="#be123c")
    ax.set_ylabel("Node %")
    ax2 = ax.twinx()
    ax2.bar(t, df["analyzer_pending_pods"], width=3, alpha=0.4, label="analyzer pending", color="#ef4444")
    ax2.set_ylabel("Pending pods")
    ax.set_xlabel("Elapsed (s)")
    ax.set_title("Node capacity + scheduling pressure")
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

    fig.tight_layout()
    png = out_dir / "load-test-autoscaling.png"
    fig.savefig(png, dpi=150)
    plt.close(fig)
    print(f"Wrote {png}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv", type=Path, help="Metrics CSV from collect_load_metrics.py")
    parser.add_argument(
        "--output-dir",
        "-o",
        type=Path,
        default=Path("results/charts"),
        help="Directory for PNG output",
    )
    parser.add_argument("--title", default="LOAD-003 — K8 HPA autoscale (cxr-ui namespace)")
    args = parser.parse_args()

    if not args.csv.exists():
        print(f"Missing {args.csv}", file=sys.stderr)
        return 1

    df = load_csv(args.csv)
    plot_run(df, args.output_dir, args.title)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
