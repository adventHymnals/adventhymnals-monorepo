# GitHub Actions Workflows

This repository uses a simplified three-workflow architecture for deployment automation.

## Active Workflows

### 1. `data-sync.yml` - Data Synchronization
**Triggers:** Push to `data/**` paths
- Syncs media files to production server
- Restarts media server
- Performs health checks
- **Independent of code changes**

### 2. `build-deploy.yml` - Build and Deploy
**Triggers:** Push to code paths (`apps/web/**`, `packages/**`, etc.)
- **Two parallel build paths:**
  - **Docker Path:** Build → Push to registry → Deploy to server
  - **Static Path:** Build → Export → Deploy to GitHub Pages
- **Independent execution:** Docker and Static builds run simultaneously
- **Cross-repository deployment:** Deploys static site to public repository

### 3. `manual-deploy.yml` - Manual Deployment
**Triggers:** Manual workflow dispatch
- Flexible deployment options:
  - Full deployment (data + server + pages)
  - Server-only deployment
  - Pages-only deployment
  - Data-only deployment
- Optional force rebuild
- Custom image tag selection

## Required Secrets

### Server Deployment
- `DEPLOY_SSH_KEY` - SSH private key for server access
- `DEPLOY_HOST` - Production server hostname
- `DEPLOY_USER` - SSH username
- `DEPLOY_PORT` - SSH port (optional, defaults to 22)

### GitHub Pages Deployment
- `PAGES_DEPLOY_TOKEN` - Personal Access Token for cross-repo deployment
- `PUBLIC_REPO_NAME` - Target public repository name (e.g., `username/repo`)

### Application Secrets
- `NEXT_PUBLIC_GA_ID` - Google Analytics ID
- `GOOGLE_VERIFICATION` - Google verification token
- `YANDEX_VERIFICATION` - Yandex verification token

## Architecture Benefits

1. **Path-based triggers** - No complex change detection logic
2. **True parallelism** - Docker and Static builds run independently
3. **Failure isolation** - One deployment type can fail without affecting others
4. **No token complexity** - Uses native GitHub Actions features
5. **Cross-repository support** - Private development, public hosting
6. **Manual control** - Flexible manual deployment options

## Migration Notes

Old workflows have been moved to `.github/workflows/old/` for reference:
- `build.yml` → replaced by `build-deploy.yml`
- `deploy.yml` → replaced by `build-deploy.yml`
- `detect-media-changes.yml` → replaced by path-based triggers
- `sync-media.yml` → replaced by `data-sync.yml`

## Troubleshooting

### Common Issues
1. **Cross-repo deployment fails:** Check `PAGES_DEPLOY_TOKEN` has access to target repository
2. **Server deployment fails:** Verify SSH key and server connectivity
3. **Static build fails:** Check Next.js static export configuration
4. **Docker build fails:** Verify Dockerfile and build context

### Debug Steps
1. Check workflow logs in GitHub Actions tab
2. Verify all required secrets are set
3. Test SSH connectivity manually
4. Validate Docker registry access
5. Check target repository permissions

---
*Generated: 2025-07-09*
*Architecture: Three separate workflows with path-based triggers*