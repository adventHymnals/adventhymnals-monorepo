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
    const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/meters`);
    if (!response.ok) return [];
    
    const meters = await response.json();
    return meters.map((meter: { meter: string }) => ({
      meter: encodeURIComponent(meter.meter)
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
  
  let metersData;
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/meters`, {
      cache: 'force-cache'
    });
    if (!response.ok) {
      throw new Error('Failed to fetch meters');
    }
    metersData = await response.json();
  } catch (error) {
    console.error('Failed to load meter data:', error);
    notFound();
  }
  
  const meterData = metersData.find((m: { meter: string }) => m.meter === decodedMeter);
  
  if (!meterData) {
    notFound();
  }
  
  const hymns: HymnData[] = meterData.hymns;

  return (
    <MeterDetailClient 
      hymns={hymns}
      decodedMeter={decodedMeter}
      hymnalReferences={hymnalReferences}
    />
  );
}