'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MusicalNoteIcon, ArrowLeftIcon, ChartBarIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import HymnFilters from '@/components/search/HymnFilters';
import { HymnalCollection } from '@advent-hymnals/shared';

interface HymnData {
  id: string;
  number: number;
  title: string;
  composer?: string;
  hymnal: {
    id: string;
    name: string;
    url_slug: string;
    abbreviation: string;
  };
}

interface ComposerDetailClientProps {
  hymns: HymnData[];
  decodedComposer: string;
  hymnalReferences: HymnalCollection;
}

export default function ComposerDetailClient({ hymns, decodedComposer, hymnalReferences }: ComposerDetailClientProps) {
  const [filteredHymns, setFilteredHymns] = useState<HymnData[]>(hymns);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedHymnal, setSelectedHymnal] = useState('');
  const [sortBy, setSortBy] = useState<'title' | 'number'>('number');
  const [showStats, setShowStats] = useState(false);

  // Calculate hymnal breakdown statistics
  const hymnalStats = hymns.reduce((acc, hymn) => {
    const key = hymn.hymnal.id;
    if (!acc[key]) {
      acc[key] = {
        hymnal: hymn.hymnal,
        count: 0,
        hymns: []
      };
    }
    acc[key].count++;
    acc[key].hymns.push(hymn);
    return acc;
  }, {} as Record<string, { hymnal: HymnData['hymnal'], count: number, hymns: HymnData[] }>);

  const sortedHymnalStats = Object.values(hymnalStats).sort((a, b) => b.count - a.count);

  // Filter and sort hymns
  useEffect(() => {
    let filtered = hymns;

    // Filter by search term
    if (searchTerm.trim()) {
      const normalizedSearch = searchTerm.toLowerCase();
      filtered = filtered.filter(hymn =>
        hymn.title.toLowerCase().includes(normalizedSearch) ||
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
                href="/composers"
                className="inline-flex items-center text-primary-200 hover:text-white mb-6 transition-colors"
              >
                <ArrowLeftIcon className="h-4 w-4 mr-2" />
                Back to Composers
              </Link>
              
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                {decodedComposer}
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                {filteredHymns.length} of {hymns.length} hymn{hymns.length !== 1 ? 's' : ''} by this composer
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          {/* Statistics Toggle */}
          <div className="mb-6">
            <button
              onClick={() => setShowStats(!showStats)}
              className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <ChartBarIcon className="h-4 w-4 mr-2" />
              {showStats ? 'Hide' : 'Show'} Hymnal Breakdown
            </button>
          </div>

          {/* Hymnal Statistics */}
          {showStats && (
            <div className="mb-8 bg-white p-6 rounded-lg shadow-sm border">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Hymnal Breakdown</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {sortedHymnalStats.map((stat) => (
                  <div key={stat.hymnal.id} className="p-4 bg-gray-50 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <h4 className="font-medium text-gray-900">{stat.hymnal.abbreviation}</h4>
                      <span className="text-sm font-semibold text-primary-600">{stat.count}</span>
                    </div>
                    <p className="text-sm text-gray-600">{stat.hymnal.name}</p>
                    <div className="mt-2 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-primary-600 h-2 rounded-full"
                        style={{ width: `${(stat.count / hymns.length) * 100}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

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
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {filteredHymns.length === 0 && hymns.length > 0 && (
            <div className="text-center py-12">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns match your filters</h3>
              <p className="text-gray-600">Try adjusting your search terms or filters.</p>
            </div>
          )}

          {hymns.length === 0 && (
            <div className="text-center py-12">
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
              <p className="text-gray-600">No hymns found by this composer.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}