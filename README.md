# local-environments

Desired state and Kubernetes manifests for local development environments.

## Purpose

This repository defines how applications and environment-specific resources are
deployed into the local Kubernetes platform.

It owns the desired state of the environment, but does not own application
source code or platform infrastructure.

Application source code belongs in application repositories.

Platform infrastructure belongs in `local-platform`.

## Responsibilities

Current responsibilities:

* Kubernetes application manifests
* Environment-specific Kubernetes resources
* Kustomize composition
* Argo CD application definitions
* GitOps desired state
* Gateway API workload routing
* Local deployment validation and troubleshooting

Future responsibilities may include:

* Additional local environments
* Environment-specific configuration
* More application workloads
* Alternative GitOps implementations
* Configuration and secret management
* Additional workload routing policies

## Repository Relationships

The repositories have distinct responsibilities:

```text
example-backend
        │
        │ builds and publishes image
        ▼
Local container registry
        │
        │ referenced by desired state
        ▼
local-environments
        │
        │ Git
        ▼
     Argo CD
        │
        │ reconciles
        ▼
 Kubernetes cluster
        │
        ▼
   Gateway API
        │
        ▼
    Workloads
```

`example-backend` produces the application artifact.

`local-platform` provides the Kubernetes cluster, local container registry,
Argo CD, Envoy Gateway, `GatewayClass`, and shared `Gateway`.

`local-environments` declares what should run in the environment and how
workloads are exposed through standard Gateway API resources.

## Prerequisites

Development is performed inside the provided Dev Container.

The developer host is intentionally kept lightweight and is expected to provide:

* Git
* Podman
* Dev Container CLI
* tmux
* terminal and editor of choice

Repository-specific tooling runs inside the Dev Container.

## Golden Path

Start or reconnect to the development environment:

```bash
./dev.sh
```

Rebuild the Dev Container when its definition has changed:

```bash
./dev.sh rebuild
```

The local platform should first be running from the `local-platform`
repository:

```bash
task up
```

Then bootstrap the Argo CD applications defined by this repository:

```bash
task argocd:bootstrap
```

The bootstrap establishes the connection between Argo CD and the desired state
stored in Git.

After bootstrap, the normal workflow is GitOps-based:

```text
edit manifests
      │
      ▼
task validate
      │
      ▼
git commit
      │
      ▼
git push
      │
      ▼
Argo CD detects the new revision
      │
      ▼
Kubernetes is reconciled
      │
      ▼
Gateway API routes traffic
```

Inspect the registered Argo CD applications:

```bash
task argocd:apps
```

During development, repository polling can be bypassed by explicitly asking
Argo CD to refresh:

```bash
task argocd:refresh
```

Verify the deployed environment:

```bash
task status
```

To access workloads through the shared Gateway, start the local Envoy
port-forward from `local-platform`:

```bash
task envoy:forward
```

Then verify the example backend through Gateway API routing:

```bash
curl http://localhost:8080/api/greeting
```

Expected response:

```json
{"message":"Hello from Quarkus"}
```

## GitOps

Git is the source of truth for the desired state of the local environment.

Argo CD is the initial GitOps implementation and runs as part of
`local-platform`.

This repository contains the Argo CD `Application` resources that connect Argo
CD to the desired environment state.

### Bootstrap

The initial Argo CD applications are registered explicitly:

```bash
task argocd:bootstrap
```

This forms the boundary between imperative bootstrap and GitOps reconciliation:

```text
task argocd:bootstrap
        │
        ▼
Argo CD Applications
        │
        ▼
Git becomes the source of truth
```

After the initial bootstrap, normal environment changes should be made through
Git rather than by manually applying manifests.

### Inspect and Refresh

List registered applications:

```bash
task argocd:apps
```

Argo CD normally discovers new Git revisions through repository polling.

A refresh can be requested explicitly while working with environment changes:

```bash
task argocd:refresh
```

A hard refresh, including cached manifests, can be requested with:

```bash
task argocd:refresh:hard
```

Argo CD itself is owned and operated by `local-platform`. These tasks are
provided here as convenient developer operations while working with the desired
environment state.

## Gateway API

Workload routing is expressed using Kubernetes Gateway API.

The shared Gateway infrastructure is owned by `local-platform`:

```text
local-platform
    │
    ├── Envoy Gateway controller
    ├── GatewayClass
    └── Gateway
            │
            ▼
local-environments
    │
    └── HTTPRoute
            │
            ▼
         Service
            │
            ▼
         Workload
```

This repository owns workload-specific routing resources such as `HTTPRoute`.

For `example-backend`, the route forwards requests under `/api` through the
shared Gateway to the application's Kubernetes Service.

The routing configuration is reconciled through Argo CD together with the
application manifests.

Keeping workload routing based on the standard Gateway API avoids coupling the
desired state directly to Envoy Gateway and makes it possible to evaluate
alternative Gateway API implementations later.

## Kubernetes Manifests

Application manifests are organized under `apps/`.

For example:

```text
apps/
└── example-backend/
    ├── deployment.yaml
    ├── service.yaml
    ├── httproute.yaml
    └── kustomization.yaml
```

Kustomize is used to compose Kubernetes resources before they are reconciled by
Argo CD.

The `HTTPRoute` is part of the workload's desired state and is managed in the
same way as its Deployment and Service.

Validate the manifests with:

```bash
task validate
```

## Manual Deployment

GitOps is the normal deployment mechanism.

Imperative deployment tasks remain available for development, troubleshooting,
and experimentation.

Apply the manifests manually:

```bash
task apply
```

Show the current workload status:

```bash
task status
```

Delete manually deployed resources:

```bash
task delete
```

These operations are intentionally kept available even though they are not the
normal path for environment changes.

They provide a simple way to inspect and exercise the underlying Kubernetes
deployment without requiring the GitOps layer.

## Available Tasks

List all available tasks:

```bash
task --list
```

The primary tasks are:

```text
validate
apply
status
delete

argocd:bootstrap
argocd:apps
argocd:refresh
argocd:refresh:hard
```

## Repository Structure

```text
.
├── .devcontainer/
├── apps/
│   └── example-backend/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── httproute.yaml
│       └── kustomization.yaml
├── argocd/
│   └── applications/
│       ├── local-bootstrap.yaml
│       └── example-backend.yaml
├── clusters/
│   └── local/
│       └── bootstrap/
│           ├── kustomization.yaml
│           └── namespace.yaml
├── scripts/
├── Taskfile.yaml
├── dev.sh
└── README.md
```

`apps/` contains workload manifests, including workload-specific Gateway API
routing.

`clusters/` contains environment-specific desired state.

`argocd/applications/` contains the initial Argo CD application definitions.

`scripts/` contains reusable automation behind Task commands.

## Design

This repository follows the architecture and design principles documented in
the top-level `homelab` repository.

The responsibility boundaries are intentionally explicit:

```text
Application repositories
        │
        │ build artifacts
        ▼
local-environments
        │
        │ desired state
        ▼
GitOps engine
        │
        │ reconciliation
        ▼
Kubernetes
        │
        ▼
Gateway API
        │
        ▼
Workloads
```

Task provides the stable developer interface.

Reusable or non-trivial automation is implemented as shell scripts under
`scripts/`. Simple operations may be kept directly in the Taskfile when doing
so keeps the underlying command visible and easy to understand.

Desired state is expressed declaratively through Kubernetes manifests,
Kustomize, and standard Gateway API resources.

The repository is intentionally kept focused on environment state. Application
source code belongs in application repositories, while cluster infrastructure,
Gateway infrastructure, and platform services belong in `local-platform`.

