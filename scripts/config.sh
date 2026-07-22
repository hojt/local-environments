#!/usr/bin/env bash

CLUSTER_NAME="${CLUSTER_NAME:-local}"
KUBE_CONTEXT="${KUBE_CONTEXT:-kind-local}"

APP_NAME="${APP_NAME:-example-backend}"

IMAGE_NAME="${IMAGE_NAME:-localhost/example-backend}"
IMAGE_TAG="${IMAGE_TAG:-0.1.0}"
IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

MANIFEST_DIR="apps/${APP_NAME}"
