'use client';

import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import { HymnalCollection } from '@advent-hymnals/shared';

interface HymnFiltersProps {
  searchTerm: string;
  onSearchChange: (value: string) => void;
  selectedHymnal: string;
  onHymnalChange: (value: string) => void;
  sortBy: 'title' | 'number';
  onSortChange: (value: 'title' | 'number') => void;
  hymnalReferences?: HymnalCollection;
}

export default function HymnFilters({
  searchTerm,
  onSearchChange,
  selectedHymnal,
  onHymnalChange,
  sortBy,
  onSortChange,
  hymnalReferences
}: HymnFiltersProps) {
  return (
    <div className="mb-8 bg-white p-6 rounded-lg shadow-sm border">
      <div className="flex flex-col md:flex-row gap-4">
        {/* Search */}
        <div className="relative flex-1">
          <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search hymns..."
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm"
          />
        </div>

        {/* Hymnal Filter */}
        <select
          value={selectedHymnal}
          onChange={(e) => onHymnalChange(e.target.value)}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm"
        >
          <option value="">All Hymnals</option>
          {hymnalReferences && Object.values(hymnalReferences.hymnals).map((hymnal) => (
            <option key={hymnal.id} value={hymnal.id}>
              {hymnal.abbreviation}
            </option>
          ))}
        </select>

        {/* Sort */}
        <select
          value={sortBy}
          onChange={(e) => onSortChange(e.target.value as 'title' | 'number')}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm"
        >
          <option value="number">Sort by Number</option>
          <option value="title">Sort by Title</option>
        </select>
      </div>
    </div>
  );
}