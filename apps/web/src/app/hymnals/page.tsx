import { Metadata } from 'next';
import { CalendarIcon, BookOpenIcon, GlobeAltIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import HymnalsFilter from '@/components/hymnals/HymnalsFilter';
import { loadHymnalReferences } from '@/lib/data-server';

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
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center text-white">
              <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
                Hymnal Collections
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Explore 13 complete hymnal collections spanning 160+ years of Adventist musical heritage
              </p>
              <div className="mt-8 flex justify-center gap-8 text-sm text-primary-200">
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

        {/* Hymnal Grid with Filtering */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <HymnalsFilter hymnals={hymnals} />
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