import { Metadata } from 'next';
import Link from 'next/link';
import { UserIcon, MusicalNoteIcon, CalendarIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Composers Index - Advent Hymnals',
  description: 'Browse hymns by composer and author. Discover works by Fanny Crosby, Charles Wesley, John Newton, and other renowned hymn writers.',
  keywords: ['hymn composers', 'hymn authors', 'Fanny Crosby', 'Charles Wesley', 'John Newton', 'hymn writers'],
};

const featuredComposers = [
  {
    name: 'Fanny J. Crosby',
    life: '1820-1915',
    hymnCount: 156,
    description: 'Prolific American hymn writer who wrote over 8,000 hymns despite being blind from infancy.',
    notableWorks: ['Blessed Assurance', 'To God Be the Glory', 'All the Way My Savior Leads Me'],
    slug: 'fanny-crosby'
  },
  {
    name: 'Charles Wesley',
    life: '1707-1788',
    hymnCount: 134,
    description: 'English Methodist leader and hymn writer, brother of John Wesley, wrote over 6,000 hymns.',
    notableWorks: ['Hark! The Herald Angels Sing', 'Love Divine, All Loves Excelling', 'Christ the Lord Is Risen Today'],
    slug: 'charles-wesley'
  },
  {
    name: 'John Newton',
    life: '1725-1807',
    hymnCount: 89,
    description: 'Former slave trader turned Anglican clergyman, best known for writing "Amazing Grace".',
    notableWorks: ['Amazing Grace', 'How Sweet the Name of Jesus Sounds', 'Glorious Things of Thee Are Spoken'],
    slug: 'john-newton'
  },
  {
    name: 'Isaac Watts',
    life: '1674-1748',
    hymnCount: 87,
    description: 'English Congregationalist minister, known as the "Father of English Hymnody".',
    notableWorks: ['When I Survey the Wondrous Cross', 'Joy to the World', 'O God, Our Help in Ages Past'],
    slug: 'isaac-watts'
  },
  {
    name: 'Frances R. Havergal',
    life: '1836-1879',
    hymnCount: 76,
    description: 'English religious poet and hymn writer known for her devotional hymns.',
    notableWorks: ['Take My Life and Let It Be', 'Like a River Glorious', 'I Am Trusting Thee, Lord Jesus'],
    slug: 'frances-havergal'
  },
  {
    name: 'Philip P. Bliss',
    life: '1838-1876',
    hymnCount: 65,
    description: 'American composer and Gospel singer who wrote both words and music for many hymns.',
    notableWorks: ['It Is Well with My Soul', 'Wonderful Words of Life', 'Let the Lower Lights Be Burning'],
    slug: 'philip-bliss'
  }
];

const composerAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

export default async function ComposersPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Composers & Authors
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Discover the lives and works of renowned hymn writers and composers whose music has shaped Christian worship
              </p>
              <div className="mt-8 flex justify-center gap-8 text-sm text-gray-500">
                <div className="flex items-center">
                  <UserIcon className="h-5 w-5 mr-2" />
                  <span>500+ Composers</span>
                </div>
                <div className="flex items-center">
                  <MusicalNoteIcon className="h-5 w-5 mr-2" />
                  <span>5,500+ Hymns</span>
                </div>
                <div className="flex items-center">
                  <CalendarIcon className="h-5 w-5 mr-2" />
                  <span>16th-20th Century</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Featured Composers */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="mb-12">
            <h2 className="text-2xl font-bold text-gray-900 mb-8">Featured Composers</h2>
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
              {featuredComposers.map((composer) => (
                <Link
                  key={composer.slug}
                  href={`/search?composer=${encodeURIComponent(composer.name)}`}
                  className="group bg-white rounded-xl shadow-sm p-6 hover:shadow-lg transition-all duration-300 hover:scale-105"
                >
                  <div className="flex items-start space-x-4">
                    <div className="flex-shrink-0">
                      <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center">
                        <UserIcon className="h-8 w-8 text-primary-600" />
                      </div>
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between mb-2">
                        <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                          {composer.name}
                        </h3>
                        <span className="text-sm font-medium text-primary-600 bg-primary-50 px-2 py-1 rounded">
                          {composer.hymnCount} hymns
                        </span>
                      </div>
                      <p className="text-sm text-gray-600 mb-2">{composer.life}</p>
                      <p className="text-sm text-gray-700 mb-3">{composer.description}</p>
                      <div>
                        <p className="text-xs font-medium text-gray-500 mb-1">Notable works:</p>
                        <p className="text-xs text-gray-600">
                          {composer.notableWorks.join(', ')}
                        </p>
                      </div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </div>

          {/* Alphabetical Index */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-8">Browse Alphabetically</h2>
            
            {/* Alphabet Navigation */}
            <div className="flex flex-wrap gap-2 mb-8 justify-center">
              {composerAlphabet.map((letter) => (
                <a
                  key={letter}
                  href={`#letter-${letter}`}
                  className="w-10 h-10 rounded-lg border border-gray-300 bg-white text-gray-700 hover:bg-primary-50 hover:border-primary-300 hover:text-primary-600 transition-all duration-200 font-medium flex items-center justify-center"
                >
                  {letter}
                </a>
              ))}
            </div>

            {/* Composer Lists by Letter */}
            <div className="space-y-8">
              {composerAlphabet.map((letter) => (
                <div key={letter} id={`letter-${letter}`}>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4 border-b border-gray-200 pb-2">
                    {letter}
                  </h3>
                  <div className="grid grid-cols-1 gap-2 sm:grid-cols-2 lg:grid-cols-3">
                    {/* Example composers for each letter - in a real app, these would come from data */}
                    {letter === 'A' && (
                      <>
                        <Link href="/search?composer=Adams" className="text-primary-600 hover:text-primary-800 transition-colors">
                          Adams, Sarah F. <span className="text-gray-500 text-sm">(12 hymns)</span>
                        </Link>
                        <Link href="/search?composer=Alexander" className="text-primary-600 hover:text-primary-800 transition-colors">
                          Alexander, Cecil F. <span className="text-gray-500 text-sm">(8 hymns)</span>
                        </Link>
                      </>
                    )}
                    {letter === 'B' && (
                      <>
                        <Link href="/search?composer=Baring-Gould" className="text-primary-600 hover:text-primary-800 transition-colors">
                          Baring-Gould, Sabine <span className="text-gray-500 text-sm">(6 hymns)</span>
                        </Link>
                        <Link href="/search?composer=Bliss" className="text-primary-600 hover:text-primary-800 transition-colors">
                          Bliss, Philip P. <span className="text-gray-500 text-sm">(65 hymns)</span>
                        </Link>
                      </>
                    )}
                    {letter === 'C' && (
                      <>
                        <Link href="/search?composer=Cowper" className="text-primary-600 hover:text-primary-800 transition-colors">
                          Cowper, William <span className="text-gray-500 text-sm">(23 hymns)</span>
                        </Link>
                        <Link href="/search?composer=Crosby" className="text-primary-600 hover:text-primary-800 transition-colors">
                          Crosby, Fanny J. <span className="text-gray-500 text-sm">(156 hymns)</span>
                        </Link>
                      </>
                    )}
                    {/* Add placeholder text for other letters */}
                    {!['A', 'B', 'C'].includes(letter) && (
                      <p className="text-gray-500 text-sm italic">Loading composers...</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Search CTA */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                Search by Composer
              </h2>
              <p className="text-gray-600 mb-8">
                Can&apos;t find a specific composer? Use our search to discover hymns by any author or composer
              </p>
              <Link
                href="/search"
                className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
              >
                <MusicalNoteIcon className="h-5 w-5 mr-2" />
                Search All Composers
              </Link>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}