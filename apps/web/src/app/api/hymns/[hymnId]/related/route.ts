import { NextResponse } from 'next/server';
import { getRelatedHymns } from '@/lib/data-server';

export async function generateStaticParams() {
  // For static export, just return a few sample hymn IDs
  return [
    { hymnId: 'SDAH-en-001' },
    { hymnId: 'SDAH-en-002' },
    { hymnId: 'SDAH-en-003' },
  ];
}

export async function GET(
  request: Request,
  { params }: { params: { hymnId: string } }
) {
  try {
    let limit = 10;
    
    try {
      const { searchParams } = new URL(request.url);
      limit = parseInt(searchParams.get('limit') || '10', 10);
    } catch {
      // Use default for static export
      console.log('Using default limit for static export');
    }
    
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