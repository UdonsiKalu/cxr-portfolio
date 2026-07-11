#!/usr/bin/env bash
# Capture portfolio investigation screenshots (CI + K8)
set -euo pipefail

K8_OUT="/home/udonsi-kalu/staging/cxr-portfolio/investigations/kubernetes-deploy/screenshots"
CI_OUT="/home/udonsi-kalu/staging/cxr-portfolio/investigations/ci-pipeline/screenshots"
TMP="/tmp/cxr-screenshot-html"
CHROME="${CHROME:-google-chrome}"

mkdir -p "$K8_OUT" "$CI_OUT" "$TMP"
export PATH="/home/udonsi-kalu/staging/cxr-ops-lab/bin:$PATH"

shot_url() {
  local out="$1" url="$2" w="${3:-1400}" h="${4:-900}" budget="${5:-15000}"
  "$CHROME" --headless=new --disable-gpu --no-sandbox \
    --window-size="${w},${h}" --virtual-time-budget="$budget" \
    --screenshot="$out" "$url" 2>/dev/null
  echo "OK $out"
}

shot_html() {
  local out="$1" html="$2"
  local f="$TMP/$(basename "$out" .png).html"
  printf '%s' "$html" > "$f"
  "$CHROME" --headless=new --disable-gpu --no-sandbox \
    --window-size=1400,1200 --screenshot="$out" "file://$f" 2>/dev/null
  echo "OK $out"
}

html_terminal() {
  local title="$1" body="$2"
  body=$(printf '%s' "$body" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  cat <<EOF
<!DOCTYPE html><html><head><meta charset="utf-8">
<style>
body{margin:0;background:#0d1117;font-family:ui-monospace,Menlo,Consolas,monospace}
.bar{background:#161b22;color:#8b949e;padding:12px 18px;font-size:14px;border-bottom:1px solid #30363d}
pre{color:#c9d1d9;padding:22px;margin:0;font-size:13px;line-height:1.5;white-space:pre-wrap}
.ok{color:#3fb950}.fail{color:#f85149}
</style></head><body>
<div class="bar">$title</div><pre>$body</pre></body></html>
EOF
}

html_gh_run() {
  local title="$1" body="$2"
  body=$(printf '%s' "$body" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/✓/<span class="ok">✓<\/span>/g')
  cat <<EOF
<!DOCTYPE html><html><head><meta charset="utf-8">
<style>
body{margin:0;background:#0d1117;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;color:#c9d1d9}
.header{background:#161b22;padding:16px 24px;border-bottom:1px solid #30363d}
.header h1{font-size:18px;margin:0 0 6px;font-weight:600;color:#f0f6fc}
.header p{margin:0;font-size:13px;color:#8b949e}
pre{padding:20px 24px;margin:0;font-family:ui-monospace,Menlo,monospace;font-size:13px;line-height:1.55;white-space:pre-wrap}
.ok{color:#3fb950;font-weight:bold}
.badge{display:inline-block;background:#238636;color:#fff;font-size:11px;padding:2px 8px;border-radius:12px;margin-left:8px}
</style></head><body>
<div class="header"><h1>cxr-bootcamp-ci <span class="badge">success</span></h1><p>$title</p></div>
<pre>$body</pre></body></html>
EOF
}

# --- K8 ---
shot_url "$K8_OUT/browser-localhost-8081.png" "http://127.0.0.1:8081/" 1400 900

KUBECTL=$(kubectl get all -n cxr-ui 2>&1)
shot_html "$K8_OUT/kubectl-get-all-cxr-ui.png" "$(html_terminal "kubectl get all -n cxr-ui" "$KUBECTL")"

HELM=$(helm list -n cxr-ui 2>&1)
shot_html "$K8_OUT/helm-list-cxr-ui.png" "$(html_terminal "helm list -n cxr-ui" "$HELM")"

# --- CI (private repo — CLI + styled summary, not logged-in GitHub UI) ---
GH_LIST=$(cd /home/udonsi-kalu/staging/cxr-ui-prune-rehearsal/cxr-ui && gh run list --workflow=ci.yml --limit 8 2>&1)
shot_html "$CI_OUT/github-actions-run-list.png" "$(html_terminal "gh run list --workflow=ci.yml --limit 8  ·  cxr-ui-rehearsal (private)" "$GH_LIST")"

GH_RUN=$(cd /home/udonsi-kalu/staging/cxr-ui-prune-rehearsal/cxr-ui && gh run view 26505883238 2>&1)
shot_html "$CI_OUT/github-actions-jobs-green.png" "$(html_gh_run "Run 26505883238 · chore/rehearsal-high-risk-batch11 · Add SW.6a Playwright smoke" "$GH_RUN")"

ls -la "$K8_OUT"/*.png "$CI_OUT"/*.png 2>/dev/null
