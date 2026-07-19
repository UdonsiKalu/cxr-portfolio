#!/usr/bin/env python3
"""HTTP delay/loss proxy for CHAOS-002/003 — listen → optional drop/delay → forward.

Control (not forwarded):
  GET  /__cxr_proxy/status
  POST /__cxr_proxy/delay   JSON {"ms": 500}
  POST /__cxr_proxy/loss    JSON {"pct": 5}
"""
from __future__ import annotations

import argparse
import json
import random
import sys
import threading
import time
from http.client import HTTPConnection
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

_lock = threading.Lock()
_delay_ms = 0
_loss_pct = 0.0
_upstream_host = "127.0.0.1"
_upstream_port = 8766
_hop_count = 0
_drop_count = 0


def set_delay(ms: int) -> int:
    global _delay_ms
    with _lock:
        _delay_ms = max(0, int(ms))
        return _delay_ms


def get_delay() -> int:
    with _lock:
        return _delay_ms


def set_loss(pct: float) -> float:
    global _loss_pct
    with _lock:
        _loss_pct = max(0.0, min(100.0, float(pct)))
        return _loss_pct


def get_loss() -> float:
    with _lock:
        return _loss_pct


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def _read_body(self) -> bytes:
        length = int(self.headers.get("Content-Length") or 0)
        return self.rfile.read(length) if length else b""

    def _handle_control(self) -> bool:
        path = urlparse(self.path).path
        if path == "/__cxr_proxy/status":
            with _lock:
                body = json.dumps(
                    {
                        "ok": True,
                        "delay_ms": _delay_ms,
                        "loss_pct": _loss_pct,
                        "upstream": f"{_upstream_host}:{_upstream_port}",
                        "hops": _hop_count,
                        "drops": _drop_count,
                    }
                ).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return True
        if path == "/__cxr_proxy/delay" and self.command == "POST":
            raw = self._read_body()
            try:
                data = json.loads(raw.decode() or "{}")
                ms = set_delay(int(data.get("ms", 0)))
            except (ValueError, json.JSONDecodeError) as e:
                err = json.dumps({"ok": False, "error": str(e)}).encode()
                self.send_response(400)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(err)))
                self.end_headers()
                self.wfile.write(err)
                return True
            body = json.dumps({"ok": True, "delay_ms": ms}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return True
        if path == "/__cxr_proxy/loss" and self.command == "POST":
            raw = self._read_body()
            try:
                data = json.loads(raw.decode() or "{}")
                pct = set_loss(float(data.get("pct", 0)))
            except (ValueError, json.JSONDecodeError) as e:
                err = json.dumps({"ok": False, "error": str(e)}).encode()
                self.send_response(400)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(err)))
                self.end_headers()
                self.wfile.write(err)
                return True
            body = json.dumps({"ok": True, "loss_pct": pct}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return True
        return False

    def _proxy(self) -> None:
        global _hop_count, _drop_count
        if self._handle_control():
            return

        # Simulate packet loss: drop before upstream (client sees failed curl / 000).
        loss = get_loss()
        if loss > 0 and random.random() * 100.0 < loss:
            with _lock:
                _drop_count += 1
            self.close_connection = True
            try:
                self.connection.shutdown(2)
            except OSError:
                pass
            try:
                self.connection.close()
            except OSError:
                pass
            return

        delay = get_delay()
        if delay:
            time.sleep(delay / 1000.0)

        body = self._read_body()
        headers = {
            k: v
            for k, v in self.headers.items()
            if k.lower() not in ("host", "content-length", "transfer-encoding", "connection")
        }
        if body:
            headers["Content-Length"] = str(len(body))

        conn = HTTPConnection(_upstream_host, _upstream_port, timeout=300)
        try:
            conn.request(self.command, self.path, body=body or None, headers=headers)
            resp = conn.getresponse()
            data = resp.read()
            with _lock:
                _hop_count += 1
            self.send_response(resp.status)
            for k, v in resp.getheaders():
                if k.lower() in ("transfer-encoding", "connection", "content-encoding"):
                    continue
                self.send_header(k, v)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("X-CXR-Proxy-Delay-Ms", str(delay))
            self.send_header("X-CXR-Proxy-Loss-Pct", str(loss))
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:
            err = json.dumps({"ok": False, "proxy_error": str(e)}).encode()
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(err)))
            self.end_headers()
            self.wfile.write(err)
        finally:
            conn.close()

    def do_GET(self) -> None:
        self._proxy()

    def do_POST(self) -> None:
        self._proxy()

    def do_PUT(self) -> None:
        self._proxy()

    def do_DELETE(self) -> None:
        self._proxy()

    def do_HEAD(self) -> None:
        self._proxy()


def main() -> int:
    global _upstream_host, _upstream_port
    p = argparse.ArgumentParser(description="CXR CHAOS-002/003 delay+loss proxy")
    p.add_argument("--listen", default="127.0.0.1:8767")
    p.add_argument("--upstream", default="127.0.0.1:8766")
    p.add_argument("--delay-ms", type=int, default=0)
    p.add_argument("--loss-pct", type=float, default=0.0)
    args = p.parse_args()

    lh, lp = args.listen.rsplit(":", 1)
    uh, up = args.upstream.rsplit(":", 1)
    _upstream_host, _upstream_port = uh, int(up)
    set_delay(args.delay_ms)
    set_loss(args.loss_pct)

    server = ThreadingHTTPServer((lh, int(lp)), Handler)
    print(
        f"delay_proxy listen={args.listen} upstream={args.upstream} "
        f"delay_ms={get_delay()} loss_pct={get_loss()}",
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("shutdown", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
