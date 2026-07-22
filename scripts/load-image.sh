#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${repo_root}/scripts/config.sh"

archive="$(mktemp --suffix=.tar)"
trap 'rm -f "${archive}"' EXIT

echo "Checking image ${IMAGE}"
podman image exists "${IMAGE}"

echo "Exporting image ${IMAGE}"
podman save \
  --format oci-archive \
  --output "${archive}" \
  "${IMAGE}"

echo "Loading image ${IMAGE} into kind cluster ${CLUSTER_NAME}"
kind load image-archive \
  "${archive}" \
  --name "${CLUSTER_NAME}"
