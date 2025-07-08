#!/bin/bash
set -e

# Production Server Setup Script for Advent Hymnals
# Usage: ./setup-production-server.sh <domain> <server-ip>
# Example: ./setup-production-server.sh adventhymnals.org 143.198.237.6

DOMAIN=${1:-adventhymnals.org}
SERVER_IP=${2}
ADMIN_EMAIL=${3:-admin@$DOMAIN}

if [ -z "$SERVER_IP" ]; then
    echo "Usage: $0 <domain> <server-ip> [admin-email]"
    echo "Example: $0 adventhymnals.org 143.198.237.6 admin@adventhymnals.org"
    exit 1
fi

echo "🚀 Setting up production server for $DOMAIN on $SERVER_IP"

# 1. Install Docker and dependencies
echo "📦 Installing Docker and dependencies..."
ssh root@$SERVER_IP << 'EOF'
# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install additional tools
apt-get install -y git rsync curl wget nginx certbot python3-certbot-nginx

# Create deployment user
useradd -m -s /bin/bash deploy
usermod -aG docker deploy
mkdir -p /home/deploy/.ssh
mkdir -p /opt/advent-hymnals
chown -R deploy:deploy /opt/advent-hymnals
EOF

# 2. Setup SSH access for deployment user
echo "🔑 Setting up SSH access..."
ssh-copy-id deploy@$SERVER_IP

# 3. Clone and setup the application
echo "📥 Setting up application..."
ssh deploy@$SERVER_IP << EOF
cd /opt/advent-hymnals

# Clone the repository
git clone https://github.com/adventHymnals/advent-hymnals-web.git .

# Create domains.txt
echo "$DOMAIN www.$DOMAIN media.$DOMAIN" > nginx/domains.txt

# Create data directories
mkdir -p data/sources/{audio,images,pdf}
mkdir -p logs nginx/ssl data backups

# Set permissions
sudo chown -R 1001:1001 data/
EOF

# 4. Upload media files
echo "📁 Uploading media files..."
rsync -avz --progress data/sources/ deploy@$SERVER_IP:/opt/advent-hymnals/data/sources/

# 5. Setup environment and secrets
echo "⚙️ Setting up environment..."
ssh deploy@$SERVER_IP << EOF
cd /opt/advent-hymnals

# Create production environment file
cat > .env << ENVEOF
# Production Environment Variables for Advent Hymnals
SITE_URL=https://$DOMAIN
NEXT_PUBLIC_SITE_URL=https://$DOMAIN
NODE_ENV=production

# Analytics and Verification (update these with real values)
NEXT_PUBLIC_GA_ID=
GOOGLE_VERIFICATION=
YANDEX_VERIFICATION=
ENVEOF

# Create external network
docker network create web-network || true
EOF

# 6. Initial deployment
echo "🚀 Starting initial deployment..."
ssh deploy@$SERVER_IP << 'EOF'
cd /opt/advent-hymnals

# Pull images
docker-compose pull

# Start containers (this will trigger SSL certificate generation)
docker-compose up -d

# Wait for services to start
echo "⏱️ Waiting for services to start..."
sleep 30

# Check status
docker-compose ps
EOF

# 7. Verify deployment
echo "✅ Verifying deployment..."
sleep 10

# Test main site
if curl -sf https://$DOMAIN > /dev/null; then
    echo "✅ Main site ($DOMAIN) is accessible"
else
    echo "❌ Main site ($DOMAIN) is not accessible"
fi

# Test media server
if curl -sf https://media.$DOMAIN/health > /dev/null; then
    echo "✅ Media server (media.$DOMAIN) is accessible"
else
    echo "❌ Media server (media.$DOMAIN) is not accessible"
fi

echo ""
echo "🎉 Production server setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update DNS records:"
echo "   - $DOMAIN -> $SERVER_IP (Proxied through Cloudflare)"
echo "   - www.$DOMAIN -> $SERVER_IP (Proxied through Cloudflare)" 
echo "   - media.$DOMAIN -> $SERVER_IP (Proxied through Cloudflare)"
echo "   - direct.$DOMAIN -> $SERVER_IP (DNS-only, for deployment access)"
echo ""
echo "2. Update GitHub repository secrets:"
echo "   - DEPLOY_HOST: direct.$DOMAIN"
echo "   - DEPLOY_USER: deploy"
echo "   - DEPLOY_SSH_KEY: (private key for deploy user)"
echo ""
echo "3. Configure analytics and verification codes in .env"
echo ""
echo "4. Test the deployment workflow"
echo ""
echo "🌐 Your sites should be available at:"
echo "   - Main site: https://$DOMAIN"
echo "   - Media server: https://media.$DOMAIN"
echo "   - Health check: https://media.$DOMAIN/health"