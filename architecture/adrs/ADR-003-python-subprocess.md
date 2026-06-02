# ADR-003: Python subprocess for analyze (superseded)

## Status

Superseded by [ADR-004](./ADR-004-long-running-analyzer.md)

## Context

Original Claim Studio route used `spawn("python3", [analyze_sample.py, tempFile])` for simplicity and isolation.

## Decision (historical)

One subprocess per analyze request — easy to wire, matches CLI tooling.

## Why superseded

Jaeger + Locust proved **per-request process start** dominated latency (imports + `ClaimCorrectorV31Integrated()` init). Subprocess path retained only as fallback when `ANALYZER_URL` unset.

## Lesson

Simple wiring can be the most expensive line of code under load.
