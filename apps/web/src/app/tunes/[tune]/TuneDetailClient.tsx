'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MusicalNoteIcon, ArrowLeftIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import HymnFilters from '@/components/search/HymnFilters';
import { HymnalCollection } from '@advent-hymnals/shared';
import { loadHymnalReferences, loadHymnalHymns } from '@/lib/data';

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

interface TuneDetailClientProps {
  tune: string;
  params: {
    tune: string;
  };
}

export default function TuneDetailClient({ tune, params }: TuneDetailClientProps) {
  const [hymns, setHymns] = useState<HymnData[]>([]);
  const [filteredHymns, setFilteredHymns] = useState<HymnData[]>([]);
  const [hymnalReferences, setHymnalReferences] = useState<HymnalCollection | undefined>(undefined);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        const references = await loadHymnalReferences();
        setHymnalReferences(references);
        
        const hymnsList: HymnData[] = [];
        
        // Load hymns from all hymnals to find hymns with this tune
        for (const hymnalRef of Object.values(references.hymnals)) {
          try {
            const { hymns: hymnalHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
            hymnalHymns.forEach((hymn: any) => {
              if (hymn.tune === tune) {
                hymnsList.push({
                  id: hymn.id,
                  number: hymn.number,
                  title: hymn.title,
                  author: hymn.author,
                  hymnal: {
                    id: hymnalRef.id,
                    name: hymnalRef.name,
                    url_slug: hymnalRef.url_slug,
                    abbreviation: hymnalRef.abbreviation
                  }
                });
              }
            });
          } catch (error) {
            console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
          }
        }
        
        setHymns(hymnsList);
        setFilteredHymns(hymnsList);
        
      } catch (err) {
        console.error('Failed to load tune data:', err);
        setError('Failed to load tune data');
      } finally {
        setLoading(false);
      }
    };
    
    loadData();
  }, [tune]);
  
  if (loading) {
    return (
      <Layout>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading tune details...</p>
          </div>
        </div>
      </Layout>
    );
  }
  
  if (error || hymns.length === 0) {
    return (
      <Layout hymnalReferences={hymnalReferences}>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border p-8 text-center">
            <h1 className="text-xl font-semibold text-gray-900 mb-3">
              Tune Not Found
            </h1>
            <p className="text-gray-600 mb-6">
              No hymns found with the tune "{tune}".
            </p>
            <div className="space-y-3">
              <Link
                href="/tunes"
                className="block w-full bg-primary-600 text-white py-2 px-4 rounded-lg hover:bg-primary-700 transition-colors"
              >
                Back to Tunes
              </Link>
              <Link
                href="/"
                className="block w-full bg-gray-100 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-200 transition-colors"
              >
                Back to Home
              </Link>
            </div>
          </div>
        </div>
      </Layout>
    );
  }
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedHymnal, setSelectedHymnal] = useState('');
  const [sortBy, setSortBy] = useState<'title' | 'number'>('number');

  // Filter and sort hymns
  useEffect(() => {
    let filtered = hymns;

    // Filter by search term
    if (searchTerm.trim()) {
      const normalizedSearch = searchTerm.toLowerCase();
      filtered = filtered.filter(hymn =>
        hymn.title.toLowerCase().includes(normalizedSearch) ||
        hymn.author?.toLowerCase().includes(normalizedSearch) ||
        hymn.hymnal.abbreviation.toLowerCase().includes(normalizedSearch) ||
        hymn.number.toString().includes(normalizedSearch)
      );
    }

    // Filter by hymnal
    if (selectedHymnal) {
      filtered = filtered.filter(hymn => hymn.hymnal.id === selectedHymnal);
    }

    // Sort
    filtered.sort((a, b) => {
      if (sortBy === 'title') {
        return a.title.localeCompare(b.title);
      } else {
        // Sort by number, but group by hymnal first
        if (a.hymnal.id !== b.hymnal.id) {
          return a.hymnal.abbreviation.localeCompare(b.hymnal.abbreviation);
        }
        return a.number - b.number;
      }
    });

    setFilteredHymns(filtered);
  }, [hymns, searchTerm, selectedHymnal, sortBy]);

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <Link
                href="/tunes"
                className="inline-flex items-center text-primary-200 hover:text-white mb-6 transition-colors"
              >
                <ArrowLeftIcon className="h-4 w-4 mr-2" />
                Back to Tunes
              </Link>
              
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                {tune}
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                {filteredHymns.length} of {hymns.length} hymn{hymns.length !== 1 ? 's' : ''} using this tune
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <HymnFilters
            searchTerm={searchTerm}
            onSearchChange={setSearchTerm}
            selectedHymnal={selectedHymnal}
            onHymnalChange={setSelectedHymnal}
            sortBy={sortBy}
            onSortChange={setSortBy}
            hymnalReferences={hymnalReferences}
          />

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {filteredHymns.map((hymn) => (
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

          {filteredHymns.length === 0 && hymns.length > 0 && (
            <div className="text-center py-12 col-span-full">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns match your filters</h3>
              <p className="text-gray-600">Try adjusting your search terms or filters.</p>
            </div>
          )}

          {hymns.length === 0 && (
            <div className="text-center py-12">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
              <p className="text-gray-600">No hymns found for this tune.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}