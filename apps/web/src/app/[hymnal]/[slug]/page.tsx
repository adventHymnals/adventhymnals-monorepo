import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  CalendarIcon, 
  UserIcon, 
  MusicalNoteIcon,
  ArrowLeftIcon,
  PlayIcon,
  PrinterIcon,
  ShareIcon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import Breadcrumbs, { generateHymnalBreadcrumbs } from '@/components/ui/Breadcrumbs';
import { loadHymnalReferences, loadHymn, getRelatedHymns } from '@/lib/data';
import { generateHymnMetadata, generateHymnStructuredData } from '@/lib/seo';

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
  const hymnalReferences = await loadHymnalReferences();
  const hymnalRef = Object.values(hymnalReferences.hymnals).find(
    h => h.url_slug === params.hymnal
  );

  if (!hymnalRef) {
    return {
      title: 'Hymn Not Found',
      description: 'The requested hymn could not be found.',
    };
  }

  const hymnNumber = extractHymnNumber(params.slug);
  if (!hymnNumber) {
    return {
      title: 'Invalid Hymn',
      description: 'Invalid hymn URL format.',
    };
  }

  // Try to load the hymn for metadata
  const hymnId = `${hymnalRef.id}-${hymnalRef.language}-${hymnNumber.toString().padStart(3, '0')}`;
  const hymn = await loadHymn(hymnId);
  
  if (!hymn) {
    return {
      title: 'Hymn Not Found',
      description: 'The requested hymn could not be found.',
    };
  }

  return generateHymnMetadata(hymn, hymnalRef, params.hymnal);
}

export default async function HymnPage({ params }: HymnPageProps) {
  const hymnalReferences = await loadHymnalReferences();
  const hymnalRef = Object.values(hymnalReferences.hymnals).find(
    h => h.url_slug === params.hymnal
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

  const breadcrumbs = generateHymnalBreadcrumbs(
    hymnalRef.name, 
    params.hymnal, 
    hymn.title, 
    hymn.number
  );

  const structuredData = generateHymnStructuredData(hymn, hymnalRef, params.hymnal);

  return (
    <Layout hymnalReferences={hymnalReferences}>
      {/* Structured Data */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(structuredData),
        }}
      />

      <div className="min-h-screen bg-white">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
            <div className="mx-auto max-w-4xl">
              {/* Breadcrumbs */}
              <Breadcrumbs 
                items={breadcrumbs} 
                className="mb-6 text-primary-100" 
              />

              {/* Back Button */}
              <div className="mb-6">
                <Link
                  href={`/${params.hymnal}`}
                  className="inline-flex items-center text-primary-100 hover:text-white transition-colors"
                >
                  <ArrowLeftIcon className="h-4 w-4 mr-2" />
                  Back to {hymnalRef.site_name || hymnalRef.name}
                </Link>
              </div>

              {/* Hymn Header */}
              <div className="text-center text-white">
                <div className="inline-flex items-center justify-center w-16 h-16 bg-white/20 rounded-full mb-4">
                  <span className="text-2xl font-bold text-white">
                    {hymn.number}
                  </span>
                </div>
                <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl mb-4">
                  {hymn.title}
                </h1>
                
                {/* Metadata */}
                <div className="flex flex-wrap justify-center gap-6 text-sm text-primary-200">
                  {hymn.author && (
                    <div className="flex items-center">
                      <UserIcon className="mr-2 h-4 w-4" />
                      Words: {hymn.author}
                    </div>
                  )}
                  {hymn.composer && (
                    <div className="flex items-center">
                      <MusicalNoteIcon className="mr-2 h-4 w-4" />
                      Music: {hymn.composer}
                    </div>
                  )}
                  {hymn.tune && (
                    <div className="flex items-center">
                      <BookOpenIcon className="mr-2 h-4 w-4" />
                      Tune: {hymn.tune}
                    </div>
                  )}
                  {hymn.meter && (
                    <div className="flex items-center">
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      Meter: {hymn.meter}
                    </div>
                  )}
                </div>

                {/* Action Buttons */}
                <div className="mt-8 flex flex-wrap justify-center gap-4">
                  <button className="btn-secondary bg-white/10 text-white border-white/20 hover:bg-white/20">
                    <PlayIcon className="h-4 w-4 mr-2" />
                    Play Audio
                  </button>
                  <button className="btn-secondary bg-white/10 text-white border-white/20 hover:bg-white/20">
                    <PrinterIcon className="h-4 w-4 mr-2" />
                    Print
                  </button>
                  <button className="btn-secondary bg-white/10 text-white border-white/20 hover:bg-white/20">
                    <ShareIcon className="h-4 w-4 mr-2" />
                    Share
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
            {/* Main Content */}
            <div className="lg:col-span-2">
              {/* Hymn Text */}
              <div className="bg-white rounded-xl shadow-sm border p-8 mb-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Hymn Text</h2>
                
                <div className="space-y-6">
                  {hymn.verses.map((verse) => (
                    <div key={verse.number} className="relative">
                      <div className="absolute left-0 top-0 w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                        <span className="text-sm font-bold text-primary-600">
                          {verse.number}
                        </span>
                      </div>
                      <div className="ml-12">
                        <div className="text-lg leading-relaxed text-gray-800 whitespace-pre-line">
                          {verse.text}
                        </div>
                      </div>
                    </div>
                  ))}

                  {/* Chorus */}
                  {hymn.chorus && (
                    <div className="relative mt-8 p-6 bg-primary-50 border-l-4 border-primary-500 rounded-r-lg">
                      <div className="absolute left-0 top-0 w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center -ml-6 mt-2">
                        <span className="text-sm font-bold text-white">C</span>
                      </div>
                      <div className="ml-6">
                        <h3 className="text-lg font-semibold text-primary-900 mb-2">Chorus</h3>
                        <div className="text-lg leading-relaxed text-primary-800 whitespace-pre-line">
                          {hymn.chorus.text}
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Additional Info */}
              {hymn.metadata && (
                <div className="bg-gray-50 rounded-xl p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Additional Information</h3>
                  
                  {hymn.metadata.themes && hymn.metadata.themes.length > 0 && (
                    <div className="mb-4">
                      <h4 className="text-sm font-medium text-gray-700 mb-2">Themes:</h4>
                      <div className="flex flex-wrap gap-2">
                        {hymn.metadata.themes.map((theme) => (
                          <span
                            key={theme}
                            className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
                          >
                            {theme}
                          </span>
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