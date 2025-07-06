import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // Simple health check
    return NextResponse.json({ 
      status: 'ok', 
      timestamp: new Date().toISOString(),
      service: 'advent-hymnals-web'
    });
  } catch (error) {
    return NextResponse.json(
      { status: 'error', error: 'Health check failed' },
      { status: 500 }
    );
  }
}