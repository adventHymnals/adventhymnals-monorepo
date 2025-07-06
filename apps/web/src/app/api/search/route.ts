import { NextResponse } from 'next/server';
import { searchHymns } from '@/lib/data-server';

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
    } catch (urlError) {
      // For static export, return empty results
      return NextResponse.json({ hymns: [], total: 0 });
    }
    
    if (!query) {
      return NextResponse.json(
        { error: 'Search query is required' }, 
        { status: 400 }
      );
    }
    
    const results = await searchHymns(query, hymnalId, limit);
    return NextResponse.json(results);
  } catch (error) {
    console.error('API Error searching hymns:', error);
    return NextResponse.json(
      { error: 'Failed to search hymns' }, 
      { status: 500 }
    );
  }
}