import { NextResponse } from 'next/server';
import { loadHymn } from '@/lib/data-server';

export async function generateStaticParams() {
  // For static export, just return a few sample hymn IDs
  // In production, this could be expanded to include more hymns
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