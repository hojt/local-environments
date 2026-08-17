#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

source "${repo_root}/scripts/config.sh"

cd "${repo_root}"

for app_dir in "${MANIFEST_DIR}"/*; do
  if [[ ! -d "${app_dir}" || ! -f "${app_dir}/kustomization.yaml" ]]; then
    continue
  fi

  echo "Validating ${app_dir}"

  kubectl \
    kustomize "${app_dir}" |
    kubectl \
      --context "${KUBE_CONTEXT}" \
      --namespace "${NAMESPACE}" \
      apply \
      --dry-run=client \
      --filename -
done
