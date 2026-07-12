#!/usr/bin/env python3
"""Busy-loop CPU hog for CHAOS-004. Usage: cpu_hog.py <workers> <pidfile>"""
from __future__ import annotations

import os
import signal
import sys
import time


def burn() -> None:
    x = 0
    while True:
        x = (x * 1103515245 + 12345) & 0x7FFFFFFF
        x ^= (x << 13) & 0x7FFFFFFF


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <workers> <pidfile>", file=sys.stderr)
        return 2
    n = int(sys.argv[1])
    pidfile = sys.argv[2]
    children: list[int] = []

    def shutdown(_signum=None, _frame=None) -> None:
        for c in children:
            try:
                os.kill(c, signal.SIGKILL)
            except OSError:
                pass
        raise SystemExit(0)

    signal.signal(signal.SIGTERM, shutdown)
    signal.signal(signal.SIGINT, shutdown)

    # Ensure we are a session/process-group leader when not launched via setsid.
    try:
        os.setsid()
    except OSError:
        pass

    for _ in range(n):
        pid = os.fork()
        if pid == 0:
            signal.signal(signal.SIGTERM, signal.SIG_DFL)
            burn()
            os._exit(0)
        children.append(pid)

    # Parent keeps pidfile; do not unlink on signal (bash stop_hog owns cleanup).
    with open(pidfile, "w", encoding="utf-8") as f:
        f.write(f"{os.getpid()}\n")
        for c in children:
            f.write(f"{c}\n")

    while True:
        time.sleep(60)


if __name__ == "__main__":
    raise SystemExit(main())
