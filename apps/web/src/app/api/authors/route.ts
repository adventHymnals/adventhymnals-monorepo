import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';

export async function GET() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const authorMap = new Map<string, { count: number; hymns: any[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.author) {
            const author = hymn.author.trim();
            if (!authorMap.has(author)) {
              authorMap.set(author, { count: 0, hymns: [] });
            }
            const authorData = authorMap.get(author)!;
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

    return NextResponse.json(authors);
  } catch (error) {
    console.error('API Error fetching authors:', error);
    return NextResponse.json(
      { error: 'Failed to fetch authors' }, 
      { status: 500 }
    );
  }
}