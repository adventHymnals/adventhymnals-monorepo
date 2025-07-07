'use client';

import { PlayIcon, PrinterIcon, ShareIcon, PencilIcon } from '@heroicons/react/24/outline';

interface HymnActionButtonsProps {
  hymn: {
    title: string;
    number: number;
  };
  hymnalSlug: string;
  hymnSlug: string;
}

export default function HymnActionButtons({ hymn, hymnalSlug, hymnSlug }: HymnActionButtonsProps) {
  const handlePlayAudio = () => {
    // Mock audio play functionality
    alert('Audio playback feature coming soon!');
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