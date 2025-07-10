# Google Sheets Integration Setup

## Quick Setup (Manual)

1. **Enable Google Apps Script API**:
   - Visit https://script.google.com/home/usersettings
   - Turn on the Google Apps Script API
   - Wait a few minutes

2. **Create Google Apps Script Project**:
   ```bash
   cd apps/web/google-apps-script
   clasp create --title "Advent Hymnals Email Subscriptions" --type standalone
   clasp push
   clasp deploy --description "Email subscription handler"
   ```

3. **Get the Web App URL**:
   ```bash
   clasp deployments
   ```

4. **Add to Environment Variables**:
   ```env
   GOOGLE_SCRIPT_URL=https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec
   NEXT_PUBLIC_GA_ID=G-JPQZVQ70L9
   ```

## Alternative: Manual Setup

If you prefer to set up manually:

1. Go to https://script.google.com/
2. Create a new project named "Advent Hymnals Email Subscriptions"
3. Copy the contents of `google-apps-script/Code.js` into the script editor
4. Deploy as web app with:
   - Execute as: "Me" 
   - Who has access: "Anyone"
5. Copy the web app URL and add it to your environment variables

## Testing

Once deployed, you can test the integration:

```bash
# Test the web app endpoint
curl -X POST "YOUR_WEB_APP_URL" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","source":"test"}'
```

## Features

The Google Apps Script will:
- ✅ Create a Google Sheets document automatically
- ✅ Set up proper headers and formatting
- ✅ Validate email addresses
- ✅ Prevent duplicate subscriptions
- ✅ Log all submissions with timestamps
- ✅ Handle CORS for web requests
- ✅ Provide proper error responses

## Sheet Structure

The created Google Sheet will have these columns:
- **Email**: Subscriber's email address
- **Source**: Where they subscribed (popup, footer, etc.)
- **Timestamp**: When they subscribed (client-side)
- **User Agent**: Browser/device information
- **Referer**: Which page they came from
- **Server Timestamp**: When the server processed it