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
  // For static export, generate edit pages for all hymns but show "not supported" message
  // For dynamic server builds, generate edit pages with full functionality
  try {
    console.log('🚀 Generating static params for edit pages, NEXT_OUTPUT:', process.env.NEXT_OUTPUT);
    const hymnalReferences = await loadHymnalReferences();
    const staticParams: { hymnal: string; slug: string }[] = [];

    // Generate static params for all hymns 
    const isStaticExport = process.env.NEXT_OUTPUT === 'export';
    const hymnLimit = isStaticExport ? 1000 : 10; // Full generation for static export
    
    console.log(`📖 Loading hymns from ${Object.keys(hymnalReferences.hymnals).length} hymnals, limit: ${hymnLimit}`);
    
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, hymnLimit);
        console.log(`✅ Loaded ${hymns.length} hymns from ${hymnalRef.id}`);
        
        for (const hymn of hymns) {
          const slug = `hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`;
          staticParams.push({
            hymnal: hymnalRef.url_slug,
            slug: slug
          });
        }
      } catch (error) {
        console.warn(`❌ Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    console.log(`🎯 Generated ${staticParams.length} edit page static params`);
    // Log first few for debugging
    console.log('First 3 edit params:', staticParams.slice(0, 3));
    
    return staticParams;
  } catch (error) {
    console.error('💥 Error generating static params for edit pages:', error);
    return [];
  }
}

export default async function EditPage({ params }: EditPageProps) {
  // Always render client component to avoid RSC requests during navigation
  // The client component will handle data loading via external API
  const { default: EditPageClient } = await import('./EditPageClient');
  return <EditPageClient params={params} />;
}