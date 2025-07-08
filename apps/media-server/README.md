# Media Server

Static file server for serving hymnal images and audio files at `media.adventhymnals.org`.

## Overview

This is a lightweight Nginx-based static file server that serves media files from the `data/sources` directory. It's optimized for:

- **Audio files**: MP3, MIDI files with range request support for seeking
- **Images**: JPG, PNG, WebP with proper caching headers
- **Performance**: Gzip compression and long-term caching
- **Security**: CORS headers and basic protection mechanisms

## Quick Start

### Local Development

1. **Start the server**:
   ```bash
   cd apps/media-server
   docker-compose up -d
   ```

2. **Test endpoints**:
   ```bash
   # Health check
   curl http://localhost:8080/health
   
   # Test audio file (if exists)
   curl -I http://localhost:8080/audio/CH1941/1.mp3
   
   # Test image file (if exists) 
   curl -I http://localhost:8080/images/CH1941/page-001.jpg
   ```

3. **View logs** (optional):
   ```bash
   # Start with log viewer
   docker-compose --profile development up -d
   
   # Visit http://localhost:9999 for log viewer
   ```

4. **Stop the server**:
   ```bash
   docker-compose down
   ```

### Production Deployment

The media server is automatically deployed when changes are made to `data/sources/` directory.

**Deployment URL**: `https://media.adventhymnals.org`

## API Endpoints

### Health Check
```
GET /health
```
Returns: `healthy` (200 OK)

### Audio Files
```
GET /audio/{hymnal_id}/{filename}
```
Example: `GET /audio/CH1941/1.mp3`

**Features**:
- Range request support for audio seeking
- Long-term caching (1 year)
- CORS enabled for cross-origin requests

### Image Files
```
GET /images/{hymnal_id}/{filename}
```
Example: `GET /images/CH1941/page-001.jpg`

**Features**:
- Long-term caching (1 year)
- CORS enabled for cross-origin requests
- Supports JPG, PNG, WebP, SVG formats

## Configuration

### Docker Compose

- **Port**: 8080 (local development)
- **Volume**: Maps `../../data/sources` to nginx document root
- **Health Check**: Automated container health monitoring

### Nginx Configuration

- **Gzip Compression**: Enabled for text and SVG files
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Cache Control**: 1-year expiration for static media files
- **CORS**: Enabled for hymnal website integration

## File Structure

```
apps/media-server/
├── docker-compose.yml      # Container orchestration
├── nginx.conf             # Nginx server configuration
├── README.md              # This file
└── scripts/               # Deployment and utility scripts
    ├── deploy.sh          # Production deployment script
    ├── test-endpoints.sh  # Local testing script
    └── sync-check.sh      # File synchronization verification
```

## Development

### Adding New File Types

To support additional file formats, update `nginx.conf`:

```nginx
# Add to audio location block
location ~* ^/audio/.+\.(mp3|mid|midi|wav|ogg|m4a|newformat)$ {
    # ... existing config
}
```

### Testing Locally

```bash
# Test health endpoint
curl http://localhost:8080/health

# Test with actual files from data directory
ls ../../data/sources/audio/  # See available audio files
ls ../../data/sources/images/ # See available image files

# Test file serving
curl -I http://localhost:8080/audio/CH1941/1.mp3
curl -I http://localhost:8080/images/CH1941/page-001.jpg
```

### Debugging

```bash
# View nginx logs
docker-compose logs media-server

# Follow logs in real-time
docker-compose logs -f media-server

# Access container shell
docker-compose exec media-server sh

# Check nginx configuration
docker-compose exec media-server nginx -t
```

## Production Deployment

The media server is deployed automatically via GitHub Actions when:

1. Files are added/changed in `data/sources/`
2. Media server configuration is updated
3. Manual deployment is triggered

**Deployment Process**:
1. Sync media files to production server
2. Update nginx configuration
3. Restart containers with zero downtime
4. Perform health checks
5. Update CDN cache if needed

## Monitoring

### Health Checks

- **Container Health**: Docker health check every 30 seconds
- **HTTP Health**: `/health` endpoint monitoring
- **File Availability**: Automated testing of sample files

### Metrics

- **Response Times**: Nginx access log analysis
- **Bandwidth Usage**: Monthly data transfer monitoring
- **Error Rates**: 404 and 5xx error tracking
- **Geographic Distribution**: CDN analytics

### Alerts

- **Server Down**: Health check failures
- **High Error Rate**: >5% 4xx/5xx responses
- **Bandwidth Threshold**: Approaching monthly limits
- **Storage Space**: Disk usage >80%

## Security

### Current Protections

- **CORS Configuration**: Controlled cross-origin access
- **Security Headers**: XSS, clickjacking protection
- **Hidden Files**: Block access to dotfiles and backups
- **Server Information**: Hide nginx version

### Optional Enhancements

```nginx
# Uncomment in nginx.conf for hotlink protection
valid_referers none blocked server_names *.adventhymnals.org adventhymnals.org;
if ($invalid_referer) {
    return 403;
}
```

### Rate Limiting (Future)

```nginx
# Add to http block for rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req zone=api burst=20 nodelay;
```

## Performance

### Optimization Features

- **Gzip Compression**: Reduces bandwidth for text-based files
- **Long-term Caching**: 1-year cache headers for immutable files
- **Sendfile**: Efficient file transfer with kernel space operations
- **Keep-alive**: Persistent connections for multiple requests

### Capacity Planning

- **Current Storage**: ~20GB media files
- **Projected Growth**: ~50GB annually
- **Bandwidth**: ~1TB/month estimated
- **Concurrent Users**: 1000+ supported with current configuration

## Troubleshooting

### Common Issues

**Files not found (404)**:
- Verify file exists in `data/sources/`
- Check file permissions
- Confirm nginx container can access volume

**CORS errors**:
- Verify Access-Control headers in response
- Check browser console for specific error
- Test with curl to isolate browser issues

**Performance issues**:
- Check nginx access logs for slow requests
- Monitor container resource usage
- Verify CDN is properly configured

**Container startup failures**:
- Validate nginx configuration: `nginx -t`
- Check docker-compose logs
- Verify port availability (8080)