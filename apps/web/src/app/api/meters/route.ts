import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';

export async function GET() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const meterMap = new Map<string, { count: number; hymns: unknown[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.meter) {
            const originalMeter = hymn.meter.trim();
            // Normalize meter by removing punctuation and extra spaces
            const normalizedMeter = originalMeter.replace(/[.,\s]+/g, '').toUpperCase();
            
            // Find existing meter with same normalized form or create new entry
            let existingMeter = null;
            for (const [existingKey] of Array.from(meterMap.entries())) {
              const existingNormalized = existingKey.replace(/[.,\s]+/g, '').toUpperCase();
              if (existingNormalized === normalizedMeter) {
                existingMeter = existingKey;
                break;
              }
            }
            
            const meterKey = existingMeter || originalMeter;
            if (!meterMap.has(meterKey)) {
              meterMap.set(meterKey, { count: 0, hymns: [] });
            }
            const meterData = meterMap.get(meterKey)!;
            meterData.count++;
            meterData.hymns.push({
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
    const meters = Array.from(meterMap.entries())
      .map(([meter, data]) => ({
        meter,
        count: data.count,
        hymns: data.hymns
      }))
      .sort((a, b) => b.count - a.count);

    return NextResponse.json(meters);
  } catch (error) {
    console.error('API Error fetching meters:', error);
    return NextResponse.json(
      { error: 'Failed to fetch meters' }, 
      { status: 500 }
    );
  }
}