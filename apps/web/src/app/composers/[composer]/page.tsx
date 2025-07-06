import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import Link from 'next/link';
import { MusicalNoteIcon, ArrowLeftIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

interface HymnData {
  id: string;
  number: number;
  title: string;
  composer?: string;
  hymnal: {
    id: string;
    name: string;
    url_slug: string;
    abbreviation: string;
  };
}

interface ComposerDetailProps {
  params: {
    composer: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalReferences, loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const composerSet = new Set<string>();

    // Load hymns from all hymnals to get unique composers
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        hymns.forEach((hymn: { composer?: string }) => {
          if (hymn.composer) {
            composerSet.add(hymn.composer);
          }
        });
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return Array.from(composerSet).map((composer: string) => ({
      composer: encodeURIComponent(composer)
    }));
  } catch (error) {
    console.error('Error generating static params for composers:', error);
    return [];
  }
}

export async function generateMetadata({ params }: ComposerDetailProps): Promise<Metadata> {
  const decodedComposer = decodeURIComponent(params.composer);
  return {
    title: `${decodedComposer} - Hymn Composer`,
    description: `Browse hymns composed by ${decodedComposer}. Explore Adventist hymnody with full text, themes, and musical information.`
  };
}

export default async function ComposerDetailPage({ params }: ComposerDetailProps) {
  const decodedComposer = decodeURIComponent(params.composer);
  const hymnalReferences = await loadHymnalReferences();
  
  let composersData;
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/api/composers`, {
      cache: 'force-cache'
    });
    if (!response.ok) {
      throw new Error('Failed to fetch composers');
    }
    composersData = await response.json();
  } catch (error) {
    console.error('Failed to load composer data:', error);
    notFound();
  }
  
  const composerData = composersData.find((c: { composer: string }) => c.composer === decodedComposer);
  
  if (!composerData) {
    notFound();
  }
  
  const hymns: HymnData[] = composerData.hymns;

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <Link
                href="/composers"
                className="inline-flex items-center text-primary-200 hover:text-white mb-6 transition-colors"
              >
                <ArrowLeftIcon className="h-4 w-4 mr-2" />
                Back to Composers
              </Link>
              
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                {decodedComposer}
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                {hymns.length} hymn{hymns.length !== 1 ? 's' : ''} by this composer
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {hymns.map((hymn) => (
              <Link
                key={hymn.id}
                href={`/${hymn.hymnal.url_slug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                className="block p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow border border-gray-200 hover:border-primary-300"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 hover:text-primary-600 transition-colors">
                      {hymn.title}
                    </h3>
                    <div className="text-sm text-gray-600 mt-1">
                      {hymn.hymnal.abbreviation} #{hymn.number}
                    </div>
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {hymns.length === 0 && (
            <div className="text-center py-12">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
              <p className="text-gray-600">No hymns found by this composer.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}