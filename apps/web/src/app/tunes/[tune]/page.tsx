import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import TuneDetailClient from './TuneDetailClient';

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

interface TuneDetailProps {
  params: {
    tune: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalReferences, loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const tuneSet = new Set<string>();

    // Load hymns from all hymnals to get unique tunes
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        hymns.forEach((hymn: { tune?: string }) => {
          if (hymn.tune) {
            tuneSet.add(hymn.tune);
          }
        });
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return Array.from(tuneSet).map((tune: string) => ({
      tune: encodeURIComponent(tune)
    }));
  } catch (error) {
    console.error('Error generating static params for tunes:', error);
    return [];
  }
}

export async function generateMetadata({ params }: TuneDetailProps): Promise<Metadata> {
  const decodedTune = decodeURIComponent(params.tune);
  return {
    title: `${decodedTune} - Hymn Tune`,
    description: `Browse hymns using the tune "${decodedTune}". Explore Adventist hymnody with full text, themes, and musical information.`
  };
}

export default async function TuneDetailPage({ params }: TuneDetailProps) {
  const decodedTune = decodeURIComponent(params.tune);
  const hymnalReferences = await loadHymnalReferences();
  
  let tunesData;
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/tunes`, {
      cache: 'force-cache'
    });
    if (!response.ok) {
      throw new Error('Failed to fetch tunes');
    }
    tunesData = await response.json();
  } catch (error) {
    console.error('Failed to load tune data:', error);
    notFound();
  }
  
  const tuneData = tunesData.find((t: { tune: string }) => t.tune === decodedTune);
  
  if (!tuneData) {
    notFound();
  }
  
  const hymns: HymnData[] = tuneData.hymns;

  return (
    <TuneDetailClient 
      hymns={hymns}
      decodedTune={decodedTune}
      hymnalReferences={hymnalReferences}
    />
  );
}