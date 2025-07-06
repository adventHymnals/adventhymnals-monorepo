import { NextResponse } from 'next/server';
import { loadHymnalReferences } from '@/lib/data-server';
import { withCors, handleOptionsRequest } from '@/lib/cors';

export async function OPTIONS(request: Request) {
  return handleOptionsRequest(request);
}

export async function GET(request: Request) {
  try {
    const references = await loadHymnalReferences();
    const response = NextResponse.json(references);
    return withCors(response, request.headers.get('origin'));
  } catch (error) {
    console.error('API Error loading hymnal references:', error);
    const response = NextResponse.json(
      { error: 'Failed to load hymnal references' }, 
      { status: 500 }
    );
    return withCors(response, request.headers.get('origin'));
  }
}