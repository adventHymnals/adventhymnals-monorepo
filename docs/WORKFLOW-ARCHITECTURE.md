# Workflow Architecture Documentation

## Current State vs Desired State

### Desired Workflow Architecture - Visual Representation

```
PUSH TRIGGERS:
├── Push to master/main (data/ changes only)
└── Push to master/main (code changes: apps/, packages/, etc.)

                    ┌─────────────────────────────────────────────────┐
                    │              GIT PUSH EVENT                     │
                    │           (to master/main)                      │
                    └─────────────────┬───────────────────────────────┘
                                      │
                    ┌─────────────────▼───────────────────────────────┐
                    │           PATH-BASED ROUTER                     │
                    │   • Check changed files                         │
                    │   • Route to appropriate workflow               │
                    └─────────┬───────────────────────────┬───────────┘
                              │                           │
                    ┌─────────▼──────────┐    ┌─────────▼──────────────┐
                    │   DATA CHANGES     │    │     CODE CHANGES       │
                    │   (data/**)        │    │  (apps/**, packages/**)│
                    └─────────┬──────────┘    └─────────┬──────────────┘
                              │                         │
                    ┌─────────▼──────────┐              │
                    │   SYNC-MEDIA       │              │
                    │ • rsync to server  │              │
                    │ • restart media    │              │
                    │ • health check     │              │
                    └────────────────────┘              │
                                                        │
                                          ┌─────────────┼─────────────┐
                                          │             │             │
                            ┌─────────────▼─────────┐   ┌─▼─────────────┐
                            │    BUILD DOCKER       │   │ BUILD STATIC  │
                            │ • Install deps        │   │ • Install deps│
                            │ • Build packages      │   │ • Build packages│
                            │ • Create Docker image │   │ • Static export│
                            │ • Push to ghcr.io     │   │ • No Docker   │
                            └─────────────┬─────────┘   └─┬─────────────┘
                                          │               │
                                ┌─────────▼──────┐        │
                                │  DEPLOY SERVER │        │
                                │ • Pull image   │        │
                                │ • SSH deploy   │        │
                                │ • Health check │        │
                                └────────────────┘        │
                                                          │
                                                ┌─────────▼─────────┐
                                                │ DEPLOY TO PUBLIC  │
                                                │   GITHUB PAGES    │
                                                │ • Push static to  │
                                                │   public repo     │
                                                │ • Cross-repo      │
                                                │   deployment      │
                                                └───────────────────┘
```

## Implementation Options Analysis

### Option 1: Three Separate Workflows (RECOMMENDED)
- **data-sync.yml**: Handles data/ changes only
- **build-deploy.yml**: Handles code changes with parallel build paths
- **manual-deploy.yml**: Manual triggers

**Updated Benefits:**
- No token complexity
- True parallelism between Docker and Static builds
- BUILD STATIC independent of Docker container
- Clear separation of concerns
- Easy debugging
- Faster GitHub Pages deployment (no Docker overhead)

### Option 2: Single Workflow with Matrix Strategy
- Uses path filters and job conditions
- More complex but single file
- Matrix strategy behavior needs analysis

### Option 3: workflow_call Pattern
- Keep current detection logic
- Replace repository-dispatch with workflow_call
- More complex but maintains structure

## Matrix Strategy Failure Analysis

**Key Question:** If one matrix job fails, do others continue or stop?

**Research needed on:**
- Matrix job independence
- Failure propagation behavior
- Conditional execution impact
- Best practices for critical vs non-critical deployments

## Decision Criteria

1. **Simplicity**: Path-based triggers vs complex detection
2. **Reliability**: Independent jobs vs coupled execution
3. **Maintainability**: Single vs multiple workflows
4. **Failure Handling**: Isolation vs propagation
5. **Token Management**: Native triggers vs cross-workflow communication

## Updated Implementation Analysis

### Key Architectural Changes Made:

1. **BUILD STATIC Independence**: Now branches directly from CODE CHANGES, not dependent on Docker build
2. **Parallel Build Paths**: Docker and Static builds can run simultaneously 
3. **Performance Improvement**: GitHub Pages deployment faster without Docker overhead
4. **Resource Optimization**: Static build doesn't need container registry access

### Recommended Configuration:

```yaml
# data-sync.yml - Simple, focused
on:
  push:
    branches: [master]
    paths: ['data/**']

# build-deploy.yml - Parallel independent build paths
jobs:
  # Docker Build Path
  build-docker: # Install deps, build packages, create Docker image
  deploy-server: # Critical - must succeed
    needs: build-docker
  
  # Static Build Path (Independent)
  build-static: # Install deps, build packages, static export (no Docker)
  deploy-to-public-repo: # Cross-repo GitHub Pages deployment
    needs: build-static
```

### Performance Benefits:
- **Static builds** complete faster (no Docker overhead)
- **Parallel execution** of Docker and Static paths
- **Independent failure isolation** between deployment types
- **Resource efficiency** - static builds use fewer resources
- **Cross-repo deployment** - Private repo builds, public repo hosts

### Cross-Repository Deployment Flow:

**Private Repository** (this repo):
- Contains source code and builds
- Runs GitHub Actions workflows
- Generates static site artifacts

**Public Repository** (target):
- Hosts GitHub Pages site
- Receives static build artifacts
- Serves public website

**Deployment Method:**
- Use `peaceiris/actions-gh-pages` or similar action
- Deploy from private repo to public repo
- Requires `GITHUB_TOKEN` or PAT with access to public repo

## Final Recommendation: Option 1 with Simplified Architecture

The updated architecture removes BUILD BRANCH complexity and focuses on the essential deployment paths: server (Docker) and public GitHub Pages (static).

---
*Generated: 2025-07-09*
*Purpose: Document workflow architecture analysis and decision-making process*