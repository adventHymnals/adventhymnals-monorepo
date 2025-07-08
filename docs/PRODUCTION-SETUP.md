# Production Server Setup Guide

This guide automates the complete setup of a new production server for Advent Hymnals.

## Prerequisites

### 1. Server Requirements
- Ubuntu 22.04 LTS VPS/Droplet
- 2+ GB RAM, 2+ CPU cores
- 20+ GB storage
- Root access initially
- Static IP address

### 2. Domain Setup
- Domain registered and managed through Cloudflare
- DNS API access (optional, for automation)

### 3. Local Setup
- SSH access to the new server
- This repository cloned locally
- rsync installed locally

## Quick Setup (Recommended)

### 1. Run the automated setup script:
```bash
# From your local machine
cd advent-hymnals-mono-repo
./scripts/setup-production-server.sh yourdomain.com YOUR_SERVER_IP admin@yourdomain.com
```

### 2. Configure DNS in Cloudflare:
```
A    yourdomain.com       -> YOUR_SERVER_IP (Proxied 🟠)
A    www.yourdomain.com   -> YOUR_SERVER_IP (Proxied 🟠)  
A    media.yourdomain.com -> YOUR_SERVER_IP (Proxied 🟠)
A    direct.yourdomain.com-> YOUR_SERVER_IP (DNS-only 🔘)
```

### 3. Update GitHub repository secrets:
```bash
gh secret set DEPLOY_HOST --body "direct.yourdomain.com"
gh secret set DEPLOY_USER --body "deploy"
gh secret set DEPLOY_SSH_KEY --body "$(cat ~/.ssh/id_rsa)"
```

### 4. Test deployment:
```bash
gh workflow run deploy.yml
```

## Manual Setup (Alternative)

If you prefer manual setup or need customization:

### 1. Server Preparation
```bash
# SSH to new server as root
ssh root@YOUR_SERVER_IP

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create deploy user
useradd -m -s /bin/bash deploy
usermod -aG docker deploy
mkdir -p /opt/advent-hymnals
chown -R deploy:deploy /opt/advent-hymnals
```

### 2. Application Setup
```bash
# Switch to deploy user
su - deploy
cd /opt/advent-hymnals

# Clone repository
git clone https://github.com/adventHymnals/advent-hymnals-web.git .

# Setup domains
echo "yourdomain.com www.yourdomain.com media.yourdomain.com" > nginx/domains.txt

# Create directories
mkdir -p data/sources/{audio,images,pdf} logs nginx/ssl backups
```

### 3. Upload Data
```bash
# From your local machine
rsync -avz data/sources/ deploy@YOUR_SERVER_IP:/opt/advent-hymnals/data/sources/
```

### 4. Deploy
```bash
# On server as deploy user
cd /opt/advent-hymnals

# Create network
docker network create web-network

# Start services
docker-compose up -d
```

## Verification Checklist

After setup, verify these endpoints:

- [ ] `https://yourdomain.com` - Main website loads
- [ ] `https://www.yourdomain.com` - Redirects to main site
- [ ] `https://media.yourdomain.com/health` - Returns "healthy"
- [ ] `https://media.yourdomain.com/audio/SDAH/1.mid` - Serves MIDI file
- [ ] `https://direct.yourdomain.com` - Accessible via SSH (for deployment)

## Continuous Deployment

The setup includes automated deployment workflows:

### 1. Web Application Updates
- Triggered on code changes to `main` branch
- Builds and deploys new web application version
- Uses `direct.yourdomain.com` for SSH access

### 2. Media File Updates  
- Triggered on changes to `data/sources/`
- Syncs media files to production server
- Restarts media server to refresh content

### 3. Infrastructure Updates
- Triggered on changes to Docker configuration
- Updates containers and nginx configuration
- Maintains zero-downtime deployment

## Troubleshooting

### SSL Certificate Issues
```bash
# Check certificate status
ssh deploy@direct.yourdomain.com "docker exec advent-hymnals-nginx openssl x509 -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem -text -noout | grep DNS"

# Force certificate renewal
ssh deploy@direct.yourdomain.com "docker exec advent-hymnals-nginx certbot renew --force-renewal"
```

### Container Issues
```bash
# Check container status
ssh deploy@direct.yourdomain.com "cd /opt/advent-hymnals && docker-compose ps"

# View logs
ssh deploy@direct.yourdomain.com "cd /opt/advent-hymnals && docker-compose logs"

# Restart services
ssh deploy@direct.yourdomain.com "cd /opt/advent-hymnals && docker-compose restart"
```

### Media Server Issues
```bash
# Check media files
ssh deploy@direct.yourdomain.com "ls -la /opt/advent-hymnals/data/sources/audio/"

# Test media server directly
ssh deploy@direct.yourdomain.com "docker exec advent-hymnals-media curl -I http://localhost/health"
```

## Scaling Considerations

### When to Move to Separate Media Server:
- Media files exceed 10GB
- High concurrent audio streaming (>100 users)
- Need better geographic distribution
- Storage costs become significant

### Migration Path:
1. **Cloud Storage**: Move files to S3/Spaces
2. **CDN**: Use Cloudflare R2 or AWS CloudFront  
3. **Separate Server**: Dedicated media server
4. **Microservices**: Full service separation

## Security Notes

- Uses non-root deployment user
- SSL certificates auto-renewed
- Firewall configured for ports 80, 443, 22 only
- Container isolation
- Regular security updates via unattended-upgrades

## Backup Strategy

Essential backups:
- Database dumps (if using database)
- Media files (`data/sources/`)
- SSL certificates
- Application configuration

```bash
# Backup script
ssh deploy@direct.yourdomain.com "cd /opt/advent-hymnals && tar czf backup-$(date +%Y%m%d).tar.gz data/ .env nginx/domains.txt"
```