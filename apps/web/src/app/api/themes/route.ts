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
              const originalTheme = theme.trim();
              // Normalize theme by removing punctuation and extra spaces
              const normalizedTheme = originalTheme.replace(/[.,\s\-'&]+/g, '').toUpperCase();
              
              // Find existing theme with same normalized form or create new entry
              let existingTheme = null;
              for (const [existingKey] of themeMap.entries()) {
                const existingNormalized = existingKey.replace(/[.,\s\-'&]+/g, '').toUpperCase();
                if (existingNormalized === normalizedTheme) {
                  existingTheme = existingKey;
                  break;
                }
              }
              
              const themeKey = existingTheme || originalTheme;
              if (!themeMap.has(themeKey)) {
                themeMap.set(themeKey, { count: 0, hymns: [] });
              }
              const themeData = themeMap.get(themeKey)!;
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