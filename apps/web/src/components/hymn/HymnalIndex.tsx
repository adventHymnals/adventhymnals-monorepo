'use client';

import { useState, useMemo } from 'react';
import Link from 'next/link';
import { MagnifyingGlassIcon, ListBulletIcon } from '@heroicons/react/24/outline';

interface HymnIndexItem {
  id: string;
  number: number;
  title: string;
  author?: string;
}

interface HymnalIndexProps {
  hymns: HymnIndexItem[];
  currentHymnNumber: number;
  hymnalSlug: string;
}

export default function HymnalIndex({ hymns, currentHymnNumber, hymnalSlug }: HymnalIndexProps) {
  const [searchTerm, setSearchTerm] = useState('');

  // Filter hymns based on search term
  const filteredHymns = useMemo(() => {
    if (!searchTerm.trim()) {
      return hymns.slice(0, 20); // Show first 20 when no search
    }

    const term = searchTerm.toLowerCase();
    const filtered = hymns.filter((hymn) => {
      // Search by number (exact or partial match)
      if (hymn.number.toString().includes(term)) {
        return true;
      }
      
      // Search by title
      if (hymn.title.toLowerCase().includes(term)) {
        return true;
      }
      
      // Search by author
      if (hymn.author && hymn.author.toLowerCase().includes(term)) {
        return true;
      }
      
      return false;
    });

    // Limit results to 50 for performance
    return filtered.slice(0, 50);
  }, [hymns, searchTerm]);

  const generateHymnSlug = (hymn: HymnIndexItem) => {
    return `hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`;
  };

  return (
    <div className="bg-white rounded-xl shadow-sm border p-6 mb-6">
      <div className="flex items-center mb-4">
        <ListBulletIcon className="h-5 w-5 text-primary-600 mr-2" />
        <h3 className="text-lg font-semibold text-gray-900">Hymnal Index</h3>
      </div>
      
      {/* Search Input */}
      <div className="relative mb-4">
        <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type="text"
          placeholder="Search hymns..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
        />
      </div>

      {/* Results info */}
      {searchTerm.trim() && (
        <div className="text-xs text-gray-500 mb-2">
          {filteredHymns.length === 0 
            ? 'No hymns found' 
            : `${filteredHymns.length} hymn${filteredHymns.length === 1 ? '' : 's'} found`
          }
        </div>
      )}

      {/* Hymn List */}
      <div className="max-h-64 overflow-y-auto custom-scrollbar space-y-1">
        {filteredHymns.length === 0 && searchTerm.trim() ? (
          <div className="text-center py-4 text-gray-500 text-sm">
            No hymns match your search.
          </div>
        ) : (
          filteredHymns.map((indexHymn) => (
            <Link
              key={indexHymn.id}
              href={`/${hymnalSlug}/${generateHymnSlug(indexHymn)}`}
              className={`block p-2 rounded-lg hover:bg-gray-50 transition-colors ${
                indexHymn.number === currentHymnNumber ? 'bg-primary-50 border border-primary-200' : ''
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-gray-900 truncate">
                    <span className="text-primary-600 mr-2">#{indexHymn.number}</span>
                    {/* Highlight search term in title */}
                    {searchTerm.trim() ? (
                      <span dangerouslySetInnerHTML={{ 
                        __html: indexHymn.title.replace(
                          new RegExp(`(${searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi'),
                          '<mark class="bg-yellow-200">$1</mark>'
                        )
                      }} />
                    ) : (
                      indexHymn.title
                    )}
                  </div>
                  {indexHymn.author && (
                    <div className="text-xs text-gray-500 truncate">
                      by {/* Highlight search term in author */}
                      {searchTerm.trim() ? (
                        <span dangerouslySetInnerHTML={{ 
                          __html: indexHymn.author.replace(
                            new RegExp(`(${searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi'),
                            '<mark class="bg-yellow-200">$1</mark>'
                          )
                        }} />
                      ) : (
                        indexHymn.author
                      )}
                    </div>
                  )}
                </div>
              </div>
            </Link>
          ))
        )}
        
        {!searchTerm.trim() && hymns.length > 20 && (
          <div className="text-center pt-2">
            <Link
              href={`/${hymnalSlug}`}
              className="text-sm text-primary-600 hover:text-primary-700 font-medium"
            >
              View all {hymns.length} hymns →
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}