'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MagnifyingGlassIcon, MusicalNoteIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

interface TuneData {
  tune: string;
  count: number;
  hymns: Array<{
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
  }>;
}

export default function TunesPage() {
  const [tunes, setTunes] = useState<TuneData[]>([]);
  const [filteredTunes, setFilteredTunes] = useState<TuneData[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [hymnalReferences, setHymnalReferences] = useState<any>(null);
  const [sortBy, setSortBy] = useState<'count' | 'alphabetical'>('count');

  useEffect(() => {
    const loadData = async () => {
      try {
        const [tunesResponse, references] = await Promise.all([
          fetch('/api/tunes'),
          loadHymnalReferences()
        ]);
        
        if (!tunesResponse.ok) {
          throw new Error('Failed to fetch tunes');
        }
        
        const tunesData = await tunesResponse.json();
        setTunes(tunesData);
        setFilteredTunes(tunesData);
        setHymnalReferences(references);
      } catch (error) {
        console.error('Failed to load tunes:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  useEffect(() => {
    let filtered = tunes;

    // Filter by search term
    if (searchTerm.trim()) {
      filtered = tunes.filter(tuneData => {
        const normalizedTune = tuneData.tune.replace(/[.,\s\-']+/g, '').toLowerCase();
        const normalizedSearch = searchTerm.replace(/[.,\s\-']+/g, '').toLowerCase();
        return normalizedTune.includes(normalizedSearch);
      });
    }

    // Sort
    filtered.sort((a, b) => {
      if (sortBy === 'count') {
        return b.count - a.count; // Descending by count
      } else {
        return a.tune.localeCompare(b.tune); // Alphabetical
      }
    });

    setFilteredTunes(filtered);
  }, [searchTerm, tunes, sortBy]);

  if (loading) {
    return (
      <Layout hymnalReferences={hymnalReferences}>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading tunes...</p>
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
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                Hymn Tunes
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Explore hymns organized by their musical tunes and melodies
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          {/* Search and Sort */}
          <div className="mb-8">
            <div className="flex flex-col sm:flex-row gap-4 items-center justify-center">
              <div className="relative max-w-md flex-1">
                <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search hymn tunes..."
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-gray-900 bg-white"
                />
              </div>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as 'count' | 'alphabetical')}
                className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-gray-900 bg-white"
              >
                <option value="count">Sort by Hymn Count</option>
                <option value="alphabetical">Sort Alphabetically</option>
              </select>
            </div>
          </div>

          {/* Results Summary */}
          <div className="mb-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900">
              {searchTerm ? `Found ${filteredTunes.length} tunes` : `${tunes.length} Hymn Tunes`}
            </h2>
            {searchTerm && (
              <p className="mt-2 text-gray-600">Results for &quot;{searchTerm}&quot;</p>
            )}
          </div>

          {/* Tunes Grid */}
          {filteredTunes.length === 0 ? (
            <div className="text-center py-12">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No tunes found</h3>
              <p className="text-gray-600">Try adjusting your search terms.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {filteredTunes.map((tuneData) => (
                <Link
                  key={tuneData.tune}
                  href={`/tunes/${encodeURIComponent(tuneData.tune)}`}
                  className="block p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow border border-gray-200 hover:border-primary-300"
                >
                  <div className="text-center">
                    <div className="text-lg font-bold text-primary-600 mb-2">
                      {tuneData.tune}
                    </div>
                    <div className="text-sm text-gray-600 mb-4">
                      {tuneData.count} hymn{tuneData.count !== 1 ? 's' : ''}
                    </div>
                    
                    {/* Sample hymns */}
                    <div className="space-y-1">
                      {tuneData.hymns.slice(0, 3).map((hymn) => (
                        <div key={hymn.id} className="text-xs text-gray-500">
                          <span className="font-medium text-primary-600">
                            {hymn.hymnal.abbreviation} #{hymn.number}
                          </span>{' '}
                          {hymn.title}
                        </div>
                      ))}
                      {tuneData.count > 3 && (
                        <div className="text-xs text-gray-400">
                          +{tuneData.count - 3} more
                        </div>
                      )}
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}