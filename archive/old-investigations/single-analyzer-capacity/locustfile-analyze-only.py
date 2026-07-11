"""LOAD-001 — POST /api/claim-studio/analyze only (no GET noise)."""

from __future__ import annotations

import json
import os

from locust import HttpUser, between, task

_ANALYZE_BODY = {
    "input": {
        "content": json.dumps(
            {
                "claim_id": os.environ.get("CXR_LOAD_CLAIM_ID", "load-001-capacity"),
                "description": "office visit (capacity sweep)",
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
