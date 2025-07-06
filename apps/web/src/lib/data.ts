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
 * Load hymnal reference metadata
 */
export async function loadHymnalReferences(): Promise<HymnalCollection> {
  const cacheKey = 'hymnal-references';
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey) as HymnalCollection;
  }

  try {
    const filePath = path.join(process.cwd(), '../../data/processed/metadata/hymnals-reference.json');
    const data = await fs.readFile(filePath, 'utf8');
    const collection = JSON.parse(data) as HymnalCollection;
    
    // Add URL slugs to each hymnal reference
    Object.values(collection.hymnals).forEach(hymnal => {
      if (!hymnal.url_slug) {
        hymnal.url_slug = generateUrlSlug(hymnal.name);
      }
    });
    
    cache.set(cacheKey, collection);
    return collection;
  } catch (error) {
    console.error('Failed to load hymnal references:', error);
    throw new Error('Failed to load hymnal data');
  }
}

/**
 * Get a specific hymnal reference by ID
 */
export async function getHymnalReference(id: string): Promise<HymnalReference | null> {
  const collection = await loadHymnalReferences();
  return collection.hymnals[id] || null;
}

/**
 * Load a specific hymnal collection
 */
export async function loadHymnal(hymnalId: string): Promise<Hymnal | null> {
  const cacheKey = `hymnal-${hymnalId}`;
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey) as Hymnal;
  }

  try {
    const filePath = path.join(process.cwd(), `../../data/processed/hymnals/${hymnalId}-collection.json`);
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
 * Load a specific hymn by ID
 */
export async function loadHymn(hymnId: string): Promise<Hymn | null> {
  const cacheKey = `hymn-${hymnId}`;
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey) as Hymn;
  }

  try {
    // Extract hymnal and hymn number from ID (e.g., "SDAH-en-001" -> "SDAH", "001")
    const parts = hymnId.split('-');
    if (parts.length !== 3) {
      throw new Error(`Invalid hymn ID format: ${hymnId}`);
    }
    
    const [hymnalId] = parts;
    const filePath = path.join(process.cwd(), `../../data/processed/hymns/${hymnalId}/${hymnId}.json`);
    
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
 * Load hymns for a specific hymnal with pagination
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
 * Search hymns across all hymnals or within a specific hymnal
 */
export async function searchHymns(
  query: string,
  hymnalId?: string,
  limit: number = 20
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference; score: number }>> {
  const references = await loadHymnalReferences();
  const hymnalsToSearch = hymnalId 
    ? [references.hymnals[hymnalId]].filter(Boolean)
    : Object.values(references.hymnals);

  const results: Array<{ hymn: Hymn; hymnal: HymnalReference; score: number }> = [];
  const queryLower = query.toLowerCase();

  for (const hymnalRef of hymnalsToSearch) {
    const hymnal = await loadHymnal(hymnalRef.id);
    if (!hymnal) continue;

    for (const entry of hymnal.hymns) {
      const hymn = await loadHymn(entry.hymn_id);
      if (!hymn) continue;

      let score = 0;

      // Title match (highest priority)
      if (hymn.title.toLowerCase().includes(queryLower)) {
        score += 100;
        if (hymn.title.toLowerCase().startsWith(queryLower)) {
          score += 50;
        }
      }

      // Number match
      if (hymn.number.toString() === query) {
        score += 200;
      }

      // Author/composer match
      if (hymn.author?.toLowerCase().includes(queryLower)) {
        score += 30;
      }
      if (hymn.composer?.toLowerCase().includes(queryLower)) {
        score += 30;
      }

      // Tune match
      if (hymn.tune?.toLowerCase().includes(queryLower)) {
        score += 20;
      }

      // Verse text match (lower priority)
      for (const verse of hymn.verses) {
        if (verse.text.toLowerCase().includes(queryLower)) {
          score += 10;
          break; // Only count once per hymn
        }
      }

      // Theme match
      if (hymn.metadata?.themes?.some(theme => theme.toLowerCase().includes(queryLower))) {
        score += 15;
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
 * Get hymns by theme
 */
export async function getHymnsByTheme(
  theme: string,
  limit: number = 20
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference }>> {
  const references = await loadHymnalReferences();
  const results: Array<{ hymn: Hymn; hymnal: HymnalReference }> = [];
  const themeLower = theme.toLowerCase();

  for (const hymnalRef of Object.values(references.hymnals)) {
    const hymnal = await loadHymnal(hymnalRef.id);
    if (!hymnal) continue;

    for (const entry of hymnal.hymns) {
      const hymn = await loadHymn(entry.hymn_id);
      if (!hymn?.metadata?.themes) continue;

      if (hymn.metadata.themes.some(t => t.toLowerCase() === themeLower)) {
        results.push({ hymn, hymnal: hymnalRef });
        
        if (results.length >= limit) {
          return results;
        }
      }
    }
  }

  return results;
}

/**
 * Get hymns by composer
 */
export async function getHymnsByComposer(
  composer: string,
  limit: number = 20
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference }>> {
  const references = await loadHymnalReferences();
  const results: Array<{ hymn: Hymn; hymnal: HymnalReference }> = [];
  const composerLower = composer.toLowerCase();

  for (const hymnalRef of Object.values(references.hymnals)) {
    const hymnal = await loadHymnal(hymnalRef.id);
    if (!hymnal) continue;

    for (const entry of hymnal.hymns) {
      const hymn = await loadHymn(entry.hymn_id);
      if (!hymn?.composer) continue;

      if (hymn.composer.toLowerCase().includes(composerLower)) {
        results.push({ hymn, hymnal: hymnalRef });
        
        if (results.length >= limit) {
          return results;
        }
      }
    }
  }

  return results;
}

/**
 * Get related hymns (same tune, composer, or theme)
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
 * Get popular/featured hymns
 */
export async function getFeaturedHymns(limit: number = 10): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference }>> {
  // For now, return hymns from the main SDAH collection
  // In the future, this could be based on actual usage data
  const sdahHymns = await loadHymnalHymns('SDAH', 1, limit);
  const references = await loadHymnalReferences();
  const sdahRef = references.hymnals['SDAH'];

  return sdahHymns.hymns.map(hymn => ({
    hymn,
    hymnal: sdahRef
  }));
}

/**
 * Clear the data cache (useful for development)
 */
export function clearCache(): void {
  cache.clear();
}