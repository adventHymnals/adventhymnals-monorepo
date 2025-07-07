#!/bin/bash
set -e

DOMAIN="adventhymnals.org"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"

echo "🚀 Starting nginx setup for $DOMAIN..."

# Check if SSL certificates exist
if [ -f "$CERT_PATH" ]; then
    echo "✅ SSL certificates found, using HTTPS configuration"
    
    # Create HTTPS configuration
    cat > /etc/nginx/conf.d/default.conf << 'EOF'
# HTTP redirect to HTTPS
server {
    listen 80;
    server_name adventhymnals.org www.adventhymnals.org;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name adventhymnals.org www.adventhymnals.org;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/adventhymnals.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/adventhymnals.org/privkey.pem;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Proxy to Next.js app
    location / {
        proxy_pass http://advent-hymnals-web:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Static file caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
        proxy_pass http://advent-hymnals-web:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

else
    echo "🔐 No SSL certificates found, using HTTP-only configuration for certificate generation"
    
    # Create HTTP-only configuration for certificate generation
    cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name adventhymnals.org www.adventhymnals.org;
    
    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Proxy to Next.js app
    location / {
        proxy_pass http://advent-hymnals-web:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

fi

echo "📝 Nginx configuration created successfully"

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

echo "✅ Nginx setup completed successfully"