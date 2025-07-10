# 🔧 Configure Web App Permissions

The Google Apps Script is deployed but needs manual permission configuration. Here's how to fix it:

## 📝 Step-by-Step Instructions

### 1. Open the Google Apps Script Editor
Visit: https://script.google.com/d/1CWdh6pbAwjmGkzzQU9gBfLJi5umjcSj_OnbXoFsauuR_-0k6VQosyFvL/edit

### 2. Configure Deployment Permissions
1. Click the **"Deploy"** button (top right)
2. Select **"Manage deployments"**
3. Click the **edit icon (⚙️)** next to the latest deployment
4. Configure settings:
   - **Execute as**: "Me (surgbc@gmail.com)"
   - **Who has access**: "Anyone"
5. Click **"Update"**
6. **Authorize** when prompted (this is crucial!)

### 3. Test the Web App
After authorization, test with:

```bash
curl -X GET "https://script.google.com/macros/s/AKfycbx-jdSCIf9vSn-Cd1FMwmcG9_KksBj1Bh1aLz9MWzY5PCCzujqkSvP_rO-lSrOVvKm8wA/exec"
```

Should return:
```json
{
  "message": "Advent Hymnals Email Subscription API",
  "status": "running",
  "timestamp": "2025-01-10T...",
  "version": "1.0.0"
}
```

### 4. Test Email Collection
```bash
curl -X POST "https://script.google.com/macros/s/AKfycbx-jdSCIf9vSn-Cd1FMwmcG9_KksBj1Bh1aLz9MWzY5PCCzujqkSvP_rO-lSrOVvKm8wA/exec" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","source":"test"}'
```

## 🔍 Troubleshooting

### Common Issues:
1. **"Page Not Found"** → Permissions not configured
2. **"Authorization required"** → Need to authorize in step 2.6
3. **"Script function not found"** → Push latest code with `clasp push --force`

### Alternative Setup (if CLI method fails):
1. Go to https://script.google.com/
2. Create new project: "Advent Hymnals Subscriptions"
3. Copy-paste the code from `google-apps-script/Code.js`
4. Deploy manually as web app

## 📊 Expected Result

Once configured, the script will:
- ✅ Create Google Sheet: "Advent Hymnals Subscriptions" 
- ✅ Accept email submissions via API
- ✅ Validate and store emails with metadata
- ✅ Prevent duplicate subscriptions
- ✅ Return proper JSON responses

The Google Sheet will be automatically created with columns:
- Email | Source | Timestamp | User Agent | Referer | Server Timestamp