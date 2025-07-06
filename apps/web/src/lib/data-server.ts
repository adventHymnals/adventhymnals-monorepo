import { Hymn, Hymnal, HymnalCollection, HymnalReference } from '@advent-hymnals/shared';
import { promises as fs } from 'fs';
import path from 'path';

// Cache for loaded data
const cache = new Map<string, unknown>();

/**
 * Generate URL slug from hymnal name
 */
function generateUrlSlug(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

/**
 * Load hymnal reference metadata (Server-side only)
 */
export async function loadHymnalReferences(): Promise<HymnalCollection> {
  const cacheKey = 'hymnal-references';
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey) as HymnalCollection;
  }

  try {
    const filePath = path.join(process.cwd(), '../..', 'data/processed/metadata/hymnals-reference.json');
    const data = await fs.readFile(filePath, 'utf8');
    const collection = JSON.parse(data) as HymnalCollection;
    
    // Add URL slugs to each hymnal reference if not present
    Object.values(collection.hymnals).forEach(hymnal => {
      if (!hymnal.url_slug) {
        hymnal.url_slug = generateUrlSlug(hymnal.name);
      }
    });
    
    cache.set(cacheKey, collection);
    return collection;
  } catch (error) {
    console.error('Failed to load hymnal references:', error);
    
    // Fallback to minimal data structure
    const fallbackCollection: HymnalCollection = {
      hymnals: {
        'SDAH': {
          id: 'SDAH',
          name: 'Seventh-day Adventist Hymnal',
          abbreviation: 'SDAH',
          year: 1985,
          total_songs: 695,
          language: 'en',
          language_name: 'English',
          site_name: 'Seventh-day Adventist Hymnal',
          url_slug: 'seventh-day-adventist-hymnal'
        }
      },
      languages: {
        'en': 'English'
      },
      metadata: {
        total_hymnals: 1,
        date_range: { earliest: 1985, latest: 1985 },
        languages_supported: ['en'],
        total_estimated_songs: 695,
        source: 'Fallback data',
        generated_date: new Date().toISOString().split('T')[0]
      }
    };
    
    cache.set(cacheKey, fallbackCollection);
    return fallbackCollection;
  }
}

/**
 * Get a specific hymnal reference by ID (Server-side only)
 */
export async function getHymnalReference(id: string): Promise<HymnalReference | null> {
  const collection = await loadHymnalReferences();
  return collection.hymnals[id] || null;
}

/**
 * Load a specific hymnal collection (Server-side only)
 */
export async function loadHymnal(hymnalId: string): Promise<Hymnal | null> {
  const cacheKey = `hymnal-${hymnalId}`;
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey) as Hymnal;
  }

  try {
    const filePath = path.join(process.cwd(), '../..', `data/processed/hymnals/${hymnalId}-collection.json`);
    const data = await fs.readFile(filePath, 'utf8');
    const hymnal = JSON.parse(data) as Hymnal;
    
    cache.set(cacheKey, hymnal);
    return hymnal;
  } catch (error) {
    console.warn(`Failed to load hymnal ${hymnalId}:`, error);
    return null;
  }
}

/**
 * Load a specific hymn by ID (Server-side only)
 */
export async function loadHymn(hymnId: string): Promise<Hymn | null> {
  const cacheKey = `hymn-${hymnId}`;
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey) as Hymn;
  }

  try {
    // Extract hymnal from ID (e.g., "SDAH-en-001" -> "SDAH")
    const parts = hymnId.split('-');
    if (parts.length !== 3) {
      throw new Error(`Invalid hymn ID format: ${hymnId}`);
    }
    
    const [hymnalId] = parts;
    const filePath = path.join(process.cwd(), '../..', `data/processed/hymns/${hymnalId}/${hymnId}.json`);
    
    const data = await fs.readFile(filePath, 'utf8');
    const hymn = JSON.parse(data) as Hymn;
    
    cache.set(cacheKey, hymn);
    return hymn;
  } catch (error) {
    console.warn(`Failed to load hymn ${hymnId}:`, error);
    return null;
  }
}

/**
 * Load hymns for a specific hymnal with pagination (Server-side only)
 */
export async function loadHymnalHymns(
  hymnalId: string, 
  page: number = 1, 
  limit: number = 50
): Promise<{ hymns: Hymn[]; total: number; totalPages: number }> {
  const hymnal = await loadHymnal(hymnalId);
  if (!hymnal) {
    return { hymns: [], total: 0, totalPages: 0 };
  }

  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + limit;
  const hymnEntries = hymnal.hymns.slice(startIndex, endIndex);
  
  const hymns = await Promise.all(
    hymnEntries.map(async (entry) => {
      const hymn = await loadHymn(entry.hymn_id);
      return hymn;
    })
  );

  const validHymns = hymns.filter((hymn): hymn is Hymn => hymn !== null);
  
  return {
    hymns: validHymns,
    total: hymnal.hymns.length,
    totalPages: Math.ceil(hymnal.hymns.length / limit)
  };
}

/**
 * Get related hymns (same tune, composer, or theme) (Server-side only)
 */
export async function getRelatedHymns(
  hymnId: string,
  limit: number = 10
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference; relationship: string }>> {
  const sourceHymn = await loadHymn(hymnId);
  if (!sourceHymn) return [];

  const references = await loadHymnalReferences();
  const results: Array<{ hymn: Hymn; hymnal: HymnalReference; relationship: string }> = [];

  for (const hymnalRef of Object.values(references.hymnals)) {
    const hymnal = await loadHymnal(hymnalRef.id);
    if (!hymnal) continue;

    for (const entry of hymnal.hymns) {
      if (entry.hymn_id === hymnId) continue; // Skip the source hymn

      const hymn = await loadHymn(entry.hymn_id);
      if (!hymn) continue;

      let relationship = '';

      // Same tune
      if (sourceHymn.tune && hymn.tune === sourceHymn.tune) {
        relationship = 'Same tune';
      }
      // Same composer
      else if (sourceHymn.composer && hymn.composer === sourceHymn.composer) {
        relationship = 'Same composer';
      }
      // Same author
      else if (sourceHymn.author && hymn.author === sourceHymn.author) {
        relationship = 'Same author';
      }
      // Shared themes
      else if (sourceHymn.metadata?.themes && hymn.metadata?.themes) {
        const sharedThemes = sourceHymn.metadata.themes.filter(theme =>
          hymn.metadata?.themes?.includes(theme)
        );
        if (sharedThemes.length > 0) {
          relationship = `Shared theme: ${sharedThemes[0]}`;
        }
      }

      if (relationship) {
        results.push({ hymn, hymnal: hymnalRef, relationship });
        
        if (results.length >= limit) {
          return results;
        }
      }
    }
  }

  return results;
}

/**
 * Search hymns across all hymnals or within a specific hymnal (Server-side only)
 */
export async function searchHymns(
  query: string,
  hymnalId?: string,
  limit: number = 20
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference; score: number }>> {
  const references = await loadHymnalReferences();
  const results: Array<{ hymn: Hymn; hymnal: HymnalReference; score: number }> = [];
  const searchTerms = query.toLowerCase().split(' ').filter(term => term.length > 0);

  const hymnalsToSearch = hymnalId 
    ? [references.hymnals[hymnalId]].filter(Boolean)
    : Object.values(references.hymnals);

  for (const hymnalRef of hymnalsToSearch) {
    const hymnal = await loadHymnal(hymnalRef.id);
    if (!hymnal) continue;

    for (const entry of hymnal.hymns) {
      const hymn = await loadHymn(entry.hymn_id);
      if (!hymn) continue;

      let score = 0;
      const searchableText = [
        hymn.title,
        hymn.author,
        hymn.composer,
        hymn.tune,
        hymn.notation?.lyrics?.content || '',
        ...(hymn.metadata?.themes || []),
        ...(hymn.metadata?.topics || [])
      ].join(' ').toLowerCase();

      // Calculate relevance score
      for (const term of searchTerms) {
        if (hymn.title.toLowerCase().includes(term)) score += 10;
        if (hymn.author?.toLowerCase().includes(term)) score += 5;
        if (hymn.composer?.toLowerCase().includes(term)) score += 5;
        if (hymn.tune?.toLowerCase().includes(term)) score += 5;
        if (searchableText.includes(term)) score += 1;
      }

      if (score > 0) {
        results.push({ hymn, hymnal: hymnalRef, score });
      }
    }
  }

  // Sort by score (descending) and limit results
  return results
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);
}

/**
 * Clear the data cache (useful for development)
 */
export function clearCache(): void {
  cache.clear();
}