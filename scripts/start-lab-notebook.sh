#!/usr/bin/env bash
# Launch JupyterLab for CXR investigation notebooks (working hyperlinks + code cells).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Prefer conda base when available (system /bin/python3 usually lacks jupyter).
if [[ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/miniconda3/etc/profile.d/conda.sh"
  conda activate base 2>/dev/null || true
elif [[ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/anaconda3/etc/profile.d/conda.sh"
  conda activate base 2>/dev/null || true
fi

pick_python() {
  local py candidates=()
  [[ -n "${CONDA_PREFIX:-}" ]] && candidates+=("${CONDA_PREFIX}/bin/python")
  candidates+=(
    "${HOME}/miniconda3/bin/python"
    "${HOME}/anaconda3/bin/python"
    "$(command -v python 2>/dev/null || true)"
    "$(command -v python3 2>/dev/null || true)"
  )
  for py in "${candidates[@]}"; do
    [[ -n "$py" && -x "$py" ]] || continue
    if "$py" -c "import jupyterlab" 2>/dev/null; then
      echo "$py"
      return 0
    fi
  done
  return 1
}

ensure_jupyter() {
  if pick_python >/dev/null; then
    return 0
  fi
  if command -v conda >/dev/null 2>&1; then
    echo "Installing jupyterlab via conda (once, base env)..."
    conda install -y -c conda-forge jupyterlab
    if pick_python >/dev/null; then
      return 0
    fi
  fi
  VENV="$ROOT/.venv-jupyter"
  if [[ ! -d "$VENV" ]]; then
    echo "Creating $VENV and installing jupyterlab..."
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install jupyterlab
  fi
  # shellcheck disable=SC1091
  source "$VENV/bin/activate"
}

ensure_jupyter
PYTHON="$(pick_python)"
if [[ -z "$PYTHON" ]]; then
  echo "ERROR: jupyterlab not found after install. Try: conda activate base && conda install jupyterlab" >&2
  exit 1
fi

echo ""
echo "CXR lab notebook — open in browser:"
echo "  http://127.0.0.1:8888"
echo ""
echo "Using: $PYTHON"
echo "Open first:"
echo "  investigations/lab-navigation.html   (browser — always clickable links)"
echo "  investigations/00-navigation.ipynb   (JupyterLab — run cell Shift+Enter)"
echo ""
echo "Start from: investigations/template-investigation.ipynb"
echo "Copy to:    investigations/<your-study>/notebook.ipynb"
echo ""

exec "$PYTHON" -m jupyter lab \
  --notebook-dir="$ROOT/investigations" \
  --port=8888 \
  --no-browser \
  --ServerApp.token='' \
  --ServerApp.password=''
