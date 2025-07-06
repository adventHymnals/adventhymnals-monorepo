import { NextResponse } from 'next/server';
import { searchHymns } from '@/lib/data-server';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const query = searchParams.get('q');
    const hymnalId = searchParams.get('hymnal') || undefined;
    const limit = parseInt(searchParams.get('limit') || '20', 10);
    
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