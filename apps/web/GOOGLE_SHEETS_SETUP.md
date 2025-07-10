# Google Sheets Email Collection Setup

This document explains how to set up Google Sheets integration for collecting email subscriptions.

## Step 1: Create Google Sheets Document

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet
3. Name it "Advent Hymnals Subscriptions"
4. Set up the following columns in row 1:
   - A1: `Email`
   - B1: `Source`
   - C1: `Timestamp`
   - D1: `User Agent`
   - E1: `Referer`

## Step 2: Create Google Apps Script

1. In your Google Sheet, go to `Extensions > Apps Script`
2. Replace the default code with the following:

```javascript
function doPost(e) {
  try {
    // Get the active spreadsheet
    const sheet = SpreadsheetApp.getActiveSheet();
    
    // Parse the incoming data
    const data = JSON.parse(e.postData.contents);
    
    // Validate email
    if (!data.email || !data.email.includes('@')) {
      return ContentService.createTextOutput(
        JSON.stringify({ error: 'Invalid email' })
      ).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Check if email already exists
    const emailColumn = sheet.getRange('A:A').getValues();
    const existingEmails = emailColumn.map(row => row[0]).slice(1); // Skip header
    
    if (existingEmails.includes(data.email)) {
      return ContentService.createTextOutput(
        JSON.stringify({ message: 'Email already subscribed' })
      ).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Add new row with subscription data
    sheet.appendRow([
      data.email,
      data.source || 'unknown',
      data.timestamp || new Date().toISOString(),
      data.userAgent || 'unknown',
      data.referer || 'unknown'
    ]);
    
    // Return success response
    return ContentService.createTextOutput(
      JSON.stringify({ success: true })
    ).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log('Error: ' + error.toString());
    return ContentService.createTextOutput(
      JSON.stringify({ error: 'Internal server error' })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}
```

3. Save the script (Ctrl+S or Cmd+S)
4. Name your project (e.g., "Advent Hymnals Subscriptions")

## Step 3: Deploy as Web App

1. Click the "Deploy" button in the top right
2. Choose "New deployment"
3. Select "Web app" as the type
4. Set the following:
   - Description: "Email subscription handler"
   - Execute as: "Me"
   - Who has access: "Anyone"
5. Click "Deploy"
6. Copy the Web App URL that appears - you'll need this for the environment variable

## Step 4: Set Environment Variables

Add the following environment variables to your deployment:

### For Production (adventhymnals.org):
```
GOOGLE_SCRIPT_URL=https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec
NEXT_PUBLIC_GA_ID=G-JPQZVQ70L9
```

### For GitHub Pages (adventhymnals.github.io):
```
GOOGLE_SCRIPT_URL=https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec
NEXT_PUBLIC_GA_ID=G-JPQZVQ70L9
```

## Step 5: Test the Integration

1. Deploy your application with the environment variables
2. Visit your site as a first-time visitor
3. The development popup should appear after 2 seconds
4. Submit an email address
5. Check your Google Sheet to confirm the data was recorded

## Security Notes

- The Google Apps Script is set to "Anyone" access, but it only accepts POST requests with valid JSON
- Email validation is performed on both client and server side
- Duplicate emails are prevented automatically
- All submissions are logged with timestamp and source tracking

## Troubleshooting

- If the popup doesn't appear, check browser console for errors
- If emails aren't being saved, check the Google Apps Script execution logs
- Make sure the Google Sheet has the correct column headers
- Verify the GOOGLE_SCRIPT_URL environment variable is correct