import { NextResponse } from 'next/server';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';

export async function GET() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const themeMap = new Map<string, { count: number; hymns: any[] }>();

    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
        for (const hymn of hymns) {
          if (hymn.metadata?.themes) {
            for (const theme of hymn.metadata.themes) {
              const normalizedTheme = theme.trim();
              if (!themeMap.has(normalizedTheme)) {
                themeMap.set(normalizedTheme, { count: 0, hymns: [] });
              }
              const themeData = themeMap.get(normalizedTheme)!;
              themeData.count++;
              themeData.hymns.push({
                ...hymn,
                hymnal: hymnalRef
              });
            }
          }
        }
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    // Convert to array and sort by count
    const themes = Array.from(themeMap.entries())
      .map(([theme, data]) => ({
        theme,
        count: data.count,
        hymns: data.hymns
      }))
      .sort((a, b) => b.count - a.count);

    return NextResponse.json(themes);
  } catch (error) {
    console.error('API Error fetching themes:', error);
    return NextResponse.json(
      { error: 'Failed to fetch themes' }, 
      { status: 500 }
    );
  }
}