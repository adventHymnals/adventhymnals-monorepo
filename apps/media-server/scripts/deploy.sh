#!/bin/bash

# Production deployment script for media server
# Usage: ./deploy.sh [server_host] [user]

set -e

SERVER_HOST=${1:-"media.adventhymnals.org"}
USER=${2:-"deploy"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Deploying Media Server"
echo "========================="
echo "Target: $USER@$SERVER_HOST"
echo "Source: $APP_DIR"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we can connect to the server
print_status "Testing connection to $SERVER_HOST..."
if ! ssh -o ConnectTimeout=10 "$USER@$SERVER_HOST" "echo 'Connection successful'" 2>/dev/null; then
    print_error "Cannot connect to $USER@$SERVER_HOST"
    echo "Please ensure:"
    echo "  1. SSH key is set up for $USER@$SERVER_HOST"
    echo "  2. Server is accessible"
    echo "  3. User has appropriate permissions"
    exit 1
fi

# Create remote directory structure
print_status "Creating remote directory structure..."
ssh "$USER@$SERVER_HOST" "mkdir -p /opt/media-server"

# Sync application files
print_status "Syncing application files..."
rsync -avz --delete \
    --exclude='.git*' \
    --exclude='node_modules' \
    --exclude='*.log' \
    "$APP_DIR/" "$USER@$SERVER_HOST:/opt/media-server/"

# Sync media files from data repository
print_status "Syncing media files..."
DATA_DIR="$APP_DIR/../../data/sources"
if [ -d "$DATA_DIR" ]; then
    rsync -avz --delete \
        --include='audio/' \
        --include='images/' \
        --include='audio/**' \
        --include='images/**' \
        --exclude='*' \
        "$DATA_DIR/" "$USER@$SERVER_HOST:/opt/media-server/media-files/"
else
    print_warning "Data directory not found at $DATA_DIR"
    print_warning "You may need to sync media files manually"
fi

# Deploy Docker containers
print_status "Deploying Docker containers..."
ssh "$USER@$SERVER_HOST" "cd /opt/media-server && docker-compose pull"
ssh "$USER@$SERVER_HOST" "cd /opt/media-server && docker-compose up -d"

# Wait for containers to start
print_status "Waiting for containers to start..."
sleep 10

# Health check
print_status "Performing health check..."
if ssh "$USER@$SERVER_HOST" "curl -f http://localhost/health" 2>/dev/null; then
    print_status "✅ Health check passed!"
else
    print_error "❌ Health check failed!"
    print_status "Checking container status..."
    ssh "$USER@$SERVER_HOST" "cd /opt/media-server && docker-compose ps"
    print_status "Checking logs..."
    ssh "$USER@$SERVER_HOST" "cd /opt/media-server && docker-compose logs --tail=20 media-server"
    exit 1
fi

# Test a few sample endpoints
print_status "Testing sample endpoints..."
ssh "$USER@$SERVER_HOST" "curl -s -o /dev/null -w 'Health check: %{http_code}\n' http://localhost/health"
ssh "$USER@$SERVER_HOST" "curl -s -o /dev/null -w 'Audio test: %{http_code}\n' http://localhost/audio/CH1941/1.mp3 || echo 'Audio test: File not found (OK)'"
ssh "$USER@$SERVER_HOST" "curl -s -o /dev/null -w 'Image test: %{http_code}\n' http://localhost/images/CH1941/001.png || echo 'Image test: File not found (OK)'"

print_status "✅ Deployment completed successfully!"
echo ""
echo "🔗 Your media server should be available at: https://$SERVER_HOST"
echo ""
echo "📋 Next steps:"
echo "  1. Configure your CDN/proxy to point to this server"
echo "  2. Set up SSL certificates (Let's Encrypt recommended)"
echo "  3. Configure monitoring and alerting"
echo "  4. Update DNS records if needed"
echo ""
echo "🛠️  Management commands:"
echo "  View logs:    ssh $USER@$SERVER_HOST 'cd /opt/media-server && docker-compose logs -f'"
echo "  Restart:      ssh $USER@$SERVER_HOST 'cd /opt/media-server && docker-compose restart'"
echo "  Update:       ./deploy.sh $SERVER_HOST $USER"