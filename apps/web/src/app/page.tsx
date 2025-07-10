import { Metadata } from 'next';
import Link from 'next/link';
import { BookOpenIcon, GlobeAltIcon, MusicalNoteIcon, AcademicCapIcon, PlayIcon, UserGroupIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import HymnalCarousel from '@/components/ui/HymnalCarousel';
import { loadHymnalReferences } from '@/lib/data-server';
import { SupportedLanguage } from '@advent-hymnals/shared';

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
  // For static export, use a minimal fallback since we can't access the file system
  let hymnalReferences;
  try {
    hymnalReferences = await loadHymnalReferences();
  } catch (error) {
    console.warn('Failed to load hymnal references, using fallback data:', error);
    // Minimal fallback for static export
    hymnalReferences = {
      hymnals: {
        'SDAH': {
          id: 'SDAH',
          name: 'Seventh-day Adventist Hymnal',
          abbreviation: 'SDAH',
          year: 1985,
          total_songs: 695,
          language: 'en' as SupportedLanguage,
          language_name: 'English',
          site_name: 'Seventh-day Adventist Hymnal',
          url_slug: 'seventh-day-adventist-hymnal'
        }
      },
      languages: { 'en': 'English' },
      metadata: {
        total_hymnals: 1,
        date_range: { earliest: 1985, latest: 1985 },
        languages_supported: ['en'] as SupportedLanguage[],
        total_estimated_songs: 695,
        source: 'Fallback data for static export',
        generated_date: new Date().toISOString().split('T')[0]
      }
    };
  }

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
            <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4 sm:gap-x-6">
              <div className="flex flex-col sm:flex-row items-center gap-4">
                <div className="flex items-center gap-x-4">
                  <Link
                    href="/search"
                    className="btn-primary bg-white text-primary-600 hover:bg-gray-50 shadow-lg"
                  >
                    Start Searching
                  </Link>
                  <Link
                    href="/download"
                    className="btn-primary bg-primary-500 text-white hover:bg-primary-400 shadow-lg border border-primary-400"
                  >
                    Download App
                  </Link>
                </div>
                {/* Option 1: Added choir project button */}
                <Link
                  href="/choir-project"
                  className="btn-primary bg-emerald-500 text-white hover:bg-emerald-400 shadow-lg border border-emerald-400"
                >
                  🎵 Join Our Choir Project
                </Link>
              </div>
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

      {/* Option 3: Bringing Hymns to Life Section */}
      <div className="py-24 sm:py-32 bg-white">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Left side - Mission & Info */}
            <div>
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl mb-6">
                Bringing Hymns to Life
              </h2>
              <p className="text-lg text-gray-600 mb-6">
                These beautiful hymns deserve to be heard, not just read. Unlike contemporary songs that 
                come and go, hymns have sustained faith for centuries and will continue for generations to come.
              </p>
              
              <div className="space-y-4 mb-8">
                <div className="flex items-start">
                  <UserGroupIcon className="h-5 w-5 text-emerald-600 mt-1 mr-3 flex-shrink-0" />
                  <div>
                    <h3 className="font-semibold text-gray-900">Choir Collaborations</h3>
                    <p className="text-gray-600 text-sm">Partner with choirs worldwide to create authentic, heartfelt recordings</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <PlayIcon className="h-5 w-5 text-emerald-600 mt-1 mr-3 flex-shrink-0" />
                  <div>
                    <h3 className="font-semibold text-gray-900">AI-Assisted Production</h3>
                    <p className="text-gray-600 text-sm">Cutting-edge technology ensures every hymn can be beautifully represented</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <MusicalNoteIcon className="h-5 w-5 text-emerald-600 mt-1 mr-3 flex-shrink-0" />
                  <div>
                    <h3 className="font-semibold text-gray-900">Preserving Heritage</h3>
                    <p className="text-gray-600 text-sm">Ensuring 160+ years of sacred music reaches current and future generations</p>
                  </div>
                </div>
                
                <div className="flex items-start">
                  <BookOpenIcon className="h-5 w-5 text-emerald-600 mt-1 mr-3 flex-shrink-0" />
                  <div>
                    <h3 className="font-semibold text-gray-900">Hymnal Projects</h3>
                    <p className="text-gray-600 text-sm">Creating curated collections that reflect historic Adventist theology and worship traditions</p>
                  </div>
                </div>
              </div>

              <div className="flex flex-col sm:flex-row gap-4">
                <Link
                  href="/choir-project"
                  className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-emerald-600 hover:bg-emerald-700 transition-colors"
                >
                  <UserGroupIcon className="h-5 w-5 mr-2" />
                  Join Our Mission
                </Link>
                <Link
                  href="/hymnal-projects"
                  className="inline-flex items-center px-6 py-3 border border-emerald-600 text-base font-medium rounded-md text-emerald-600 hover:bg-emerald-50 transition-colors"
                >
                  <BookOpenIcon className="h-5 w-5 mr-2" />
                  Hymnal Projects
                </Link>
                <a
                  href="https://www.youtube.com/@adventhymnals"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center px-6 py-3 border border-emerald-600 text-base font-medium rounded-md text-emerald-600 hover:bg-emerald-50 transition-colors"
                >
                  <PlayIcon className="h-5 w-5 mr-2" />
                  Visit Our Channel
                </a>
              </div>
            </div>

            {/* Right side - YouTube Channel Preview */}
            <div className="lg:pl-8">
              <div className="relative bg-gray-900 rounded-xl p-8 text-white">
                <div className="flex items-center mb-6">
                  <div className="bg-red-600 p-3 rounded-lg mr-4">
                    <PlayIcon className="h-8 w-8 text-white" />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold">@adventhymnals</h3>
                    <p className="text-gray-300">YouTube Channel</p>
                  </div>
                </div>
                
                <p className="text-gray-200 mb-6">
                  Experience the beauty of traditional Adventist hymnody through our growing collection 
                  of choir recordings and AI-assisted performances.
                </p>

                <div className="grid grid-cols-2 gap-4 mb-6">
                  <div className="text-center p-4 bg-gray-800 rounded-lg">
                    <div className="text-2xl font-bold text-emerald-400">5,500+</div>
                    <div className="text-sm text-gray-300">Hymns to Record</div>
                  </div>
                  <div className="text-center p-4 bg-gray-800 rounded-lg">
                    <div className="text-2xl font-bold text-emerald-400">Growing</div>
                    <div className="text-sm text-gray-300">Active Project</div>
                  </div>
                </div>

                <div className="bg-emerald-600/20 border border-emerald-600/30 rounded-lg p-4">
                  <p className="text-emerald-200 text-sm">
                    🎵 <strong>Join us</strong> in preserving centuries of sacred music for future generations
                  </p>
                </div>
              </div>
            </div>
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