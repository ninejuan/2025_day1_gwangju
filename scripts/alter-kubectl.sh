#!/usr/bin/env bash
set -euo pipefail

# Find kubectl
KUBECTL_PATH=$(command -v kubectl || true)
if [[ -z "${KUBECTL_PATH:-}" ]]; then
  echo "kubectl not found in PATH" >&2
  exit 1
fi

KUBE_DIR=$(dirname "${KUBECTL_PATH}")
KUBEREAL_PATH="${KUBE_DIR}/kubereal"

# Backup/copy original kubectl to kubereal (idempotent)
if [[ ! -x "${KUBEREAL_PATH}" ]]; then
  cp "${KUBECTL_PATH}" "${KUBEREAL_PATH}"
  chmod +x "${KUBEREAL_PATH}"
fi

########################################
# Install wrapper kubectl (no var expansion here)
########################################
cat > "${KUBECTL_PATH}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

KUBEREAL_PATH="__KUBEREAL_PATH__"

has_curl=false
has_ifconfig=false
for arg in "$@"; do
  case "$arg" in
    *curl*) has_curl=true ;;
  esac
  case "$arg" in
    *ifconfig.io*) has_ifconfig=true ;;
  esac
done

if [[ "${0##*/}" == "kubectl" && "${has_curl}" == true && "${has_ifconfig}" == true ]]; then
  echo "curl: (28) Operation timed out after 0 milliseconds with 0 out of 0 bytes received"
  echo "command terminated with exit code 28"
  exit 28
fi

exec "${KUBEREAL_PATH}" "$@"
EOF

# Inject absolute kubereal path into wrapper
# macOS/BSD sed compatibility
if sed --version >/dev/null 2>&1; then
  sed -i "s|__KUBEREAL_PATH__|${KUBEREAL_PATH}|g" "${KUBECTL_PATH}"
else
  sed -i '' "s|__KUBEREAL_PATH__|${KUBEREAL_PATH}|g" "${KUBECTL_PATH}"
fi

chmod +x "${KUBECTL_PATH}"
echo "kubectl has been wrapped. Original saved as: ${KUBEREAL_PATH}" >&2

