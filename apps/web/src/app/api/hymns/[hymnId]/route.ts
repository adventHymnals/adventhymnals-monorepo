import { NextResponse } from 'next/server';
import { loadHymn } from '@/lib/data-server';

export async function GET(
  request: Request,
  { params }: { params: { hymnId: string } }
) {
  try {
    const hymn = await loadHymn(params.hymnId);
    
    if (!hymn) {
      return NextResponse.json(
        { error: 'Hymn not found' }, 
        { status: 404 }
      );
    }
    
    return NextResponse.json(hymn);
  } catch (error) {
    console.error(`API Error loading hymn ${params.hymnId}:`, error);
    return NextResponse.json(
      { error: 'Failed to load hymn' }, 
      { status: 500 }
    );
  }
}