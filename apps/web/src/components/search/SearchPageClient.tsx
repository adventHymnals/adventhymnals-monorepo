'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MagnifyingGlassIcon, FunnelIcon } from '@heroicons/react/24/outline';
import { HymnalCollection } from '@advent-hymnals/shared';
import MultiSelect from '@/components/ui/MultiSelect';
import { getApiUrl } from '@/lib/data';

interface SearchPageClientProps {
  hymnalReferences: HymnalCollection;
}

export default function SearchPageClient({ hymnalReferences }: SearchPageClientProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedHymnals, setSelectedHymnals] = useState<string[]>([]);
  const [selectedLanguages, setSelectedLanguages] = useState<string[]>([]);
  const [selectedThemes, setSelectedThemes] = useState<string[]>([]);
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);

  // Prepare hymnal options
  const hymnalOptions = Object.values(hymnalReferences.hymnals).map(hymnal => ({
    value: hymnal.id,
    label: hymnal.abbreviation || hymnal.name
  }));

  // Language options
  const languageOptions = [
    { value: 'english', label: 'English' },
    { value: 'kiswahili', label: 'Kiswahili' },
    { value: 'dholuo', label: 'Dholuo' }
  ];

  // Theme options (you can expand this based on your data)
  const themeOptions = [
    { value: 'worship', label: 'Worship' },
    { value: 'praise', label: 'Praise' },
    { value: 'prayer', label: 'Prayer' },
    { value: 'salvation', label: 'Salvation' },
    { value: 'christmas', label: 'Christmas' },
    { value: 'easter', label: 'Easter' },
    { value: 'communion', label: 'Communion' },
    { value: 'baptism', label: 'Baptism' }
  ];

  // Perform search when query changes
  useEffect(() => {
    const performSearch = async () => {
      if (!searchQuery.trim()) {
        setSearchResults([]);
        setHasSearched(false);
        return;
      }

      setIsSearching(true);
      setHasSearched(true);

      try {
        const response = await fetch(getApiUrl(`/api/search?q=${encodeURIComponent(searchQuery)}&limit=50`));
        if (!response.ok) {
          throw new Error('Search failed');
        }
        const results = await response.json();
        setSearchResults(results);
      } catch (error) {
        console.error('Search error:', error);
        setSearchResults([]);
      } finally {
        setIsSearching(false);
      }
    };

    const debounceTimer = setTimeout(performSearch, 500);
    return () => clearTimeout(debounceTimer);
  }, [searchQuery]);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Search Interface */}
      <div className="mx-auto max-w-7xl px-6 py-6 sm:py-8 lg:py-12 lg:px-8">
        <div className="mx-auto max-w-4xl">
          {/* Main Search Bar */}
          <div className="relative mb-6 sm:mb-8">
            <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
              <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
            </div>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="block w-full rounded-lg border-0 py-3 sm:py-4 pl-10 pr-3 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 text-base sm:text-lg"
              placeholder="Search by title, number, composer, author, or theme..."
              autoFocus
            />
          </div>

          {/* Search Filters */}
          <div className="mb-6 sm:mb-8">
            <div className="flex flex-wrap gap-3 sm:gap-4 items-center">
              <div className="flex items-center">
                <FunnelIcon className="h-4 w-4 sm:h-5 sm:w-5 text-gray-400 mr-2" />
                <span className="text-xs sm:text-sm font-medium text-gray-700">Filter by:</span>
              </div>
              
              <MultiSelect
                options={hymnalOptions}
                selectedValues={selectedHymnals}
                onChange={setSelectedHymnals}
                placeholder="All Hymnals"
                className="min-w-[120px] max-w-[200px]"
              />

              <MultiSelect
                options={languageOptions}
                selectedValues={selectedLanguages}
                onChange={setSelectedLanguages}
                placeholder="All Languages"
                className="min-w-[100px] max-w-[150px]"
              />

              <div className="flex items-center gap-2">
                <MultiSelect
                  options={themeOptions}
                  selectedValues={selectedThemes}
                  onChange={setSelectedThemes}
                  placeholder="All Themes"
                  className="min-w-[100px] max-w-[150px]"
                />
                <Link
                  href="/search/topics"
                  className="text-xs sm:text-sm text-primary-600 hover:text-primary-700 font-medium whitespace-nowrap"
                >
                  Browse Topics →
                </Link>
              </div>
            </div>
          </div>

          {/* Search Results */}
          {isSearching ? (
            <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto mb-4"></div>
              <p className="text-gray-600">Searching...</p>
            </div>
          ) : hasSearched ? (
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-4 border-b border-gray-200">
                <p className="text-sm text-gray-600">
                  Found {searchResults.length} result{searchResults.length !== 1 ? 's' : ''} for "{searchQuery}"
                </p>
              </div>
              
              {searchResults.length === 0 ? (
                <div className="p-8 text-center text-gray-500">
                  <MagnifyingGlassIcon className="mx-auto h-12 w-12 text-gray-300 mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
                  <p className="text-sm">Try a different search term or check your spelling.</p>
                </div>
              ) : (
                <div className="p-4">
                  <div className="grid gap-4">
                    {searchResults.map((result) => (
                      <div key={result.hymn.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <h3 className="text-lg font-semibold text-gray-900 mb-2">
                              <Link 
                                href={`/${result.hymnal.url_slug}/${result.hymn.slug || `hymn-${result.hymn.number}-${result.hymn.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`}`}
                                className="hover:text-primary-600 transition-colors"
                              >
                                #{result.hymn.number} - {result.hymn.title}
                              </Link>
                            </h3>
                            <div className="flex items-center gap-4 text-sm text-gray-600 mb-2">
                              <span className="font-medium text-primary-600">{result.hymnal.abbreviation}</span>
                              {result.hymn.author && <span>Author: {result.hymn.author}</span>}
                              {result.hymn.composer && <span>Composer: {result.hymn.composer}</span>}
                            </div>
                            {result.hymn.first_line && (
                              <p className="text-gray-500 italic text-sm">"{result.hymn.first_line}"</p>
                            )}
                          </div>
                          <div className="ml-4 flex space-x-2">
                            <Link
                              href={`/${result.hymnal.url_slug}/${result.hymn.slug || `hymn-${result.hymn.number}-${result.hymn.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`}`}
                              className="inline-flex items-center px-3 py-1 border border-primary-300 text-sm font-medium rounded-md text-primary-700 bg-primary-50 hover:bg-primary-100 transition-colors"
                            >
                              View
                            </Link>
                            <Link
                              href={`/projection/${result.hymn.id}`}
                              className="inline-flex items-center px-3 py-1 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors"
                            >
                              Project
                            </Link>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow-sm border p-8 text-center text-gray-500">
              <MagnifyingGlassIcon className="mx-auto h-12 w-12 text-gray-300 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Start Your Search</h3>
              <p className="text-sm">
                Enter a search term above to find hymns across all collections, or use the filters to narrow your search.
              </p>
              
              {/* Show active filters */}
              {(selectedHymnals.length > 0 || selectedLanguages.length > 0 || selectedThemes.length > 0) && (
                <div className="mt-4 pt-4 border-t border-gray-200">
                  <p className="text-xs text-gray-600 mb-2">Active filters:</p>
                  <div className="flex flex-wrap gap-1 justify-center">
                    {selectedHymnals.map(id => {
                      const hymnal = hymnalOptions.find(h => h.value === id);
                      return (
                        <span key={id} className="inline-flex items-center rounded-full bg-blue-100 px-2 py-1 text-xs text-blue-800">
                          {hymnal?.label}
                        </span>
                      );
                    })}
                    {selectedLanguages.map(lang => {
                      const language = languageOptions.find(l => l.value === lang);
                      return (
                        <span key={lang} className="inline-flex items-center rounded-full bg-green-100 px-2 py-1 text-xs text-green-800">
                          {language?.label}
                        </span>
                      );
                    })}
                    {selectedThemes.map(theme => {
                      const themeOption = themeOptions.find(t => t.value === theme);
                      return (
                        <span key={theme} className="inline-flex items-center rounded-full bg-purple-100 px-2 py-1 text-xs text-purple-800">
                          {themeOption?.label}
                        </span>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Quick Search Suggestions */}
          <div className="mt-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <div className="bg-white p-4 rounded-lg border hover:shadow-md transition-shadow">
              <h4 className="font-medium text-gray-900 mb-2">Popular Searches</h4>
              <div className="space-y-1">
                <Link href="/search?q=amazing+grace" className="block text-sm text-primary-600 hover:text-primary-700">
                  Amazing Grace
                </Link>
                <Link href="/search?q=holy+holy+holy" className="block text-sm text-primary-600 hover:text-primary-700">
                  Holy, Holy, Holy
                </Link>
                <Link href="/search?q=blessed+assurance" className="block text-sm text-primary-600 hover:text-primary-700">
                  Blessed Assurance
                </Link>
              </div>
            </div>

            <div className="bg-white p-4 rounded-lg border hover:shadow-md transition-shadow">
              <h4 className="font-medium text-gray-900 mb-2">Browse by Theme</h4>
              <div className="space-y-1">
                <Link href="/search?theme=christmas" className="block text-sm text-primary-600 hover:text-primary-700">
                  Christmas Hymns
                </Link>
                <Link href="/search?theme=easter" className="block text-sm text-primary-600 hover:text-primary-700">
                  Easter Songs
                </Link>
                <Link href="/search?theme=communion" className="block text-sm text-primary-600 hover:text-primary-700">
                  Communion
                </Link>
              </div>
            </div>

            <div className="bg-white p-4 rounded-lg border hover:shadow-md transition-shadow">
              <h4 className="font-medium text-gray-900 mb-2">Quick Access</h4>
              <div className="space-y-1">
                <Link href="/seventh-day-adventist-hymnal" className="block text-sm text-primary-600 hover:text-primary-700">
                  SDA Hymnal
                </Link>
                <Link href="/christ-in-song" className="block text-sm text-primary-600 hover:text-primary-700">
                  Christ in Song
                </Link>
                <Link href="/hymnals" className="block text-sm text-primary-600 hover:text-primary-700">
                  All Collections
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}