import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';

export async function GET() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const composerMap = new Map<string, { count: number; hymns: any[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.composer) {
            const composer = hymn.composer.trim();
            if (!composerMap.has(composer)) {
              composerMap.set(composer, { count: 0, hymns: [] });
            }
            const composerData = composerMap.get(composer)!;
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

    return NextResponse.json(composers);
  } catch (error) {
    console.error('API Error fetching composers:', error);
    return NextResponse.json(
      { error: 'Failed to fetch composers' }, 
      { status: 500 }
    );
  }
}