import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  CalendarIcon, 
  UserIcon, 
  MusicalNoteIcon,
  MagnifyingGlassIcon,
  ListBulletIcon,
  HomeIcon,
  ChevronRightIcon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import { generateHymnalBreadcrumbs } from '@/components/ui/Breadcrumbs';
import HymnActionButtons from '@/components/ui/HymnActionButtons';
import HymnDisplaySection from '@/components/hymn/HymnDisplaySection';
import { loadHymnalReferences, loadHymn, loadHymnalHymns, getRelatedHymns } from '@/lib/data-server';

interface HymnPageProps {
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

export async function generateMetadata({ params }: HymnPageProps): Promise<Metadata> {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const hymnalRef = Object.values(hymnalReferences.hymnals).find(
      (h) => h.url_slug === params.hymnal
    );
    
    if (!hymnalRef) {
      return {
        title: 'Hymn Not Found',
      };
    }
    
    const hymnNumber = extractHymnNumber(params.slug);
    if (!hymnNumber) {
      return {
        title: 'Hymn Not Found',
      };
    }
    
    const hymnId = `${hymnalRef.id}-${hymnalRef.language}-${hymnNumber.toString().padStart(3, '0')}`;
    const hymn = await loadHymn(hymnId);
    
    if (!hymn) {
      return {
        title: 'Hymn Not Found',
      };
    }

    const title = `${hymn.title} - ${hymnalRef.site_name} #${hymn.number}`;
    const description = `${hymn.title} from ${hymnalRef.site_name} hymnal. ${hymn.author ? `Words by ${hymn.author}. ` : ''}${hymn.composer ? `Music by ${hymn.composer}. ` : ''}${hymn.verses[0]?.text?.split('\n')[0] || ''}`;

    return {
      title,
      description,
      keywords: [
        hymn.title,
        hymnalRef.site_name,
        hymn.author,
        hymn.composer,
        ...(hymn.metadata?.themes || []),
        'hymn',
        'worship music',
        'Christian music'
      ].filter(Boolean) as string[],
      openGraph: {
        title,
        description,
        type: 'article',
      },
    };
  } catch {
    return {
      title: 'Hymn Not Found',
    };
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
    console.error('Error generating static params:', error);
    return [];
  }
}

export default async function HymnPage({ params }: HymnPageProps) {
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

  // Load hymn data
  const hymnId = `${hymnalRef.id}-${hymnalRef.language}-${hymnNumber.toString().padStart(3, '0')}`;
  const hymn = await loadHymn(hymnId);
  
  if (!hymn) {
    notFound();
  }

  // Load related hymns
  const relatedHymns = await getRelatedHymns(hymnId, 6);
  
  // Load all hymns for the hymnal index
  const { hymns: allHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);

  const breadcrumbs = generateHymnalBreadcrumbs(
    hymnalRef.name, 
    params.hymnal, 
    hymn.title, 
    hymn.number
  );

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-white">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700 hymn-header no-print">
          <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
            <div className="mx-auto max-w-4xl">
              {/* Breadcrumbs with custom colors for visibility */}
              <div className="mb-6">
                <nav className="flex" aria-label="Breadcrumb">
                  <ol role="list" className="flex items-center space-x-2">
                    {/* Home icon */}
                    <li>
                      <div>
                        <Link
                          href="/"
                          className="text-primary-200 hover:text-white transition-colors duration-200"
                        >
                          <HomeIcon className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
                          <span className="sr-only">Home</span>
                        </Link>
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
                            <Link
                              href={item.href}
                              className="ml-2 text-sm font-medium text-primary-100 hover:text-white transition-colors duration-200"
                            >
                              {item.label}
                            </Link>
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
                  </ol>
                </nav>
              </div>

              {/* Hymn Header */}
              <div className="text-center text-white">
                <h1 className="text-2xl font-bold tracking-tight sm:text-3xl lg:text-4xl mb-4">
                  <span className="text-primary-200 mr-3">#{hymn.number}</span>
                  {hymn.title}
                </h1>
                
                {/* Metadata */}
                <div className="flex flex-wrap justify-center gap-6 text-sm text-primary-200">
                  {hymn.author && (
                    <div className="flex items-center">
                      <UserIcon className="mr-2 h-4 w-4" />
                      Words: <Link href={`/authors?search=${encodeURIComponent(hymn.author)}`} className="ml-1 text-primary-100 hover:text-white underline transition-colors">{hymn.author}</Link>
                    </div>
                  )}
                  {hymn.composer && (
                    <div className="flex items-center">
                      <MusicalNoteIcon className="mr-2 h-4 w-4" />
                      Music: <Link href={`/composers?search=${encodeURIComponent(hymn.composer)}`} className="ml-1 text-primary-100 hover:text-white underline transition-colors">{hymn.composer}</Link>
                    </div>
                  )}
                  {hymn.tune && (
                    <div className="flex items-center">
                      <BookOpenIcon className="mr-2 h-4 w-4" />
                      Tune: <Link href={`/tunes?search=${encodeURIComponent(hymn.tune)}`} className="ml-1 text-primary-100 hover:text-white underline transition-colors">{hymn.tune}</Link>
                    </div>
                  )}
                  {hymn.meter && (
                    <div className="flex items-center">
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      Meter: <Link href={`/meters?search=${encodeURIComponent(hymn.meter)}`} className="ml-1 text-primary-100 hover:text-white underline transition-colors">{hymn.meter}</Link>
                    </div>
                  )}
                </div>

                {/* Action Buttons */}
                <HymnActionButtons hymn={hymn} hymnalSlug={params.hymnal} hymnSlug={params.slug} />
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
            {/* Main Content */}
            <div className="lg:col-span-2">
              {/* Multi-Format Hymn Display */}
              <HymnDisplaySection hymn={hymn} />

              {/* Additional Info */}
              {hymn.metadata && (
                <div className="bg-gray-50 rounded-xl p-6 mt-8">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Additional Information</h3>
                  
                  {hymn.metadata.themes && hymn.metadata.themes.length > 0 && (
                    <div className="mb-4">
                      <h4 className="text-sm font-medium text-gray-700 mb-2">Themes:</h4>
                      <div className="flex flex-wrap gap-2">
                        {hymn.metadata.themes.map((theme) => (
                          <Link
                            key={theme}
                            href={`/topics?search=${encodeURIComponent(theme)}`}
                            className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800 hover:bg-primary-200 transition-colors"
                          >
                            {theme}
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}

                  {hymn.metadata.scripture_references && hymn.metadata.scripture_references.length > 0 && (
                    <div className="mb-4">
                      <h4 className="text-sm font-medium text-gray-700 mb-2">Scripture References:</h4>
                      <div className="text-sm text-gray-600">
                        {hymn.metadata.scripture_references.join(', ')}
                      </div>
                    </div>
                  )}

                  {hymn.metadata.copyright && (
                    <div className="mb-4">
                      <h4 className="text-sm font-medium text-gray-700 mb-2">Copyright:</h4>
                      <div className="text-sm text-gray-600">{hymn.metadata.copyright}</div>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1">
              {/* Quick Info */}
              <div className="bg-white rounded-xl shadow-sm border p-6 mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Info</h3>
                <dl className="space-y-3">
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Hymnal</dt>
                    <dd className="text-sm text-gray-900">{hymnalRef.name}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Number</dt>
                    <dd className="text-sm text-gray-900">#{hymn.number}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Language</dt>
                    <dd className="text-sm text-gray-900">{hymnalRef.language_name}</dd>
                  </div>
                  {hymn.metadata?.year && (
                    <div>
                      <dt className="text-sm font-medium text-gray-500">Year</dt>
                      <dd className="text-sm text-gray-900">{hymn.metadata.year}</dd>
                    </div>
                  )}
                </dl>
              </div>

              {/* Hymnal Index */}
              <div className="bg-white rounded-xl shadow-sm border p-6 mb-6">
                <div className="flex items-center mb-4">
                  <ListBulletIcon className="h-5 w-5 text-primary-600 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">Hymnal Index</h3>
                </div>
                
                {/* Search Input */}
                <div className="relative mb-4">
                  <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Search hymns..."
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                  />
                </div>

                {/* Hymn List */}
                <div className="max-h-64 overflow-y-auto custom-scrollbar space-y-1">
                  {allHymns.slice(0, 20).map((indexHymn) => (
                    <Link
                      key={indexHymn.id}
                      href={`/${params.hymnal}/hymn-${indexHymn.number}-${indexHymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                      className={`block p-2 rounded-lg hover:bg-gray-50 transition-colors ${
                        indexHymn.number === hymn.number ? 'bg-primary-50 border border-primary-200' : ''
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium text-gray-900 truncate">
                            <span className="text-primary-600 mr-2">#{indexHymn.number}</span>
                            {indexHymn.title}
                          </div>
                          {indexHymn.author && (
                            <div className="text-xs text-gray-500 truncate">
                              by {indexHymn.author}
                            </div>
                          )}
                        </div>
                      </div>
                    </Link>
                  ))}
                  
                  {allHymns.length > 20 && (
                    <div className="text-center pt-2">
                      <Link
                        href={`/${params.hymnal}`}
                        className="text-sm text-primary-600 hover:text-primary-700 font-medium"
                      >
                        View all {allHymns.length} hymns →
                      </Link>
                    </div>
                  )}
                </div>
              </div>

              {/* Related Hymns */}
              {relatedHymns.length > 0 && (
                <div className="bg-white rounded-xl shadow-sm border p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Related Hymns</h3>
                  <div className="space-y-3">
                    {relatedHymns.slice(0, 5).map(({ hymn: relatedHymn, hymnal: relatedHymnal, relationship }) => (
                      <Link
                        key={relatedHymn.id}
                        href={`/${relatedHymnal.url_slug}/hymn-${relatedHymn.number}-${relatedHymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                        className="block p-3 rounded-lg hover:bg-gray-50 transition-colors"
                      >
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="text-sm font-medium text-gray-900">
                              #{relatedHymn.number} {relatedHymn.title}
                            </div>
                            <div className="text-xs text-gray-500 mt-1">
                              {relatedHymnal.abbreviation} • {relationship}
                            </div>
                          </div>
                        </div>
                      </Link>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}