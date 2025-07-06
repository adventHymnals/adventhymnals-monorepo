'use client';

import { useState, useEffect, useRef } from 'react';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';

interface SearchResult {
  id: string;
  title: string;
  hymnal: string;
  number: number;
  url: string;
}

interface SearchDropdownProps {
  isOpen: boolean;
  onClose: () => void;
  searchQuery: string;
  onQueryChange: (query: string) => void;
  placeholder?: string;
}

export default function SearchDropdown({ 
  isOpen, 
  onClose, 
  searchQuery, 
  onQueryChange, 
  placeholder = "Search hymns..." 
}: SearchDropdownProps) {
  // Prevent unused variable warnings
  void onQueryChange;
  void placeholder;
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Real search function using the search API
  const performSearch = async (query: string) => {
    if (!query.trim()) {
      setResults([]);
      return;
    }

    setLoading(true);
    
    try {
      const response = await fetch(`/api/search?q=${encodeURIComponent(query)}&limit=5`);
      if (!response.ok) {
        throw new Error('Search failed');
      }
      
      const searchResults = await response.json();
      
      // Transform the API response to match our SearchResult interface
      const transformedResults: SearchResult[] = searchResults.map((result: { 
        hymn: { 
          id: string; 
          number: number; 
          title: string 
        }; 
        hymnal: { 
          abbreviation: string; 
          url_slug: string 
        } 
      }) => ({
        id: result.hymn.id,
        title: result.hymn.title,
        hymnal: result.hymnal.abbreviation,
        number: result.hymn.number,
        url: `/${result.hymnal.url_slug}/hymn-${result.hymn.number}-${result.hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`
      }));
      
      setResults(transformedResults);
    } catch (error) {
      console.error('Search error:', error);
      setResults([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const debounceTimer = setTimeout(() => {
      if (searchQuery && isOpen) {
        performSearch(searchQuery);
      } else {
        setResults([]);
      }
    }, 300);

    return () => clearTimeout(debounceTimer);
  }, [searchQuery, isOpen]);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      return () => document.removeEventListener('mousedown', handleClickOutside);
    }
  }, [isOpen, onClose]);

  const handleResultClick = (result: SearchResult) => {
    window.location.href = result.url;
    onClose();
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      window.location.href = `/search?q=${encodeURIComponent(searchQuery.trim())}`;
    }
  };

  if (!isOpen) return null;

  return (
    <div 
      ref={dropdownRef}
      className="absolute top-full left-0 right-0 mt-2 bg-white rounded-lg shadow-lg border border-gray-200 z-50 max-h-80 overflow-y-auto"
    >
      <div className="p-4">
        {/* Search Results */}
        {loading && (
          <div className="text-center py-4 text-gray-500">
            <div className="animate-spin h-5 w-5 mx-auto border-2 border-primary-500 border-t-transparent rounded-full"></div>
            <p className="mt-2 text-sm">Searching...</p>
          </div>
        )}

        {!loading && searchQuery && results.length === 0 && (
          <div className="text-center py-4 text-gray-500">
            <p className="text-sm">No results found for &quot;{searchQuery}&quot;</p>
            <button
              onClick={handleSearchSubmit}
              className="mt-2 text-sm text-primary-600 hover:text-primary-700 font-medium"
            >
              Search all hymns →
            </button>
          </div>
        )}

        {!loading && results.length > 0 && (
          <div className="space-y-1">
            <div className="text-xs text-gray-500 mb-2">
              Found {results.length} result{results.length !== 1 ? 's' : ''}
            </div>
            {results.map((result) => (
              <button
                key={result.id}
                onClick={() => handleResultClick(result)}
                className="w-full text-left p-2 rounded hover:bg-gray-50 transition-colors"
              >
                <div className="flex items-center justify-between">
                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm font-medium text-gray-900 truncate">
                      {result.title}
                    </h4>
                    <div className="text-xs text-gray-500 mt-0.5">
                      {result.hymnal} #{result.number}
                    </div>
                  </div>
                  <MagnifyingGlassIcon className="h-4 w-4 text-gray-400 ml-2 flex-shrink-0" />
                </div>
              </button>
            ))}
            <div className="border-t border-gray-200 pt-2 mt-2">
              <button
                onClick={handleSearchSubmit}
                className="w-full text-left p-2 rounded hover:bg-gray-50 transition-colors"
              >
                <div className="flex items-center justify-between">
                  <span className="text-sm text-primary-600 font-medium">
                    Search all hymns for &quot;{searchQuery}&quot;
                  </span>
                  <span className="text-xs text-gray-400">→</span>
                </div>
              </button>
            </div>
          </div>
        )}

        {!searchQuery && (
          <div className="text-center py-8 text-gray-500">
            <MagnifyingGlassIcon className="mx-auto h-8 w-8 mb-2 text-gray-300" />
            <p className="text-sm">Start typing to search hymns...</p>
          </div>
        )}
      </div>
    </div>
  );
}