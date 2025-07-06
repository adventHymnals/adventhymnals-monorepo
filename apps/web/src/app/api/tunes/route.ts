import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';

export async function GET() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const tuneMap = new Map<string, { count: number; hymns: any[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.tune) {
            const tune = hymn.tune.trim();
            if (!tuneMap.has(tune)) {
              tuneMap.set(tune, { count: 0, hymns: [] });
            }
            const tuneData = tuneMap.get(tune)!;
            tuneData.count++;
            tuneData.hymns.push({
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
    const tunes = Array.from(tuneMap.entries())
      .map(([tune, data]) => ({
        tune,
        count: data.count,
        hymns: data.hymns
      }))
      .sort((a, b) => b.count - a.count);

    return NextResponse.json(tunes);
  } catch (error) {
    console.error('API Error fetching tunes:', error);
    return NextResponse.json(
      { error: 'Failed to fetch tunes' }, 
      { status: 500 }
    );
  }
}