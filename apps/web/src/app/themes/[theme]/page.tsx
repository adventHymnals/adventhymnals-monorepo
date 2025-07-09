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
  
  // Get some basic stats about the theme
  const hymnalReferences = await loadHymnalReferences();
  const { loadHymnalHymns } = await import('@/lib/data-server');
  let hymnCount = 0;
  const hymnalSet = new Set<string>();
  
  // Count hymns and hymnals for this theme
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      const themeHymns = hymns.filter((hymn: any) => hymn.metadata?.themes?.includes(decodedTheme));
      if (themeHymns.length > 0) {
        hymnCount += themeHymns.length;
        hymnalSet.add(hymnalRef.abbreviation);
      }
    } catch (error) {
      console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
    }
  }
  
  const hymnalList = Array.from(hymnalSet).join(', ');
  const title = `${decodedTheme} - Hymn Theme | Advent Hymnals`;
  const description = `Browse ${hymnCount} hymns with the theme "${decodedTheme}" across ${hymnalSet.size} hymnal collections (${hymnalList}). Explore Adventist hymnody with full text, themes, and musical information.`;
  
  // Determine site URL
  const siteUrl = process.env.SITE_URL || 
    (process.env.NEXT_OUTPUT === 'export' ? 'https://adventhymnals.github.io' : 'https://adventhymnals.org');
  
  return {
    title,
    description,
    keywords: [
      decodedTheme,
      'hymn theme',
      'Adventist hymns',
      'church music',
      'worship music',
      'Christian music',
      'hymnal',
      ...Array.from(hymnalSet)
    ],
    openGraph: {
      title,
      description,
      type: 'website',
      url: `${siteUrl}/themes/${encodeURIComponent(decodedTheme)}`,
      images: [
        {
          url: `${siteUrl}/og-image.jpg`,
          width: 1200,
          height: 630,
          alt: `${decodedTheme} - Hymn Theme on Advent Hymnals`,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [`${siteUrl}/og-image.jpg`],
    },
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