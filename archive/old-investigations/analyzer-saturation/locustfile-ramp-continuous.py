"""
Saturation — continuous user ramp until you stop or hit safety cap.

Every CXR_RAMP_STAGE_SECONDS, add CXR_RAMP_STEP_USERS (default +5).
Watch Locust Charts for failures (red line) or p95 runaway; click Stop when broken.

Env:
  CXR_RAMP_START_USERS     — default 15
  CXR_RAMP_STEP_USERS      — default 5
  CXR_RAMP_STAGE_SECONDS   — default 60
  CXR_RAMP_MAX_USERS       — safety cap (default 300)
  CXR_RAMP_MAX_DURATION    — stop after N seconds (default 7200 = 2h)
  CXR_CAPACITY_SPAWN_RATE  — default 2
"""

from __future__ import annotations

import json
import os

from locust import HttpUser, LoadTestShape, between, task

_START = int(os.environ.get("CXR_RAMP_START_USERS", "15"))
_STEP = int(os.environ.get("CXR_RAMP_STEP_USERS", "5"))
_STAGE_SECONDS = int(os.environ.get("CXR_RAMP_STAGE_SECONDS", "60"))
_MAX_USERS = int(os.environ.get("CXR_RAMP_MAX_USERS", "300"))
_MAX_DURATION = int(os.environ.get("CXR_RAMP_MAX_DURATION", "7200"))
_SPAWN_RATE = float(os.environ.get("CXR_CAPACITY_SPAWN_RATE", "2"))

_ANALYZE_BODY = {
    "input": {
        "content": json.dumps(
            {
                "claim_id": os.environ.get("CXR_LOAD_CLAIM_ID", "saturation-ramp"),
                "description": "office visit (continuous ramp)",
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
            timeout=120,
            catch_response=True,
        ) as resp:
            if resp.status_code != 200:
                resp.failure(f"status {resp.status_code}: {resp.text[:200]}")


class ContinuousRampShape(LoadTestShape):
    """Add users every stage until max_users or max_duration."""

    def tick(self):
        run_time = self.get_run_time()
        if run_time >= _MAX_DURATION:
            return None

        stage = int(run_time // _STAGE_SECONDS)
        users = min(_START + stage * _STEP, _MAX_USERS)
        return (users, _SPAWN_RATE)
