import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  CalendarIcon, 
  UserIcon, 
  MusicalNoteIcon,
  MagnifyingGlassIcon,
  ListBulletIcon,
  Squares2X2Icon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import Breadcrumbs, { generateHymnalBreadcrumbs } from '@/components/ui/Breadcrumbs';
import HymnalSearch from '@/components/hymnal/HymnalSearch';
import { loadHymnalReferences, loadHymnal, loadHymnalHymns } from '@/lib/data';
import { generateHymnalMetadata, generateHymnalStructuredData, generateHymnalFAQStructuredData } from '@/lib/seo';
import { formatNumber, classNames } from '@advent-hymnals/shared';

interface HymnalPageProps {
  params: {
    hymnal: string;
  };
  searchParams: {
    page?: string;
    view?: 'grid' | 'list';
  };
}

export async function generateMetadata({ params }: HymnalPageProps): Promise<Metadata> {
  const hymnalReferences = await loadHymnalReferences();
  const hymnalRef = Object.values(hymnalReferences.hymnals).find(
    h => h.url_slug === params.hymnal
  );

  if (!hymnalRef) {
    return {
      title: 'Hymnal Not Found',
      description: 'The requested hymnal could not be found.',
    };
  }

  return generateHymnalMetadata(hymnalRef);
}

export default async function HymnalPage({ params, searchParams }: HymnalPageProps) {
  const hymnalReferences = await loadHymnalReferences();
  const hymnalRef = Object.values(hymnalReferences.hymnals).find(
    h => h.url_slug === params.hymnal
  );

  if (!hymnalRef) {
    notFound();
  }

  const hymnal = await loadHymnal(hymnalRef.id);
  if (!hymnal) {
    console.warn(`Hymnal data not found for ${hymnalRef.id}`);
    notFound();
  }

  const currentPage = parseInt(searchParams.page || '1', 10);
  const view = searchParams.view || 'grid';
  const hymnsData = await loadHymnalHymns(hymnalRef.id, currentPage, 24);

  const breadcrumbs = generateHymnalBreadcrumbs(hymnalRef.name, params.hymnal);

  const structuredData = {
    hymnal: generateHymnalStructuredData(hymnalRef),
    faq: generateHymnalFAQStructuredData(hymnalRef),
  };

  return (
    <Layout hymnalReferences={hymnalReferences}>
      {/* Structured Data */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify([structuredData.hymnal, structuredData.faq]),
        }}
      />

      <div className="min-h-screen bg-white">
        {/* Header Section */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="mx-auto max-w-4xl">
              {/* Breadcrumbs */}
              <Breadcrumbs 
                items={breadcrumbs} 
                className="mb-6 text-primary-100" 
              />

              {/* Hymnal Info */}
              <div className="text-center text-white">
                <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
                  {hymnalRef.site_name}
                </h1>
                <p className="mt-4 text-xl text-primary-100">
                  {hymnalRef.name}
                </p>
                
                {/* Metadata */}
                <div className="mt-8 flex flex-wrap justify-center gap-6 text-sm text-primary-200">
                  <div className="flex items-center">
                    <CalendarIcon className="mr-2 h-5 w-5" />
                    Published {hymnalRef.year}
                  </div>
                  <div className="flex items-center">
                    <BookOpenIcon className="mr-2 h-5 w-5" />
                    {formatNumber(hymnalRef.total_songs)} Hymns
                  </div>
                  <div className="flex items-center">
                    <MusicalNoteIcon className="mr-2 h-5 w-5" />
                    {hymnalRef.language_name}
                  </div>
                  {hymnalRef.compiler && (
                    <div className="flex items-center">
                      <UserIcon className="mr-2 h-5 w-5" />
                      {hymnalRef.compiler}
                    </div>
                  )}
                </div>

                {/* Search */}
                <div className="mt-8 mx-auto max-w-md">
                  <HymnalSearch
                    placeholder={`Search ${hymnalRef.site_name}...`}
                    size="lg"
                    className="text-gray-900"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Content Section */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          {/* Controls */}
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-8">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                Hymns ({formatNumber(hymnsData.total)})
              </h2>
              <p className="mt-1 text-gray-600">
                Page {currentPage} of {hymnsData.totalPages}
              </p>
            </div>
            
            <div className="mt-4 sm:mt-0 flex items-center space-x-4">
              {/* View Toggle */}
              <div className="flex rounded-lg border border-gray-300">
                <Link
                  href={`/${params.hymnal}?page=${currentPage}&view=grid`}
                  className={classNames(
                    'px-3 py-2 text-sm font-medium rounded-l-lg',
                    view === 'grid'
                      ? 'bg-primary-600 text-white'
                      : 'bg-white text-gray-700 hover:bg-gray-50'
                  )}
                >
                  <Squares2X2Icon className="h-4 w-4" />
                </Link>
                <Link
                  href={`/${params.hymnal}?page=${currentPage}&view=list`}
                  className={classNames(
                    'px-3 py-2 text-sm font-medium rounded-r-lg border-l border-gray-300',
                    view === 'list'
                      ? 'bg-primary-600 text-white'
                      : 'bg-white text-gray-700 hover:bg-gray-50'
                  )}
                >
                  <ListBulletIcon className="h-4 w-4" />
                </Link>
              </div>

              {/* Quick Actions */}
              <Link
                href={`/${params.hymnal}/search`}
                className="btn-secondary"
              >
                <MagnifyingGlassIcon className="mr-2 h-4 w-4" />
                Advanced Search
              </Link>
            </div>
          </div>

          {/* Hymns Grid/List */}
          {view === 'grid' ? (
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {hymnsData.hymns.map((hymn) => (
                <Link
                  key={hymn.id}
                  href={`/${params.hymnal}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                  className="hymnal-card p-6 hover:scale-105 transform transition-all duration-200"
                >
                  <div className="flex items-center justify-between mb-4">
                    <span className="hymn-number">
                      #{hymn.number}
                    </span>
                    {hymn.metadata?.themes && hymn.metadata.themes.length > 0 && (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                        {hymn.metadata.themes[0]}
                      </span>
                    )}
                  </div>
                  
                  <h3 className="hymn-title mb-2">
                    {hymn.title}
                  </h3>
                  
                  {(hymn.author || hymn.composer) && (
                    <div className="text-sm text-gray-600 mb-3">
                      {hymn.author && <div>By {hymn.author}</div>}
                      {hymn.composer && <div>Music: {hymn.composer}</div>}
                    </div>
                  )}
                  
                  {hymn.verses[0] && (
                    <p className="text-sm text-gray-700 line-clamp-2">
                      {hymn.verses[0].text.split('\n')[0]}
                    </p>
                  )}
                </Link>
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {hymnsData.hymns.map((hymn) => (
                <Link
                  key={hymn.id}
                  href={`/${params.hymnal}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                  className="hymnal-card p-6 flex items-center justify-between hover:shadow-lg transition-shadow duration-200"
                >
                  <div className="flex-1">
                    <div className="flex items-center space-x-4">
                      <span className="hymn-number font-mono">
                        {hymn.number.toString().padStart(3, '0')}
                      </span>
                      <div className="flex-1">
                        <h3 className="hymn-title">
                          {hymn.title}
                        </h3>
                        {(hymn.author || hymn.composer) && (
                          <div className="text-sm text-gray-600 mt-1">
                            {hymn.author && <span>By {hymn.author}</span>}
                            {hymn.author && hymn.composer && <span> • </span>}
                            {hymn.composer && <span>Music: {hymn.composer}</span>}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  {hymn.metadata?.themes && hymn.metadata.themes.length > 0 && (
                    <div className="flex flex-wrap gap-1">
                      {hymn.metadata.themes.slice(0, 2).map((theme) => (
                        <span
                          key={theme}
                          className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
                        >
                          {theme}
                        </span>
                      ))}
                    </div>
                  )}
                </Link>
              ))}
            </div>
          )}

          {/* Pagination */}
          {hymnsData.totalPages > 1 && (
            <div className="mt-12 flex items-center justify-center">
              <nav className="flex items-center space-x-1">
                {/* Previous */}
                {currentPage > 1 && (
                  <Link
                    href={`/${params.hymnal}?page=${currentPage - 1}&view=${view}`}
                    className="px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                  >
                    Previous
                  </Link>
                )}

                {/* Page Numbers */}
                {Array.from({ length: Math.min(5, hymnsData.totalPages) }, (_, i) => {
                  const page = Math.max(1, currentPage - 2) + i;
                  if (page > hymnsData.totalPages) return null;
                  
                  return (
                    <Link
                      key={page}
                      href={`/${params.hymnal}?page=${page}&view=${view}`}
                      className={classNames(
                        'px-3 py-2 text-sm font-medium rounded-md',
                        page === currentPage
                          ? 'bg-primary-600 text-white'
                          : 'text-gray-700 bg-white border border-gray-300 hover:bg-gray-50'
                      )}
                    >
                      {page}
                    </Link>
                  );
                })}

                {/* Next */}
                {currentPage < hymnsData.totalPages && (
                  <Link
                    href={`/${params.hymnal}?page=${currentPage + 1}&view=${view}`}
                    className="px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                  >
                    Next
                  </Link>
                )}
              </nav>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}