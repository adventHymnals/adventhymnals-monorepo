import { Metadata } from 'next';
import Link from 'next/link';
import { Suspense } from 'react';
import { MusicalNoteIcon, MagnifyingGlassIcon, BookOpenIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Tune Index - Advent Hymnals',
  description: 'Browse hymns by tune name. Find different texts set to the same melodies across hymnal collections.',
  keywords: ['hymn tunes', 'tune index', 'melody names', 'LASST UNS ERFREUEN', 'OLD 100TH'],
};

// Mock data - replace with actual data loading
const featuredTunes = [
  { name: 'OLD 100TH', count: 12, description: 'Traditional psalm tune, most famous for "Praise God from Whom All Blessings Flow"' },
  { name: 'LASST UNS ERFREUEN', count: 8, description: 'German tune used for "All Creatures of Our God and King"' },
  { name: 'GERMANY', count: 15, description: 'Popular tune for "Where Cross the Crowded Ways of Life"' },
  { name: 'ST. ANNE', count: 6, description: 'Classic tune for "O God, Our Help in Ages Past"' },
  { name: 'HYFRYDOL', count: 9, description: 'Welsh tune often used for "Come, Thou Long Expected Jesus"' },
  { name: 'KREMSER', count: 4, description: 'Dutch melody for "We Gather Together"' },
];

const tuneCategories = [
  { name: 'Common Meter Tunes', description: 'Tunes in 8.6.8.6 meter', count: 89 },
  { name: 'Long Meter Tunes', description: 'Tunes in 8.8.8.8 meter', count: 67 },
  { name: 'Short Meter Tunes', description: 'Tunes in 6.6.8.6 meter', count: 34 },
  { name: 'Irregular Meter Tunes', description: 'Unique metrical patterns', count: 156 },
];

function TunesContent({ searchParams }: { searchParams: { search?: string } }) {
  const searchQuery = searchParams.search || '';

  return (
    <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
      <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
        {/* Main Content */}
        <div className="lg:col-span-2">
          {/* Search Section */}
          <div className="bg-white rounded-xl shadow-sm border p-8 mb-8">
            <div className="flex items-center mb-6">
              <MagnifyingGlassIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h2 className="text-2xl font-bold text-gray-900">Search Tunes</h2>
            </div>
            
            <form method="GET" className="mb-6">
              <div className="relative">
                <MusicalNoteIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  name="search"
                  defaultValue={searchQuery}
                  placeholder="Search by tune name (e.g., LASST UNS ERFREUEN)..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg text-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                />
              </div>
              <button
                type="submit"
                className="mt-4 btn-primary"
              >
                Search Tunes
              </button>
            </form>

            {searchQuery && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h3 className="font-semibold text-blue-900 mb-2">
                  Search Results for "{searchQuery}"
                </h3>
                <p className="text-blue-800 text-sm mb-4">
                  This feature is under development. Full tune search will be available soon.
                </p>
                <div className="space-y-2">
                  <div className="bg-white rounded-lg p-3 border border-blue-200">
                    <div className="flex items-center justify-between">
                      <div>
                        <h4 className="font-medium text-gray-900">{searchQuery}</h4>
                        <p className="text-sm text-gray-600">Tune found in multiple hymns</p>
                      </div>
                      <span className="text-sm bg-primary-100 text-primary-800 px-2 py-1 rounded">
                        Coming Soon
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Featured Tunes */}
          <div className="bg-white rounded-xl shadow-sm border p-8 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Popular Tunes</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {featuredTunes.map((tune) => (
                <div key={tune.name} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-3">
                    <h3 className="font-semibold text-gray-900 font-mono">{tune.name}</h3>
                    <span className="text-sm bg-gray-100 text-gray-700 px-2 py-1 rounded">
                      {tune.count} hymns
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-3">{tune.description}</p>
                  <button className="text-sm text-primary-600 hover:text-primary-700 font-medium">
                    View hymns using {tune.name} →
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Tune Categories */}
          <div className="bg-white rounded-xl shadow-sm border p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Browse by Meter</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {tuneCategories.map((category) => (
                <div key={category.name} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="font-semibold text-gray-900">{category.name}</h3>
                    <span className="text-sm bg-primary-100 text-primary-700 px-2 py-1 rounded">
                      {category.count}
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-3">{category.description}</p>
                  <button className="text-sm text-primary-600 hover:text-primary-700 font-medium">
                    Browse tunes →
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Coming Soon */}
          <div className="mt-8 bg-yellow-50 border border-yellow-200 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-yellow-800 mb-2">🚧 Under Development</h3>
            <p className="text-yellow-700">
              Our comprehensive tune index will include:
            </p>
            <ul className="mt-3 space-y-1 text-yellow-700">
              <li>• Complete alphabetical listing of all tune names</li>
              <li>• Cross-references showing which texts use the same melody</li>
              <li>• Historical information about tune origins</li>
              <li>• Audio examples and sheet music previews</li>
              <li>• Grouping by metrical patterns and musical characteristics</li>
            </ul>
          </div>
        </div>

        {/* Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Understanding Tune Names</h3>
            <div className="space-y-4 text-sm text-gray-600">
              <p>
                Tune names are traditional identifiers for hymn melodies, often named after:
              </p>
              <ul className="space-y-1 ml-4">
                <li>• Places (GERMANY, ST. ANNE)</li>
                <li>• People (WESLEY, BEETHOVEN)</li>
                <li>• First lines (LASST UNS ERFREUEN)</li>
                <li>• Composers (MENDELSSOHN)</li>
              </ul>
              <p>
                The same tune can be used with different texts, allowing for creative hymn arrangements.
              </p>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Related Indexes</h3>
            <div className="space-y-2">
              <Link href="/authors" className="block text-sm text-primary-600 hover:text-primary-700">
                Authors Index →
              </Link>
              <Link href="/composers" className="block text-sm text-primary-600 hover:text-primary-700">
                Composers Index →
              </Link>
              <Link href="/meters" className="block text-sm text-primary-600 hover:text-primary-700">
                Metrical Index →
              </Link>
              <Link href="/topics" className="block text-sm text-primary-600 hover:text-primary-700">
                Topics Index →
              </Link>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Stats</h3>
            <div className="space-y-3 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-600">Total Tunes</span>
                <span className="font-semibold">800+</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Most Popular</span>
                <span className="font-semibold">OLD 100TH</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Oldest Tune</span>
                <span className="font-semibold">~1500s</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default async function TunesPage({
  searchParams,
}: {
  searchParams: { search?: string };
}) {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-primary-200 mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                Tune Index
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Explore hymn melodies and discover texts set to the same tunes
              </p>
            </div>
          </div>
        </div>

        <Suspense fallback={<div className="p-8">Loading...</div>}>
          <TunesContent searchParams={searchParams} />
        </Suspense>
      </div>
    </Layout>
  );
}