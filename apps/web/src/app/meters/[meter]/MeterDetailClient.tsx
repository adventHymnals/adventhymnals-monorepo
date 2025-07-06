'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MusicalNoteIcon, ArrowLeftIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import HymnFilters from '@/components/search/HymnFilters';
import { HymnalCollection } from '@advent-hymnals/shared';

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

interface MeterDetailClientProps {
  hymns: HymnData[];
  decodedMeter: string;
  hymnalReferences: HymnalCollection;
}

export default function MeterDetailClient({ hymns, decodedMeter, hymnalReferences }: MeterDetailClientProps) {
  const [filteredHymns, setFilteredHymns] = useState<HymnData[]>(hymns);
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
                href="/meters"
                className="inline-flex items-center text-primary-200 hover:text-white mb-6 transition-colors"
              >
                <ArrowLeftIcon className="h-4 w-4 mr-2" />
                Back to Meters
              </Link>
              
              <MusicalNoteIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                {decodedMeter}
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                {filteredHymns.length} of {hymns.length} hymn{hymns.length !== 1 ? 's' : ''} in this metrical pattern
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
              <p className="text-gray-600">No hymns found for this metrical pattern.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}