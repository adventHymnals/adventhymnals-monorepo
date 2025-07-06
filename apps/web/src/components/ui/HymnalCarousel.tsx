'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { ChevronLeftIcon, ChevronRightIcon, BookOpenIcon, MagnifyingGlassIcon, DocumentArrowDownIcon } from '@heroicons/react/24/outline';
import SearchDialog from './SearchDialog';

interface HymnalCard {
  id: string;
  name: string;
  year: number;
  songs: number;
  language: string;
  description: string;
  href: string;
  featured: boolean;
  colors: {
    gradient: string;
    text: string;
    button: string;
    searchBg: string;
  };
}

interface HymnalCarouselProps {
  hymnals: HymnalCard[];
}

export default function HymnalCarousel({ hymnals }: HymnalCarouselProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [searchDialog, setSearchDialog] = useState<{ isOpen: boolean; hymnal?: HymnalCard }>({
    isOpen: false
  });

  const nextSlide = () => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % hymnals.length);
  };

  const prevSlide = () => {
    setCurrentIndex((prevIndex) => (prevIndex - 1 + hymnals.length) % hymnals.length);
  };


  const openSearchDialog = (hymnal: HymnalCard) => {
    setSearchDialog({ isOpen: true, hymnal });
  };

  const closeSearchDialog = () => {
    setSearchDialog({ isOpen: false });
  };

  // Calculate visible count based on screen size
  const [visibleCount, setVisibleCount] = useState(3);

  useEffect(() => {
    const updateVisibleCount = () => {
      if (typeof window !== 'undefined') {
        const count = window.innerWidth >= 1024 ? 3 : window.innerWidth >= 768 ? 2 : 1;
        setVisibleCount(count);
      }
    };

    updateVisibleCount();
    window.addEventListener('resize', updateVisibleCount);
    return () => window.removeEventListener('resize', updateVisibleCount);
  }, []);

  // Create a circular display by repeating hymnals array
  const getVisibleHymnals = () => {
    const visibleHymnals = [];
    for (let i = 0; i < visibleCount + 2; i++) { // Extra items for smooth scrolling
      const index = (currentIndex + i - 1 + hymnals.length) % hymnals.length;
      visibleHymnals.push({ ...hymnals[index], displayIndex: i });
    }
    return visibleHymnals;
  };

  const visibleHymnals = getVisibleHymnals();

  return (
    <>
      <div className="relative px-16">
        {/* Navigation arrows - improved styling */}
        <button
          onClick={prevSlide}
          className="absolute left-0 top-1/2 transform -translate-y-1/2 z-10 w-12 h-12 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 rounded-full shadow-lg transition-all duration-200 flex items-center justify-center text-white"
          aria-label="Previous hymnal"
        >
          <ChevronLeftIcon className="h-6 w-6" />
        </button>
        
        <button
          onClick={nextSlide}
          className="absolute right-0 top-1/2 transform -translate-y-1/2 z-10 w-12 h-12 bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 rounded-full shadow-lg transition-all duration-200 flex items-center justify-center text-white"
          aria-label="Next hymnal"
        >
          <ChevronRightIcon className="h-6 w-6" />
        </button>

        {/* Carousel container - dynamic height based on center card */}
        <div className="overflow-hidden">
          <div 
            className="flex transition-transform duration-500 ease-in-out"
            style={{ 
              transform: `translateX(-${100 / visibleCount}%)`, // Always show second item as first visible
              minHeight: '420px' // Accommodate scaled center card
            }}
          >
            {visibleHymnals.map((hymnal, index) => {
              // Calculate if this card is in the center position
              const centerIndex = Math.floor(visibleCount / 2) + 1; // Adjust for offset
              const isCenter = index === centerIndex;
              
              return (
                <div
                  key={`${hymnal.id}-${hymnal.displayIndex}`}
                  className="w-full md:w-1/2 lg:w-1/3 flex-shrink-0 px-4 flex items-center"
                >
                  <div className={`relative overflow-hidden rounded-2xl shadow-xl transition-all duration-300 w-full ${
                    isCenter 
                      ? 'transform scale-110 hover:scale-115 shadow-2xl' 
                      : 'transform scale-95 hover:scale-100 shadow-lg'
                  }`}>
                    {/* Colorful gradient background */}
                    <div className={`absolute inset-0 bg-gradient-to-br ${hymnal.colors.gradient}`}></div>
                    
                    {/* Card content */}
                    <div className="relative p-6 h-80 flex flex-col">
                      {/* Header */}
                      <div className="flex items-center justify-between mb-4">
                        <div className={`text-lg font-bold ${hymnal.colors.text} bg-white/20 rounded-lg px-2 py-1`}>
                          {hymnal.year}
                        </div>
                        <div className={`text-xs ${hymnal.colors.text} bg-white/20 rounded-lg px-2 py-1`}>
                          {hymnal.songs} hymns
                        </div>
                      </div>

                      {/* Content */}
                      <div className="flex-grow">
                        <h3 className={`text-lg font-bold ${hymnal.colors.text} mb-2 line-clamp-2`}>
                          {hymnal.name.length > 25 ? `${hymnal.name.substring(0, 25)}...` : hymnal.name}
                        </h3>
                        <p className={`text-xs ${hymnal.colors.text} mb-3 opacity-90`}>
                          {hymnal.language}
                        </p>
                        <p className={`text-sm ${hymnal.colors.text} opacity-80 mb-4 line-clamp-2`}>
                          {hymnal.description}
                        </p>
                      </div>

                      {/* Search bar */}
                      <div className="mb-4">
                        <div className="relative">
                          <MagnifyingGlassIcon className="absolute left-2 top-1/2 transform -translate-y-1/2 h-3 w-3 text-gray-400" />
                          <button
                            onClick={() => openSearchDialog(hymnal)}
                            className={`w-full pl-8 pr-3 py-2 rounded-lg border ${hymnal.colors.searchBg} focus:outline-none focus:ring-2 focus:ring-white/50 text-xs text-left cursor-pointer hover:bg-opacity-90 transition-colors truncate`}
                          >
                            Search {hymnal.name.length > 15 ? `${hymnal.name.substring(0, 15)}...` : hymnal.name}
                          </button>
                        </div>
                      </div>

                      {/* Bottom-aligned buttons */}
                      <div className="mt-auto space-y-2">
                        <Link
                          href={hymnal.href}
                          className={`inline-flex items-center justify-center w-full px-4 py-2 rounded-lg font-medium transition-colors duration-200 text-sm ${hymnal.colors.button}`}
                        >
                          <BookOpenIcon className="h-4 w-4 mr-1" />
                          Explore
                        </Link>
                        <Link
                          href="/download#pdf-downloads"
                          className={`inline-flex items-center justify-center w-full px-4 py-2 rounded-lg font-medium transition-colors duration-200 text-sm bg-white/20 text-white hover:bg-white/30 border border-white/30`}
                        >
                          <DocumentArrowDownIcon className="h-4 w-4 mr-1" />
                          Download PDF
                        </Link>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Search Dialog */}
      {searchDialog.isOpen && searchDialog.hymnal && (
        <SearchDialog
          isOpen={searchDialog.isOpen}
          onClose={closeSearchDialog}
          hymnalId={searchDialog.hymnal.id}
          hymnalName={searchDialog.hymnal.name}
          placeholder={`Search ${searchDialog.hymnal.name}...`}
        />
      )}
    </>
  );
}