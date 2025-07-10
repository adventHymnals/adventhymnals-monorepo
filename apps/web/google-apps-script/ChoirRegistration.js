/**
 * Advent Hymnals Choir Registration Handler
 * Google Apps Script Web App to collect choir registration data and save to Google Sheets
 */

function doGet(e) {
  try {
    const params = e.parameter || {};
    
    // If choir registration parameters are provided, handle registration via GET
    if (params.choirName) {
      return handleChoirRegistration(params);
    }
    
    // Default API status response
    return ContentService.createTextOutput(JSON.stringify({ 
      message: 'Advent Hymnals Choir Registration API',
      status: 'running',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      usage: 'POST choir registration data to register'
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    console.error('doGet error:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'Internal server error',
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function doPost(e) {
  try {
    let params;
    
    // Parse the POST data
    if (e.postData && e.postData.contents) {
      try {
        params = JSON.parse(e.postData.contents);
      } catch (parseError) {
        console.error('JSON parse error:', parseError);
        return ContentService.createTextOutput(JSON.stringify({
          error: 'Invalid JSON in request body'
        })).setMimeType(ContentService.MimeType.JSON);
      }
    } else {
      params = e.parameter || {};
    }
    
    // Handle choir registration
    return handleChoirRegistration(params);
    
  } catch (error) {
    console.error('doPost error:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'Internal server error',
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function handleChoirRegistration(params) {
  try {
    // Validate required fields
    const requiredFields = ['choirName', 'contactName', 'email', 'location', 'choirSize', 'experience', 'equipment', 'preferredTimeline'];
    for (const field of requiredFields) {
      if (!params[field]) {
        return ContentService.createTextOutput(JSON.stringify({
          error: `Missing required field: ${field}`
        })).setMimeType(ContentService.MimeType.JSON);
      }
    }
    
    // Validate email
    if (!params.email || !params.email.includes('@')) {
      return ContentService.createTextOutput(JSON.stringify({
        error: 'Invalid email address'
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Get or create spreadsheet
    const sheet = getOrCreateChoirRegistrationSheet();
    
    // Check for duplicate emails
    const emailColumn = sheet.getRange('C:C').getValues();
    const existingEmails = emailColumn.map(row => row[0]).slice(1); // Skip header
    
    if (existingEmails.includes(params.email)) {
      return ContentService.createTextOutput(JSON.stringify({
        success: true,
        message: 'Choir already registered with this email address'
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Add new registration
    const selectedHymnsCount = Array.isArray(params.selectedHymns) ? params.selectedHymns.length : 0;
    const selectedHymnsDetails = Array.isArray(params.selectedHymnsDetails) ? params.selectedHymnsDetails.join(' | ') : (params.selectedHymnsDetails || '');
    
    sheet.appendRow([
      params.choirName || '',
      params.contactName || '',
      params.email || '',
      params.phone || '',
      params.location || '',
      params.churchAffiliation || '',
      params.choirSize || '',
      params.experience || '',
      params.equipment || '',
      params.preferredTimeline || '',
      selectedHymnsCount.toString(),
      selectedHymnsDetails,
      params.additionalInfo || '',
      params.timestamp || new Date().toISOString(),
      params.userAgent || 'unknown',
      params.referer || 'unknown',
      new Date() // Server timestamp
    ]);
    
    console.log(`New choir registration: ${params.choirName} (${params.email}) - ${selectedHymnsCount} hymns selected`);
    
    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: 'Choir registration successful',
      choirName: params.choirName,
      email: params.email,
      timestamp: new Date().toISOString()
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    console.error('Choir registration error:', error);
    return ContentService.createTextOutput(JSON.stringify({
      error: 'Failed to process choir registration',
      message: error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function getOrCreateChoirRegistrationSheet() {
  const spreadsheetName = 'Advent Hymnals Subscriptions';
  const sheetName = 'Choir Registrations';
  
  // Try to find existing spreadsheet
  const files = DriveApp.getFilesByName(spreadsheetName);
  let spreadsheet;
  
  if (files.hasNext()) {
    // Use existing spreadsheet
    const file = files.next();
    spreadsheet = SpreadsheetApp.openById(file.getId());
    
    // Check if the choir registrations sheet exists
    let sheet = spreadsheet.getSheetByName(sheetName);
    
    if (!sheet) {
      // Create the choir registrations sheet
      sheet = spreadsheet.insertSheet(sheetName);
      
      // Set up the header row
      sheet.getRange('A1:Q1').setValues([[
        'Choir Name',
        'Contact Name',
        'Email',
        'Phone',
        'Location',
        'Church/Organization',
        'Choir Size',
        'Recording Experience',
        'Equipment',
        'Preferred Timeline',
        'Selected Hymns Count',
        'Selected Hymns Details',
        'Additional Info',
        'Timestamp',
        'User Agent',
        'Referer',
        'Server Timestamp'
      ]]);
      
      // Format the header row
      const headerRange = sheet.getRange('A1:Q1');
      headerRange.setFontWeight('bold');
      headerRange.setBackground('#4285f4');
      headerRange.setFontColor('white');
      
      // Auto-resize columns
      sheet.autoResizeColumns(1, 17);
      
      // Set column widths for better readability
      sheet.setColumnWidth(1, 200); // Choir Name
      sheet.setColumnWidth(2, 150); // Contact Name
      sheet.setColumnWidth(3, 200); // Email
      sheet.setColumnWidth(5, 150); // Location
      sheet.setColumnWidth(6, 200); // Church/Organization
      sheet.setColumnWidth(9, 300); // Equipment
      sheet.setColumnWidth(12, 500); // Selected Hymns Details
      sheet.setColumnWidth(13, 300); // Additional Info
      
      console.log(`Created new choir registration sheet in existing spreadsheet: ${spreadsheet.getUrl()}`);
    }
    
    return sheet;
  } else {
    // Create new spreadsheet if it doesn't exist
    spreadsheet = SpreadsheetApp.create(spreadsheetName);
    
    // Set up the choir registrations sheet
    const sheet = spreadsheet.getActiveSheet();
    sheet.setName(sheetName);
    sheet.getRange('A1:Q1').setValues([[
      'Choir Name',
      'Contact Name',
      'Email',
      'Phone',
      'Location',
      'Church/Organization',
      'Choir Size',
      'Recording Experience',
      'Equipment',
      'Preferred Timeline',
      'Selected Hymns Count',
      'Selected Hymns Details',
      'Additional Info',
      'Timestamp',
      'User Agent',
      'Referer',
      'Server Timestamp'
    ]]);
    
    // Format the header row
    const headerRange = sheet.getRange('A1:Q1');
    headerRange.setFontWeight('bold');
    headerRange.setBackground('#4285f4');
    headerRange.setFontColor('white');
    
    // Auto-resize columns
    sheet.autoResizeColumns(1, 17);
    
    // Set column widths for better readability
    sheet.setColumnWidth(1, 200); // Choir Name
    sheet.setColumnWidth(2, 150); // Contact Name
    sheet.setColumnWidth(3, 200); // Email
    sheet.setColumnWidth(5, 150); // Location
    sheet.setColumnWidth(6, 200); // Church/Organization
    sheet.setColumnWidth(9, 300); // Equipment
    sheet.setColumnWidth(12, 500); // Selected Hymns Details
    sheet.setColumnWidth(13, 300); // Additional Info
    
    console.log(`Created new spreadsheet with choir registration sheet: ${spreadsheet.getUrl()}`);
    return sheet;
  }
}

function createResponse(data, statusCode = 200) {
  const response = ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
  
  // Add CORS headers for cross-origin requests
  return response;
}

function testChoirRegistration() {
  // Test function to verify the script works
  const testData = {
    choirName: 'Test Choir',
    contactName: 'Test Director',
    email: 'test@example.com',
    phone: '+1-555-123-4567',
    location: 'Test City, Country',
    churchAffiliation: 'Test Church',
    choirSize: 'Medium (16-35 members)',
    experience: 'Moderate - Regular recording experience',
    equipment: 'Basic recording setup with USB microphones',
    preferredTimeline: 'Short-term (3-6 months)',
    selectedHymnsCount: '5',
    selectedHymnsDetails: 'SDAH-1: Praise to the Lord | SDAH-2: Amazing Grace',
    additionalInfo: 'Test registration',
    timestamp: new Date().toISOString(),
    userAgent: 'Test Agent',
    referer: 'Test'
  };
  
  const result = handleChoirRegistration(testData);
  console.log('Test result:', result.getContent());
}

function getChoirRegistrationSpreadsheetUrl() {
  // Helper function to get the spreadsheet URL
  const sheet = getOrCreateChoirRegistrationSheet();
  const spreadsheet = sheet.getParent();
  console.log('Choir Registration Spreadsheet URL:', spreadsheet.getUrl());
  return spreadsheet.getUrl();
}

function getRegistrationStats() {
  // Helper function to get registration statistics
  const sheet = getOrCreateChoirRegistrationSheet();
  const data = sheet.getDataRange().getValues();
  
  if (data.length <= 1) {
    console.log('No registrations yet');
    return { total: 0, choirs: [] };
  }
  
  const stats = {
    total: data.length - 1, // Exclude header
    choirs: data.slice(1).map(row => ({
      name: row[0],
      contact: row[1],
      email: row[2],
      location: row[4],
      size: row[6],
      hymnsCount: row[10],
      timestamp: row[16]
    }))
  };
  
  console.log('Registration stats:', stats);
  return stats;
}