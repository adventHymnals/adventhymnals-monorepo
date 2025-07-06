import { NextResponse } from 'next/server';
import { getRelatedHymns } from '@/lib/data-server';

export async function GET(
  request: Request,
  { params }: { params: { hymnId: string } }
) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '10', 10);
    
    const relatedHymns = await getRelatedHymns(params.hymnId, limit);
    return NextResponse.json(relatedHymns);
  } catch (error) {
    console.error(`API Error loading related hymns for ${params.hymnId}:`, error);
    return NextResponse.json(
      { error: 'Failed to load related hymns' }, 
      { status: 500 }
    );
  }
}