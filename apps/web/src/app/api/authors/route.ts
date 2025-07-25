import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';
import { withCors, handleOptionsRequest } from '@/lib/cors';

export async function OPTIONS(request: Request) {
  return handleOptionsRequest(request);
}

export async function GET(request: Request) {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const authorMap = new Map<string, { count: number; hymns: unknown[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.author) {
            const originalAuthor = hymn.author.trim();
            // Normalize author by removing punctuation and extra spaces
            const normalizedAuthor = originalAuthor.replace(/[.,\s\-']+/g, '').toUpperCase();
            
            // Find existing author with same normalized form or create new entry
            let existingAuthor = null;
            for (const [existingKey] of Array.from(authorMap.entries())) {
              const existingNormalized = existingKey.replace(/[.,\s\-']+/g, '').toUpperCase();
              if (existingNormalized === normalizedAuthor) {
                existingAuthor = existingKey;
                break;
              }
            }
            
            const authorKey = existingAuthor || originalAuthor;
            if (!authorMap.has(authorKey)) {
              authorMap.set(authorKey, { count: 0, hymns: [] });
            }
            const authorData = authorMap.get(authorKey)!;
            authorData.count++;
            authorData.hymns.push({
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
    const authors = Array.from(authorMap.entries())
      .map(([author, data]) => ({
        author,
        count: data.count,
        hymns: data.hymns
      }))
      .sort((a, b) => b.count - a.count);

    const response = NextResponse.json(authors);
    return withCors(response, request.headers.get('origin'));
  } catch (error) {
    console.error('API Error fetching authors:', error);
    const response = NextResponse.json(
      { error: 'Failed to fetch authors' }, 
      { status: 500 }
    );
    return withCors(response, request.headers.get('origin'));
  }
}