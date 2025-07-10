# 📧 Research-Based Email Collection Setup with CLASP & Google Apps Script

## 🔍 **Research Summary from Leading Tutorials (2024-2025)**

Based on research from Google's official documentation, labnol.org, ravsam.in, and other authoritative sources, here's the complete setup for email collection using CLASP and Google Apps Script.

## 🚀 **Complete Setup Guide**

### **Step 1: CLASP Installation & Setup**

```bash
# Install CLASP globally
npm install @google/clasp -g

# Login to Google Apps Script
clasp login

# Create new project
clasp create --title "Email Collection System" --type standalone

# Or clone existing project
clasp clone <script-id>
```

### **Step 2: Core Google Apps Script Code**

Based on research from multiple sources, here's the proven pattern:

**File: `Code.js`**
```javascript
/**
 * Handle GET requests - API status check
 */
function doGet(event = {}) {
  const { parameter } = event;
  
  return ContentService.createTextOutput(
    JSON.stringify({
      status: 'running',
      message: 'Email Collection API',
      timestamp: new Date().toISOString()
    })
  ).setMimeType(ContentService.MimeType.JSON);
}

/**
 * Handle POST requests - Email collection
 */
function doPost(request = {}) {
  try {
    const { postData: { contents, type } = {} } = request;
    
    // Parse JSON data
    if (type === 'application/json') {
      const data = JSON.parse(contents);
      
      // Validate email
      if (!data.email || !data.email.includes('@')) {
        return createErrorResponse('Invalid email address');
      }
      
      // Store in Google Sheets
      const result = storeEmailData(data);
      
      // Send confirmation email (optional)
      sendConfirmationEmail(data.email);
      
      return createSuccessResponse(result);
    }
    
    return createErrorResponse('Invalid content type');
    
  } catch (error) {
    console.error('Error:', error);
    return createErrorResponse('Internal server error');
  }
}

/**
 * Store email data in Google Sheets
 */
function storeEmailData(data) {
  const spreadsheetId = getOrCreateSpreadsheet();
  const sheet = SpreadsheetApp.openById(spreadsheetId).getActiveSheet();
  
  // Check for duplicates
  const emailColumn = sheet.getRange('A:A').getValues();
  const existingEmails = emailColumn.map(row => row[0]).slice(1);
  
  if (existingEmails.includes(data.email)) {
    return { message: 'Email already subscribed' };
  }
  
  // Add new row
  sheet.appendRow([
    data.email,
    data.source || 'unknown',
    data.timestamp || new Date().toISOString(),
    data.userAgent || 'unknown',
    data.referer || 'unknown',
    new Date() // Server timestamp
  ]);
  
  return { message: 'Successfully subscribed' };
}

/**
 * Get or create spreadsheet for email storage
 */
function getOrCreateSpreadsheet() {
  const fileName = 'Email Subscriptions';
  
  // Try to find existing file
  const files = DriveApp.getFilesByName(fileName);
  
  if (files.hasNext()) {
    return files.next().getId();
  }
  
  // Create new spreadsheet
  const spreadsheet = SpreadsheetApp.create(fileName);
  const sheet = spreadsheet.getActiveSheet();
  
  // Setup headers
  sheet.getRange('A1:F1').setValues([[
    'Email', 'Source', 'Timestamp', 'User Agent', 'Referer', 'Server Time'
  ]]);
  
  // Format headers
  const headerRange = sheet.getRange('A1:F1');
  headerRange.setFontWeight('bold');
  headerRange.setBackground('#4285f4');
  headerRange.setFontColor('white');
  
  return spreadsheet.getId();
}

/**
 * Send confirmation email to subscriber
 */
function sendConfirmationEmail(email) {
  try {
    MailApp.sendEmail({
      to: email,
      subject: 'Welcome to Advent Hymnals Updates',
      body: `
        Thank you for subscribing to Advent Hymnals updates!
        
        We'll keep you informed about our development progress and notify you when new features are available.
        
        Best regards,
        The Advent Hymnals Team
      `
    });
  } catch (error) {
    console.error('Email sending failed:', error);
  }
}

/**
 * Create success response
 */
function createSuccessResponse(data) {
  return ContentService.createTextOutput(
    JSON.stringify({ success: true, ...data })
  ).setMimeType(ContentService.MimeType.JSON);
}

/**
 * Create error response
 */
function createErrorResponse(message) {
  return ContentService.createTextOutput(
    JSON.stringify({ error: message })
  ).setMimeType(ContentService.MimeType.JSON);
}
```

**File: `appsscript.json`**
```json
{
  "timeZone": "Africa/Nairobi",
  "dependencies": {},
  "exceptionLogging": "STACKDRIVER",
  "runtimeVersion": "V8",
  "webapp": {
    "access": "ANYONE",
    "executeAs": "USER_DEPLOYING"
  }
}
```

### **Step 3: CLASP Deployment Commands**

```bash
# Push code to Google Apps Script
clasp push --force

# Deploy as web app
clasp deploy --description "Email Collection System v1.0"

# Get deployment URLs
clasp deployments

# Open in browser for configuration
clasp open
```

### **Step 4: Web App Configuration**

In the Google Apps Script editor:

1. Click **"Deploy"** → **"Manage deployments"**
2. Click the edit icon (⚙️) next to latest deployment
3. Set:
   - **Execute as**: "Me"
   - **Who has access**: "Anyone"
4. Click **"Update"**
5. **Authorize** when prompted

### **Step 5: Frontend Integration**

**React/Next.js Component:**
```javascript
const subscribeUser = async (email, source = 'website') => {
  try {
    const response = await fetch(process.env.GOOGLE_SCRIPT_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email,
        source,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        referer: document.referrer
      })
    });
    
    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Subscription error:', error);
    throw error;
  }
};
```

### **Step 6: Testing & Monitoring**

```bash
# Test GET request
curl "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"

# Test POST request
curl -X POST "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","source":"test"}'

# View logs
clasp logs

# Watch logs in real-time
clasp logs --watch
```

## 🔧 **Advanced Features**

### **Email Validation Enhancement**
```javascript
function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}
```

### **Rate Limiting**
```javascript
function checkRateLimit(email) {
  const cache = CacheService.getScriptCache();
  const key = `rate_limit_${email}`;
  const attempts = cache.get(key) || 0;
  
  if (attempts > 5) {
    throw new Error('Too many requests');
  }
  
  cache.put(key, attempts + 1, 3600); // 1 hour
}
```

### **Slack Notifications**
```javascript
function sendSlackNotification(email, source) {
  const webhookUrl = 'YOUR_SLACK_WEBHOOK_URL';
  
  UrlFetchApp.fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    payload: JSON.stringify({
      text: `New email subscription: ${email} from ${source}`
    })
  });
}
```

## 📊 **Best Practices from Research**

1. **Security**: Always validate input data
2. **Performance**: Use caching for rate limiting
3. **Reliability**: Implement error handling
4. **Monitoring**: Log all operations
5. **Privacy**: Handle email data responsibly
6. **Scalability**: Use Google Sheets efficiently

## 🎯 **Expected Results**

- ✅ Automated email collection
- ✅ Google Sheets data storage
- ✅ Confirmation emails
- ✅ Duplicate prevention
- ✅ Source tracking
- ✅ Error handling
- ✅ Real-time notifications

This setup is based on proven patterns from leading tutorials and Google's official documentation, ensuring reliability and best practices for 2024-2025.