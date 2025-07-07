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
    <div className="mt-8 flex flex-wrap justify-center gap-4 action-buttons no-print">
      <button 
        onClick={handlePlayAudio}
        className="inline-flex items-center px-4 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200"
      >
        <PlayIcon className="h-4 w-4 mr-2" />
        Play Audio
      </button>
      <button 
        onClick={handlePrint}
        className="inline-flex items-center px-4 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200"
      >
        <PrinterIcon className="h-4 w-4 mr-2" />
        Print
      </button>
      <a
        href={`/${hymnalSlug}/${hymnSlug}/edit`}
        target="_blank"
        rel="noopener noreferrer"
        className="inline-flex items-center px-4 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200"
      >
        <PencilIcon className="h-4 w-4 mr-2" />
        Edit
      </a>
      <button 
        onClick={handleShare}
        className="inline-flex items-center px-4 py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200"
      >
        <ShareIcon className="h-4 w-4 mr-2" />
        Share
      </button>
    </div>
  );
}