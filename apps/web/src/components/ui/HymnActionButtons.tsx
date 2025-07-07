'use client';

import { PlayIcon, PrinterIcon, ShareIcon, PencilIcon } from '@heroicons/react/24/outline';

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
  const handlePlayAudio = () => {
    if (!hymnalRef?.music) {
      alert('Audio not available for this hymnal.');
      return;
    }

    // Generate audio URLs with fallback logic
    const audioSources = [];
    
    // For development, try local files first, then external URLs
    const isDevelopment = process.env.NODE_ENV === 'development';
    
    if (isDevelopment) {
      // Try local files first in development
      if (hymnalRef.music.mp3) {
        audioSources.push(`/data/sources/audio/${hymnalRef.id}/${hymn.number}.mp3`);
      }
      if (hymnalRef.music.midi) {
        audioSources.push(`/data/sources/audio/${hymnalRef.id}/${hymn.number}.mid`);
      }
    }
    
    // Add external URLs as fallback
    if (hymnalRef.music.mp3) {
      audioSources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3`);
    }
    if (hymnalRef.music.midi) {
      audioSources.push(`${hymnalRef.music.midi}/${hymn.number}.mid`);
    }

    if (audioSources.length === 0) {
      alert('No audio files available for this hymn.');
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

  return (
    <div className="mt-8 flex flex-wrap justify-center gap-2 sm:gap-4 action-buttons no-print">
      <button 
        onClick={handlePlayAudio}
        className="inline-flex items-center px-2 py-1.5 sm:px-4 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
      >
        <PlayIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
        <span className="sm:hidden">Play</span>
        <span className="hidden sm:inline">Play Audio</span>
      </button>
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