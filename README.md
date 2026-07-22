# local-environments

Kubernetes manifests for the local development platform.

## Purpose

This repository defines how applications are deployed into the local Kubernetes cluster.

It contains Kubernetes resources and deployment automation, but does not own the applications themselves or the platform infrastructure.

## Responsibilities

Current responsibilities:

- Kubernetes Deployments
- Kubernetes Services
- Local deployment automation
- Loading locally built container images into the kind cluster

Planned responsibilities:

- Kustomize overlays
- Multiple local environments
- GitOps integration with Flux or ArgoCD
- Environment-specific configuration

## Repository relationships

```
example-backend
        │
        │ builds
        ▼
Container image
        │
        ▼
local-environments
        │
        │ deploys
        ▼
kind cluster
```

## Requirements

Development is performed inside the provided Dev Container.

The host only needs:

- Podman
- Dev Container CLI

## Available tasks

List all tasks:

```bash
task --list
```

Current tasks:

- `task validate`
- `task image:load`
- `task apply`
- `task status`
- `task delete`

## Typical workflow

Load the application image into the cluster:

```bash
task image:load
```

Validate the manifests:

```bash
task validate
```

Deploy the application:

```bash
task apply
```

Check the deployment:

```bash
task status
```

Port-forward the service:

```bash
kubectl port-forward service/example-backend 8080:8080
```

Verify:

```bash
curl http://localhost:8080/api/greeting
```

Remove all deployed resources:

```bash
task delete
```

## Repository structure

```
.
├── .devcontainer/
├── apps/
│   └── example-backend/
├── scripts/
├── Taskfile.yml
└── README.md
```

## Design

This repository follows the same architecture as the other repositories in the platform.

```
Task
  ↓
scripts/
  ↓
kubectl / kind
```

Task provides the stable developer interface.

The implementation is kept in reusable shell scripts under `scripts/`.

## Future direction

This repository intentionally focuses only on local Kubernetes deployment.

Application source code belongs in application repositories.

Cluster infrastructure belongs in the `local-platform` repository.

GitOps will eventually become the primary deployment mechanism, but imperative deployment is used during the MVP phase to validate the platform step by step.

## Status

Current MVP:

- ✅ Dev Container
- ✅ Task interface
- ✅ Kubernetes Deployment
- ✅ Kubernetes Service
- ✅ Local image loading
- ✅ End-to-end deployment verification
