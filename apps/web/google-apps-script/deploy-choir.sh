#!/bin/bash

# Advent Hymnals - Deploy Choir Registration Google Apps Script
# This script deploys the choir registration handler to Google Apps Script

echo "🎵 Deploying Choir Registration Google Apps Script..."

# Check if clasp is installed
if ! command -v clasp &> /dev/null; then
    echo "❌ Error: clasp is not installed. Please install it first:"
    echo "   npm install -g @google/clasp"
    exit 1
fi

# Check if user is logged in to clasp
if ! clasp login --status &> /dev/null; then
    echo "❌ Error: Not logged in to clasp. Please run 'clasp login' first"
    exit 1
fi

# Create a new Google Apps Script project for choir registration
echo "📝 Creating new Google Apps Script project..."
clasp create --type webapp --title "Advent Hymnals Choir Registration" --rootDir ./

# Copy the choir registration script
echo "📋 Copying choir registration script..."
cp ChoirRegistration.js Code.js

# Deploy the script
echo "🚀 Deploying script..."
clasp push
clasp deploy --description "Choir Registration Handler v1.0"

# Get the web app URL
echo "🌐 Getting web app URL..."
WEB_APP_URL=$(clasp deployments | grep -oE 'https://script\.google\.com/macros/s/[A-Za-z0-9_-]+/exec' | head -n1)

if [ -n "$WEB_APP_URL" ]; then
    echo "✅ Deployment successful!"
    echo ""
    echo "🔗 Web App URL: $WEB_APP_URL"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Add this URL to your .env file as GOOGLE_CHOIR_SCRIPT_URL"
    echo "   2. Test the integration with the choir registration form"
    echo "   3. Check the Google Sheets created for choir registrations"
    echo ""
    echo "🔧 Environment variable to add:"
    echo "   GOOGLE_CHOIR_SCRIPT_URL=$WEB_APP_URL"
else
    echo "❌ Error: Could not retrieve web app URL. Please check the deployment manually."
    exit 1
fi

# Restore original Code.js
echo "🔄 Restoring original subscription script..."
cp ../Code.js.backup Code.js 2>/dev/null || echo "⚠️  Warning: Could not restore original Code.js"

echo "✨ Choir registration deployment complete!"