import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import MeterDetailClient from './MeterDetailClient';

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

interface MeterDetailProps {
  params: {
    meter: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalReferences, loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const meterSet = new Set<string>();

    // Load hymns from all hymnals to get unique meters
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        hymns.forEach((hymn: { meter?: string }) => {
          if (hymn.meter) {
            meterSet.add(hymn.meter);
          }
        });
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return Array.from(meterSet).map((meter: string) => ({
      meter: encodeURIComponent(meter)
    }));
  } catch (error) {
    console.error('Error generating static params for meters:', error);
    return [];
  }
}

export async function generateMetadata({ params }: MeterDetailProps): Promise<Metadata> {
  const decodedMeter = decodeURIComponent(params.meter);
  return {
    title: `${decodedMeter} - Hymn Meter`,
    description: `Browse hymns in the meter "${decodedMeter}". Explore Adventist hymnody with full text, themes, and musical information.`
  };
}

export default async function MeterDetailPage({ params }: MeterDetailProps) {
  const decodedMeter = decodeURIComponent(params.meter);
  const hymnalReferences = await loadHymnalReferences();
  
  // Use server-side data loading directly instead of API fetch
  const { loadHymnalHymns } = await import('@/lib/data-server');
  const hymns: HymnData[] = [];
  
  // Load hymns from all hymnals to find hymns with this meter
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns: hymnalHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      hymnalHymns.forEach((hymn: any) => {
        if (hymn.meter === decodedMeter) {
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
    <MeterDetailClient 
      hymns={hymns}
      decodedMeter={decodedMeter}
      hymnalReferences={hymnalReferences}
    />
  );
}