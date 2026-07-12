#!/usr/bin/env python3
"""PERF-003 follow-up: direct concurrent Qdrant search pressure (bypass Analyze).

Timings always go to CSV. Optional OpenTelemetry → Jaeger when OTLP is enabled
(default: http://127.0.0.1:4318 unless CXR_PRESSURE_TRACE=0).

Jaeger: service **cxr-qdrant-pressure**, ops **qdrant.pressure.tier** /
**qdrant.points.search**.
"""
from __future__ import annotations

import concurrent.futures
import json
import os
import time
import urllib.error
import urllib.request
from pathlib import Path

OUT = Path(__file__).resolve().parent / "results"
OUT.mkdir(parents=True, exist_ok=True)

QDRANT = "http://127.0.0.1:6333"
COLLECTION = "claims__cms_policies"
LIMIT = 5
TIERS = [8, 16, 32, 64]
REQUESTS_PER_TIER = 64  # total searches per tier

_TRACER = None
_PROVIDER = None


def _tracing_wanted() -> bool:
    if os.environ.get("CXR_PRESSURE_TRACE", "1").strip() in ("0", "false", "no"):
        return False
    return True


def init_tracing() -> bool:
    """OTLP HTTP → collector :4318. Returns True if spans will export."""
    global _TRACER, _PROVIDER
    if not _tracing_wanted():
        print("tracing: off (CXR_PRESSURE_TRACE=0)")
        return False
    try:
        from opentelemetry import trace
        from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
            OTLPSpanExporter,
        )
        from opentelemetry.sdk.resources import Resource
        from opentelemetry.sdk.trace import TracerProvider
        from opentelemetry.sdk.trace.export import BatchSpanProcessor
    except ImportError:
        print("tracing: skipped (opentelemetry not installed)")
        return False

    endpoint = (
        os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "http://127.0.0.1:4318")
        .rstrip("/")
    )
    # Prefer dedicated name so we don't inherit analyzer's OTEL_SERVICE_NAME.
    service = os.environ.get(
        "CXR_PRESSURE_SERVICE_NAME",
        "cxr-qdrant-pressure",
    )
    resource = Resource.create({"service.name": service})
    provider = TracerProvider(resource=resource)
    provider.add_span_processor(
        BatchSpanProcessor(OTLPSpanExporter(endpoint=f"{endpoint}/v1/traces"))
    )
    trace.set_tracer_provider(provider)
    _PROVIDER = provider
    _TRACER = trace.get_tracer("perf003.qdrant.pressure", "1.0.0")
    print(f"tracing: on → {endpoint} service={service}")
    return True


def flush_tracing() -> None:
    if _PROVIDER is None:
        return
    try:
        _PROVIDER.force_flush(timeout_millis=15000)
    except Exception:
        pass


def load_vector() -> list[float]:
    raw = Path("/tmp/perf003-query-vector.json")
    if raw.exists():
        v = json.loads(raw.read_text())
        if isinstance(v, list):
            return v
    body = json.dumps({"limit": 1, "with_vector": True, "with_payload": False}).encode()
    req = urllib.request.Request(
        f"{QDRANT}/collections/{COLLECTION}/points/scroll",
        data=body,
        headers={"Content-Type": "application/json"},
    )
    d = json.load(urllib.request.urlopen(req, timeout=60))
    v = d["result"]["points"][0]["vector"]
    raw.write_text(json.dumps(v))
    return v


def _do_search(vector: list[float]) -> tuple[int, float, int]:
    body = json.dumps(
        {
            "vector": vector,
            "limit": LIMIT,
            "with_payload": False,
        }
    ).encode()
    req = urllib.request.Request(
        f"{QDRANT}/collections/{COLLECTION}/points/search",
        data=body,
        headers={"Content-Type": "application/json"},
    )
    t0 = time.perf_counter()
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.load(resp)
            code = resp.status
        hits = len(data.get("result") or [])
        ms = (time.perf_counter() - t0) * 1000
        return code, ms, hits
    except urllib.error.HTTPError as e:
        return e.code, (time.perf_counter() - t0) * 1000, 0
    except Exception:
        return 0, (time.perf_counter() - t0) * 1000, 0


def one_search(
    vector: list[float],
    parent_ctx=None,
    concurrency: int = 0,
) -> tuple[int, float, int]:
    if _TRACER is None:
        return _do_search(vector)

    from opentelemetry import context as otel_context
    from opentelemetry.trace import Status, StatusCode

    token = otel_context.attach(parent_ctx) if parent_ctx is not None else None
    try:
        with _TRACER.start_as_current_span("qdrant.points.search") as span:
            span.set_attribute("qdrant.collection", COLLECTION)
            span.set_attribute("qdrant.limit", LIMIT)
            span.set_attribute("pressure.concurrency", concurrency)
            span.set_attribute("peer.service", "qdrant")
            code, ms, hits = _do_search(vector)
            span.set_attribute("http.status_code", code)
            span.set_attribute("retrieved_chunk_count", hits)
            span.set_attribute("duration_ms", round(ms, 3))
            if code != 200:
                span.set_status(Status(StatusCode.ERROR, f"http {code}"))
            return code, ms, hits
    finally:
        if token is not None:
            otel_context.detach(token)


def pct(xs: list[float], p: float) -> float:
    if not xs:
        return 0.0
    xs = sorted(xs)
    i = min(len(xs) - 1, int(round((p / 100) * (len(xs) - 1))))
    return xs[i]


def run_tier(vector: list[float], concurrency: int, n: int) -> dict:
    latencies: list[float] = []
    codes: list[int] = []
    hits: list[int] = []

    def _execute(parent_ctx=None, tier_span=None) -> dict:
        t0 = time.perf_counter()
        with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
            futs = [
                pool.submit(one_search, vector, parent_ctx, concurrency)
                for _ in range(n)
            ]
            for f in concurrent.futures.as_completed(futs):
                code, ms, h = f.result()
                codes.append(code)
                latencies.append(ms)
                hits.append(h)
        wall = (time.perf_counter() - t0) * 1000
        ok = sum(1 for c in codes if c == 200)
        row = {
            "concurrency": concurrency,
            "n": n,
            "ok": ok,
            "fail": n - ok,
            "ms_min": round(min(latencies), 1) if latencies else 0,
            "ms_p50": round(pct(latencies, 50), 1),
            "ms_p95": round(pct(latencies, 95), 1),
            "ms_max": round(max(latencies), 1) if latencies else 0,
            "hits_p50": pct([float(h) for h in hits], 50) if hits else 0,
            "wall_ms": round(wall, 1),
            "rps": round(n / (wall / 1000.0), 1) if wall else 0,
        }
        if tier_span is not None:
            tier_span.set_attribute("pressure.ok", ok)
            tier_span.set_attribute("pressure.fail", n - ok)
            tier_span.set_attribute("pressure.ms_p50", row["ms_p50"])
            tier_span.set_attribute("pressure.ms_p95", row["ms_p95"])
            tier_span.set_attribute("pressure.rps", row["rps"])
        return row

    if _TRACER is None:
        return _execute()

    from opentelemetry import context as otel_context

    with _TRACER.start_as_current_span("qdrant.pressure.tier") as tier_span:
        tier_span.set_attribute("pressure.concurrency", concurrency)
        tier_span.set_attribute("pressure.n", n)
        tier_span.set_attribute("qdrant.collection", COLLECTION)
        return _execute(otel_context.get_current(), tier_span)


def main() -> None:
    tracing = init_tracing()
    vector = load_vector()
    print(f"vector_dim={len(vector)} collection={COLLECTION} limit={LIMIT}")

    def _run_tiers() -> list[dict]:
        out = []
        for c in TIERS:
            print(f"tier concurrency={c} n={REQUESTS_PER_TIER} ...", flush=True)
            row = run_tier(vector, c, REQUESTS_PER_TIER)
            out.append(row)
            print(row, flush=True)
            time.sleep(1)
        return out

    if _TRACER is not None:
        with _TRACER.start_as_current_span("qdrant.pressure.run") as run_span:
            run_span.set_attribute("pressure.tiers", ",".join(str(t) for t in TIERS))
            run_span.set_attribute("pressure.requests_per_tier", REQUESTS_PER_TIER)
            run_span.set_attribute("qdrant.collection", COLLECTION)
            rows = _run_tiers()
    else:
        rows = _run_tiers()

    flush_tracing()

    csv_path = OUT / "qdrant-direct-pressure.csv"
    cols = list(rows[0].keys())
    with csv_path.open("w") as f:
        f.write(",".join(cols) + "\n")
        for r in rows:
            f.write(",".join(str(r[k]) for k in cols) + "\n")

    summary = OUT / "qdrant-direct-pressure-summary.txt"
    lines = [
        "PERF-003 hard pressure — direct Qdrant search (bypass Analyze)",
        f"collection={COLLECTION} points~11892 vector_dim={len(vector)} limit={LIMIT}",
        f"requests_per_tier={REQUESTS_PER_TIER} tiers={TIERS}",
        f"tracing={'on' if tracing else 'off'} service=cxr-qdrant-pressure",
        "",
    ]
    for r in rows:
        lines.append(
            f"c={r['concurrency']}: ok={r['ok']}/{r['n']} fail={r['fail']} "
            f"p50={r['ms_p50']}ms p95={r['ms_p95']}ms max={r['ms_max']}ms "
            f"rps={r['rps']} hits_p50={r['hits_p50']}"
        )
    summary.write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
    print(f"wrote {csv_path}")
    print(f"wrote {summary}")
    if tracing:
        print(
            "Jaeger: service cxr-qdrant-pressure · "
            "ops qdrant.pressure.run / qdrant.pressure.tier / qdrant.points.search"
        )


if __name__ == "__main__":
    main()
