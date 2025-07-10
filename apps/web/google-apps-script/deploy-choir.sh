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

# Backup existing Code.js if it exists
if [ -f "Code.js" ]; then
    echo "💾 Backing up existing Code.js..."
    cp Code.js Code.js.backup
fi

# Create a new Google Apps Script project for choir registration
echo "📝 Creating new Google Apps Script project..."
clasp create --type webapp --title "Advent Hymnals Choir Registration"

# Copy the choir registration script and manifest
echo "📋 Setting up project files..."
cp ChoirRegistration.js Code.js

# Ensure appsscript.json is properly configured
cat > appsscript.json << EOF
{
  "timeZone": "America/New_York",
  "dependencies": {},
  "exceptionLogging": "STACKDRIVER",
  "runtimeVersion": "V8",
  "webapp": {
    "access": "ANYONE",
    "executeAs": "USER_DEPLOYING"
  }
}
EOF

# Push files to Google Apps Script
echo "📤 Pushing files to Google Apps Script..."
clasp push

# Create a new deployment
echo "🚀 Creating deployment..."
DEPLOYMENT_OUTPUT=$(clasp deploy --description "Choir Registration Handler v1.0" 2>&1)
echo "$DEPLOYMENT_OUTPUT"

# Get the deployment ID and construct the web app URL
DEPLOYMENT_ID=$(echo "$DEPLOYMENT_OUTPUT" | grep -oE '[A-Za-z0-9_-]{57}' | head -n1)

if [ -n "$DEPLOYMENT_ID" ]; then
    # Get the script ID
    SCRIPT_ID=$(clasp list | grep "Advent Hymnals Choir Registration" | grep -oE '[A-Za-z0-9_-]{57}')
    
    if [ -n "$SCRIPT_ID" ]; then
        WEB_APP_URL="https://script.google.com/macros/s/$SCRIPT_ID/exec"
        
        echo ""
        echo "✅ Deployment successful!"
        echo ""
        echo "🔗 Web App URL: $WEB_APP_URL"
        echo "📋 Script ID: $SCRIPT_ID"
        echo "🆔 Deployment ID: $DEPLOYMENT_ID"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Go to: https://script.google.com/d/$SCRIPT_ID/edit"
        echo "   2. Click 'Deploy' > 'Manage deployments'"
        echo "   3. Click the gear icon next to your deployment"
        echo "   4. Set 'Execute as' to 'Me' and 'Who has access' to 'Anyone'"
        echo "   5. Click 'Update' and authorize the script"
        echo "   6. Add this URL to your .env file:"
        echo ""
        echo "🔧 Environment variable to add:"
        echo "   GOOGLE_CHOIR_SCRIPT_URL=$WEB_APP_URL"
        echo ""
        echo "🧪 Test the script with:"
        echo "   curl \"$WEB_APP_URL\""
    else
        echo "❌ Error: Could not retrieve script ID"
        exit 1
    fi
else
    echo "❌ Error: Could not retrieve deployment ID. Please check the deployment manually."
    echo "Output was: $DEPLOYMENT_OUTPUT"
    exit 1
fi

# Restore original Code.js if backup exists
if [ -f "Code.js.backup" ]; then
    echo "🔄 Restoring original Code.js..."
    mv Code.js.backup Code.js
fi

echo ""
echo "✨ Choir registration deployment complete!"
echo ""
echo "📋 Summary:"
echo "   - Google Apps Script project created"
echo "   - Choir registration handler deployed"
echo "   - Spreadsheet will be auto-created on first registration"
echo "   - Manual authorization required (see steps above)"