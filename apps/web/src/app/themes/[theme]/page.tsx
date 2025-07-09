import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import ThemeDetailClient from './ThemeDetailClient';

interface HymnData {
  id: string;
  number: number;
  title: string;
  author?: string;
  hymnal: {
    id: string;
    name: string;
    url_slug: string;
    abbreviation: string;
  };
}

interface ThemeDetailProps {
  params: {
    theme: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalReferences, loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const themeSet = new Set<string>();

    // Load hymns from all hymnals to get unique themes
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        hymns.forEach((hymn: { metadata?: { themes?: string[] } }) => {
          if (hymn.metadata?.themes) {
            hymn.metadata.themes.forEach(theme => themeSet.add(theme));
          }
        });
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return Array.from(themeSet).map((theme: string) => ({
      theme: encodeURIComponent(theme)
    }));
  } catch (error) {
    console.error('Error generating static params for themes:', error);
    return [];
  }
}

export async function generateMetadata({ params }: ThemeDetailProps): Promise<Metadata> {
  const decodedTheme = decodeURIComponent(params.theme);
  return {
    title: `${decodedTheme} - Hymn Theme`,
    description: `Browse hymns with the theme "${decodedTheme}". Explore Adventist hymnody with full text, themes, and musical information.`
  };
}

export default async function ThemeDetailPage({ params }: ThemeDetailProps) {
  const decodedTheme = decodeURIComponent(params.theme);
  const hymnalReferences = await loadHymnalReferences();
  
  // Use server-side data loading directly instead of API fetch
  const { loadHymnalHymns } = await import('@/lib/data-server');
  const hymns: HymnData[] = [];
  
  // Load hymns from all hymnals to find hymns with this theme
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns: hymnalHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      hymnalHymns.forEach((hymn: any) => {
        if (hymn.metadata?.themes?.includes(decodedTheme)) {
          hymns.push({
            id: hymn.id,
            number: hymn.number,
            title: hymn.title,
            author: hymn.author,
            hymnal: {
              id: hymnalRef.id,
              name: hymnalRef.name,
              url_slug: hymnalRef.url_slug,
              abbreviation: hymnalRef.abbreviation
            }
          });
        }
      });
    } catch (error) {
      console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
    }
  }
  
  if (hymns.length === 0) {
    notFound();
  }

  return (
    <ThemeDetailClient 
      hymns={hymns}
      decodedTheme={decodedTheme}
      hymnalReferences={hymnalReferences}
    />
  );
}