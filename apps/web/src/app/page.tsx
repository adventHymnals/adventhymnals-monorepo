import { Metadata } from 'next';
import Link from 'next/link';
import { BookOpenIcon, GlobeAltIcon, MusicalNoteIcon, AcademicCapIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Advent Hymnals - Digital Collection of Adventist Hymnody',
  description: 'Explore 160+ years of Adventist hymnody heritage. Search through 13 complete hymnal collections including the Seventh-day Adventist Hymnal, Christ in Song, Nyimbo za Kristo, and more.',
  openGraph: {
    title: 'Advent Hymnals - Digital Collection of Adventist Hymnody',
    description: 'Explore 160+ years of Adventist hymnody heritage. Search through 13 complete hymnal collections.',
    url: '/',
  },
};


const features = [
  {
    name: 'Comprehensive Search',
    description: 'Search across all 13 hymnal collections by title, number, author, composer, or first line.',
    icon: BookOpenIcon,
  },
  {
    name: 'Multilingual Support',
    description: 'Access hymnals in English, Kiswahili, and Dholuo with cultural context.',
    icon: GlobeAltIcon,
  },
  {
    name: 'Rich Media',
    description: 'View sheet music, listen to audio recordings, and access historical notes.',
    icon: MusicalNoteIcon,
  },
  {
    name: 'Academic Tools',
    description: 'Compare hymns across collections, generate citations, and access scholarly resources.',
    icon: AcademicCapIcon,
  },
];

export default async function HomePage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      {/* Hero Section */}
      <div className="relative bg-gradient-to-br from-hymnal-navy via-primary-800 to-hymnal-burgundy">
        <div className="absolute inset-0 bg-black/20"></div>
        <div className="relative mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-4xl text-center">
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-6xl">
              Advent Hymnals
            </h1>
            <p className="mt-6 text-xl leading-8 text-blue-100">
              Preserving 160+ years of Adventist hymnody heritage
            </p>
            <p className="mt-4 text-lg text-blue-200">
              Explore 13 complete hymnal collections with over 5,000 hymns from 1838 to 2000
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Link
                href="/search"
                className="btn-primary bg-white text-primary-600 hover:bg-gray-50 shadow-lg"
              >
                Start Searching
              </Link>
              <Link
                href="/hymnals"
                className="text-sm font-semibold leading-6 text-white hover:text-blue-200 transition-colors"
              >
                Browse Collections <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Featured Hymnals */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Featured Collections
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Discover our most popular and historically significant hymnal collections
            </p>
          </div>
          <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
            {/* Static featured hymnals for now */}
            <div className="relative overflow-hidden rounded-2xl shadow-xl bg-gradient-to-br from-blue-600 to-indigo-700">
              <div className="relative p-8 h-full flex flex-col">
                <div className="flex items-center justify-between mb-6">
                  <div className="text-2xl font-bold text-blue-50 bg-white/20 rounded-lg px-3 py-1">
                    1985
                  </div>
                  <div className="text-sm text-blue-50 bg-white/20 rounded-lg px-3 py-1">
                    695 hymns
                  </div>
                </div>
                <div className="flex-grow">
                  <h3 className="text-xl font-bold text-blue-50 mb-2">
                    Seventh-day Adventist Hymnal
                  </h3>
                  <p className="text-sm text-blue-50 mb-4 opacity-90">
                    English
                  </p>
                  <p className="text-blue-50 opacity-80 mb-6">
                    The current official hymnal of the Seventh-day Adventist Church
                  </p>
                </div>
                <div className="mt-auto">
                  <Link
                    href="/seventh-day-adventist-hymnal"
                    className="inline-flex items-center justify-center w-full px-6 py-3 rounded-lg font-medium bg-blue-500 hover:bg-blue-600 text-white transition-colors duration-200"
                  >
                    <BookOpenIcon className="h-5 w-5 mr-2" />
                    Explore Collection
                  </Link>
                </div>
              </div>
            </div>

            <div className="relative overflow-hidden rounded-2xl shadow-xl bg-gradient-to-br from-emerald-600 to-teal-700">
              <div className="relative p-8 h-full flex flex-col">
                <div className="flex items-center justify-between mb-6">
                  <div className="text-2xl font-bold text-emerald-50 bg-white/20 rounded-lg px-3 py-1">
                    1908
                  </div>
                  <div className="text-sm text-emerald-50 bg-white/20 rounded-lg px-3 py-1">
                    949 hymns
                  </div>
                </div>
                <div className="flex-grow">
                  <h3 className="text-xl font-bold text-emerald-50 mb-2">
                    Christ in Song
                  </h3>
                  <p className="text-sm text-emerald-50 mb-4 opacity-90">
                    English
                  </p>
                  <p className="text-emerald-50 opacity-80 mb-6">
                    F.E. Belden&apos;s comprehensive collection of early Adventist hymns
                  </p>
                </div>
                <div className="mt-auto">
                  <Link
                    href="/christ-in-song"
                    className="inline-flex items-center justify-center w-full px-6 py-3 rounded-lg font-medium bg-emerald-500 hover:bg-emerald-600 text-white transition-colors duration-200"
                  >
                    <BookOpenIcon className="h-5 w-5 mr-2" />
                    Explore Collection
                  </Link>
                </div>
              </div>
            </div>

            <div className="relative overflow-hidden rounded-2xl shadow-xl bg-gradient-to-br from-orange-600 to-red-700">
              <div className="relative p-8 h-full flex flex-col">
                <div className="flex items-center justify-between mb-6">
                  <div className="text-2xl font-bold text-orange-50 bg-white/20 rounded-lg px-3 py-1">
                    1944
                  </div>
                  <div className="text-sm text-orange-50 bg-white/20 rounded-lg px-3 py-1">
                    220 hymns
                  </div>
                </div>
                <div className="flex-grow">
                  <h3 className="text-xl font-bold text-orange-50 mb-2">
                    Nyimbo za Kristo
                  </h3>
                  <p className="text-sm text-orange-50 mb-4 opacity-90">
                    Kiswahili
                  </p>
                  <p className="text-orange-50 opacity-80 mb-6">
                    The Kiswahili hymnal for East African Adventist congregations
                  </p>
                </div>
                <div className="mt-auto">
                  <Link
                    href="/nyimbo-za-kristo"
                    className="inline-flex items-center justify-center w-full px-6 py-3 rounded-lg font-medium bg-orange-500 hover:bg-orange-600 text-white transition-colors duration-200"
                  >
                    <BookOpenIcon className="h-5 w-5 mr-2" />
                    Explore Collection
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Features */}
      <div className="py-24 sm:py-32 bg-gray-50">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Everything you need to explore Adventist hymnody
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              From worship leaders to scholars, our platform serves the global Adventist community
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-4">
              {features.map((feature) => (
                <div key={feature.name} className="flex flex-col">
                  <dt className="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                    <feature.icon className="h-5 w-5 flex-none text-primary-600" aria-hidden="true" />
                    {feature.name}
                  </dt>
                  <dd className="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                    <p className="flex-auto">{feature.description}</p>
                  </dd>
                </div>
              ))}
            </dl>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-primary-600">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Join the global community
              <br />
              preserving Adventist musical heritage
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-primary-200">
              Whether you&apos;re leading worship, conducting research, or simply love traditional hymns, 
              Advent Hymnals connects you to centuries of faithful music.
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Link
                href="/about"
                className="btn-primary bg-white text-primary-600 hover:bg-gray-50"
              >
                Learn more
              </Link>
              <Link 
                href="/contribute" 
                className="text-sm font-semibold leading-6 text-white hover:text-primary-200 transition-colors"
              >
                Contribute <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}