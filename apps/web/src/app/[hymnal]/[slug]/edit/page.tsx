import { notFound } from 'next/navigation';
import { Metadata } from 'next';

import HymnEditView from '@/components/hymn/HymnEditView';
import { loadHymnalReferences, loadHymn, loadHymnalHymns } from '@/lib/data-server';

// Client component for the close button
function CloseButton() {
  'use client';
  
  const handleClose = () => {
    if (window.opener) {
      window.close();
    } else {
      // Fallback if window.close() doesn't work
      window.history.back();
    }
  };

  return (
    <button
      onClick={handleClose}
      className="inline-flex items-center px-3 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-sm"
    >
      Close
    </button>
  );
}

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
  try {
    const hymnalReferences = await loadHymnalReferences();
    const staticParams: { hymnal: string; slug: string }[] = [];

    // Generate static params for all hymns in all hymnals
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        
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
      {/* Minimal Header */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-700 py-4 px-6">
        <div className="flex items-center justify-between text-white">
          <div>
            <h1 className="text-lg font-bold">
              <span className="text-primary-200 mr-2">#{hymn.number}</span>
              {hymn.title}
            </h1>
            <p className="text-sm text-primary-100">
              Edit hymn text and view original images
            </p>
          </div>
          
          {/* Close button */}
          <CloseButton />
        </div>
      </div>

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