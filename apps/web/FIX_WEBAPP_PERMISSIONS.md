# 🔧 Fix Web App Permissions - Step by Step

## ❌ **Current Issue**
The web app deployments are showing "Moved Temporarily" errors, which means they need proper authorization configuration.

## 🎯 **Solution: Manual Authorization Required**

### **Step 1: Open the Script Editor**
```bash
clasp open
```
Or visit: https://script.google.com/d/1CWdh6pbAwjmGkzzQU9gBfLJi5umjcSj_OnbXoFsauuR_-0k6VQosyFvL/edit

### **Step 2: Create New Deployment with Proper Settings**

1. Click **"Deploy"** (blue button, top right)
2. Click **"New deployment"**
3. Set deployment type: **"Web app"**
4. Configure settings:
   - **Description**: "Email Collection API - Public Access"
   - **Execute as**: "Me (surgbc@gmail.com)"
   - **Who has access**: "Anyone"
5. Click **"Deploy"**
6. **IMPORTANT**: When prompted, click **"Authorize access"**
7. Review and accept all permissions
8. Copy the new Web App URL

### **Step 3: Test the New Deployment**

After creating the deployment, you'll get a new URL like:
```
https://script.google.com/macros/s/NEW_DEPLOYMENT_ID/exec
```

Test it immediately:
```bash
curl -X GET "https://script.google.com/macros/s/NEW_DEPLOYMENT_ID/exec"
```

Should return JSON like:
```json
{
  "message": "Advent Hymnals Email Subscription API",
  "status": "running",
  "timestamp": "2025-01-10T...",
  "version": "1.0.0"
}
```

### **Step 4: Test Email Collection**

```bash
curl -X POST "https://script.google.com/macros/s/NEW_DEPLOYMENT_ID/exec" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@adventhymnals.org","source":"cli_test"}'
```

Should return:
```json
{
  "success": true,
  "message": "Successfully subscribed"
}
```

### **Step 5: Verify Google Sheets Creation**

1. Go to https://drive.google.com/
2. Look for "Advent Hymnals Subscriptions" spreadsheet
3. Check if test email was added

## 🔧 **Alternative: CLASP Deployment Fix**

If you prefer using CLASP:

```bash
# Create new deployment via CLASP
clasp deploy --description "Public Email Collection API"

# Get the deployment ID
clasp deployments

# Open to configure permissions
clasp open
```

Then follow steps 2-5 above to configure permissions.

## ✅ **Expected Success Indicators**

1. **GET request returns JSON** (not HTML error page)
2. **POST request accepts email data**
3. **Google Sheets automatically created**
4. **Test email appears in spreadsheet**

## 🚨 **Common Issues & Solutions**

### **Issue**: Still getting "Moved Temporarily"
**Solution**: The deployment wasn't properly authorized. Repeat Step 2 and ensure you click "Authorize access"

### **Issue**: "Script function not found"
**Solution**: Push latest code first:
```bash
clasp push --force
```

### **Issue**: "Permission denied"
**Solution**: Make sure you're the script owner and have proper Google Apps Script permissions

## 🎯 **Final Test Script**

Once working, use this to verify everything:

```bash
#!/bin/bash
WEB_APP_URL="https://script.google.com/macros/s/YOUR_NEW_DEPLOYMENT_ID/exec"

echo "Testing GET request..."
curl -X GET "$WEB_APP_URL"

echo -e "\n\nTesting POST request..."
curl -X POST "$WEB_APP_URL" \
  -H "Content-Type: application/json" \
  -d '{"email":"working-test@adventhymnals.org","source":"verification_test"}'
```

## 📊 **Update Environment Files**

Once you have the working URL, update:

```bash
# Update .env files with new working URL
GOOGLE_SCRIPT_URL=https://script.google.com/macros/s/YOUR_NEW_DEPLOYMENT_ID/exec
```

The key issue is that Google Apps Script deployments created via CLASP often need manual authorization through the web interface for public access.