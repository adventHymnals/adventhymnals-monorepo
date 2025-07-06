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
            const originalTune = hymn.tune.trim();
            // Normalize tune by removing punctuation and extra spaces
            const normalizedTune = originalTune.replace(/[.,\s\-']+/g, '').toUpperCase();
            
            // Find existing tune with same normalized form or create new entry
            let existingTune = null;
            for (const [existingKey] of tuneMap.entries()) {
              const existingNormalized = existingKey.replace(/[.,\s\-']+/g, '').toUpperCase();
              if (existingNormalized === normalizedTune) {
                existingTune = existingKey;
                break;
              }
            }
            
            const tuneKey = existingTune || originalTune;
            if (!tuneMap.has(tuneKey)) {
              tuneMap.set(tuneKey, { count: 0, hymns: [] });
            }
            const tuneData = tuneMap.get(tuneKey)!;
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