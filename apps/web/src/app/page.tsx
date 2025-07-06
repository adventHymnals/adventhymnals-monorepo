import { Metadata } from 'next';
import Link from 'next/link';
import { BookOpenIcon, GlobeAltIcon, MusicalNoteIcon, AcademicCapIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import HymnalCarousel from '@/components/ui/HymnalCarousel';
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

  // Convert hymnal references to carousel format - get all hymnals from actual data
  const allHymnals = Object.values(hymnalReferences.hymnals);
  
  // Create featured hymnals with colors
  const featuredHymnals = allHymnals.map((hymnal, index) => {
    const colorSchemes = [
      {
        gradient: 'from-blue-600 to-indigo-700',
        text: 'text-blue-50',
        button: 'bg-blue-500 hover:bg-blue-600 text-white',
        searchBg: 'bg-blue-50 border-blue-200 focus:border-blue-400',
      },
      {
        gradient: 'from-emerald-600 to-teal-700',
        text: 'text-emerald-50',
        button: 'bg-emerald-500 hover:bg-emerald-600 text-white',
        searchBg: 'bg-emerald-50 border-emerald-200 focus:border-emerald-400',
      },
      {
        gradient: 'from-orange-600 to-red-700',
        text: 'text-orange-50',
        button: 'bg-orange-500 hover:bg-orange-600 text-white',
        searchBg: 'bg-orange-50 border-orange-200 focus:border-orange-400',
      },
      {
        gradient: 'from-purple-600 to-violet-700',
        text: 'text-purple-50',
        button: 'bg-purple-500 hover:bg-purple-600 text-white',
        searchBg: 'bg-purple-50 border-purple-200 focus:border-purple-400',
      },
      {
        gradient: 'from-pink-600 to-rose-700',
        text: 'text-pink-50',
        button: 'bg-pink-500 hover:bg-pink-600 text-white',
        searchBg: 'bg-pink-50 border-pink-200 focus:border-pink-400',
      },
      {
        gradient: 'from-cyan-600 to-blue-700',
        text: 'text-cyan-50',
        button: 'bg-cyan-500 hover:bg-cyan-600 text-white',
        searchBg: 'bg-cyan-50 border-cyan-200 focus:border-cyan-400',
      },
    ];

    const colorScheme = colorSchemes[index % colorSchemes.length];

    return {
      id: hymnal.id,
      name: hymnal.site_name || hymnal.name,
      year: hymnal.year,
      songs: hymnal.total_songs,
      language: hymnal.language_name,
      description: `A collection of ${hymnal.total_songs} hymns from ${hymnal.year}`,
      href: `/${hymnal.url_slug}`,
      featured: true,
      colors: colorScheme,
    };
  });

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
          <div className="mx-auto mt-16 sm:mt-20">
            <HymnalCarousel hymnals={featuredHymnals} />
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