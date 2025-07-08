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
  // Check if this is a static export build
  const isStaticExport = process.env.NEXT_OUTPUT === 'export';
  
  if (isStaticExport) {
    // For static export, generate a placeholder page that shows "not supported" message
    return [
      {
        hymnId: 'placeholder'
      }
    ];
  }
  
  // For dynamic server builds, generate projection pages for all hymns
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const allHymnIds: string[] = [];
    
    // Load hymns from all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        allHymnIds.push(...hymns.map((hymn: { id: string }) => hymn.id));
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
  // Check if this is a static export build
  const isStaticExport = process.env.NEXT_OUTPUT === 'export';
  
  // Show "not supported" message for static export builds
  if (isStaticExport) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border p-8 text-center">
          <div className="mb-6">
            <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
          </div>
          
          <h1 className="text-xl font-semibold text-gray-900 mb-3">
            Projection Mode Not Available
          </h1>
          
          <p className="text-gray-600 mb-6">
            Projection mode is not supported in fully static mode. This feature requires a dynamic server environment.
          </p>
          
          <div className="space-y-3">
            <a
              href="/"
              className="block w-full bg-primary-600 text-white py-2 px-4 rounded-lg hover:bg-primary-700 transition-colors"
            >
              Back to Home
            </a>
          </div>
        </div>
      </div>
    );
  }

  // For dynamic server builds, show the actual projection interface
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