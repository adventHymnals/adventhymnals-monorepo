# Deployment Quick Start Guide

This guide provides a fast-track setup for deploying Advent Hymnals using Docker and GitHub Actions.

## 🚀 Quick Setup Checklist

### 1. Environment Setup
```bash
# Copy environment files
cp apps/web/.env.local.example apps/web/.env.local
cp .env.production .env.production.local

# Edit with your values
NEXT_PUBLIC_GA_ID=G-JPQZVQ70L9  # Your Google Analytics ID
```

### 2. GitHub Secrets Configuration
Add these secrets to your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DEPLOY_HOST` | Server IP/hostname | `192.168.1.100` |
| `DEPLOY_USER` | SSH username | `ubuntu` |
| `DEPLOY_SSH_KEY` | Private SSH key | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `NEXT_PUBLIC_GA_ID` | Google Analytics ID | `G-JPQZVQ70L9` |
| `GOOGLE_VERIFICATION` | Google verification code | `abc123xyz` |

### 3. SSH Key Generation
```bash
# Generate deployment key
ssh-keygen -t ed25519 -f ~/.ssh/advent-hymnals-deploy -C "deploy@adventhymnals.org"

# Copy public key to server
ssh-copy-id -i ~/.ssh/advent-hymnals-deploy.pub user@your-server.com

# Add private key to GitHub Secrets
cat ~/.ssh/advent-hymnals-deploy
```

### 4. Server Preparation
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create deployment directory
sudo mkdir -p /opt/advent-hymnals
sudo chown $USER:$USER /opt/advent-hymnals
```

### 5. Local Development
```bash
# Install dependencies
pnpm install

# Start development server
pnpm --filter @advent-hymnals/web dev
```

### 6. Production Deployment
```bash
# Build and run with Docker Compose
docker compose up -d

# Or deploy via GitHub Actions (push to main branch)
git push origin main
```

## 🔧 Configuration Files Created

### Docker & Deployment
- `apps/web/Dockerfile` - Multi-stage Docker build
- `docker-compose.yml` - Production deployment configuration
- `.github/workflows/deploy.yml` - Automated CI/CD pipeline
- `apps/web/src/app/api/health/route.ts` - Health check endpoint

### Environment & Configuration
- `apps/web/.env.example` - Environment template
- `apps/web/.env.local.example` - Local development template
- `.env.production` - Production environment template

### Favicons & Branding
- `apps/web/public/icon.svg` - Scalable vector icon
- `apps/web/public/favicon.ico` - Browser favicon
- `apps/web/public/apple-touch-icon.png` - iOS home screen icon
- `apps/web/public/manifest.json` - PWA manifest
- `scripts/generate-favicons.js` - Favicon generation script

### Documentation
- `docs/DEPLOYMENT.md` - Comprehensive deployment guide
- `docs/GOOGLE-SUBMISSION.md` - Google Search Console setup
- `docs/DEPLOYMENT-QUICK-START.md` - This quick start guide

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   GitHub Actions │    │ Container Registry│
│                 │───▶│                 │───▶│    (GHCR)      │
│  Source Code    │    │   Build & Test  │    │  Docker Images  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Google Analytics│    │  Production     │    │   Deployment    │
│                 │◀───│    Server       │◀───│     Server      │
│   Tracking      │    │  adventhymnals  │    │   Docker Host   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🌐 URLs & Endpoints

### Production URLs
- **Website**: `https://adventhymnals.org`
- **Health Check**: `https://adventhymnals.org/api/health`
- **Sitemap**: `https://adventhymnals.org/sitemap.xml`
- **Robots**: `https://adventhymnals.org/robots.txt`

### GitHub Resources
- **Container Registry**: `ghcr.io/adventhymnals/advent-hymnals-web`
- **Repository**: `https://github.com/adventhymnals/advent-hymnals-web`

## 🔍 Monitoring & Analytics

### Google Analytics
- **Measurement ID**: Set via `NEXT_PUBLIC_GA_ID`
- **Events Tracked**: Page views, search queries, hymn views, downloads

### Health Monitoring
```bash
# Check application health
curl https://adventhymnals.org/api/health

# Check container status
docker compose ps

# View logs
docker compose logs -f advent-hymnals-web
```

## 🛠️ Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Check build logs
   docker compose logs advent-hymnals-web
   ```

2. **Environment Variables Not Loading**
   ```bash
   # Verify .env file
   cat .env.production.local
   ```

3. **Permission Errors**
   ```bash
   # Fix ownership
   sudo chown -R 1001:1001 /path/to/data
   ```

4. **Port Conflicts**
   ```bash
   # Check port usage
   sudo netstat -tulpn | grep :3000
   ```

### Quick Fixes

```bash
# Restart services
docker compose restart

# Rebuild and restart
docker compose up -d --build

# View real-time logs
docker compose logs -f

# Clean up old images
docker system prune -a
```

## 📊 Performance Optimization

### Production Settings
- **Output**: Standalone for Docker optimization
- **Image Optimization**: WebP/AVIF formats
- **Caching**: Long-term caching for static assets
- **Compression**: Gzip/Brotli compression enabled

### Monitoring
- Core Web Vitals tracking
- Error boundary implementation
- Performance analytics integration
- Health check endpoints

## 🔐 Security Features

- HTTPS enforcement
- Security headers (CSP, HSTS, etc.)
- No sensitive data in environment files
- SSH key-based authentication
- Regular security updates via automated builds

## 📝 Next Steps

1. **Domain Setup**: Configure DNS for your domain
2. **SSL Certificate**: Set up HTTPS (Cloudflare/Let's Encrypt)
3. **Monitoring**: Set up alerting and monitoring
4. **Backup**: Implement regular data backups
5. **CDN**: Configure content delivery network

For detailed instructions, see the comprehensive guides in the `docs/` directory.