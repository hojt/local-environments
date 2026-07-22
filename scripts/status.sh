#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${repo_root}/scripts/config.sh"

kubectl \
  --context "${KUBE_CONTEXT}" \
  get deployment,replicaset,pod,service \
  --selector app.kubernetes.io/name=example-backend
