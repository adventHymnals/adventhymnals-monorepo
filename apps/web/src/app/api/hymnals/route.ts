import { NextResponse } from 'next/server';
import { loadHymnalReferences } from '@/lib/data-server';

export async function GET() {
  try {
    const references = await loadHymnalReferences();
    return NextResponse.json(references);
  } catch (error) {
    console.error('API Error loading hymnal references:', error);
    return NextResponse.json(
      { error: 'Failed to load hymnal references' }, 
      { status: 500 }
    );
  }
}