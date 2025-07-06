'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { ChevronLeftIcon, ChevronRightIcon, BookOpenIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline';
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
    setCurrentIndex((prevIndex) => 
      prevIndex + 1 >= hymnals.length ? 0 : prevIndex + 1
    );
  };

  const prevSlide = () => {
    setCurrentIndex((prevIndex) => 
      prevIndex - 1 < 0 ? hymnals.length - 1 : prevIndex - 1
    );
  };

  const goToSlide = (index: number) => {
    setCurrentIndex(index);
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

  return (
    <>
      <div className="relative">
        {/* Navigation arrows */}
        <button
          onClick={prevSlide}
          className="absolute left-4 top-1/2 transform -translate-y-1/2 z-10 bg-white/90 hover:bg-white rounded-full p-2 shadow-lg transition-all duration-200"
          aria-label="Previous hymnal"
        >
          <ChevronLeftIcon className="h-5 w-5 text-gray-600" />
        </button>
        
        <button
          onClick={nextSlide}
          className="absolute right-4 top-1/2 transform -translate-y-1/2 z-10 bg-white/90 hover:bg-white rounded-full p-2 shadow-lg transition-all duration-200"
          aria-label="Next hymnal"
        >
          <ChevronRightIcon className="h-5 w-5 text-gray-600" />
        </button>

        {/* Carousel container */}
        <div className="overflow-hidden">
          <div 
            className="flex transition-transform duration-500 ease-in-out"
            style={{ 
              transform: `translateX(-${currentIndex * (100 / visibleCount)}%)` 
            }}
          >
            {hymnals.map((hymnal) => (
              <div
                key={hymnal.id}
                className="w-full md:w-1/2 lg:w-1/3 flex-shrink-0 px-4"
              >
                <div className="relative overflow-hidden rounded-2xl shadow-xl hover:shadow-2xl transform hover:scale-105 transition-all duration-300">
                  {/* Colorful gradient background */}
                  <div className={`absolute inset-0 bg-gradient-to-br ${hymnal.colors.gradient}`}></div>
                  
                  {/* Card content */}
                  <div className="relative p-8 h-full flex flex-col">
                    {/* Header */}
                    <div className="flex items-center justify-between mb-6">
                      <div className={`text-2xl font-bold ${hymnal.colors.text} bg-white/20 rounded-lg px-3 py-1`}>
                        {hymnal.year}
                      </div>
                      <div className={`text-sm ${hymnal.colors.text} bg-white/20 rounded-lg px-3 py-1`}>
                        {hymnal.songs} hymns
                      </div>
                    </div>

                    {/* Content */}
                    <div className="flex-grow">
                      <h3 className={`text-xl font-bold ${hymnal.colors.text} mb-2`}>
                        {hymnal.name}
                      </h3>
                      <p className={`text-sm ${hymnal.colors.text} mb-4 opacity-90`}>
                        {hymnal.language}
                      </p>
                      <p className={`${hymnal.colors.text} opacity-80 mb-6`}>
                        {hymnal.description}
                      </p>
                    </div>

                    {/* Search bar */}
                    <div className="mb-6">
                      <div className="relative">
                        <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <button
                          onClick={() => openSearchDialog(hymnal)}
                          className={`w-full pl-10 pr-4 py-2 rounded-lg border ${hymnal.colors.searchBg} focus:outline-none focus:ring-2 focus:ring-white/50 text-sm text-left cursor-pointer hover:bg-opacity-90 transition-colors`}
                        >
                          Search {hymnal.name}...
                        </button>
                      </div>
                    </div>

                    {/* Bottom-aligned button */}
                    <div className="mt-auto">
                      <Link
                        href={hymnal.href}
                        className={`inline-flex items-center justify-center w-full px-6 py-3 rounded-lg font-medium transition-colors duration-200 ${hymnal.colors.button}`}
                      >
                        <BookOpenIcon className="h-5 w-5 mr-2" />
                        Explore Collection
                      </Link>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Dots indicator */}
        <div className="flex justify-center mt-6 space-x-2">
          {hymnals.map((_, index) => (
            <button
              key={index}
              onClick={() => goToSlide(index)}
              className={`w-3 h-3 rounded-full transition-colors duration-200 ${
                index === currentIndex 
                  ? 'bg-primary-600' 
                  : 'bg-gray-300 hover:bg-gray-400'
              }`}
              aria-label={`Go to slide ${index + 1}`}
            />
          ))}
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