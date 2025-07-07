'use client';

import { useState, useEffect, useRef } from 'react';
import { PlayIcon, PrinterIcon, ShareIcon, PencilIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

interface HymnActionButtonsProps {
  hymn: {
    title: string;
    number: number;
  };
  hymnalSlug: string;
  hymnSlug: string;
  hymnalRef?: {
    id: string;
    music?: {
      mp3?: string;
      midi?: string;
    };
  };
}

export default function HymnActionButtons({ hymn, hymnalSlug, hymnSlug, hymnalRef }: HymnActionButtonsProps) {
  const [selectedFormat, setSelectedFormat] = useState<'midi' | 'mp3'>('midi'); // Default to MIDI
  const [showFormatDropdown, setShowFormatDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setShowFormatDropdown(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  // Get available formats for this hymnal
  const getAvailableFormats = () => {
    const formats: Array<{ key: 'midi' | 'mp3'; label: string; size: string }> = [];
    
    if (hymnalRef?.music?.midi) {
      formats.push({ key: 'midi', label: 'MIDI', size: '~2KB' });
    }
    if (hymnalRef?.music?.mp3) {
      formats.push({ key: 'mp3', label: 'MP3', size: '~2MB' });
    }
    
    return formats;
  };

  const handlePlayAudio = (format?: 'midi' | 'mp3') => {
    if (!hymnalRef?.music) {
      alert('Audio not available for this hymnal.');
      return;
    }

    const formatToUse = format || selectedFormat;
    const audioSources = [];
    
    // For development, try local files first, then external URLs
    const isDevelopment = process.env.NODE_ENV === 'development';
    
    if (isDevelopment) {
      // Try local files first in development
      if (formatToUse === 'mp3' && hymnalRef.music.mp3) {
        audioSources.push(`/data/sources/audio/${hymnalRef.id}/${hymn.number}.mp3`);
      }
      if (formatToUse === 'midi' && hymnalRef.music.midi) {
        audioSources.push(`/data/sources/audio/${hymnalRef.id}/${hymn.number}.mid`);
      }
    }
    
    // Add external URLs as fallback
    if (formatToUse === 'mp3' && hymnalRef.music.mp3) {
      audioSources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3`);
    }
    if (formatToUse === 'midi' && hymnalRef.music.midi) {
      audioSources.push(`${hymnalRef.music.midi}/${hymn.number}.mid`);
    }

    if (audioSources.length === 0) {
      alert(`No ${formatToUse.toUpperCase()} files available for this hymn.`);
      return;
    }

    // Try to play the first available audio source
    tryPlayAudio(audioSources, 0);
  };

  const tryPlayAudio = (sources: string[], index: number) => {
    if (index >= sources.length) {
      alert('Audio file could not be loaded for this hymn.');
      return;
    }

    const audio = new Audio();
    
    audio.onloadeddata = () => {
      audio.play().catch((error) => {
        console.error('Error playing audio:', error);
        alert('Could not play audio. Please check your browser settings.');
      });
    };

    audio.onerror = () => {
      console.log(`Failed to load ${sources[index]}, trying next source...`);
      tryPlayAudio(sources, index + 1);
    };

    audio.src = sources[index];
    audio.load();
  };

  const handlePrint = () => {
    window.print();
  };

  const handleEdit = () => {
    const editUrl = `/${hymnalSlug}/${hymnSlug}/edit`;
    // Open in new window like projection
    window.open(editUrl, '_blank', 'width=1600,height=900,scrollbars=yes,resizable=yes');
  };

  const handleShare = () => {
    const url = window.location.href;
    const title = `${hymn.title} - Hymn #${hymn.number}`;
    
    const fallbackCopy = (text: string) => {
      try {
        const textArea = document.createElement('textarea');
        textArea.value = text;
        textArea.style.position = 'fixed';
        textArea.style.left = '-999999px';
        textArea.style.top = '-999999px';
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        alert('Link copied to clipboard!');
      } catch (err) {
        console.error('Failed to copy text:', err);
        alert('Unable to copy link. Please copy manually: ' + text);
      }
    };

    if (navigator.share) {
      navigator.share({
        title: title,
        text: `Check out this hymn: ${title}`,
        url: url,
      }).catch((error) => {
        console.log('Error sharing:', error);
        // Fallback to clipboard
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(`${title} - ${url}`)
            .then(() => alert('Link copied to clipboard!'))
            .catch(() => fallbackCopy(`${title} - ${url}`));
        } else {
          fallbackCopy(`${title} - ${url}`);
        }
      });
    } else {
      // Fallback for browsers without Web Share API
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(`${title} - ${url}`)
          .then(() => {
            alert('Link copied to clipboard!');
          })
          .catch(() => {
            fallbackCopy(`${title} - ${url}`);
          });
      } else {
        fallbackCopy(`${title} - ${url}`);
      }
    }
  };

  const availableFormats = getAvailableFormats();
  const currentFormat = availableFormats.find(f => f.key === selectedFormat);

  return (
    <div className="mt-8 flex flex-wrap justify-center gap-2 sm:gap-4 action-buttons no-print">
      {/* Audio Play Button with Format Selector */}
      {availableFormats.length > 0 && (
        <div className="relative" ref={dropdownRef}>
          <div className="flex">
            <button 
              onClick={() => handlePlayAudio()}
              className="inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-l-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
            >
              <PlayIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="sm:hidden">Play</span>
              <span className="hidden sm:inline">Play {currentFormat?.label}</span>
            </button>
            {availableFormats.length > 1 && (
              <button
                onClick={() => setShowFormatDropdown(!showFormatDropdown)}
                className="inline-flex items-center px-1 sm:px-2 py-1.5 sm:py-2 bg-white/10 text-white border-l border-l-white/30 border-y border-r border-white/20 hover:bg-white/20 rounded-r-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
              >
                <ChevronDownIcon className="h-3 w-3 sm:h-4 sm:w-4" />
              </button>
            )}
          </div>

          {/* Format Dropdown */}
          {showFormatDropdown && availableFormats.length > 1 && (
            <div className="absolute top-full left-0 mt-1 w-full min-w-32 bg-white border border-gray-200 rounded-lg shadow-lg z-10">
              {availableFormats.map((format) => (
                <button
                  key={format.key}
                  onClick={() => {
                    setSelectedFormat(format.key);
                    setShowFormatDropdown(false);
                  }}
                  className={`w-full px-3 py-2 text-left text-sm hover:bg-gray-50 first:rounded-t-lg last:rounded-b-lg transition-colors ${
                    selectedFormat === format.key ? 'bg-primary-50 text-primary-600 font-medium' : 'text-gray-700'
                  }`}
                >
                  <div className="flex justify-between items-center">
                    <span>{format.label}</span>
                    <span className="text-xs text-gray-500">{format.size}</span>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}
      <button 
        onClick={handlePrint}
        className="inline-flex items-center px-2 py-1.5 sm:px-4 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
      >
        <PrinterIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
        Print
      </button>
      <button 
        onClick={handleEdit}
        className="inline-flex items-center px-2 py-1.5 sm:px-4 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
      >
        <PencilIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
        Edit
      </button>
      <button 
        onClick={handleShare}
        className="inline-flex items-center px-2 py-1.5 sm:px-4 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
      >
        <ShareIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
        Share
      </button>
    </div>
  );
}