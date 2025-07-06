import { NextResponse } from 'next/server';
import { loadHymnal } from '@/lib/data-server';

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