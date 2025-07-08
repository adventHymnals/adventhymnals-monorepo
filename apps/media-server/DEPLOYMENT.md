# Media Server Deployment Guide

## Overview

This guide covers deploying the Advent Hymnals media server to production at `media.adventhymnals.org`.

## Prerequisites

### Server Requirements
- **OS**: Ubuntu 20.04+ or similar Linux distribution
- **CPU**: 2 cores minimum
- **RAM**: 4GB minimum  
- **Storage**: 100GB SSD minimum
- **Network**: 1Gbps connection recommended
- **Docker**: Latest version installed
- **Docker Compose**: Latest version installed

### GitHub Secrets Required

Configure these secrets in your GitHub repository settings:

| Secret | Description | Example |
|--------|-------------|---------|
| `MEDIA_SERVER_HOST` | Production server hostname | `media.adventhymnals.org` |
| `MEDIA_SERVER_USER` | SSH username for deployment | `deploy` |
| `MEDIA_SERVER_SSH_KEY` | Private SSH key for server access | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `MEDIA_SERVER_PORT` | SSH port (optional, defaults to 22) | `22` |

## Deployment Methods

### 1. Automatic Deployment (Recommended)

The media server deploys automatically when:
- Changes are pushed to `data/sources/` directory
- Changes are pushed to `apps/media-server/` directory
- Manual workflow trigger is used

**Trigger Manual Deployment:**
1. Go to GitHub Actions tab
2. Select "Deploy Media Server" workflow
3. Click "Run workflow"
4. Check "Force deployment" if needed

### 2. Manual Deployment

```bash
# Clone repository
git clone https://github.com/adventhymnals/adventhymnals-monorepo.git
cd adventhymnals-monorepo/apps/media-server

# Deploy to production server
./scripts/deploy.sh media.adventhymnals.org deploy
```

## Server Setup

### 1. Initial Server Configuration

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add deploy user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create application directory
sudo mkdir -p /opt/media-server
sudo chown $USER:$USER /opt/media-server
```

### 2. SSH Key Setup

```bash
# On your local machine, generate deployment key
ssh-keygen -t ed25519 -f ~/.ssh/media_server_deploy -C "media-server-deploy"

# Copy public key to server
ssh-copy-id -i ~/.ssh/media_server_deploy.pub deploy@media.adventhymnals.org

# Add private key to GitHub Secrets as MEDIA_SERVER_SSH_KEY
cat ~/.ssh/media_server_deploy
```

### 3. Domain and SSL Setup

```bash
# Install Certbot for Let's Encrypt
sudo apt install certbot

# Obtain SSL certificate
sudo certbot certonly --standalone -d media.adventhymnals.org

# Set up automatic renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Production Configuration

### Environment Variables

Create `.env` file in `/opt/media-server/`:

```bash
# Production environment
NODE_ENV=production
NGINX_HOST=media.adventhymnals.org
NGINX_PORT=80

# SSL Configuration  
SSL_CERT_PATH=/etc/letsencrypt/live/media.adventhymnals.org/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/media.adventhymnals.org/privkey.pem

# Optional: CDN Configuration
CDN_ENABLED=true
CDN_PROVIDER=cloudflare
```

### Nginx Production Configuration

For production with SSL, update `nginx.conf`:

```nginx
server {
    listen 80;
    server_name media.adventhymnals.org;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name media.adventhymnals.org;
    
    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/certs/privkey.pem;
    
    # SSL optimization
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # ... rest of configuration
}
```

## Monitoring and Maintenance

### Health Monitoring

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f media-server

# Check nginx configuration
docker-compose exec media-server nginx -t

# Monitor resource usage
docker stats
```

### Automated Monitoring Script

Create `/opt/media-server/monitor.sh`:

```bash
#!/bin/bash
# Simple monitoring script for media server

HEALTH_URL="https://media.adventhymnals.org/health"
LOG_FILE="/var/log/media-server-monitor.log"

if curl -f "$HEALTH_URL" > /dev/null 2>&1; then
    echo "$(date): ✅ Media server healthy" >> "$LOG_FILE"
else
    echo "$(date): ❌ Media server down - restarting" >> "$LOG_FILE"
    cd /opt/media-server && docker-compose restart
    # Optional: Send alert email/slack notification
fi
```

Add to crontab:
```bash
# Check every 5 minutes
*/5 * * * * /opt/media-server/monitor.sh
```

### Log Rotation

```bash
# Configure log rotation for docker logs
sudo tee /etc/logrotate.d/docker <<EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF
```

## CDN Integration

### Cloudflare Setup

1. **Add Domain**: Add `media.adventhymnals.org` to Cloudflare
2. **DNS Configuration**: 
   - A record: `media` → Server IP
   - Proxy enabled for CDN benefits
3. **Cache Rules**:
   - Cache everything for `*.mp3`, `*.mid`, `*.png`, `*.jpg`
   - Edge cache TTL: 1 month
   - Browser cache TTL: 1 year

### Cache Purging

```bash
# Purge CDN cache after deployment (if using Cloudflare)
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CF_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
```

## Backup and Disaster Recovery

### Data Backup

```bash
# Backup media files
rsync -av /opt/media-server/media-files/ backup-server:/backups/media-files/

# Backup configuration
tar -czf /tmp/media-server-config.tar.gz /opt/media-server/*.yml /opt/media-server/*.conf
```

### Disaster Recovery

```bash
# Quick recovery steps
cd /opt/media-server

# Pull latest configuration from GitHub
git pull origin main

# Restore from backup
rsync -av backup-server:/backups/media-files/ ./media-files/

# Restart services
docker-compose up -d
```

## Performance Optimization

### Server Optimizations

```bash
# Increase file descriptor limits
echo 'fs.file-max = 2097152' >> /etc/sysctl.conf
echo 'net.core.somaxconn = 65535' >> /etc/sysctl.conf
sysctl -p

# Configure nginx worker processes
# Edit nginx.conf: worker_processes auto;
```

### Storage Optimization

```bash
# Use SSD storage for media files
# Mount SSD to /opt/media-server/media-files

# Enable compression for storage
# Consider using ZFS with compression
```

## Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check logs
docker-compose logs media-server

# Validate nginx configuration
docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx:alpine nginx -t
```

**404 errors for media files:**
```bash
# Check file permissions
ls -la media-files/

# Verify volume mounts
docker-compose exec media-server ls -la /usr/share/nginx/html/
```

**SSL certificate issues:**
```bash
# Renew certificate
sudo certbot renew

# Check certificate validity
openssl x509 -in /etc/letsencrypt/live/media.adventhymnals.org/fullchain.pem -text -noout
```

**High memory usage:**
```bash
# Monitor memory usage
free -h
docker stats

# Restart containers if needed
docker-compose restart
```

## Security Considerations

### Firewall Configuration

```bash
# Basic UFW setup
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Security Headers

Ensure nginx.conf includes:
```nginx
add_header X-Frame-Options DENY always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### Regular Security Updates

```bash
# Auto-update system packages
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Update Docker images monthly
0 2 1 * * cd /opt/media-server && docker-compose pull && docker-compose up -d
```

## Support and Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Review server logs
- Check disk space usage
- Verify backup completion

**Monthly:**
- Update system packages
- Update Docker images  
- Review performance metrics

**Quarterly:**
- Review and optimize nginx configuration
- Audit SSL certificate renewal
- Capacity planning review

### Getting Help

- **GitHub Issues**: Report deployment issues
- **Documentation**: Check README.md files
- **Logs**: Always include relevant logs when reporting issues
- **Health Check**: Use `/health` endpoint for basic diagnostics