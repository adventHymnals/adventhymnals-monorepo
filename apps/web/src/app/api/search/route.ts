import { NextResponse } from 'next/server';
import { searchHymns } from '@/lib/data-server';
import { withCors, handleOptionsRequest } from '@/lib/cors';

export async function OPTIONS(request: Request) {
  return handleOptionsRequest(request);
}

export async function GET(request: Request) {
  try {
    let query = null;
    let hymnalId = undefined;
    let limit = 20;
    
    try {
      const { searchParams } = new URL(request.url);
      query = searchParams.get('q');
      hymnalId = searchParams.get('hymnal') || undefined;
      limit = parseInt(searchParams.get('limit') || '20', 10);
    } catch {
      // For static export, return empty results
      return NextResponse.json({ hymns: [], total: 0 });
    }
    
    if (!query) {
      const response = NextResponse.json(
        { error: 'Search query is required' }, 
        { status: 400 }
      );
    return withCors(response, request.headers.get('origin'));
    }
    
    const results = await searchHymns(query, hymnalId, limit);
    const response = NextResponse.json(results);
    return withCors(response, request.headers.get('origin'));
  } catch (error) {
    console.error('API Error searching hymns:', error);
    const response = NextResponse.json(
      { error: 'Failed to search hymns' }, 
      { status: 500 }
    );
    return withCors(response, request.headers.get('origin'));
  }
}