#!/usr/bin/env python3
"""Create or refresh notebook.ipynb from README.md for CXR investigations."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INV = ROOT / "investigations"

# Main study folders (not screenshots/)
STUDY_DIRS = [
    "latency-investigation",
    "load-testing",
    "missing-spans",
    "postmortems",
    "cold-vs-warm-analyzer",
    "single-analyzer-capacity",
    "analyzer-saturation",
    "kill-analyzer-under-traffic",
    "qdrant-outage",
    "trace-propagation",
    "ci-pipeline",
    "kubernetes-deploy",
    "planned",
]

LINK_RE = re.compile(r"\]\(([^)#\s]+)\)")


def notebook_links(text: str) -> str:
    """Prefer notebook.ipynb over README.md in markdown links."""

    def repl(match: re.Match[str]) -> str:
        url = match.group(1)
        if url.endswith("/README.md"):
            return f"]({url[:-len('README.md')]}notebook.ipynb)"
        if url.endswith("README.md"):
            return f"]({url[:-len('README.md')]}notebook.ipynb)"
        return match.group(0)

    return LINK_RE.sub(repl, text)


def nav_cell(links: list[tuple[str, str]]) -> list[str]:
    items = "".join(
        f'    <li><a href="{href}"><b>{label}</b></a></li>\n' for label, href in links
    )
    return [
        "<div style=\"background:#eef4ff;border-left:4px solid #0550ae;padding:12px 16px;margin-bottom:16px;\">\n",
        "  <strong>Run this cell (Shift+Enter)</strong> to see blue clickable links.<br/>\n",
        "  Edit <code>.ipynb</code> only — not <code>.md</code>.\n",
        "</div>\n",
        "\n",
        "<div style=\"background:#f6f8fa;padding:12px 16px;border-radius:8px;\">\n",
        "  <h3 style=\"margin-top:0;\">🔗 Navigation</h3>\n",
        "  <ul>\n",
        items,
        "  </ul>\n",
        "</div>\n",
    ]


NAV = {
    "root": [
        ("Investigation index", "investigations/00-navigation.ipynb"),
        ("HTML index", "investigations/lab-navigation.html"),
    ],
    "investigations_index": [
        ("All investigations", "00-navigation.ipynb"),
        ("HTML index", "lab-navigation.html"),
        ("Portfolio home", "../README.ipynb"),
        ("New study template", "template-investigation.ipynb"),
    ],
    "study": [
        ("All investigations", "../00-navigation.ipynb"),
        ("HTML index", "../lab-navigation.html"),
        ("Portfolio home", "../../README.ipynb"),
        ("Investigations index", "../README.ipynb"),
    ],
    "planned": [
        ("All investigations", "../00-navigation.ipynb"),
        ("Backlog index", "notebook.ipynb"),
        ("Portfolio home", "../../README.ipynb"),
    ],
}


def write_notebook(md_path: Path, nb_path: Path, nav_key: str) -> None:
    text = notebook_links(md_path.read_text(encoding="utf-8"))
    lines = text.splitlines(keepends=True)
    if lines and not lines[-1].endswith("\n"):
        lines[-1] += "\n"

    nb = {
        "cells": [
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": nav_cell(NAV[nav_key]),
            },
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": lines,
            },
        ],
        "metadata": {
            "kernelspec": {
                "display_name": "Python 3",
                "language": "python",
                "name": "python3",
            },
            "language_info": {"name": "python"},
        },
        "nbformat": 4,
        "nbformat_minor": 5,
    }
    nb_path.write_text(json.dumps(nb, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"  wrote {nb_path.relative_to(ROOT)}")


def main() -> int:
    # portfolio root index
    root_md = ROOT / "README.md"
    if root_md.is_file():
        write_notebook(root_md, ROOT / "README.ipynb", "root")

    idx_md = INV / "README.md"
    if idx_md.is_file():
        write_notebook(idx_md, INV / "README.ipynb", "investigations_index")

    for name in STUDY_DIRS:
        folder = INV / name
        md = folder / "README.md"
        if md.is_file():
            key = "planned" if name == "planned" else "study"
            write_notebook(md, folder / "notebook.ipynb", key)

    planned = INV / "planned"
    for md in sorted(planned.glob("*.md")):
        if md.name == "README.md":
            continue
        write_notebook(md, planned / f"{md.stem}.ipynb", "planned")

    return 0


if __name__ == "__main__":
    sys.exit(main())
