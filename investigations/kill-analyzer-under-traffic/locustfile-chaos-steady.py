"""CHAOS-001 — steady analyze load for kill-analyzer-under-traffic."""

from __future__ import annotations

import json
import os

from locust import HttpUser, LoadTestShape, between, task

_USERS = int(os.environ.get("CXR_CHAOS_USERS", "5"))
_SPAWN = float(os.environ.get("CXR_CHAOS_SPAWN_RATE", "1"))

_ANALYZE_BODY = {
    "input": {
        "content": json.dumps(
            {
                "claim_id": os.environ.get("CXR_LOAD_CLAIM_ID", "chaos-001-kill-analyzer"),
                "description": "office visit (chaos under traffic)",
            }
        )
    }
}


class AnalyzeOnlyUser(HttpUser):
    wait_time = between(1, 2)

    @task
    def analyze_claim(self) -> None:
        with self.client.post(
            "/api/claim-studio/analyze",
            json=_ANALYZE_BODY,
            name="POST /api/claim-studio/analyze",
            timeout=30,
            catch_response=True,
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"status {resp.status_code}: {resp.text[:200]}")


class SteadyLoadShape(LoadTestShape):
    """Hold fixed user count for entire run."""

    def tick(self):
        return (_USERS, _SPAWN)
