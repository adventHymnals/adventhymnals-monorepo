import { Metadata } from 'next';
import Link from 'next/link';
import { Suspense } from 'react';
import { UserIcon, MagnifyingGlassIcon, BookOpenIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Authors Index - Advent Hymnals',
  description: 'Browse hymns by author. Discover works by hymn writers across all Adventist hymnal collections.',
  keywords: ['hymn authors', 'hymn writers', 'author index', 'Francis of Assisi', 'Charles Wesley'],
};

// Mock data - replace with actual data loading
const featuredAuthors = [
  { name: 'Charles Wesley', count: 156, description: 'Methodist preacher and prolific hymn writer' },
  { name: 'Isaac Watts', count: 89, description: 'Father of English hymnody' },
  { name: 'Fanny Crosby', count: 67, description: 'Blind American hymn writer' },
  { name: 'John Newton', count: 45, description: 'Former slave trader turned minister' },
  { name: 'William Cowper', count: 34, description: 'English poet and hymnodist' },
  { name: 'Frances Ridley Havergal', count: 29, description: 'Victorian era hymn writer' },
];

function AuthorsContent({ searchParams }: { searchParams: { search?: string } }) {
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
              <h2 className="text-2xl font-bold text-gray-900">Search Authors</h2>
            </div>
            
            <form method="GET" className="mb-6">
              <div className="relative">
                <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  name="search"
                  defaultValue={searchQuery}
                  placeholder="Search by author name..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg text-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                />
              </div>
              <button
                type="submit"
                className="mt-4 btn-primary"
              >
                Search Authors
              </button>
            </form>

            {searchQuery && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h3 className="font-semibold text-blue-900 mb-2">
                  Search Results for "{searchQuery}"
                </h3>
                <p className="text-blue-800 text-sm mb-4">
                  This feature is under development. Full author search will be available soon.
                </p>
                <div className="space-y-2">
                  <div className="bg-white rounded-lg p-3 border border-blue-200">
                    <div className="flex items-center justify-between">
                      <div>
                        <h4 className="font-medium text-gray-900">{searchQuery}</h4>
                        <p className="text-sm text-gray-600">Found in multiple hymnal collections</p>
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

          {/* Featured Authors */}
          <div className="bg-white rounded-xl shadow-sm border p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Featured Authors</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {featuredAuthors.map((author) => (
                <div key={author.name} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                  <div className="flex items-start justify-between mb-3">
                    <h3 className="font-semibold text-gray-900">{author.name}</h3>
                    <span className="text-sm bg-gray-100 text-gray-700 px-2 py-1 rounded">
                      {author.count} hymns
                    </span>
                  </div>
                  <p className="text-sm text-gray-600 mb-3">{author.description}</p>
                  <button className="text-sm text-primary-600 hover:text-primary-700 font-medium">
                    View hymns by {author.name} →
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Coming Soon */}
          <div className="mt-8 bg-yellow-50 border border-yellow-200 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-yellow-800 mb-2">🚧 Under Development</h3>
            <p className="text-yellow-700">
              We're building a comprehensive author index that will include:
            </p>
            <ul className="mt-3 space-y-1 text-yellow-700">
              <li>• Complete alphabetical listing of all hymn authors</li>
              <li>• Biographical information and historical context</li>
              <li>• Cross-references between different hymnal collections</li>
              <li>• Advanced filtering by time period, denomination, and language</li>
            </ul>
          </div>
        </div>

        {/* Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Browse by Category</h3>
            <div className="space-y-3">
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-200">
                <h4 className="font-medium text-gray-900">Classical Authors</h4>
                <p className="text-sm text-gray-600">Traditional hymn writers</p>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-200">
                <h4 className="font-medium text-gray-900">Modern Authors</h4>
                <p className="text-sm text-gray-600">20th century writers</p>
              </button>
              <button className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-200">
                <h4 className="font-medium text-gray-900">Adventist Authors</h4>
                <p className="text-sm text-gray-600">SDA church writers</p>
              </button>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm border p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Related Indexes</h3>
            <div className="space-y-2">
              <Link href="/composers" className="block text-sm text-primary-600 hover:text-primary-700">
                Composers Index →
              </Link>
              <Link href="/tunes" className="block text-sm text-primary-600 hover:text-primary-700">
                Tune Index →
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
                <span className="text-gray-600">Total Authors</span>
                <span className="font-semibold">1,200+</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Time Span</span>
                <span className="font-semibold">1500-2000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Languages</span>
                <span className="font-semibold">3</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default async function AuthorsPage({
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
              <UserIcon className="mx-auto h-12 w-12 text-primary-200 mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                Authors Index
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Discover hymns by their authors across all collections
              </p>
            </div>
          </div>
        </div>

        <Suspense fallback={<div className="p-8">Loading...</div>}>
          <AuthorsContent searchParams={searchParams} />
        </Suspense>
      </div>
    </Layout>
  );
}