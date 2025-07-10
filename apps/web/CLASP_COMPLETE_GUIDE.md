# 📚 Complete CLASP Guide for Google Apps Script

## 🔧 What is CLASP?
CLASP (Command Line Apps Script Projects) is Google's official CLI tool for managing Google Apps Script projects from your terminal.

## 🚀 Quick Setup Commands

### 1. **Check Current Status**
```bash
# Check if logged in
clasp login --status

# List your projects
clasp list

# Check current project info
clasp status
```

### 2. **Project Management**
```bash
# Create new project
clasp create --title "My Project" --type standalone

# Clone existing project
clasp clone <scriptId>

# Open project in browser
clasp open

# Open web app in browser
clasp open --webapp
```

### 3. **Code Management**
```bash
# Push local code to Google Apps Script
clasp push

# Force push (overwrites remote)
clasp push --force

# Pull remote code to local
clasp pull

# Watch for changes and auto-push
clasp push --watch
```

### 4. **Deployment & Testing**
```bash
# Create new deployment
clasp deploy --description "My deployment"

# List all deployments
clasp deployments

# Update existing deployment
clasp deploy --deploymentId <deploymentId> --description "Updated version"

# Run a function remotely
clasp run <functionName>

# View logs
clasp logs
```

## 🔨 **Setting Up Your Advent Hymnals Project**

### **Step 1: Navigate to Project Directory**
```bash
cd /home/brian/Code/AH/advent-hymnals-mono-repo/apps/web/google-apps-script
```

### **Step 2: Check Current Setup**
```bash
# Check if you're logged in
clasp login --status

# If not logged in:
clasp login
```

### **Step 3: Verify Project Connection**
```bash
# Check current project
cat .clasp.json

# Should show something like:
# {"scriptId":"1CWdh6pbAwjmGkzzQU9gBfLJi5umjcSj_OnbXoFsauuR_-0k6VQosyFvL","rootDir":"/home/brian/Code/AH/advent-hymnals-mono-repo/apps/web/google-apps-script"}
```

### **Step 4: Push Your Code**
```bash
# Push current code
clasp push --force

# Check status
clasp status
```

### **Step 5: Deploy as Web App**
```bash
# Create new deployment
clasp deploy --description "Advent Hymnals Email Subscription Handler v1.0"

# List deployments to get URL
clasp deployments
```

### **Step 6: Open and Configure**
```bash
# Open in browser to configure permissions
clasp open

# In the browser:
# 1. Click "Deploy" → "Manage deployments"
# 2. Click edit icon next to latest deployment
# 3. Set "Who has access" to "Anyone"
# 4. Click "Update" and authorize
```

## 🔍 **Troubleshooting Common Issues**

### **Issue: "Apps Script API not enabled"**
```bash
# Solution: Enable the API
# 1. Visit: https://script.google.com/home/usersettings
# 2. Turn on Google Apps Script API
# 3. Wait a few minutes, then retry
```

### **Issue: "Invalid credentials"**
```bash
# Re-login
clasp logout
clasp login
```

### **Issue: "Permission denied"**
```bash
# Check if you own the project
clasp open

# If not, create new project:
clasp create --title "Advent Hymnals Subscriptions" --type standalone
```

### **Issue: "Script function not found"**
```bash
# Push your code first
clasp push --force

# Then deploy
clasp deploy --description "Updated with functions"
```

## 📋 **Complete Workflow for Your Project**

### **Fresh Setup (if starting over):**
```bash
# 1. Navigate to directory
cd apps/web/google-apps-script

# 2. Create new project
clasp create --title "Advent Hymnals Email Subscriptions" --type standalone

# 3. Push your code
clasp push --force

# 4. Deploy
clasp deploy --description "Email subscription handler"

# 5. Get deployment info
clasp deployments

# 6. Open to configure permissions
clasp open
```

### **Updating Existing Project:**
```bash
# 1. Make code changes
# 2. Push updates
clasp push --force

# 3. Create new deployment
clasp deploy --description "Updated $(date)"

# 4. Get new deployment URL
clasp deployments
```

## 🎯 **Your Current Project Commands**

Based on your setup, here are the exact commands for your project:

```bash
# Navigate to your project
cd /home/brian/Code/AH/advent-hymnals-mono-repo/apps/web/google-apps-script

# Check current status
clasp status

# Push any code changes
clasp push --force

# Create new deployment if needed
clasp deploy --description "Production ready email handler"

# Get deployment URLs
clasp deployments

# Open in browser to configure
clasp open
```

## 📊 **Monitoring & Logs**

```bash
# View execution logs
clasp logs

# Watch logs in real-time
clasp logs --watch

# View specific function logs
clasp logs --simplified
```

## 🔗 **Useful CLASP Commands Reference**

| Command | Purpose |
|---------|---------|
| `clasp login` | Authenticate with Google |
| `clasp create` | Create new project |
| `clasp clone <id>` | Download existing project |
| `clasp push` | Upload local code |
| `clasp pull` | Download remote code |
| `clasp deploy` | Create deployment |
| `clasp open` | Open in browser |
| `clasp logs` | View execution logs |
| `clasp run <func>` | Execute function |
| `clasp status` | Show project status |
| `clasp list` | List your projects |

## 🎉 **Your Project is Ready!**

Your Google Apps Script is already set up and working. The web app URL:
```
https://script.google.com/macros/s/AKfycbzxG_DpZYLNe8QsEqPBY499zO0GUoPs-KUGC06qqVDOYolbCrkZHAwd4Au2kjIhe7EQKg/exec
```

Just deploy your web app with the environment variables and you're live! 🚀