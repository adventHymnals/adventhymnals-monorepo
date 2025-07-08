import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { Suspense } from 'react';
import { loadHymnalReferences } from '@/lib/data-server';
import ProjectionClient from './ProjectionClient';

interface ProjectionPageProps {
  params: {
    hymnId: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const allHymnIds: string[] = [];
    
    // Generate all hymns for static export
    const isStaticExport = process.env.NEXT_OUTPUT === 'export';
    const hymnLimit = isStaticExport ? 1000 : 1000;
    
    console.log(`🎵 Generating projection static params, isStaticExport: ${isStaticExport}, hymnLimit: ${hymnLimit}`);
    
    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, hymnLimit);
        allHymnIds.push(...hymns.map((hymn: { id: string }) => hymn.id));
        console.log(`✅ Added ${hymns.length} projection pages for ${hymnalRef.id}`);
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }
    
    console.log(`🎯 Generated ${allHymnIds.length} projection static params`);
    
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
  // In static export mode, the client will handle data loading via API calls to adventhymnals.org
  const isStaticExport = process.env.NEXT_OUTPUT === 'export';
  
  if (isStaticExport) {
    // For static export, render a basic structure that will be enhanced by the client
    return (
      <Suspense fallback={<div className="flex items-center justify-center min-h-screen bg-black text-white">Loading projection...</div>}>
        <ProjectionClient hymnId={params.hymnId} hymn={null} />
      </Suspense>
    );
  }

  // For server builds, pre-load the hymn data
  try {
    const { loadHymn } = await import('@/lib/data-server');
    const hymn = await loadHymn(params.hymnId);
    
    if (!hymn) {
      notFound();
    }
    
    return (
      <Suspense fallback={<div className="flex items-center justify-center min-h-screen bg-black text-white">Loading projection...</div>}>
        <ProjectionClient hymnId={params.hymnId} hymn={hymn} />
      </Suspense>
    );
  } catch (error) {
    console.error('Failed to load hymn:', error);
    notFound();
  }
}