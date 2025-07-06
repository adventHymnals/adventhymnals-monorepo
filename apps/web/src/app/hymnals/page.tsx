import { Metadata } from 'next';
import Link from 'next/link';
import { CalendarIcon, BookOpenIcon, GlobeAltIcon, UserIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Hymnal Collections - Advent Hymnals',
  description: 'Browse all 13 Adventist hymnal collections spanning 160+ years of musical heritage, from 1838 to 2000.',
  keywords: ['Adventist hymnals', 'hymnal collections', 'SDA hymnals', 'worship music', 'Christian music history'],
};

export default async function HymnalsPage() {
  const hymnalReferences = await loadHymnalReferences();
  const hymnals = Object.values(hymnalReferences.hymnals)
    .sort((a, b) => b.year - a.year); // Sort by year, newest first

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Hymnal Collections
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Explore 13 complete hymnal collections spanning 160+ years of Adventist musical heritage
              </p>
              <div className="mt-8 flex justify-center gap-8 text-sm text-gray-500">
                <div className="flex items-center">
                  <BookOpenIcon className="h-5 w-5 mr-2" />
                  <span>5,500+ Hymns</span>
                </div>
                <div className="flex items-center">
                  <CalendarIcon className="h-5 w-5 mr-2" />
                  <span>1838-2000</span>
                </div>
                <div className="flex items-center">
                  <GlobeAltIcon className="h-5 w-5 mr-2" />
                  <span>3 Languages</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Hymnal Grid */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-2 xl:grid-cols-3">
            {hymnals.map((hymnal) => (
              <Link
                key={hymnal.id}
                href={`/${hymnal.url_slug}`}
                className="group relative overflow-hidden rounded-xl bg-white p-6 shadow-sm hover:shadow-lg transition-all duration-300 hover:scale-105"
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                      <BookOpenIcon className="h-6 w-6 text-primary-600" />
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-2xl font-bold text-gray-900">{hymnal.year}</div>
                    <div className="text-sm text-gray-500">{hymnal.total_songs} hymns</div>
                  </div>
                </div>

                {/* Content */}
                <div className="mb-4">
                  <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                    {hymnal.name}
                  </h3>
                  <p className="text-sm text-gray-600 mt-1">{hymnal.abbreviation}</p>
                </div>

                {/* Metadata */}
                <div className="space-y-2 mb-4">
                  <div className="flex items-center text-sm text-gray-600">
                    <GlobeAltIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                    <span>{hymnal.language_name}</span>
                  </div>
                  {hymnal.compiler && (
                    <div className="flex items-center text-sm text-gray-600">
                      <UserIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                      <span>{hymnal.compiler}</span>
                    </div>
                  )}
                </div>

                {/* Description */}
                <div className="text-sm text-gray-700 mb-4">
                  A collection of {hymnal.total_songs} hymns from {hymnal.year}.
                </div>

                {/* Tags */}
                <div className="flex flex-wrap gap-2">
                  <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    {hymnal.language_name}
                  </span>
                  {hymnal.year < 1900 && (
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
                      Historical
                    </span>
                  )}
                  {hymnal.total_songs > 600 && (
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      Large Collection
                    </span>
                  )}
                </div>

                {/* Hover overlay */}
                <div className="absolute inset-0 bg-primary-50 opacity-0 group-hover:opacity-20 transition-opacity" />
              </Link>
            ))}
          </div>
        </div>

        {/* Additional Info */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
              <div className="text-center">
                <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-lg bg-blue-100">
                  <CalendarIcon className="h-6 w-6 text-blue-600" />
                </div>
                <h3 className="mt-4 text-lg font-semibold text-gray-900">Historical Timeline</h3>
                <p className="mt-2 text-sm text-gray-600">
                  Our collection spans from 1838 to 2000, preserving the evolution of Adventist hymnody
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-lg bg-green-100">
                  <GlobeAltIcon className="h-6 w-6 text-green-600" />
                </div>
                <h3 className="mt-4 text-lg font-semibold text-gray-900">Multiple Languages</h3>
                <p className="mt-2 text-sm text-gray-600">
                  Hymnals in English, Kiswahili, and Dholuo reflect the global reach of Adventist worship
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-lg bg-purple-100">
                  <BookOpenIcon className="h-6 w-6 text-purple-600" />
                </div>
                <h3 className="mt-4 text-lg font-semibold text-gray-900">Complete Digital Access</h3>
                <p className="mt-2 text-sm text-gray-600">
                  Every hymn digitized with searchable text, metadata, and cross-references
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}