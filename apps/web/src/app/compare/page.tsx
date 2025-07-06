import { Metadata } from 'next';
import { ArrowsRightLeftIcon, BookOpenIcon, CalendarIcon, GlobeAltIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Compare Hymnals - Advent Hymnals',
  description: 'Compare different Adventist hymnal collections side by side. Analyze similarities, differences, and evolution of hymnody across time periods.',
  keywords: ['hymnal comparison', 'Adventist hymnals', 'hymn analysis', 'worship music evolution', 'SDA hymnal differences'],
};

export default async function ComparePage() {
  const hymnalReferences = await loadHymnalReferences();
  const hymnals = Object.values(hymnalReferences.hymnals);

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Compare Hymnals
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Compare different hymnal collections side by side to understand the evolution and diversity of Adventist hymnody
              </p>
            </div>
          </div>
        </div>

        {/* Comparison Tool */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="bg-white rounded-xl shadow-sm p-8 mb-8">
            <div className="flex items-center mb-6">
              <ArrowsRightLeftIcon className="h-6 w-6 text-primary-600 mr-3" />
              <h2 className="text-2xl font-bold text-gray-900">Hymnal Comparison Tool</h2>
            </div>
            
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Left Side - Select First Hymnal */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">
                  Select First Hymnal
                </label>
                <select className="w-full rounded-lg border-gray-300 text-base">
                  <option value="">Choose a hymnal...</option>
                  {hymnals.map(hymnal => (
                    <option key={hymnal.id} value={hymnal.id}>
                      {hymnal.name} ({hymnal.year})
                    </option>
                  ))}
                </select>
              </div>

              {/* Right Side - Select Second Hymnal */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">
                  Select Second Hymnal
                </label>
                <select className="w-full rounded-lg border-gray-300 text-base">
                  <option value="">Choose a hymnal...</option>
                  {hymnals.map(hymnal => (
                    <option key={hymnal.id} value={hymnal.id}>
                      {hymnal.name} ({hymnal.year})
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="mt-6 flex justify-center">
              <button className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors">
                <ArrowsRightLeftIcon className="h-5 w-5 mr-2" />
                Compare Hymnals
              </button>
            </div>
          </div>

          {/* Comparison Features */}
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-3 mb-8">
            <div className="bg-white rounded-xl shadow-sm p-6">
              <div className="flex items-center mb-4">
                <BookOpenIcon className="h-8 w-8 text-blue-600" />
                <h3 className="text-lg font-semibold text-gray-900 ml-3">Content Analysis</h3>
              </div>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• Shared hymns between collections</li>
                <li>• Unique hymns in each collection</li>
                <li>• Text variations and revisions</li>
                <li>• Melody and tune differences</li>
              </ul>
            </div>

            <div className="bg-white rounded-xl shadow-sm p-6">
              <div className="flex items-center mb-4">
                <CalendarIcon className="h-8 w-8 text-green-600" />
                <h3 className="text-lg font-semibold text-gray-900 ml-3">Historical Context</h3>
              </div>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• Publication date comparison</li>
                <li>• Historical period influence</li>
                <li>• Compiler background</li>
                <li>• Cultural and theological context</li>
              </ul>
            </div>

            <div className="bg-white rounded-xl shadow-sm p-6">
              <div className="flex items-center mb-4">
                <GlobeAltIcon className="h-8 w-8 text-purple-600" />
                <h3 className="text-lg font-semibold text-gray-900 ml-3">Statistical Overview</h3>
              </div>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>• Total hymn count comparison</li>
                <li>• Language and translation analysis</li>
                <li>• Theme and topic distribution</li>
                <li>• Composer and author overlap</li>
              </ul>
            </div>
          </div>

          {/* Popular Comparisons */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Popular Comparisons</h2>
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <div className="border border-gray-200 rounded-lg p-6 hover:border-primary-300 hover:shadow-md transition-all cursor-pointer">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  SDAH 1985 vs Church Hymnal 1941
                </h3>
                <p className="text-sm text-gray-600 mb-4">
                  Compare the modern official hymnal with its predecessor to see how hymn selection evolved.
                </p>
                <div className="flex items-center text-sm text-gray-500">
                  <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs mr-2">695 hymns</span>
                  <ArrowsRightLeftIcon className="h-4 w-4 mx-2" />
                  <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">703 hymns</span>
                </div>
              </div>

              <div className="border border-gray-200 rounded-lg p-6 hover:border-primary-300 hover:shadow-md transition-all cursor-pointer">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  Christ in Song vs Early Hymnals
                </h3>
                <p className="text-sm text-gray-600 mb-4">
                  Explore how F.E. Belden&apos;s comprehensive collection influenced later hymnal development.
                </p>
                <div className="flex items-center text-sm text-gray-500">
                  <span className="bg-purple-100 text-purple-800 px-2 py-1 rounded text-xs mr-2">949 hymns</span>
                  <ArrowsRightLeftIcon className="h-4 w-4 mx-2" />
                  <span className="bg-orange-100 text-orange-800 px-2 py-1 rounded text-xs">Multiple</span>
                </div>
              </div>

              <div className="border border-gray-200 rounded-lg p-6 hover:border-primary-300 hover:shadow-md transition-all cursor-pointer">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  English vs Kiswahili Hymnals
                </h3>
                <p className="text-sm text-gray-600 mb-4">
                  Compare hymnal content across languages to understand cultural adaptation.
                </p>
                <div className="flex items-center text-sm text-gray-500">
                  <span className="bg-red-100 text-red-800 px-2 py-1 rounded text-xs mr-2">English</span>
                  <ArrowsRightLeftIcon className="h-4 w-4 mx-2" />
                  <span className="bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-xs">Kiswahili</span>
                </div>
              </div>

              <div className="border border-gray-200 rounded-lg p-6 hover:border-primary-300 hover:shadow-md transition-all cursor-pointer">
                <h3 className="text-lg font-semibold text-gray-900 mb-2">
                  19th vs 20th Century Collections
                </h3>
                <p className="text-sm text-gray-600 mb-4">
                  Analyze how hymn themes and styles evolved from the 1800s to 1900s.
                </p>
                <div className="flex items-center text-sm text-gray-500">
                  <span className="bg-indigo-100 text-indigo-800 px-2 py-1 rounded text-xs mr-2">1800s</span>
                  <ArrowsRightLeftIcon className="h-4 w-4 mx-2" />
                  <span className="bg-teal-100 text-teal-800 px-2 py-1 rounded text-xs">1900s</span>
                </div>
              </div>
            </div>
          </div>

          {/* Research Applications */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-8 mt-8">
            <h2 className="text-2xl font-bold text-blue-900 mb-4">Research Applications</h2>
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <div>
                <h3 className="text-lg font-semibold text-blue-800 mb-2">Academic Research</h3>
                <ul className="space-y-1 text-sm text-blue-700">
                  <li>• Theological evolution in Adventist hymnody</li>
                  <li>• Cross-cultural hymn adaptation studies</li>
                  <li>• Historical musicology research</li>
                  <li>• Liturgical development analysis</li>
                </ul>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-blue-800 mb-2">Practical Applications</h3>
                <ul className="space-y-1 text-sm text-blue-700">
                  <li>• Worship planning and hymn selection</li>
                  <li>• Understanding congregation preferences</li>
                  <li>• Educational curriculum development</li>
                  <li>• Publishing and compilation decisions</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}