'use client';

import { useState, useMemo } from 'react';
import Link from 'next/link';
import { BookOpenIcon, UserIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { HymnalReference } from '@advent-hymnals/shared';

interface HymnalsFilterProps {
  hymnals: HymnalReference[];
}

export default function HymnalsFilter({ hymnals }: HymnalsFilterProps) {
  const [selectedLanguage, setSelectedLanguage] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Get unique languages from hymnals
  const languages = useMemo(() => {
    const uniqueLanguages = Array.from(new Set(hymnals.map(h => h.language_name)));
    return uniqueLanguages.sort();
  }, [hymnals]);

  // Filter hymnals based on selected language and search query
  const filteredHymnals = useMemo(() => {
    let filtered = hymnals;
    
    // Filter by language
    if (selectedLanguage !== 'all') {
      filtered = filtered.filter(h => h.language_name === selectedLanguage);
    }
    
    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(h => 
        h.name.toLowerCase().includes(query) ||
        h.site_name?.toLowerCase().includes(query) ||
        h.abbreviation.toLowerCase().includes(query) ||
        h.compiler?.toLowerCase().includes(query) ||
        h.year.toString().includes(query)
      );
    }
    
    return filtered.sort((a, b) => b.year - a.year);
  }, [hymnals, selectedLanguage, searchQuery]);

  return (
    <div>
      {/* Search Input */}
      <div className="mb-6">
        <div className="relative max-w-md">
          <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search hymnals by name, year, compiler..."
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
          />
        </div>
      </div>

      {/* Filter Controls */}
      <div className="mb-8">
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setSelectedLanguage('all')}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              selectedLanguage === 'all'
                ? 'bg-primary-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            All Languages ({hymnals.length})
          </button>
          {languages.map((language) => {
            const count = hymnals.filter(h => h.language_name === language).length;
            return (
              <button
                key={language}
                onClick={() => setSelectedLanguage(language)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  selectedLanguage === language
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {language} ({count})
              </button>
            );
          })}
        </div>
      </div>

      {/* Results Count */}
      <div className="mb-6">
        <p className="text-gray-600">
          Showing {filteredHymnals.length} of {hymnals.length} collections
          {selectedLanguage !== 'all' && ` in ${selectedLanguage}`}
        </p>
      </div>

      {/* Hymnal Grid */}
      <div className="grid grid-cols-1 gap-8 lg:grid-cols-2 xl:grid-cols-3">
        {filteredHymnals.map((hymnal) => (
          <Link
            key={hymnal.id}
            href={`/${hymnal.url_slug}`}
            className="group relative overflow-hidden rounded-xl bg-white p-6 shadow-sm hover:shadow-lg transition-all duration-300 hover:scale-105 flex flex-col h-full"
          >
            {/* Header */}
            <div className="flex items-start justify-between mb-4">
              <div className="flex-shrink-0">
                <div className="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
                  <BookOpenIcon className="h-6 w-6 text-primary-600" />
                </div>
              </div>
              <div className="text-right">
                <div className="text-2xl font-bold text-gray-900">{hymnal.year}</div>
                <div className="text-sm text-gray-500">{hymnal.total_songs} hymns</div>
              </div>
            </div>

            {/* Content */}
            <div className="mb-4 flex-grow">
              <h3 className="text-lg font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                {hymnal.name}
              </h3>
              <p className="text-sm text-gray-600 mt-1">{hymnal.abbreviation}</p>
              
              {/* Metadata */}
              <div className="space-y-2 mt-4">
                {hymnal.compiler && (
                  <div className="flex items-center text-sm text-gray-600">
                    <UserIcon className="h-4 w-4 mr-2 flex-shrink-0" />
                    <span>{hymnal.compiler}</span>
                  </div>
                )}
              </div>

              {/* Description */}
              <div className="text-sm text-gray-700 mt-4">
                A collection of {hymnal.total_songs} hymns from {hymnal.year}.
              </div>
            </div>

            {/* Footer - Bottom aligned tags */}
            <div className="mt-auto pt-4">
              <div className="flex items-center justify-between">
                <div className="flex flex-wrap gap-2">
                  {hymnal.total_songs > 600 && (
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      Large Collection
                    </span>
                  )}
                  {hymnal.year < 1900 && (
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
                      Historical
                    </span>
                  )}
                </div>
                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                  {hymnal.language_name}
                </span>
              </div>
            </div>

            {/* Hover overlay */}
            <div className="absolute inset-0 bg-primary-50 opacity-0 group-hover:opacity-20 transition-opacity" />
          </Link>
        ))}
      </div>

      {/* No results */}
      {filteredHymnals.length === 0 && (
        <div className="text-center py-12">
          <BookOpenIcon className="mx-auto h-12 w-12 text-gray-300" />
          <h3 className="mt-4 text-lg font-medium text-gray-900">No hymnals found</h3>
          <p className="mt-2 text-gray-500">
            No hymnals match your current filter criteria.
          </p>
        </div>
      )}
    </div>
  );
}