import { NextRequest, NextResponse } from 'next/server';

async function handleChoirRegistration(data: any, request: NextRequest) {
  // Validate required fields
  const requiredFields = ['choirName', 'contactName', 'email', 'location', 'choirSize', 'experience', 'equipment', 'preferredTimeline'];
  for (const field of requiredFields) {
    if (!data[field]) {
      return NextResponse.json({ error: `Missing required field: ${field}` }, { status: 400 });
    }
  }

  // Validate email
  if (!data.email.includes('@')) {
    return NextResponse.json({ error: 'Invalid email address' }, { status: 400 });
  }

  // Google Apps Script Web App URL for choir registrations
  const GOOGLE_SCRIPT_URL = process.env.GOOGLE_CHOIR_SCRIPT_URL;
  
  if (!GOOGLE_SCRIPT_URL) {
    console.error('GOOGLE_CHOIR_SCRIPT_URL environment variable not set');
    return NextResponse.json({ error: 'Service configuration error' }, { status: 500 });
  }

  // Build URL with query parameters for GET request
  const url = new URL(GOOGLE_SCRIPT_URL);
  url.searchParams.append('choirName', data.choirName);
  url.searchParams.append('contactName', data.contactName);
  url.searchParams.append('email', data.email);
  url.searchParams.append('phone', data.phone || '');
  url.searchParams.append('location', data.location);
  url.searchParams.append('churchAffiliation', data.churchAffiliation || '');
  url.searchParams.append('choirSize', data.choirSize);
  url.searchParams.append('experience', data.experience);
  url.searchParams.append('equipment', data.equipment);
  url.searchParams.append('preferredTimeline', data.preferredTimeline);
  url.searchParams.append('selectedHymnsCount', data.selectedHymnsCount || '0');
  url.searchParams.append('selectedHymnsDetails', data.selectedHymnsDetails || '');
  url.searchParams.append('additionalInfo', data.additionalInfo || '');
  url.searchParams.append('timestamp', data.timestamp || new Date().toISOString());
  url.searchParams.append('userAgent', data.userAgent || request.headers.get('user-agent') || 'unknown');
  url.searchParams.append('referer', data.referer || request.headers.get('referer') || 'unknown');

  // Send data to Google Sheets via Google Apps Script using GET
  const response = await fetch(url.toString(), {
    method: 'GET',
  });

  if (!response.ok) {
    throw new Error(`Google Apps Script responded with ${response.status}`);
  }

  const result = await response.json();
  return NextResponse.json(result);
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const data = Object.fromEntries(searchParams.entries());
    
    return await handleChoirRegistration(data, request);
  } catch (error) {
    console.error('Choir registration GET API error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const data = await request.json();
    return await handleChoirRegistration(data, request);
  } catch (error) {
    console.error('Choir registration POST API error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}