import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import ProjectionClient from './ProjectionClient';

interface ProjectionPageProps {
  params: {
    hymnId: string;
  };
}

export async function generateStaticParams() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const allHymnIds: string[] = [];
    
    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/hymnals/${hymnalRef.id}/hymns?limit=1000`);
        if (response.ok) {
          const { hymns } = await response.json();
          allHymnIds.push(...hymns.map((hymn: { id: string }) => hymn.id));
        }
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }
    
    return allHymnIds.map((hymnId: string) => ({
      hymnId
    }));
  } catch (error) {
    console.error('Error generating static params for projection:', error);
    return [];
  }
}

export async function generateMetadata({ params }: ProjectionPageProps): Promise<Metadata> {
  try {
    const { loadHymn } = await import('@/lib/data-server');
    const hymn = await loadHymn(params.hymnId);
    if (!hymn) {
      return {
        title: 'Hymn Projection',
        description: 'Full-screen hymn presentation for worship services.'
      };
    }
    return {
      title: `${hymn.title} - Projection`,
      description: `Projection view for the hymn "${hymn.title}". Full-screen hymn presentation for worship services.`
    };
  } catch (error) {
    return {
      title: 'Hymn Projection',
      description: 'Full-screen hymn presentation for worship services.'
    };
  }
}

export default async function ProjectionPage({ params }: ProjectionPageProps) {
  try {
    const { loadHymn } = await import('@/lib/data-server');
    const hymn = await loadHymn(params.hymnId);
    
    if (!hymn) {
      notFound();
    }
    
    return (
      <ProjectionClient hymnId={params.hymnId} hymn={hymn} />
    );
  } catch (error) {
    console.error('Failed to load hymn:', error);
    notFound();
  }
}