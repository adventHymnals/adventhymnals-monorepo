#!/bin/bash

# Simple SSL setup script for adventhymnals.org
# This script requests SSL certificates and updates nginx configuration

DOMAIN="adventhymnals.org"
COMPOSE_DIR="/opt/advent-hymnals"

echo "🔐 Setting up SSL certificates for $DOMAIN..."

cd "$COMPOSE_DIR"

# Request certificate using the existing nginx container
echo "📋 Requesting SSL certificate..."
docker compose exec certbot certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email admin@$DOMAIN \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

if [ $? -eq 0 ]; then
    echo "✅ Certificate generated successfully!"
    
    echo "🔄 Updating nginx configuration for SSL..."
    
    # Create SSL configuration
    docker compose exec nginx sh -c "cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name adventhymnals.org www.adventhymnals.org;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name adventhymnals.org www.adventhymnals.org;
    
    ssl_certificate /etc/letsencrypt/live/adventhymnals.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/adventhymnals.org/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header Referrer-Policy \"strict-origin-when-cross-origin\" always;
    
    location / {
        proxy_pass http://advent-hymnals-web:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location ~* \\.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)\$ {
        proxy_pass http://advent-hymnals-web:3000;
        expires 1y;
        add_header Cache-Control \"public, immutable\";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF"
    
    # Reload nginx
    docker compose exec nginx nginx -s reload
    
    echo "🎉 SSL setup completed successfully!"
    echo "🌐 Your site is now available at: https://$DOMAIN"
else
    echo "❌ Certificate generation failed!"
    echo "🌐 Site remains available at: http://$DOMAIN"
    exit 1
fi