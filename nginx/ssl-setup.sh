#!/bin/bash

# Automated SSL Certificate Setup Script
# This script automatically configures nginx for SSL certificate generation and usage

DOMAIN="adventhymnals.org"
NGINX_CONF_DIR="/etc/nginx/conf.d"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
NGINX_HTTP_CONF="/etc/nginx/conf.d/adventhymnals-http.conf"
NGINX_SSL_CONF="/etc/nginx/conf.d/adventhymnals-ssl.conf"

echo "🔧 Starting automated SSL certificate setup for $DOMAIN..."

# Function to create HTTP-only nginx config for certificate generation
create_http_config() {
    echo "📝 Creating HTTP-only nginx configuration..."
    cat > $NGINX_HTTP_CONF << 'EOF'
server {
    listen 80;
    server_name adventhymnals.org www.adventhymnals.org;

    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirect all other traffic to app (temporary during cert generation)
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
}

# Function to create SSL nginx config
create_ssl_config() {
    echo "📝 Creating SSL nginx configuration..."
    cat > $NGINX_SSL_CONF << 'EOF'
server {
    listen 80;
    server_name adventhymnals.org www.adventhymnals.org;

    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirect all HTTP traffic to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name adventhymnals.org www.adventhymnals.org;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/adventhymnals.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/adventhymnals.org/privkey.pem;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
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
}

# Function to reload nginx safely
reload_nginx() {
    echo "🔄 Reloading nginx configuration..."
    if nginx -t; then
        nginx -s reload
        echo "✅ Nginx reloaded successfully"
    else
        echo "❌ Nginx configuration test failed"
        return 1
    fi
}

# Main logic
if [ -f "$CERT_DIR/fullchain.pem" ] && [ -f "$CERT_DIR/privkey.pem" ]; then
    echo "✅ SSL certificates found, using SSL configuration"
    
    # Remove HTTP-only config if it exists
    [ -f "$NGINX_HTTP_CONF" ] && rm "$NGINX_HTTP_CONF"
    
    # Create SSL config
    create_ssl_config
    reload_nginx
    
    echo "🌐 Site available at: https://$DOMAIN"
else
    echo "🔐 No SSL certificates found, setting up for certificate generation"
    
    # Remove SSL config if it exists
    [ -f "$NGINX_SSL_CONF" ] && rm "$NGINX_SSL_CONF"
    
    # Create HTTP-only config
    create_http_config
    reload_nginx
    
    echo "📋 Requesting SSL certificate..."
    
    # Request certificate (production)
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email admin@$DOMAIN \
        --agree-tos \
        --no-eff-email \
        -d $DOMAIN \
        -d www.$DOMAIN
    
    if [ $? -eq 0 ]; then
        echo "✅ Certificate generated successfully"
        
        # Now switch to SSL configuration
        rm "$NGINX_HTTP_CONF"
        create_ssl_config
        reload_nginx
        
        echo "🌐 Site now available at: https://$DOMAIN"
    else
        echo "❌ Certificate generation failed"
        echo "🌐 Site available at: http://$DOMAIN (HTTP only)"
        exit 1
    fi
fi

echo "🎉 SSL setup completed successfully!"