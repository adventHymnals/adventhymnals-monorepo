import { NextResponse } from 'next/server';
import { loadHymnalHymns } from '@/lib/data-server';

export async function GET(
  request: Request,
  { params }: { params: { hymnalId: string } }
) {
  try {
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page') || '1', 10);
    const limit = parseInt(searchParams.get('limit') || '50', 10);
    
    const result = await loadHymnalHymns(params.hymnalId, page, limit);
    return NextResponse.json(result);
  } catch (error) {
    console.error(`API Error loading hymns for hymnal ${params.hymnalId}:`, error);
    return NextResponse.json(
      { error: 'Failed to load hymnal hymns' }, 
      { status: 500 }
    );
  }
}