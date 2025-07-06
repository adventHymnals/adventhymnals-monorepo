import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  CalendarIcon, 
  UserIcon, 
  MusicalNoteIcon,
  HomeIcon,
  ChevronRightIcon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import HymnalSearchClient from '@/components/hymnal/HymnalSearchClient';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data-server';
import { formatNumber } from '@advent-hymnals/shared';

interface HymnalPageProps {
  params: {
    hymnal: string;
  };
}

export async function generateMetadata({ params }: HymnalPageProps): Promise<Metadata> {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const hymnalRef = Object.values(hymnalReferences.hymnals).find(
      (h) => h.url_slug === params.hymnal
    );
    
    if (!hymnalRef) {
      return {
        title: 'Hymnal Not Found',
      };
    }

    const title = `${hymnalRef.site_name} - Browse ${hymnalRef.total_songs} Hymns`;
    const description = `Browse ${hymnalRef.total_songs} hymns from ${hymnalRef.site_name} (${hymnalRef.year}). Search and explore Adventist hymnody with full text, themes, and musical information.`;

    return {
      title,
      description,
      keywords: [
        hymnalRef.site_name,
        hymnalRef.name,
        'hymnal',
        'Adventist hymns',
        'worship music',
        'Christian music',
        hymnalRef.language_name,
        hymnalRef.year.toString()
      ],
      openGraph: {
        title,
        description,
        type: 'website',
      },
    };
  } catch {
    return {
      title: 'Hymnal Not Found',
    };
  }
}

export default async function HymnalPage({ params }: HymnalPageProps) {
  const hymnalReferences = await loadHymnalReferences();
  
  const hymnalRef = Object.values(hymnalReferences.hymnals).find(
    (h) => h.url_slug === params.hymnal
  );
  
  if (!hymnalRef) {
    notFound();
  }
  
  const hymnsData = await loadHymnalHymns(hymnalRef.id, 1, 1000);

  const breadcrumbs = [{
    label: 'Hymnals',
    href: '/hymnals'
  }, {
    label: hymnalRef.site_name,
    current: true
  }];

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-white">
        {/* Header Section */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="mx-auto max-w-4xl">
              {/* Breadcrumbs */}
              <div className="mb-6">
                <nav className="flex" aria-label="Breadcrumb">
                  <ol role="list" className="flex items-center space-x-2">
                    {/* Home icon */}
                    <li>
                      <div>
                        <Link
                          href="/"
                          className="text-primary-200 hover:text-white transition-colors duration-200"
                        >
                          <HomeIcon className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
                          <span className="sr-only">Home</span>
                        </Link>
                      </div>
                    </li>

                    {/* Breadcrumb items */}
                    {breadcrumbs.map((item) => (
                      <li key={item.label}>
                        <div className="flex items-center">
                          <ChevronRightIcon
                            className="h-4 w-4 flex-shrink-0 text-primary-200"
                            aria-hidden="true"
                          />
                          {item.href && !item.current ? (
                            <Link
                              href={item.href}
                              className="ml-2 text-sm font-medium text-primary-100 hover:text-white transition-colors duration-200"
                            >
                              {item.label}
                            </Link>
                          ) : (
                            <span
                              className="ml-2 text-sm font-medium text-white"
                              aria-current={item.current ? 'page' : undefined}
                            >
                              {item.label}
                            </span>
                          )}
                        </div>
                      </li>
                    ))}
                  </ol>
                </nav>
              </div>

              {/* Hymnal Info */}
              <div className="text-center text-white">
                <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
                  {hymnalRef.site_name}
                </h1>
                
                {/* Metadata */}
                <div className="mt-8 flex flex-wrap justify-center gap-6 text-sm text-primary-200">
                  <div className="flex items-center">
                    <CalendarIcon className="mr-2 h-5 w-5" />
                    Published {hymnalRef.year}
                  </div>
                  <div className="flex items-center">
                    <BookOpenIcon className="mr-2 h-5 w-5" />
                    {formatNumber(hymnalRef.total_songs)} Hymns
                  </div>
                  <div className="flex items-center">
                    <MusicalNoteIcon className="mr-2 h-5 w-5" />
                    {hymnalRef.language_name}
                  </div>
                  {hymnalRef.compiler && (
                    <div className="flex items-center">
                      <UserIcon className="mr-2 h-5 w-5" />
                      {hymnalRef.compiler}
                    </div>
                  )}
                </div>

                </div>
            </div>
          </div>
        </div>

        {/* Client-side Search and Content */}
        <HymnalSearchClient 
          hymns={hymnsData.hymns}
          hymnalSlug={params.hymnal}
          hymnalName={hymnalRef.site_name}
          total={hymnsData.total}
        />
      </div>
    </Layout>
  );
}