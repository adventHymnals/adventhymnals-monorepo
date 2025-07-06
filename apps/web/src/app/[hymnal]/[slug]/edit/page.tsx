import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { 
  ChevronLeftIcon, 
  ChevronRightIcon,
  HomeIcon,
  BookOpenIcon,
  PhotoIcon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import { generateHymnalBreadcrumbs } from '@/components/ui/Breadcrumbs';
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

  const breadcrumbs = generateHymnalBreadcrumbs(
    hymnalRef.name, 
    params.hymnal, 
    hymn.title, 
    hymn.number
  );

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700 no-print">
          <div className="mx-auto max-w-7xl px-6 py-6 lg:px-8">
            <div className="mx-auto max-w-6xl">
              {/* Breadcrumbs */}
              <div className="mb-4">
                <nav className="flex" aria-label="Breadcrumb">
                  <ol role="list" className="flex items-center space-x-2">
                    {/* Home icon */}
                    <li>
                      <div>
                        <a
                          href="/"
                          className="text-primary-200 hover:text-white transition-colors duration-200"
                        >
                          <HomeIcon className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
                          <span className="sr-only">Home</span>
                        </a>
                      </div>
                    </li>

                    {/* Breadcrumb items */}
                    {breadcrumbs.map((item) => (
                      <li key={item.label}>
                        <div className="flex items-center">
                          <ChevronRightIcon
                            className="h-4 w-4 flex-shrink-0 text-primary-200"
                            aria-hidden="true"
                          />
                          {item.href && !item.current ? (
                            <a
                              href={item.href}
                              className="ml-2 text-sm font-medium text-primary-100 hover:text-white transition-colors duration-200"
                            >
                              {item.label}
                            </a>
                          ) : (
                            <span
                              className="ml-2 text-sm font-medium text-white"
                              aria-current={item.current ? 'page' : undefined}
                            >
                              {item.label}
                            </span>
                          )}
                        </div>
                      </li>
                    ))}
                    
                    {/* Edit indicator */}
                    <li>
                      <div className="flex items-center">
                        <ChevronRightIcon
                          className="h-4 w-4 flex-shrink-0 text-primary-200"
                          aria-hidden="true"
                        />
                        <span className="ml-2 text-sm font-medium text-primary-100">
                          Edit
                        </span>
                      </div>
                    </li>
                  </ol>
                </nav>
              </div>

              {/* Header content */}
              <div className="flex items-center justify-between text-white">
                <div>
                  <h1 className="text-xl font-bold tracking-tight sm:text-2xl lg:text-3xl">
                    <span className="text-primary-200 mr-2">#{hymn.number}</span>
                    {hymn.title}
                  </h1>
                  <p className="mt-2 text-sm text-primary-100">
                    Edit hymn text and view original images
                  </p>
                </div>
                
                {/* Navigation buttons */}
                <div className="flex items-center space-x-2">
                  <a
                    href={`/${params.hymnal}/${params.slug}`}
                    className="inline-flex items-center px-3 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-sm"
                  >
                    <BookOpenIcon className="h-4 w-4 mr-1" />
                    View
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Edit Interface */}
        <HymnEditView 
          hymn={hymn}
          hymnalRef={hymnalRef}
          allHymns={allHymns}
          params={params}
        />
      </div>
    </Layout>
  );
}