'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { TagIcon, ArrowLeftIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

interface HymnData {
  id: string;
  number: number;
  title: string;
  author?: string;
  hymnal: {
    id: string;
    name: string;
    url_slug: string;
    abbreviation: string;
  };
}

interface ThemeDetailProps {
  params: {
    theme: string;
  };
}

export default function ThemeDetailPage({ params }: ThemeDetailProps) {
  const [hymns, setHymns] = useState<HymnData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [hymnalReferences, setHymnalReferences] = useState<any>(null);
  const router = useRouter();
  
  const decodedTheme = decodeURIComponent(params.theme);

  useEffect(() => {
    const loadData = async () => {
      try {
        const [themesResponse, references] = await Promise.all([
          fetch('/api/themes'),
          loadHymnalReferences()
        ]);
        
        if (!themesResponse.ok) {
          throw new Error('Failed to fetch themes');
        }
        
        const themesData = await themesResponse.json();
        const themeData = themesData.find((t: any) => t.theme === decodedTheme);
        
        if (!themeData) {
          setError(`Theme "${decodedTheme}" not found`);
          return;
        }
        
        setHymns(themeData.hymns);
        setHymnalReferences(references);
      } catch (error) {
        console.error('Failed to load theme data:', error);
        setError('Failed to load theme information');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [decodedTheme]);

  if (loading) {
    return (
      <Layout hymnalReferences={hymnalReferences}>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading theme information...</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout hymnalReferences={hymnalReferences}>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <TagIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">{error}</h3>
            <Link
              href="/themes"
              className="text-primary-600 hover:text-primary-700 font-medium"
            >
              ← Back to Themes
            </Link>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <Link
                href="/themes"
                className="inline-flex items-center text-primary-200 hover:text-white mb-6 transition-colors"
              >
                <ArrowLeftIcon className="h-4 w-4 mr-2" />
                Back to Themes
              </Link>
              
              <TagIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                {decodedTheme}
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                {hymns.length} hymn{hymns.length !== 1 ? 's' : ''} with this theme
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {hymns.map((hymn) => (
              <Link
                key={hymn.id}
                href={`/${hymn.hymnal.url_slug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                className="block p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow border border-gray-200 hover:border-primary-300"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900 hover:text-primary-600 transition-colors">
                      {hymn.title}
                    </h3>
                    <div className="text-sm text-gray-600 mt-1">
                      {hymn.hymnal.abbreviation} #{hymn.number}
                    </div>
                    {hymn.author && (
                      <div className="text-sm text-gray-500 mt-1">
                        by {hymn.author}
                      </div>
                    )}
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {hymns.length === 0 && (
            <div className="text-center py-12">
              <TagIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
              <p className="text-gray-600">No hymns found with this theme.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}