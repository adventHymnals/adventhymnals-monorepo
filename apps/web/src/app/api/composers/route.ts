import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';
import { withCors, handleOptionsRequest } from '@/lib/cors';

export async function OPTIONS(request: Request) {
  return handleOptionsRequest(request);
}

export async function GET(request: Request) {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const composerMap = new Map<string, { count: number; hymns: unknown[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.composer) {
            const originalComposer = hymn.composer.trim();
            // Normalize composer by removing punctuation and extra spaces
            const normalizedComposer = originalComposer.replace(/[.,\s\-']+/g, '').toUpperCase();
            
            // Find existing composer with same normalized form or create new entry
            let existingComposer = null;
            for (const [existingKey] of Array.from(composerMap.entries())) {
              const existingNormalized = existingKey.replace(/[.,\s\-']+/g, '').toUpperCase();
              if (existingNormalized === normalizedComposer) {
                existingComposer = existingKey;
                break;
              }
            }
            
            const composerKey = existingComposer || originalComposer;
            if (!composerMap.has(composerKey)) {
              composerMap.set(composerKey, { count: 0, hymns: [] });
            }
            const composerData = composerMap.get(composerKey)!;
            composerData.count++;
            composerData.hymns.push({
              ...hymn,
              hymnal: hymnalRef
            });
          }
        }
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    // Convert to array and sort by count
    const composers = Array.from(composerMap.entries())
      .map(([composer, data]) => ({
        composer,
        count: data.count,
        hymns: data.hymns
      }))
      .sort((a, b) => b.count - a.count);

    const response = NextResponse.json(composers);
    return withCors(response, request.headers.get('origin'));
  } catch (error) {
    console.error('API Error fetching composers:', error);
    const response = NextResponse.json(
      { error: 'Failed to fetch composers' }, 
      { status: 500 }
    );
    return withCors(response, request.headers.get('origin'));
  }
}