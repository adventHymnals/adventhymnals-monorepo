#!/bin/bash

# Test script for media server endpoints
# Usage: ./test-endpoints.sh [base_url]

BASE_URL=${1:-"http://localhost:8080"}

echo "🧪 Testing Media Server Endpoints"
echo "================================="
echo "Base URL: $BASE_URL"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local endpoint=$1
    local expected_status=${2:-200}
    local description=$3
    
    echo -n "Testing $description... "
    
    status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✓ $status${NC}"
        return 0
    else
        echo -e "${RED}✗ $status (expected $expected_status)${NC}"
        return 1
    fi
}

# Health check
test_endpoint "/health" 200 "Health check"

# Root endpoint
test_endpoint "/" 200 "Root endpoint"

# Test audio files (if they exist)
echo ""
echo "🎵 Testing Audio Files:"
test_endpoint "/audio/CH1941/1.mp3" 200 "CH1941 MP3 file" || test_endpoint "/audio/CH1941/1.mp3" 404 "CH1941 MP3 file (not found is OK)"
test_endpoint "/audio/CH1941/1.mid" 200 "CH1941 MIDI file" || test_endpoint "/audio/CH1941/1.mid" 404 "CH1941 MIDI file (not found is OK)"
test_endpoint "/audio/SDAH/1.mid" 200 "SDAH MIDI file" || test_endpoint "/audio/SDAH/1.mid" 404 "SDAH MIDI file (not found is OK)"

# Test image files (if they exist)
echo ""
echo "🖼️  Testing Image Files:"
test_endpoint "/images/CH1941/001.png" 200 "CH1941 PNG image" || test_endpoint "/images/CH1941/001.png" 404 "CH1941 PNG image (not found is OK)"
test_endpoint "/images/SDAH/001.png" 200 "SDAH PNG image" || test_endpoint "/images/SDAH/001.png" 404 "SDAH PNG image (not found is OK)"

# Test CORS headers
echo ""
echo "🌐 Testing CORS Headers:"
cors_header=$(curl -s -I "$BASE_URL/health" | grep -i "access-control-allow-origin" | head -1)
if [ -n "$cors_header" ]; then
    echo -e "${GREEN}✓ CORS header present: $cors_header${NC}"
else
    echo -e "${YELLOW}⚠ CORS header not found${NC}"
fi

# Test caching headers
echo ""
echo "💾 Testing Cache Headers:"
cache_header=$(curl -s -I "$BASE_URL/audio/CH1941/1.mp3" 2>/dev/null | grep -i "cache-control" | head -1)
if [ -n "$cache_header" ]; then
    echo -e "${GREEN}✓ Cache header present: $cache_header${NC}"
else
    echo -e "${YELLOW}⚠ Cache header not found (file may not exist)${NC}"
fi

# Test non-existent paths
echo ""
echo "🚫 Testing Error Handling:"
test_endpoint "/nonexistent" 404 "Non-existent path"
test_endpoint "/audio/nonexistent.mp3" 404 "Non-existent audio file"
test_endpoint "/images/nonexistent.jpg" 404 "Non-existent image file"

echo ""
echo "✅ Testing complete!"
echo ""
echo "💡 Tips:"
echo "  - Use 'docker-compose logs media-server' to view server logs"
echo "  - Visit http://localhost:9999 for log viewer (with --profile development)"
echo "  - Check nginx configuration with: docker-compose exec media-server nginx -t"