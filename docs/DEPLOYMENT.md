# Deployment Guide

This guide explains how to deploy the Advent Hymnals application using Docker and GitHub Actions.

## Prerequisites

1. A server with Docker and Docker Compose installed
2. SSH access to the deployment server
3. GitHub repository with necessary secrets configured

## Required GitHub Secrets

Configure the following secrets in your GitHub repository settings:

### Deployment Secrets
- `DEPLOY_HOST`: IP address or hostname of your deployment server
- `DEPLOY_USER`: SSH username for the deployment server
- `DEPLOY_SSH_KEY`: Private SSH key for authentication
- `DEPLOY_PORT`: SSH port (optional, defaults to 22)

### Application Secrets
- `NEXT_PUBLIC_GA_ID`: Google Analytics measurement ID (e.g., G-JPQZVQ70L9)
- `GOOGLE_VERIFICATION`: Google Search Console verification code
- `YANDEX_VERIFICATION`: Yandex verification code

## Generating SSH Keys for Deployment

1. On your local machine, generate a new SSH key pair:
```bash
ssh-keygen -t ed25519 -C "deployment@adventhymnals.org" -f advent-hymnals-deploy
```

2. Copy the public key to your deployment server:
```bash
ssh-copy-id -i advent-hymnals-deploy.pub user@your-server.com
```

3. Add the private key content to GitHub Secrets:
```bash
cat advent-hymnals-deploy
# Copy the entire output to DEPLOY_SSH_KEY secret
```

## Server Setup

1. Install Docker and Docker Compose on your server:
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. Create deployment directory:
```bash
sudo mkdir -p /opt/advent-hymnals
sudo chown $USER:$USER /opt/advent-hymnals
```

## Manual Deployment

If you need to deploy manually:

1. Clone the repository:
```bash
git clone https://github.com/adventhymnals/advent-hymnals-mono-repo.git
cd advent-hymnals-mono-repo
```

2. Create environment file:
```bash
cp .env.production .env.production.local
# Edit with your actual values
```

3. Build and run:
```bash
docker compose up -d
```

## Deployment Process

The GitHub Actions workflow automatically:

1. **Build**: Creates a Docker image with the latest code
2. **Push**: Uploads the image to GitHub Container Registry (ghcr.io)
3. **Deploy**: SSH into the server and updates the running containers

## Monitoring

### Health Check
The application includes a health check endpoint: `http://your-domain.com/api/health`

### Logs
View application logs:
```bash
docker compose logs -f advent-hymnals-web
```

### Container Status
Check container status:
```bash
docker compose ps
```

## Domain Configuration

1. Configure your domain DNS to point to your server's IP address
2. Set up a reverse proxy (nginx, Cloudflare, etc.) to handle HTTPS
3. Update the `SITE_URL` environment variable

## Backup

The application uses a Docker volume for persistent data:
```bash
# Backup hymnal data
docker run --rm -v advent-hymnals_hymnal-data:/data -v $(pwd):/backup alpine tar czf /backup/hymnal-data.tar.gz /data

# Restore hymnal data
docker run --rm -v advent-hymnals_hymnal-data:/data -v $(pwd):/backup alpine tar xzf /backup/hymnal-data.tar.gz -C /
```

## Troubleshooting

### Container Won't Start
```bash
docker compose logs advent-hymnals-web
```

### Permission Issues
```bash
sudo chown -R 1001:1001 /path/to/data/volume
```

### Network Issues
```bash
docker network ls
docker network inspect advent-hymnals_default
```

## Security Considerations

1. Use HTTPS in production (configure reverse proxy)
2. Keep Docker and the host system updated
3. Regularly rotate SSH keys
4. Monitor logs for suspicious activity
5. Use strong passwords for server access