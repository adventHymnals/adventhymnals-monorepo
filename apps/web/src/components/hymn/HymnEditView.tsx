'use client';

import { useState, useEffect } from 'react';
import { 
  ChevronLeftIcon, 
  ChevronRightIcon,
  PhotoIcon,
  ArrowLeftIcon,
  ArrowRightIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline';
import Link from 'next/link';

interface HymnEditViewProps {
  hymn: any;
  hymnalRef: any;
  allHymns: any[];
  params: {
    hymnal: string;
    slug: string;
  };
}

// Generate slug from hymn title
function generateHymnSlug(number: number, title: string): string {
  const cleanTitle = title
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
  return `hymn-${number}-${cleanTitle}`;
}

export default function HymnEditView({ hymn, hymnalRef, allHymns, params }: HymnEditViewProps) {
  const [currentHymnIndex, setCurrentHymnIndex] = useState(0);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [availableImages, setAvailableImages] = useState<number[]>([]);
  const [imageError, setImageError] = useState<Set<number>>(new Set());

  // Find current hymn index
  useEffect(() => {
    const index = allHymns.findIndex(h => h.number === hymn.number);
    setCurrentHymnIndex(index >= 0 ? index : 0);
  }, [hymn.number, allHymns]);

  // Load available images for the hymnal
  useEffect(() => {
    const loadImages = async () => {
      try {
        // This is a simplified approach - in a real implementation,
        // you'd have an API endpoint that lists available images
        const images: number[] = [];
        
        // For CH1941, images are numbered 001.png, 002.png, etc.
        // For CS1900, images are page-001.png, page-002.png, etc.
        let maxImages = 700; // Reasonable limit for testing
        if (hymnalRef.id === 'CH1941') maxImages = 633;
        if (hymnalRef.id === 'CS1900') maxImages = 322;
        
        for (let i = 1; i <= maxImages; i++) {
          images.push(i);
        }
        
        setAvailableImages(images);
        
        // Try to find an image close to the hymn number
        const startImage = Math.max(1, hymn.number - 5);
        const imageIndex = images.findIndex(img => img >= startImage);
        setCurrentImageIndex(imageIndex >= 0 ? imageIndex : 0);
      } catch (error) {
        console.error('Error loading images:', error);
      }
    };

    loadImages();
  }, [hymnalRef.id, hymn.number]);

  const getCurrentImage = () => {
    if (availableImages.length === 0) return null;
    const imageNum = availableImages[currentImageIndex];
    
    if (hymnalRef.id === 'CH1941') {
      return `/data/sources/images/CH1941/${imageNum.toString().padStart(3, '0')}.png`;
    } else if (hymnalRef.id === 'CS1900') {
      return `/data/sources/images/CS1900/page-${imageNum.toString().padStart(3, '0')}.png`;
    }
    
    return null;
  };

  const getImageDisplayNumber = () => {
    if (availableImages.length === 0) return '';
    return availableImages[currentImageIndex];
  };

  const navigateHymn = (direction: 'prev' | 'next') => {
    let newIndex = currentHymnIndex;
    
    if (direction === 'prev' && currentHymnIndex > 0) {
      newIndex = currentHymnIndex - 1;
    } else if (direction === 'next' && currentHymnIndex < allHymns.length - 1) {
      newIndex = currentHymnIndex + 1;
    }
    
    if (newIndex !== currentHymnIndex) {
      const targetHymn = allHymns[newIndex];
      const slug = generateHymnSlug(targetHymn.number, targetHymn.title);
      window.location.href = `/${params.hymnal}/${slug}/edit`;
    }
  };

  const navigateImage = (direction: 'prev' | 'next') => {
    if (direction === 'prev' && currentImageIndex > 0) {
      setCurrentImageIndex(currentImageIndex - 1);
    } else if (direction === 'next' && currentImageIndex < availableImages.length - 1) {
      setCurrentImageIndex(currentImageIndex + 1);
    }
  };

  const handleImageError = (imageNum: number) => {
    setImageError(prev => new Set([...prev, imageNum]));
  };

  const currentImageSrc = getCurrentImage();
  const currentImageNum = getImageDisplayNumber();

  return (
    <div className="mx-auto max-w-8xl px-6 py-6 lg:px-8">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 h-[calc(100vh-200px)]">
        {/* Left Panel - Hymn Text */}
        <div className="bg-white rounded-xl shadow-sm border flex flex-col">
          {/* Hymn Navigation Header */}
          <div className="flex items-center justify-between p-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Hymn Text</h2>
            <div className="flex items-center space-x-2">
              <button
                onClick={() => navigateHymn('prev')}
                disabled={currentHymnIndex === 0}
                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                title="Previous hymn"
              >
                <ChevronLeftIcon className="h-4 w-4" />
              </button>
              <span className="text-sm text-gray-600 px-3">
                {currentHymnIndex + 1} of {allHymns.length}
              </span>
              <button
                onClick={() => navigateHymn('next')}
                disabled={currentHymnIndex === allHymns.length - 1}
                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                title="Next hymn"
              >
                <ChevronRightIcon className="h-4 w-4" />
              </button>
            </div>
          </div>

          {/* Hymn Content */}
          <div className="flex-1 overflow-y-auto p-6 custom-scrollbar">
            {/* Hymn Header */}
            <div className="mb-6">
              <h1 className="text-2xl font-bold text-gray-900 mb-2">
                <span className="text-primary-600 mr-2">#{hymn.number}</span>
                {hymn.title}
              </h1>
              
              {/* Metadata */}
              <div className="flex flex-wrap gap-4 text-sm text-gray-600">
                {hymn.author && (
                  <div>
                    <span className="font-medium">Words:</span> {hymn.author}
                  </div>
                )}
                {hymn.composer && (
                  <div>
                    <span className="font-medium">Music:</span> {hymn.composer}
                  </div>
                )}
                {hymn.tune && (
                  <div>
                    <span className="font-medium">Tune:</span> {hymn.tune}
                  </div>
                )}
                {hymn.meter && (
                  <div>
                    <span className="font-medium">Meter:</span> {hymn.meter}
                  </div>
                )}
              </div>
            </div>

            {/* Verses */}
            <div className="space-y-6">
              {hymn.verses.map((verse: any) => (
                <div key={verse.number} className="relative">
                  <div className="absolute left-0 top-0 w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                    <span className="text-sm font-bold text-primary-600">
                      {verse.number}
                    </span>
                  </div>
                  <div className="ml-12">
                    <div className="text-lg leading-relaxed text-gray-800 whitespace-pre-line font-serif">
                      {verse.text}
                    </div>
                  </div>
                </div>
              ))}

              {/* Chorus */}
              {hymn.chorus && (
                <div className="relative mt-8 p-6 bg-primary-50 border-l-4 border-primary-500 rounded-r-lg">
                  <div className="absolute left-0 top-0 w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center -ml-6 mt-2">
                    <span className="text-sm font-bold text-white">C</span>
                  </div>
                  <div className="ml-6">
                    <h3 className="text-lg font-semibold text-primary-900 mb-2">Chorus</h3>
                    <div className="text-lg leading-relaxed text-primary-800 whitespace-pre-line font-serif">
                      {hymn.chorus.text}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Right Panel - Images */}
        <div className="bg-white rounded-xl shadow-sm border flex flex-col">
          {/* Image Navigation Header */}
          <div className="flex items-center justify-between p-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900 flex items-center">
              <PhotoIcon className="h-5 w-5 mr-2" />
              Original Images
            </h2>
            <div className="flex items-center space-x-2">
              <button
                onClick={() => navigateImage('prev')}
                disabled={currentImageIndex === 0}
                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                title="Previous image"
              >
                <ArrowLeftIcon className="h-4 w-4" />
              </button>
              <span className="text-sm text-gray-600 px-3">
                {availableImages.length > 0 ? `Page ${currentImageNum}` : 'Loading...'}
              </span>
              <button
                onClick={() => navigateImage('next')}
                disabled={currentImageIndex === availableImages.length - 1}
                className="p-2 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                title="Next image"
              >
                <ArrowRightIcon className="h-4 w-4" />
              </button>
            </div>
          </div>

          {/* Image Display */}
          <div className="flex-1 overflow-hidden p-4">
            {currentImageSrc ? (
              <div className="h-full flex items-center justify-center bg-gray-50 rounded-lg">
                {!imageError.has(availableImages[currentImageIndex]) ? (
                  <img
                    src={currentImageSrc}
                    alt={`${hymnalRef.name} page ${currentImageNum}`}
                    className="max-w-full max-h-full object-contain shadow-lg rounded"
                    onError={() => handleImageError(availableImages[currentImageIndex])}
                  />
                ) : (
                  <div className="text-center text-gray-500 p-8">
                    <ExclamationTriangleIcon className="h-12 w-12 mx-auto mb-4 text-gray-400" />
                    <p className="text-lg font-medium">Image not available</p>
                    <p className="text-sm">Page {currentImageNum} could not be loaded</p>
                  </div>
                )}
              </div>
            ) : (
              <div className="h-full flex items-center justify-center bg-gray-50 rounded-lg">
                <div className="text-center text-gray-500 p-8">
                  <PhotoIcon className="h-12 w-12 mx-auto mb-4 text-gray-400" />
                  <p className="text-lg font-medium">Loading images...</p>
                </div>
              </div>
            )}
          </div>

          {/* Image Info */}
          {availableImages.length > 0 && (
            <div className="p-4 border-t border-gray-200 bg-gray-50 rounded-b-xl">
              <div className="text-sm text-gray-600 text-center">
                <p>Viewing page {currentImageNum} of {availableImages.length} available images</p>
                <p className="text-xs mt-1">
                  Use arrow buttons to navigate through original hymnal pages
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Quick Navigation */}
      <div className="mt-6 bg-white rounded-xl shadow-sm border p-4">
        <div className="flex items-center justify-between">
          <div className="text-sm text-gray-600">
            Editing: <span className="font-medium">{hymnalRef.name}</span>
          </div>
          <div className="flex items-center space-x-4">
            <Link
              href={`/${params.hymnal}/${params.slug}`}
              className="text-sm text-primary-600 hover:text-primary-700 font-medium"
            >
              ← Back to hymn view
            </Link>
            <Link
              href={`/${params.hymnal}`}
              className="text-sm text-gray-600 hover:text-gray-700"
            >
              View all hymns
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}