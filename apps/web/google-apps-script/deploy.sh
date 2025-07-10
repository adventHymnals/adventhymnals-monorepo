#!/bin/bash

# Advent Hymnals Google Apps Script Deployment Script

echo "🚀 Deploying Advent Hymnals Email Subscription System..."

# Check if clasp is installed
if ! command -v clasp &> /dev/null; then
    echo "❌ clasp is not installed. Installing..."
    pnpm add -g @google/clasp
fi

# Check if user is logged in
if ! clasp list &> /dev/null; then
    echo "🔑 Please login to Google Apps Script:"
    clasp login
fi

# Create the project if .clasp.json doesn't exist
if [ ! -f ".clasp.json" ]; then
    echo "📝 Creating new Google Apps Script project..."
    clasp create --title "Advent Hymnals Email Subscriptions" --type standalone
fi

# Push the code
echo "📤 Pushing code to Google Apps Script..."
clasp push

# Deploy as web app
echo "🌐 Deploying as web app..."
clasp deploy --description "Email subscription handler - $(date)"

# Show deployment info
echo "📋 Deployment information:"
clasp deployments

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the Web App URL from above"
echo "2. Add it to your environment variables as GOOGLE_SCRIPT_URL"
echo "3. Test the integration using the development popup"
echo ""
echo "🔗 View your Google Apps Script project:"
clasp open