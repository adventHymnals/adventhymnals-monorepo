import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Metrical Index - Advent Hymnals',
  description: 'Browse hymns by meter patterns. Find hymns with matching rhythmic structures across all hymnal collections.',
  keywords: ['hymn meters', 'metrical index', 'hymn patterns', 'musical meter'],
};

// Common hymn meters
const commonMeters = [
  { name: 'Common Meter (C.M.)', pattern: '8.6.8.6', description: 'Most frequently used meter in hymnody' },
  { name: 'Long Meter (L.M.)', pattern: '8.8.8.8', description: 'Four lines of eight syllables each' },
  { name: 'Short Meter (S.M.)', pattern: '6.6.8.6', description: 'Shorter first and third lines' },
  { name: '8.7.8.7', pattern: '8.7.8.7', description: 'Popular modern hymn meter' },
  { name: '7.6.7.6', pattern: '7.6.7.6', description: 'Trochaic meter, often used for gentle hymns' },
  { name: '10.10.10.10', pattern: '10.10.10.10', description: 'Extended meter for longer texts' },
];

export default async function MetersPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                Metrical Index
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Explore hymns organized by their metrical patterns and rhythmic structures
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
            {/* Main Content */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Common Hymn Meters</h2>
                
                <div className="space-y-6">
                  {commonMeters.map((meter) => (
                    <div key={meter.name} className="border-l-4 border-primary-500 pl-6 py-4">
                      <h3 className="text-lg font-semibold text-gray-900">{meter.name}</h3>
                      <p className="text-primary-600 font-mono text-lg mt-1">{meter.pattern}</p>
                      <p className="text-gray-600 mt-2">{meter.description}</p>
                      <button className="mt-3 text-sm text-primary-600 hover:text-primary-700 font-medium">
                        View hymns in this meter →
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Coming Soon */}
              <div className="mt-8 bg-yellow-50 border border-yellow-200 rounded-xl p-6">
                <h3 className="text-lg font-semibold text-yellow-800 mb-2">🚧 Under Development</h3>
                <p className="text-yellow-700">
                  We're currently building a comprehensive metrical index that will allow you to:
                </p>
                <ul className="mt-3 space-y-1 text-yellow-700">
                  <li>• Browse hymns by specific meter patterns</li>
                  <li>• Find hymns with matching rhythmic structures</li>
                  <li>• Discover tune alternatives for your favorite texts</li>
                  <li>• Search across all hymnal collections by meter</li>
                </ul>
              </div>
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1">
              <div className="bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">About Metrical Patterns</h3>
                <div className="space-y-4 text-sm text-gray-600">
                  <p>
                    Metrical patterns in hymnody describe the syllable count and rhythmic structure 
                    of each line in a hymn stanza.
                  </p>
                  <p>
                    Understanding meter helps musicians find alternative tunes for hymn texts 
                    and assists in hymn selection for worship services.
                  </p>
                  <p>
                    The notation "8.6.8.6" means the first line has 8 syllables, 
                    the second has 6, the third has 8, and the fourth has 6.
                  </p>
                </div>
              </div>

              <div className="mt-6 bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Links</h3>
                <div className="space-y-2">
                  <a href="/search" className="block text-sm text-primary-600 hover:text-primary-700">
                    Search Hymns →
                  </a>
                  <a href="/composers" className="block text-sm text-primary-600 hover:text-primary-700">
                    Composers Index →
                  </a>
                  <a href="/topics" className="block text-sm text-primary-600 hover:text-primary-700">
                    Browse by Topic →
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}