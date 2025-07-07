#!/bin/bash

# Nginx entrypoint script for automated SSL certificate management
# This script runs when the nginx container starts and automatically configures SSL

echo "🚀 Starting nginx with automated SSL management..."

# Wait for certbot volume to be ready
sleep 5

# Run SSL setup script
/usr/local/bin/ssl-setup.sh

# Start nginx in the foreground
echo "▶️ Starting nginx daemon..."
exec nginx -g "daemon off;"