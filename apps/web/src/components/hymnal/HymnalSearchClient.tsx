'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { formatNumber } from '@advent-hymnals/shared';

// Helper function to normalize text for search
function normalizeSearchText(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\w\s]/g, '') // Remove all punctuation
    .replace(/\s+/g, ' ') // Normalize whitespace
    .trim();
}

interface HymnalSearchClientProps {
  hymns: unknown[];
  hymnalSlug: string;
  hymnalName: string;
  total: number;
}

export default function HymnalSearchClient({ 
  hymns, 
  hymnalSlug, 
  hymnalName, 
  total 
}: HymnalSearchClientProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [filteredHymns, setFilteredHymns] = useState(hymns);

  useEffect(() => {
    if (!searchTerm.trim()) {
      setFilteredHymns(hymns);
      return;
    }
    
    const normalizedSearchTerm = normalizeSearchText(searchTerm);
    
    const filtered = hymns.filter((hymn: unknown) => {
      const h = hymn as { title?: string; author?: string; number?: number; composer?: string; verses?: { text?: string }[] };
      // Normalize all searchable text
      const normalizedTitle = normalizeSearchText(h.title || '');
      const normalizedAuthor = normalizeSearchText(h.author || '');
      const normalizedComposer = normalizeSearchText(h.composer || '');
      const normalizedFirstVerse = normalizeSearchText(h.verses?.[0]?.text || '');
      const hymnNumber = h.number?.toString() || '';
      
      // Check if search term matches any field
      return normalizedTitle.includes(normalizedSearchTerm) ||
             normalizedAuthor.includes(normalizedSearchTerm) ||
             normalizedComposer.includes(normalizedSearchTerm) ||
             normalizedFirstVerse.includes(normalizedSearchTerm) ||
             hymnNumber.includes(searchTerm.trim());
    });
    
    setFilteredHymns(filtered);
  }, [searchTerm, hymns]);

  return (
    <>
      {/* Search */}
      <div className="mt-8 mx-auto max-w-md">
        <div className="relative">
          <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder={`Search ${hymnalName}...`}
            className="w-full pl-10 pr-4 py-3 text-lg text-gray-900 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent shadow-sm placeholder-gray-500"
          />
        </div>
      </div>

      {/* Results Section */}
      <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
        {/* Controls */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-8">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">
              {searchTerm ? (
                <>Showing {formatNumber(filteredHymns.length)} of {formatNumber(total)} hymns</>
              ) : (
                <>Hymns ({formatNumber(total)})</>
              )}
            </h2>
            <p className="mt-1 text-gray-600">
              {searchTerm ? `Results for "${searchTerm}"` : 'All hymns in this collection'}
            </p>
          </div>
        </div>

        {/* Hymns Grid */}
        {filteredHymns.length === 0 && searchTerm ? (
          <div className="text-center py-12">
            <MagnifyingGlassIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
            <p className="text-gray-600">Try adjusting your search terms.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {filteredHymns.map((hymn) => (
            <Link
              key={hymn.id}
              href={`/${hymnalSlug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
              className="hymnal-card p-6 hover:scale-105 transform transition-all duration-200"
            >
              <div className="flex items-center justify-between mb-4">
                <span className="hymn-number">
                  #{hymn.number}
                </span>
                {hymn.metadata?.themes && hymn.metadata.themes.length > 0 && (
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                    {hymn.metadata.themes[0]}
                  </span>
                )}
              </div>
              
              <h3 className="hymn-title mb-2">
                {hymn.title}
              </h3>
              
              {(hymn.author || hymn.composer) && (
                <div className="text-sm text-gray-600 mb-3">
                  {hymn.author && <div>By {hymn.author}</div>}
                  {hymn.composer && <div>Music: {hymn.composer}</div>}
                </div>
              )}
              
              {hymn.verses[0] && hymn.verses[0].text && (
                <p className="text-sm text-gray-700 line-clamp-2">
                  {hymn.verses[0].text.split('\n')[0]}
                </p>
              )}
            </Link>
          ))}
          </div>
        )}
      </div>
    </>
  );
}