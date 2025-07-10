/**
 * Advent Hymnals Email Subscription Handler
 * Google Apps Script Web App to collect emails and save to Google Sheets
 */

function doPost(e) {
  try {
    // Get or create the subscription spreadsheet
    const sheet = getOrCreateSubscriptionSheet();
    
    // Parse the incoming data
    const data = JSON.parse(e.postData.contents);
    
    // Validate email
    if (!data.email || !data.email.includes('@')) {
      return createResponse({ error: 'Invalid email address' }, 400);
    }
    
    // Check if email already exists
    const emailColumn = sheet.getRange('A:A').getValues();
    const existingEmails = emailColumn.map(row => row[0]).slice(1); // Skip header
    
    if (existingEmails.includes(data.email)) {
      return createResponse({ message: 'Email already subscribed' });
    }
    
    // Add new row with subscription data
    const timestamp = data.timestamp || new Date().toISOString();
    const source = data.source || 'unknown';
    const userAgent = data.userAgent || 'unknown';
    const referer = data.referer || 'unknown';
    
    sheet.appendRow([
      data.email,
      source,
      timestamp,
      userAgent,
      referer,
      new Date() // Server timestamp
    ]);
    
    // Log the subscription for monitoring
    console.log(`New subscription: ${data.email} from ${source}`);
    
    // Return success response
    return createResponse({ success: true, message: 'Successfully subscribed' });
    
  } catch (error) {
    console.error('Error processing subscription:', error);
    return createResponse({ error: 'Internal server error' }, 500);
  }
}

function doGet(e) {
  try {
    const params = e.parameter || {};
    
    // If email parameter is provided, handle subscription via GET
    if (params.email) {
      return handleEmailSubscription(params);
    }
    
    // Default API status response
    return ContentService.createTextOutput(JSON.stringify({ 
      message: 'Advent Hymnals Email Subscription API',
      status: 'running',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      usage: 'Add ?email=your@email.com&source=website to subscribe'
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    console.error('doGet error:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'Internal server error',
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function handleEmailSubscription(params) {
  try {
    // Validate email
    if (!params.email || !params.email.includes('@')) {
      return ContentService.createTextOutput(JSON.stringify({
        error: 'Invalid email address'
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Get or create spreadsheet
    const sheet = getOrCreateSubscriptionSheet();
    
    // Check for duplicates
    const emailColumn = sheet.getRange('A:A').getValues();
    const existingEmails = emailColumn.map(row => row[0]).slice(1); // Skip header
    
    if (existingEmails.includes(params.email)) {
      return ContentService.createTextOutput(JSON.stringify({
        success: true,
        message: 'Email already subscribed'
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Add new subscription
    sheet.appendRow([
      params.email,
      params.source || 'unknown',
      params.timestamp || new Date().toISOString(),
      params.userAgent || 'unknown',
      params.referer || 'unknown',
      new Date() // Server timestamp
    ]);
    
    console.log(`New subscription: ${params.email} from ${params.source || 'unknown'}`);
    
    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: 'Successfully subscribed',
      email: params.email,
      timestamp: new Date().toISOString()
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    console.error('Subscription error:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'Failed to process subscription',
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function getOrCreateSubscriptionSheet() {
  const spreadsheetName = 'Advent Hymnals Subscriptions';
  
  // Try to find existing spreadsheet
  const files = DriveApp.getFilesByName(spreadsheetName);
  let spreadsheet;
  
  if (files.hasNext()) {
    // Use existing spreadsheet
    const file = files.next();
    spreadsheet = SpreadsheetApp.openById(file.getId());
  } else {
    // Create new spreadsheet
    spreadsheet = SpreadsheetApp.create(spreadsheetName);
    
    // Set up the header row
    const sheet = spreadsheet.getActiveSheet();
    sheet.setName('Email Subscriptions');
    sheet.getRange('A1:F1').setValues([[
      'Email',
      'Source',
      'Timestamp',
      'User Agent',
      'Referer',
      'Server Timestamp'
    ]]);
    
    // Format the header row
    const headerRange = sheet.getRange('A1:F1');
    headerRange.setFontWeight('bold');
    headerRange.setBackground('#4285f4');
    headerRange.setFontColor('white');
    
    // Auto-resize columns
    sheet.autoResizeColumns(1, 6);
    
    console.log(`Created new spreadsheet: ${spreadsheet.getUrl()}`);
  }
  
  return spreadsheet.getActiveSheet();
}

function createResponse(data, statusCode = 200) {
  const response = ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
  
  // Add CORS headers for cross-origin requests
  return response;
}

function testSubscription() {
  // Test function to verify the script works
  const testData = {
    email: 'test@example.com',
    source: 'test',
    timestamp: new Date().toISOString(),
    userAgent: 'Test Agent',
    referer: 'Test'
  };
  
  const mockEvent = {
    postData: {
      contents: JSON.stringify(testData)
    }
  };
  
  const result = doPost(mockEvent);
  console.log('Test result:', result.getContent());
}

function getSpreadsheetUrl() {
  // Helper function to get the spreadsheet URL
  const sheet = getOrCreateSubscriptionSheet();
  const spreadsheet = sheet.getParent();
  console.log('Spreadsheet URL:', spreadsheet.getUrl());
  return spreadsheet.getUrl();
}