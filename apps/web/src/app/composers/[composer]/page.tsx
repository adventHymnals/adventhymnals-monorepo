import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import ComposerDetailClient from './ComposerDetailClient';

interface HymnData {
  id: string;
  number: number;
  title: string;
  composer?: string;
  hymnal: {
    id: string;
    name: string;
    url_slug: string;
    abbreviation: string;
  };
}

interface ComposerDetailProps {
  params: {
    composer: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalReferences, loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const composerSet = new Set<string>();

    // Load hymns from all hymnals to get unique composers
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        hymns.forEach((hymn: { composer?: string }) => {
          if (hymn.composer) {
            composerSet.add(hymn.composer);
          }
        });
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return Array.from(composerSet).map((composer: string) => ({
      composer: encodeURIComponent(composer)
    }));
  } catch (error) {
    console.error('Error generating static params for composers:', error);
    return [];
  }
}

export async function generateMetadata({ params }: ComposerDetailProps): Promise<Metadata> {
  const decodedComposer = decodeURIComponent(params.composer);
  
  // Get some basic stats about the composer
  const hymnalReferences = await loadHymnalReferences();
  const { loadHymnalHymns } = await import('@/lib/data-server');
  let hymnCount = 0;
  const hymnalSet = new Set<string>();
  
  // Count hymns and hymnals for this composer
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      const composerHymns = hymns.filter((hymn: any) => hymn.composer === decodedComposer);
      if (composerHymns.length > 0) {
        hymnCount += composerHymns.length;
        hymnalSet.add(hymnalRef.abbreviation);
      }
    } catch (error) {
      console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
    }
  }
  
  const hymnalList = Array.from(hymnalSet).join(', ');
  const title = `${decodedComposer} - Hymn Composer | Advent Hymnals`;
  const description = `Browse ${hymnCount} hymns composed by ${decodedComposer} across ${hymnalSet.size} hymnal collections (${hymnalList}). Explore Adventist hymnody with full text, themes, and musical information.`;
  
  // Determine site URL
  const siteUrl = process.env.SITE_URL || 
    (process.env.NEXT_OUTPUT === 'export' ? 'https://adventhymnals.github.io' : 'https://adventhymnals.org');
  
  return {
    title,
    description,
    keywords: [
      decodedComposer,
      'hymn composer',
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
      type: 'profile',
      url: `${siteUrl}/composers/${encodeURIComponent(decodedComposer)}`,
      images: [
        {
          url: `${siteUrl}/og-image.jpg`,
          width: 1200,
          height: 630,
          alt: `${decodedComposer} - Hymn Composer on Advent Hymnals`,
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

export default async function ComposerDetailPage({ params }: ComposerDetailProps) {
  const decodedComposer = decodeURIComponent(params.composer);
  const hymnalReferences = await loadHymnalReferences();
  
  // Use server-side data loading directly instead of API fetch
  const { loadHymnalHymns } = await import('@/lib/data-server');
  const hymns: HymnData[] = [];
  
  // Load hymns from all hymnals to find composer's hymns
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns: hymnalHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      hymnalHymns.forEach((hymn: any) => {
        if (hymn.composer === decodedComposer) {
          hymns.push({
            id: hymn.id,
            number: hymn.number,
            title: hymn.title,
            composer: hymn.composer,
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
    <ComposerDetailClient 
      hymns={hymns}
      decodedComposer={decodedComposer}
      hymnalReferences={hymnalReferences}
    />
  );
}