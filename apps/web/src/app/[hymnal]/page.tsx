import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  CalendarIcon, 
  UserIcon, 
  MusicalNoteIcon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import Breadcrumbs, { generateHymnalBreadcrumbs } from '@/components/ui/Breadcrumbs';
import HymnalSearch from '@/components/hymnal/HymnalSearch';
import { loadHymnalReferences, loadHymnal, loadHymnalHymns } from '@/lib/data';
import { generateHymnalMetadata, generateHymnalStructuredData, generateHymnalFAQStructuredData } from '@/lib/seo';
import { formatNumber } from '@advent-hymnals/shared';

interface HymnalPageProps {
  params: {
    hymnal: string;
  };
}

// Generate static params for all hymnals
export async function generateStaticParams(): Promise<Array<{ hymnal: string }>> {
  try {
    // Only include hymnals that have actual collection files
    const availableHymnals = ['CH1941', 'HGPP', 'HT1886', 'MH1843', 'SDAH'];
    const hymnalReferences = await loadHymnalReferences();
    
    const params = Object.values(hymnalReferences.hymnals)
      .filter(hymnal => hymnal.url_slug && availableHymnals.includes(hymnal.id))
      .map(hymnal => ({
        hymnal: hymnal.url_slug!
      }));

    console.log(`Generated ${params.length} static params for hymnal pages`);
    return params;
  } catch (error) {
    console.error('Failed to generate static params for hymnals:', error);
    return [];
  }
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

export default async function HymnalPage({ params }: HymnalPageProps) {
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

  // For static export, load all hymns without pagination
  const hymnsData = await loadHymnalHymns(hymnalRef.id, 1, 1000);

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
                All hymns in this collection
              </p>
            </div>
          </div>

          {/* Hymns Grid */}
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
                
                {hymn.verses[0] && hymn.verses[0].text && (
                  <p className="text-sm text-gray-700 line-clamp-2">
                    {hymn.verses[0].text.split('\n')[0]}
                  </p>
                )}
              </Link>
            ))}
          </div>

        </div>
      </div>
    </Layout>
  );
}