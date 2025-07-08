import { Hymn, Hymnal, HymnalCollection, HymnalReference } from '@advent-hymnals/shared';

// Cache for loaded data
const cache = new Map<string, unknown>();

// API base URL - for static export, use production API
const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || process.env.API_BASE_URL || '';

export function getApiUrl(path: string): string {
  if (API_BASE_URL) {
    return `${API_BASE_URL}${path}`;
  }
  return path; // Use relative URLs for non-static builds
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
    const response = await fetch(getApiUrl('/api/hymnals'));
    if (!response.ok) {
      throw new Error('Failed to fetch hymnal references');
    }
    
    const collection = await response.json() as HymnalCollection;
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
    const response = await fetch(getApiUrl(`/api/hymnals/${hymnalId}`));
    if (!response.ok) {
      return null;
    }
    
    const hymnal = await response.json() as Hymnal;
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
    const response = await fetch(getApiUrl(`/api/hymns/${hymnId}`));
    if (!response.ok) {
      return null;
    }
    
    const hymn = await response.json() as Hymn;
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
  try {
    const response = await fetch(getApiUrl(`/api/hymnals/${hymnalId}/hymns?page=${page}&limit=${limit}`));
    if (!response.ok) {
      return { hymns: [], total: 0, totalPages: 0 };
    }
    
    return await response.json();
  } catch (error) {
    console.warn(`Failed to load hymns for hymnal ${hymnalId}:`, error);
    return { hymns: [], total: 0, totalPages: 0 };
  }
}

/**
 * Search hymns across all hymnals or within a specific hymnal
 */
export async function searchHymns(
  query: string,
  hymnalId?: string,
  limit: number = 20
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference; score: number }>> {
  try {
    const params = new URLSearchParams({
      q: query,
      limit: limit.toString()
    });
    
    if (hymnalId) {
      params.append('hymnal', hymnalId);
    }
    
    const response = await fetch(getApiUrl(`/api/search?${params.toString()}`));
    if (!response.ok) {
      return [];
    }
    
    return await response.json();
  } catch (error) {
    console.warn('Failed to search hymns:', error);
    return [];
  }
}

/**
 * Get related hymns (same tune, composer, or theme)
 */
export async function getRelatedHymns(
  hymnId: string,
  limit: number = 10
): Promise<Array<{ hymn: Hymn; hymnal: HymnalReference; relationship: string }>> {
  try {
    const response = await fetch(getApiUrl(`/api/hymns/${hymnId}/related?limit=${limit}`));
    if (!response.ok) {
      return [];
    }
    
    return await response.json();
  } catch (error) {
    console.warn(`Failed to load related hymns for ${hymnId}:`, error);
    return [];
  }
}

/**
 * Clear the data cache (useful for development)
 */
export function clearCache(): void {
  cache.clear();
}