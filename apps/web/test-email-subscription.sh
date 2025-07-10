#!/bin/bash

# Test script for Advent Hymnals Email Subscription System

WEB_APP_URL="https://script.google.com/macros/s/AKfycbzxG_DpZYLNe8QsEqPBY499zO0GUoPs-KUGC06qqVDOYolbCrkZHAwd4Au2kjIhe7EQKg/exec"

echo "🧪 Testing Advent Hymnals Email Subscription System"
echo "=================================================="
echo ""

# Test 1: GET request (should work)
echo "📡 Test 1: GET request (API status check)"
echo "-------------------------------------------"
response=$(curl -s -X GET "$WEB_APP_URL")
echo "Response: $response"
echo ""

# Test 2: POST request with email data
echo "📧 Test 2: POST request (email subscription)"
echo "-------------------------------------------"
curl -v -X POST "$WEB_APP_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@adventhymnals.org",
    "source": "cli_test",
    "timestamp": "'$(date -Iseconds)'",
    "userAgent": "Test Script",
    "referer": "CLI Testing"
  }'
echo ""
echo ""

# Test 3: POST request via browser simulation
echo "🌐 Test 3: POST request (browser simulation)"
echo "-------------------------------------------"
curl -v -X POST "$WEB_APP_URL" \
  -H "Content-Type: application/json" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
  -H "Accept: application/json, text/plain, */*" \
  -H "Origin: https://adventhymnals.org" \
  -H "Referer: https://adventhymnals.org/" \
  -d '{
    "email": "browser-test@adventhymnals.org",
    "source": "browser_test",
    "timestamp": "'$(date -Iseconds)'"
  }'
echo ""
echo ""

echo "✅ Testing complete!"
echo ""
echo "🔍 What to check:"
echo "- Test 1 should return JSON with API status"
echo "- Test 2 & 3 should create entries in Google Sheets"
echo "- Check your Google Drive for 'Advent Hymnals Subscriptions' spreadsheet"