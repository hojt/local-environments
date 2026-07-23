#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/config.sh"

echo "Environment status"
echo "Context:   ${KUBE_CONTEXT}"
echo "Namespace: ${NAMESPACE}"
echo

echo "Deployments"
kubectl \
  --context "${KUBE_CONTEXT}" \
  --namespace "${NAMESPACE}" \
  get deployments

echo
echo "Pods"
kubectl \
  --context "${KUBE_CONTEXT}" \
  --namespace "${NAMESPACE}" \
  get pods

echo
echo "Services"
kubectl \
  --context "${KUBE_CONTEXT}" \
  --namespace "${NAMESPACE}" \
  get services
