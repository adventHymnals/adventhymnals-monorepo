import { notFound } from 'next/navigation';
import { Metadata } from 'next';

import HymnEditView from '@/components/hymn/HymnEditView';
import { loadHymnalReferences, loadHymn, loadHymnalHymns } from '@/lib/data-server';


interface EditPageProps {
  params: {
    hymnal: string;
    slug: string;
  };
}

// Extract hymn number from slug like "hymn-132-o-come-all-ye-faithful"
function extractHymnNumber(slug: string): number | null {
  const match = slug.match(/^hymn-(\d+)-/);
  return match ? parseInt(match[1], 10) : null;
}


export async function generateMetadata({ params }: EditPageProps): Promise<Metadata> {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const hymnalRef = Object.values(hymnalReferences.hymnals).find(
      (h) => h.url_slug === params.hymnal
    );
    
    if (!hymnalRef) {
      return { title: 'Edit Hymn - Not Found' };
    }
    
    const hymnNumber = extractHymnNumber(params.slug);
    if (!hymnNumber) {
      return { title: 'Edit Hymn - Invalid Format' };
    }
    
    const hymnId = `${hymnalRef.id}-${hymnalRef.language}-${hymnNumber.toString().padStart(3, '0')}`;
    const hymn = await loadHymn(hymnId);
    
    if (!hymn) {
      return { title: 'Edit Hymn - Not Found' };
    }

    return {
      title: `Edit ${hymn.title} - ${hymnalRef.site_name} #${hymn.number}`,
      description: `Edit hymn text and view original images for ${hymn.title} from ${hymnalRef.site_name}.`,
    };
  } catch {
    return { title: 'Edit Hymn - Error' };
  }
}

export async function generateStaticParams() {
  // Check if this is a static export build
  const isStaticExport = process.env.NEXT_OUTPUT === 'export';
  
  if (isStaticExport) {
    // For static export, generate a placeholder page that shows "not supported" message
    return [
      {
        hymnal: 'placeholder',
        slug: 'placeholder'
      }
    ];
  }
  
  // For dynamic server builds, generate edit pages for hymns
  try {
    const hymnalReferences = await loadHymnalReferences();
    const staticParams: { hymnal: string; slug: string }[] = [];

    // Generate static params for popular hymns only (first 10 from each hymnal)
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 10);
        
        for (const hymn of hymns) {
          const slug = `hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`;
          staticParams.push({
            hymnal: hymnalRef.url_slug,
            slug: slug
          });
        }
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return staticParams;
  } catch (error) {
    console.error('Error generating static params for edit pages:', error);
    return [];
  }
}

export default async function EditPage({ params }: EditPageProps) {
  // Check if this is a static export build
  const isStaticExport = process.env.NEXT_OUTPUT === 'export';
  
  // Show "not supported" message for static export builds
  if (isStaticExport) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border p-8 text-center">
          <div className="mb-6">
            <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </div>
          
          <h1 className="text-xl font-semibold text-gray-900 mb-3">
            Edit Mode Not Available
          </h1>
          
          <p className="text-gray-600 mb-6">
            Hymn editing is not supported in fully static mode. This feature requires a dynamic server environment.
          </p>
          
          <div className="space-y-3">
            <a
              href={`/${params.hymnal}/${params.slug}`}
              className="block w-full bg-primary-600 text-white py-2 px-4 rounded-lg hover:bg-primary-700 transition-colors"
            >
              View Hymn
            </a>
            
            <a
              href={`/${params.hymnal}`}
              className="block w-full bg-gray-100 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-200 transition-colors"
            >
              Back to Hymnal
            </a>
          </div>
        </div>
      </div>
    );
  }

  // For dynamic server builds, show the actual edit interface
  const hymnalReferences = await loadHymnalReferences();
  const hymnalRef = Object.values(hymnalReferences.hymnals).find(
    (h) => h.url_slug === params.hymnal
  );

  if (!hymnalRef) {
    notFound();
  }

  const hymnNumber = extractHymnNumber(params.slug);
  if (!hymnNumber) {
    notFound();
  }

  const hymnId = `${hymnalRef.id}-${hymnalRef.language}-${hymnNumber.toString().padStart(3, '0')}`;
  const hymn = await loadHymn(hymnId);
  
  if (!hymn) {
    notFound();
  }

  // Load all hymns for navigation
  const { hymns: allHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Edit Interface - Full Height */}
      <HymnEditView 
        hymn={hymn}
        hymnalRef={hymnalRef}
        allHymns={allHymns}
        params={params}
      />
    </div>
  );
}