#!/usr/bin/env bash
# One-time: allow this user to start/stop the system Ollama service without a password prompt.
# Needed because ollama.service runs as root under systemd — pkill alone gets respawned.
set -euo pipefail

USER_NAME="${SUDO_USER:-$USER}"
DROP_IN="/etc/sudoers.d/cxr-ollama-lab-${USER_NAME}"

echo "This will install a sudoers rule so you can run:"
echo "  sudo systemctl start|stop|restart ollama"
echo "without typing a password (lab only)."
echo ""
echo "You will be asked for your password ONCE now."
echo ""

TMP="$(mktemp)"
cat >"${TMP}" <<EOF
# CXR lab — REL-002 Ollama outage script (no interactive password)
# Installed by investigations/ollama-outage/setup-passwordless-ollama-ctl.sh
${USER_NAME} ALL=(root) NOPASSWD: /usr/bin/systemctl start ollama, /usr/bin/systemctl stop ollama, /usr/bin/systemctl restart ollama, /bin/systemctl start ollama, /bin/systemctl stop ollama, /bin/systemctl restart ollama
EOF

sudo install -m 0440 "${TMP}" "${DROP_IN}"
rm -f "${TMP}"
sudo visudo -cf "${DROP_IN}"

echo ""
echo "OK — testing non-interactive stop/start..."
sudo -n systemctl is-active ollama >/dev/null
echo "sudo -n systemctl works. Re-run:"
echo "  ./investigations/ollama-outage/run-ollama-outage-check.sh"
