import { NextResponse } from 'next/server';
import { loadHymnalHymns, loadHymnalReferences } from '@/lib/data-server';

export async function generateStaticParams() {
  try {
    const references = await loadHymnalReferences();
    return Object.keys(references.hymnals).map((hymnalId) => ({
      hymnalId,
    }));
  } catch (error) {
    console.error('Error generating static params for hymnals:', error);
    return [];
  }
}

export async function GET(
  request: Request,
  { params }: { params: { hymnalId: string } }
) {
  try {
    let page = 1;
    let limit = 50;
    
    try {
      const { searchParams } = new URL(request.url);
      page = parseInt(searchParams.get('page') || '1', 10);
      limit = parseInt(searchParams.get('limit') || '50', 10);
    } catch {
      // Fallback for static export - use defaults
      console.log('Using default pagination for static export');
    }
    
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