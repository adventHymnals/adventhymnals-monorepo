#!/bin/bash
# One-command production deployment script
# Usage: ./deploy-new-production.sh

set -e

echo "🚀 Advent Hymnals Production Deployment"
echo "======================================="

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "data/sources" ]; then
    echo "❌ Please run this script from the advent-hymnals-mono-repo root directory"
    exit 1
fi

# Collect information
read -p "🌐 Enter your domain (e.g., adventhymnals.org): " DOMAIN
read -p "🖥️  Enter your server IP address: " SERVER_IP
read -p "📧 Enter admin email (default: admin@$DOMAIN): " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@$DOMAIN}

echo ""
echo "📋 Configuration Summary:"
echo "   Domain: $DOMAIN"
echo "   Server IP: $SERVER_IP"
echo "   Admin Email: $ADMIN_EMAIL"
echo ""
read -p "Continue with deployment? (y/N): " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

echo ""
echo "🔧 Starting automated deployment..."

# 1. Run server setup
echo "📦 Step 1/4: Setting up server infrastructure..."
./scripts/setup-production-server.sh "$DOMAIN" "$SERVER_IP" "$ADMIN_EMAIL"

# 2. Configure GitHub secrets
echo "🔑 Step 2/4: Configuring GitHub deployment secrets..."
if command -v gh &> /dev/null; then
    gh secret set DEPLOY_HOST --body "direct.$DOMAIN"
    gh secret set DEPLOY_USER --body "deploy"
    
    # Check if SSH key exists
    if [ -f ~/.ssh/id_rsa ]; then
        gh secret set DEPLOY_SSH_KEY --body "$(cat ~/.ssh/id_rsa)"
        echo "✅ GitHub secrets configured successfully"
    else
        echo "⚠️  SSH key not found at ~/.ssh/id_rsa"
        echo "   Please manually set DEPLOY_SSH_KEY secret in GitHub"
    fi
else
    echo "⚠️  GitHub CLI not found. Please manually configure secrets:"
    echo "   DEPLOY_HOST: direct.$DOMAIN"
    echo "   DEPLOY_USER: deploy"
    echo "   DEPLOY_SSH_KEY: [your SSH private key]"
fi

# 3. Display DNS configuration
echo ""
echo "🌐 Step 3/4: DNS Configuration Required"
echo "======================================="
echo "Please configure these DNS records in Cloudflare:"
echo ""
echo "Record Type | Name              | Target      | Proxy Status"
echo "------------|-------------------|-------------|-------------"
echo "A           | $DOMAIN           | $SERVER_IP  | Proxied 🟠"
echo "A           | www.$DOMAIN       | $SERVER_IP  | Proxied 🟠"
echo "A           | media.$DOMAIN     | $SERVER_IP  | Proxied 🟠"
echo "A           | direct.$DOMAIN    | $SERVER_IP  | DNS-only 🔘"
echo ""
read -p "Press Enter when DNS records are configured..."

# 4. Test deployment
echo ""
echo "🧪 Step 4/4: Testing deployment..."

# Wait for DNS propagation
echo "⏱️  Waiting for DNS propagation..."
sleep 30

# Test endpoints
echo "🔍 Testing endpoints..."

if curl -sf --max-time 10 "https://$DOMAIN" > /dev/null 2>&1; then
    echo "✅ Main site (https://$DOMAIN) is accessible"
else
    echo "⚠️  Main site not yet accessible (DNS may still be propagating)"
fi

if curl -sf --max-time 10 "https://media.$DOMAIN/health" > /dev/null 2>&1; then
    echo "✅ Media server (https://media.$DOMAIN) is accessible"
else
    echo "⚠️  Media server not yet accessible (DNS may still be propagating)"
fi

# Trigger GitHub deployment
if command -v gh &> /dev/null; then
    echo "🚀 Triggering GitHub deployment workflow..."
    gh workflow run deploy.yml
    echo "✅ Deployment workflow triggered"
else
    echo "⚠️  Please manually trigger the deploy.yml workflow in GitHub Actions"
fi

echo ""
echo "🎉 Production Deployment Complete!"
echo "=================================="
echo ""
echo "🌐 Your sites:"
echo "   Main site: https://$DOMAIN"
echo "   Media server: https://media.$DOMAIN"
echo "   Health check: https://media.$DOMAIN/health"
echo ""
echo "🔧 Management:"
echo "   SSH access: ssh deploy@direct.$DOMAIN"
echo "   Docker logs: ssh deploy@direct.$DOMAIN 'cd /opt/advent-hymnals && docker-compose logs'"
echo "   Restart: ssh deploy@direct.$DOMAIN 'cd /opt/advent-hymnals && docker-compose restart'"
echo ""
echo "📋 Next steps:"
echo "   1. Verify all sites are accessible"
echo "   2. Test audio file serving: https://media.$DOMAIN/audio/SDAH/1.mid"
echo "   3. Configure analytics (update .env on server)"
echo "   4. Set up monitoring and backups"
echo ""
echo "🎵 Happy hymn singing! 🎵"