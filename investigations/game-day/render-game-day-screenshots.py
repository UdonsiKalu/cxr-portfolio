#!/usr/bin/env python3
"""Render Game day CSV + terminal dumps into multiple PNG screenshots (Chrome headless)."""
from __future__ import annotations

import csv
import html
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "results"
SHOTS = HERE / "screenshots"
HTML_DIR = HERE / "html"
CSV_PATH = OUT / "game-day-probes.csv"
SUMMARY = OUT / "game-day-summary.txt"
TIMELINE = OUT / "game-day-timeline.log"

SHOTS.mkdir(exist_ok=True)
HTML_DIR.mkdir(exist_ok=True)

SCENARIO_TITLES = {
    "S0": "Baseline — everything healthy",
    "S1": "S1 — Analyzer down (kill :8766)",
    "S2": "S2 — SQL unreachable (:1433 blocked)",
    "S3": "S3 — Ollama down",
    "S4": "S4 — CPU starvation",
    "S5": "Final — stack recovered",
}


def chrome_shot(html_path: Path, png_path: Path, width: int = 980, height: int = 720) -> None:
    chrome = "google-chrome"
    subprocess.run(
        [
            chrome,
            "--headless=new",
            "--disable-gpu",
            f"--window-size={width},{height}",
            f"--screenshot={png_path}",
            html_path.as_uri(),
        ],
        check=True,
        capture_output=True,
    )


def page(title: str, body: str) -> str:
    return f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>{html.escape(title)}</title>
<style>
body {{ font-family: ui-sans-serif, system-ui, sans-serif; margin: 28px; background: #0f1419; color: #e7ecf1; }}
h1 {{ font-size: 22px; margin: 0 0 8px; }}
p.sub {{ color: #9aa7b5; margin: 0 0 18px; font-size: 13px; }}
table {{ border-collapse: collapse; width: 100%; font-size: 13px; }}
th, td {{ border: 1px solid #2a3540; padding: 8px 10px; text-align: left; }}
th {{ background: #1a2330; }}
tr:nth-child(even) {{ background: #151c25; }}
.ok {{ color: #3dd68c; font-weight: 600; }}
.bad {{ color: #ff6b6b; font-weight: 600; }}
.slow {{ color: #ffd166; font-weight: 600; }}
pre {{ background: #151c25; border: 1px solid #2a3540; padding: 14px; overflow: auto;
       font-size: 11px; line-height: 1.35; white-space: pre-wrap; }}
.badge {{ display: inline-block; padding: 2px 8px; border-radius: 4px; background: #243044; font-size: 12px; }}
</style></head><body>
<h1>{html.escape(title)}</h1>
<p class="sub">CXR Game day · local lab · synthetic data</p>
{body}
</body></html>"""


def status_class(check: str, status: str) -> str:
    s = status.lower()
    if check == "A1_analyze":
        if s.startswith("2"):
            return "ok"
        return "bad"
    if check == "A2_health":
        return "ok" if s.startswith("2") else "bad"
    if check == "A3_sql":
        return "ok" if s == "open" else "bad"
    if check == "ollama":
        return "ok" if s == "up" else "bad"
    if check == "alert_probes_rc":
        return "ok" if s == "0" else "bad"
    return ""


def main() -> None:
    rows = list(csv.DictReader(CSV_PATH.open()))

    # 1) Overview matrix
    body_rows = []
    for r in rows:
        if r["check"] not in ("A1_analyze", "A2_health", "A3_sql", "ollama"):
            continue
        cls = status_class(r["check"], r["http_or_status"])
        body_rows.append(
            "<tr>"
            f"<td>{html.escape(r['scenario'])}</td>"
            f"<td>{html.escape(r['phase'])}</td>"
            f"<td>{html.escape(r['check'])}</td>"
            f"<td class='{cls}'>{html.escape(r['http_or_status'])}</td>"
            f"<td>{html.escape(r['ms'])}</td>"
            f"<td>{html.escape(r['note'])}</td>"
            "</tr>"
        )
    overview = page(
        "Game day — all probes overview",
        "<table><thead><tr><th>Scenario</th><th>Phase</th><th>Check</th>"
        "<th>Status</th><th>ms</th><th>Note</th></tr></thead><tbody>"
        + "".join(body_rows)
        + "</tbody></table>",
    )
    p = HTML_DIR / "overview.html"
    p.write_text(overview)
    chrome_shot(p, SHOTS / "00-overview-matrix.png", 1100, 900)

    # 2) Per-scenario mid_outage cards
    for scen, title in SCENARIO_TITLES.items():
        subset = [r for r in rows if r["scenario"] == scen]
        if not subset:
            continue
        mid = [r for r in subset if r["phase"] == "mid_outage"]
        focus = mid if mid else subset
        trs = []
        for r in focus:
            cls = status_class(r["check"], r["http_or_status"])
            trs.append(
                "<tr>"
                f"<td>{html.escape(r['phase'])}</td>"
                f"<td>{html.escape(r['check'])}</td>"
                f"<td class='{cls}'>{html.escape(r['http_or_status'])}</td>"
                f"<td>{html.escape(r['ms'])} ms</td>"
                f"<td>{html.escape(r['note'])}</td>"
                "</tr>"
            )
        alert_txt = OUT / f"alert-probes-{scen}-mid_outage.txt"
        if not alert_txt.exists():
            # baseline / recovered naming
            for phase in ("baseline", "recovered", "final", "mid_outage"):
                cand = OUT / f"alert-probes-{scen}-{phase}.txt"
                if cand.exists():
                    alert_txt = cand
                    break
        pre = ""
        if alert_txt.exists():
            pre = f"<h2 style='font-size:16px;margin-top:18px'>Alert probes output</h2><pre>{html.escape(alert_txt.read_text()[:2500])}</pre>"
        hp = HTML_DIR / f"{scen}.html"
        hp.write_text(
            page(
                title,
                "<table><thead><tr><th>Phase</th><th>Check</th><th>Status</th><th>Latency</th><th>Note</th></tr></thead>"
                f"<tbody>{''.join(trs)}</tbody></table>{pre}",
            )
        )
        chrome_shot(hp, SHOTS / f"{scen.lower()}-card.png", 980, 780)

    # 3) Summary + timeline terminal-style
    if SUMMARY.exists():
        hp = HTML_DIR / "summary.html"
        hp.write_text(page("Game day — summary (terminal)", f"<pre>{html.escape(SUMMARY.read_text())}</pre>"))
        chrome_shot(hp, SHOTS / "terminal-summary.png", 1000, 900)
    if TIMELINE.exists():
        hp = HTML_DIR / "timeline.html"
        hp.write_text(page("Game day — timeline log", f"<pre>{html.escape(TIMELINE.read_text())}</pre>"))
        chrome_shot(hp, SHOTS / "terminal-timeline.png", 1000, 1100)

    # 4) Analyze HTTP codes bar-ish table for mid outages only
    mid_analyze = [r for r in rows if r["check"] == "A1_analyze" and r["phase"] in ("baseline", "mid_outage", "recovered", "final")]
    trs = []
    for r in mid_analyze:
        cls = status_class("A1_analyze", r["http_or_status"])
        trs.append(
            f"<tr><td>{html.escape(r['scenario'])}</td><td>{html.escape(r['phase'])}</td>"
            f"<td class='{cls}'>{html.escape(r['http_or_status'])}</td>"
            f"<td>{html.escape(r['ms'])}</td><td>{html.escape(r['note'])}</td></tr>"
        )
    hp = HTML_DIR / "analyze-path.html"
    hp.write_text(
        page(
            "Game day — Analyze path (A1) across scenarios",
            "<table><thead><tr><th>Scenario</th><th>Phase</th><th>HTTP</th><th>ms</th><th>Note</th></tr></thead>"
            f"<tbody>{''.join(trs)}</tbody></table>",
        )
    )
    chrome_shot(hp, SHOTS / "analyze-across-scenarios.png", 980, 720)

    print("Wrote screenshots to", SHOTS)
    for p in sorted(SHOTS.glob("*.png")):
        print(" ", p.name)


if __name__ == "__main__":
    main()
