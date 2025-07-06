import { Metadata } from 'next';
import { MagnifyingGlassIcon, FunnelIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import Breadcrumbs, { generateSearchBreadcrumbs } from '@/components/ui/Breadcrumbs';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Search Hymns - Advent Hymnals',
  description: 'Search through 13 complete hymnal collections with over 5,000 hymns. Find hymns by title, number, composer, author, or theme.',
  keywords: ['hymn search', 'Adventist hymns', 'hymnal search', 'worship music', 'Christian songs'],
};

export default async function SearchPage() {
  const hymnalReferences = await loadHymnalReferences();
  const breadcrumbs = generateSearchBreadcrumbs();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
            <Breadcrumbs items={breadcrumbs} className="mb-6" />
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Search Hymns
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Search through 13 complete hymnal collections with over 5,000 hymns
              </p>
            </div>
          </div>
        </div>

        {/* Search Interface */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="mx-auto max-w-4xl">
            {/* Main Search Bar */}
            <div className="relative mb-8">
              <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
              </div>
              <input
                type="text"
                className="block w-full rounded-lg border-0 py-4 pl-10 pr-3 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 sm:text-lg"
                placeholder="Search by title, number, composer, author, or theme..."
                autoFocus
              />
            </div>

            {/* Search Filters */}
            <div className="mb-8">
              <div className="flex flex-wrap gap-4 items-center">
                <div className="flex items-center">
                  <FunnelIcon className="h-5 w-5 text-gray-400 mr-2" />
                  <span className="text-sm font-medium text-gray-700">Filter by:</span>
                </div>
                
                <select className="rounded-md border-gray-300 text-sm">
                  <option value="">All Hymnals</option>
                  {Object.values(hymnalReferences.hymnals).map(hymnal => (
                    <option key={hymnal.id} value={hymnal.id}>
                      {hymnal.name}
                    </option>
                  ))}
                </select>

                <select className="rounded-md border-gray-300 text-sm">
                  <option value="">All Languages</option>
                  <option value="english">English</option>
                  <option value="kiswahili">Kiswahili</option>
                  <option value="dholuo">Dholuo</option>
                </select>

                <select className="rounded-md border-gray-300 text-sm">
                  <option value="">All Themes</option>
                  <option value="worship">Worship</option>
                  <option value="praise">Praise</option>
                  <option value="christmas">Christmas</option>
                  <option value="easter">Easter</option>
                  <option value="communion">Communion</option>
                  <option value="baptism">Baptism</option>
                  <option value="second-coming">Second Coming</option>
                </select>
              </div>
            </div>

            {/* Search Instructions */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-8">
              <h3 className="text-lg font-semibold text-blue-900 mb-4">Search Tips</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-blue-800">
                <div>
                  <h4 className="font-medium mb-2">By Number:</h4>
                  <ul className="space-y-1">
                    <li>• &quot;123&quot; - Find hymn number 123</li>
                    <li>• &quot;SDAH 123&quot; - Find hymn 123 in SDAH</li>
                  </ul>
                </div>
                <div>
                  <h4 className="font-medium mb-2">By Content:</h4>
                  <ul className="space-y-1">
                    <li>• &quot;Amazing Grace&quot; - Find by title</li>
                    <li>• &quot;John Newton&quot; - Find by author</li>
                    <li>• &quot;praise&quot; - Find by theme</li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Popular Searches */}
            <div className="mb-8">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Popular Searches</h3>
              <div className="flex flex-wrap gap-2">
                {[
                  'Amazing Grace',
                  'How Great Thou Art',
                  'Blessed Assurance',
                  'Christmas',
                  'Second Coming',
                  'Communion',
                  'Baptism',
                  'Praise',
                  'Worship',
                  'John Newton',
                  'Fanny Crosby',
                  'Charles Wesley'
                ].map((term) => (
                  <button
                    key={term}
                    className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-700 hover:bg-primary-200 transition-colors"
                  >
                    {term}
                  </button>
                ))}
              </div>
            </div>

            {/* Search Results Placeholder */}
            <div className="text-center py-12">
              <MagnifyingGlassIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-4 text-lg font-semibold text-gray-900">Start your search</h3>
              <p className="mt-2 text-gray-600">
                Enter a search term above to find hymns across all collections
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}