import { NextResponse } from 'next/server';
import { loadHymnal, loadHymnalReferences } from '@/lib/data-server';

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
    const hymnal = await loadHymnal(params.hymnalId);
    
    if (!hymnal) {
      return NextResponse.json(
        { error: 'Hymnal not found' }, 
        { status: 404 }
      );
    }
    
    return NextResponse.json(hymnal);
  } catch (error) {
    console.error(`API Error loading hymnal ${params.hymnalId}:`, error);
    return NextResponse.json(
      { error: 'Failed to load hymnal' }, 
      { status: 500 }
    );
  }
}