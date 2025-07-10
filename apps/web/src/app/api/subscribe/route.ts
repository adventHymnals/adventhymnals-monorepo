import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const { email, source, timestamp } = await request.json();

    if (!email || !email.includes('@')) {
      return NextResponse.json({ error: 'Invalid email address' }, { status: 400 });
    }

    // Google Apps Script Web App URL - replace with your actual URL
    const GOOGLE_SCRIPT_URL = process.env.GOOGLE_SCRIPT_URL;
    
    if (!GOOGLE_SCRIPT_URL) {
      console.error('GOOGLE_SCRIPT_URL environment variable not set');
      return NextResponse.json({ error: 'Service configuration error' }, { status: 500 });
    }

    // Build URL with query parameters for GET request (more reliable than POST)
    const url = new URL(GOOGLE_SCRIPT_URL);
    url.searchParams.append('email', email);
    url.searchParams.append('source', source || 'unknown');
    url.searchParams.append('timestamp', timestamp || new Date().toISOString());
    url.searchParams.append('userAgent', request.headers.get('user-agent') || 'unknown');
    url.searchParams.append('referer', request.headers.get('referer') || 'unknown');

    // Send data to Google Sheets via Google Apps Script using GET
    const response = await fetch(url.toString(), {
      method: 'GET',
    });

    if (!response.ok) {
      throw new Error(`Google Apps Script responded with ${response.status}`);
    }

    const result = await response.json();
    return NextResponse.json(result);
  } catch (error) {
    console.error('Subscribe API error:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}