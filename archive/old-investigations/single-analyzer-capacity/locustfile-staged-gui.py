"""
LOAD-001 — staged capacity ramp for Locust **web UI**.

Start Locust with this file, open :8089, click **Start swarming** once.
LoadTestShape drives 1 → 3 → 5 → 10 → 15 users (override via env).

Env:
  CXR_CAPACITY_STAGE_SECONDS  — hold per tier (default 60)
  CXR_CAPACITY_USERS          — space-separated counts (default "1 3 5 10 15")
"""

from __future__ import annotations

import json
import os

from locust import HttpUser, LoadTestShape, between, task

_ANALYZE_BODY = {
    "input": {
        "content": json.dumps(
            {
                "claim_id": os.environ.get("CXR_LOAD_CLAIM_ID", "load-001-capacity"),
                "description": "office visit (staged GUI ramp)",
            }
        )
    }
}

_STAGE_SECONDS = int(os.environ.get("CXR_CAPACITY_STAGE_SECONDS", "60"))
_USER_COUNTS = [
    int(x) for x in os.environ.get("CXR_CAPACITY_USERS", "1 3 5 10 15").split() if x.strip()
]
_SPAWN_RATE = float(os.environ.get("CXR_CAPACITY_SPAWN_RATE", "1"))


def _build_stages() -> list[dict[str, float | int]]:
    stages: list[dict[str, float | int]] = []
    end = 0
    for users in _USER_COUNTS:
        end += _STAGE_SECONDS
        stages.append(
            {
                "duration": end,
                "users": users,
                "spawn_rate": _SPAWN_RATE,
            }
        )
    return stages


class AnalyzeOnlyUser(HttpUser):
    wait_time = between(1, 2)

    @task
    def analyze_claim(self) -> None:
        with self.client.post(
            "/api/claim-studio/analyze",
            json=_ANALYZE_BODY,
            name="POST /api/claim-studio/analyze",
            timeout=120,
            catch_response=True,
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"status {resp.status_code}: {resp.text[:200]}")


class CapacityRampShape(LoadTestShape):
    """Cumulative-duration stages — Locust GUI runs this after one Start click."""

    stages = _build_stages()

    def tick(self):
        run_time = self.get_run_time()
        for stage in self.stages:
            if run_time < stage["duration"]:
                return (stage["users"], stage["spawn_rate"])
        return None
