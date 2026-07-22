#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${repo_root}/scripts/config.sh"

cd "${repo_root}"

kubectl \
  --context "${KUBE_CONTEXT}" \
  apply \
  --filename "${MANIFEST_DIR}"
