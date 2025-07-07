FROM nginx:alpine

# Install certbot
RUN apk add --no-cache certbot certbot-nginx

# Copy SSL setup script
COPY ssl-setup.sh /usr/local/bin/ssl-setup.sh
COPY nginx-entrypoint.sh /usr/local/bin/nginx-entrypoint.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/ssl-setup.sh /usr/local/bin/nginx-entrypoint.sh

# Create necessary directories
RUN mkdir -p /var/www/certbot /etc/nginx/conf.d

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]