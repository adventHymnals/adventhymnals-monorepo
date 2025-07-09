'use client';

import { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { notFound } from 'next/navigation';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences, searchHymns } from '@/lib/data';
import { HymnalCollection } from '@advent-hymnals/shared';

interface HymnalSearchPageProps {
  params: {
    hymnal: string;
  };
}

export default function HymnalSearchPage({ params }: HymnalSearchPageProps) {
  const searchParams = useSearchParams();
  const query = searchParams.get('q') || '';
  
  const [hymnalReferences, setHymnalReferences] = useState<HymnalCollection | undefined>(undefined);
  const [results, setResults] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [hymnalRef, setHymnalRef] = useState<any>(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        const references = await loadHymnalReferences();
        setHymnalReferences(references);
        
        const foundHymnalRef = Object.values(references.hymnals).find(
          (h) => h.url_slug === params.hymnal
        );
        
        if (!foundHymnalRef) {
          notFound();
          return;
        }
        
        setHymnalRef(foundHymnalRef);
        
        // Perform search if there's a query
        if (query.trim()) {
          setSearching(true);
          try {
            const searchResults = await searchHymns({
              query: query.trim(),
              hymnal: foundHymnalRef.id,
              limit: 50
            });
            setResults(searchResults);
          } catch (error) {
            console.error('Search failed:', error);
            setResults([]);
          } finally {
            setSearching(false);
          }
        }
      } catch (error) {
        console.error('Failed to load data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [params.hymnal, query]);

  if (loading) {
    return (
      <Layout>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading search...</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (!hymnalRef) {
    notFound();
  }

  return (
    <Layout hymnalReferences={hymnalReferences}>
      {/* Header */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-700">
        <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
          <div className="text-center">
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
              Search {hymnalRef.site_name}
            </h1>
            <p className="mt-6 text-lg leading-8 text-primary-100">
              {query ? `Results for "${query}"` : 'Search through this hymnal collection'}
            </p>
          </div>
        </div>
      </div>

      {/* Results */}
      <div className="min-h-screen bg-gray-50">
        <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
          {searching ? (
            <div className="flex items-center justify-center py-12">
              <div className="text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-4"></div>
                <p className="text-gray-600">Searching...</p>
              </div>
            </div>
          ) : query ? (
            <div>
              <div className="mb-6">
                <p className="text-gray-600">
                  Found {results.length} result{results.length !== 1 ? 's' : ''} for "{query}"
                </p>
              </div>
              
              {results.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-gray-500">No hymns found matching your search.</p>
                  <p className="text-gray-400 mt-2">Try a different search term.</p>
                </div>
              ) : (
                <div className="grid gap-4">
                  {results.map((result) => (
                    <div key={result.hymn.id} className="bg-white rounded-lg shadow-sm border p-6 hover:shadow-md transition-shadow">
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <h3 className="text-lg font-semibold text-gray-900 mb-2">
                            <a 
                              href={`/${params.hymnal}/${result.hymn.slug || `hymn-${result.hymn.number}-${result.hymn.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`}`}
                              className="hover:text-primary-600 transition-colors"
                            >
                              #{result.hymn.number} - {result.hymn.title}
                            </a>
                          </h3>
                          {result.hymn.author && (
                            <p className="text-gray-600 mb-2">Author: {result.hymn.author}</p>
                          )}
                          {result.hymn.composer && (
                            <p className="text-gray-600 mb-2">Composer: {result.hymn.composer}</p>
                          )}
                          {result.hymn.first_line && (
                            <p className="text-gray-500 italic">"{result.hymn.first_line}"</p>
                          )}
                        </div>
                        <div className="ml-4 flex space-x-2">
                          <a
                            href={`/${params.hymnal}/${result.hymn.slug || `hymn-${result.hymn.number}-${result.hymn.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`}`}
                            className="inline-flex items-center px-3 py-1 border border-primary-300 text-sm font-medium rounded-md text-primary-700 bg-primary-50 hover:bg-primary-100 transition-colors"
                          >
                            View
                          </a>
                          <a
                            href={`/projection/${result.hymn.id}`}
                            className="inline-flex items-center px-3 py-1 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors"
                          >
                            Project
                          </a>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500">Enter a search term to find hymns in this collection.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}