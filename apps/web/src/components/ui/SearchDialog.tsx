'use client';

import { useState, useEffect, useCallback } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { Fragment } from 'react';
import { MagnifyingGlassIcon, XMarkIcon } from '@heroicons/react/24/outline';

interface SearchResult {
  id: string;
  number: number;
  title: string;
  author?: string;
  composer?: string;
  firstLine?: string;
}

interface SearchDialogProps {
  isOpen: boolean;
  onClose: () => void;
  hymnalId: string;
  hymnalName: string;
  placeholder?: string;
}

export default function SearchDialog({ 
  isOpen, 
  onClose, 
  hymnalId, 
  hymnalName, 
  placeholder 
}: SearchDialogProps) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);

  // Mock search function - in real implementation, this would call your search API
  const performSearch = useCallback(async (searchQuery: string) => {
    if (!searchQuery.trim()) {
      setResults([]);
      return;
    }

    setLoading(true);
    
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 300));
    
    // Mock search results - replace with actual API call
    const mockResults: SearchResult[] = [
      {
        id: `${hymnalId}-001`,
        number: 1,
        title: 'Holy, Holy, Holy',
        author: 'Reginald Heber',
        composer: 'John B. Dykes',
        firstLine: 'Holy, holy, holy! Lord God Almighty!'
      },
      {
        id: `${hymnalId}-002`,
        number: 2,
        title: 'Come, Thou Almighty King',
        author: 'Charles Wesley',
        composer: 'Felice de Giardini',
        firstLine: 'Come, Thou Almighty King, help us Thy name to sing'
      },
      {
        id: `${hymnalId}-003`,
        number: 3,
        title: 'Praise to the Lord, the Almighty',
        author: 'Joachim Neander',
        composer: 'Unknown',
        firstLine: 'Praise to the Lord, the Almighty, the King of creation!'
      }
    ].filter(result => 
      result.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      result.author?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      result.number.toString().includes(searchQuery)
    );

    setResults(mockResults);
    setLoading(false);
  }, [hymnalId]);

  useEffect(() => {
    const debounceTimer = setTimeout(() => {
      if (query) {
        performSearch(query);
      } else {
        setResults([]);
      }
    }, 300);

    return () => clearTimeout(debounceTimer);
  }, [query, performSearch]);

  const handleClose = () => {
    setQuery('');
    setResults([]);
    onClose();
  };

  const handleResultClick = (result: SearchResult) => {
    // Generate proper hymnal URL slug from hymnalId
    const hymnalSlugMap: { [key: string]: string } = {
      'SDAH': 'seventh-day-adventist-hymnal',
      'CIS': 'christ-in-song',
      'CH1941': 'church-hymnal',
      'HT1886': 'the-seventh-day-adventist-hymn-and-tune-book-hymns-and-tunes',
      'MH1843': 'millenial-harp',
      'HGPP': 'hymns-for-god-s-peculiar-people',
      'HSAB': 'hymns-for-second-advent-believers-who-observe-the-sabbath-of-the-lord',
      'HT1869': 'hymns-and-tunes-1869',
      'HT1876': 'hymns-and-tunes-1876',
      'NZK': 'nyimbo-za-kristo',
      'WDL': 'wende-duto-luo',
      'CM': 'campus-melodies',
      'HPF': 'hymns-for-the-poor-of-the-flock'
    };
    
    const hymnalSlug = hymnalSlugMap[hymnalId] || hymnalId.toLowerCase();
    const titleSlug = result.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-');
    window.location.href = `/${hymnalSlug}/hymn-${result.number}-${titleSlug}`;
  };

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={handleClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-25" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-start justify-center p-4 text-center">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all mt-16">
                <div className="flex items-center justify-between mb-4">
                  <Dialog.Title
                    as="h3"
                    className="text-lg font-medium leading-6 text-gray-900"
                  >
                    Search {hymnalName}
                  </Dialog.Title>
                  <button
                    type="button"
                    className="rounded-md p-1 text-gray-400 hover:text-gray-500"
                    onClick={handleClose}
                  >
                    <XMarkIcon className="h-5 w-5" />
                  </button>
                </div>

                {/* Search Input */}
                <div className="relative mb-4">
                  <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <input
                    type="text"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder={placeholder || `Search ${hymnalName}...`}
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    autoFocus
                  />
                </div>

                {/* Search Results */}
                <div className="max-h-64 overflow-y-auto">
                  {loading && (
                    <div className="text-center py-4 text-gray-500">
                      Searching...
                    </div>
                  )}

                  {!loading && query && results.length === 0 && (
                    <div className="text-center py-4 text-gray-500">
                      No results found for &quot;{query}&quot;
                    </div>
                  )}

                  {!loading && results.length > 0 && (
                    <div className="space-y-2">
                      {results.map((result) => (
                        <button
                          key={result.id}
                          onClick={() => handleResultClick(result)}
                          className="w-full text-left p-3 rounded-lg hover:bg-gray-50 transition-colors"
                        >
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <div className="flex items-center space-x-2 mb-1">
                                <span className="text-sm font-medium text-primary-600">
                                  #{result.number}
                                </span>
                                <h4 className="text-sm font-medium text-gray-900">
                                  {result.title}
                                </h4>
                              </div>
                              {(result.author || result.composer) && (
                                <div className="text-xs text-gray-600 mb-1">
                                  {result.author && <span>By {result.author}</span>}
                                  {result.author && result.composer && <span> • </span>}
                                  {result.composer && <span>Music: {result.composer}</span>}
                                </div>
                              )}
                              {result.firstLine && (
                                <p className="text-xs text-gray-500 line-clamp-1">
                                  {result.firstLine}
                                </p>
                              )}
                            </div>
                          </div>
                        </button>
                      ))}
                    </div>
                  )}

                  {!query && (
                    <div className="text-center py-8 text-gray-500">
                      <MagnifyingGlassIcon className="mx-auto h-8 w-8 mb-2 text-gray-300" />
                      <p>Start typing to search hymns...</p>
                    </div>
                  )}
                </div>

                {/* Footer */}
                <div className="mt-4 pt-4 border-t border-gray-200 text-center">
                  <button
                    onClick={() => {
                      const hymnalSlugMap: { [key: string]: string } = {
                        'SDAH': 'seventh-day-adventist-hymnal',
                        'CIS': 'christ-in-song',
                        'CH1941': 'church-hymnal',
                        'HT1886': 'the-seventh-day-adventist-hymn-and-tune-book-hymns-and-tunes',
                        'MH1843': 'millenial-harp',
                        'HGPP': 'hymns-for-god-s-peculiar-people',
                        'HSAB': 'hymns-for-second-advent-believers-who-observe-the-sabbath-of-the-lord',
                        'HT1869': 'hymns-and-tunes-1869',
                        'HT1876': 'hymns-and-tunes-1876',
                        'NZK': 'nyimbo-za-kristo',
                        'WDL': 'wende-duto-luo',
                        'CM': 'campus-melodies',
                        'HPF': 'hymns-for-the-poor-of-the-flock'
                      };
                      const hymnalSlug = hymnalSlugMap[hymnalId] || hymnalId.toLowerCase();
                      window.location.href = `/${hymnalSlug}/search${query ? `?q=${encodeURIComponent(query)}` : ''}`;
                    }}
                    className="text-sm text-primary-600 hover:text-primary-700"
                  >
                    Advanced search →
                  </button>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
}