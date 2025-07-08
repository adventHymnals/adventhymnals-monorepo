'use client';

import { useState, useEffect, useRef } from 'react';
import { PlayIcon, PrinterIcon, ShareIcon, PencilIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

interface HymnActionButtonsProps {
  hymn: {
    title: string;
    number: number;
    metadata?: {
      youtube?: string;
      [key: string]: any;
    };
  };
  hymnalSlug: string;
  hymnSlug: string;
  hymnalRef?: {
    id: string;
    music?: {
      mp3?: string;
      midi?: string | string[];
    };
  };
}

export default function HymnActionButtons({ hymn, hymnalSlug, hymnSlug, hymnalRef }: HymnActionButtonsProps) {
  const [selectedFormat, setSelectedFormat] = useState<'midi' | 'mp3'>('midi'); // Default to MIDI
  const [showFormatDropdown, setShowFormatDropdown] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Set selectedFormat to first available format when component loads
  useEffect(() => {
    const formats = getAvailableFormats();
    if (formats.length > 0 && !formats.find(f => f.key === selectedFormat)) {
      setSelectedFormat(formats[0].key);
    }
  }, [hymnalRef]);

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
    
    // Only enable audio for hymnals where we know files actually exist
    const hymnalsWithActualAudio = ['CH1941', 'SDAH']; // Add more as audio files become available
    
    if (hymnalsWithActualAudio.includes(hymnalRef?.id || '')) {
      // MIDI should be shown first (as default) when available
      if (hymnalRef?.music?.midi) {
        formats.push({ key: 'midi', label: 'MIDI', size: '~2KB' });
      }
      if (hymnalRef?.music?.mp3) {
        formats.push({ key: 'mp3', label: 'MP3', size: '~2MB' });
      }
    }
    
    return formats;
  };

  const handlePlayAudio = (format?: 'midi' | 'mp3') => {
    if (!hymnalRef?.music) {
      alert('Audio not available for this hymnal.');
      return;
    }

    const availableFormats = getAvailableFormats();
    const defaultFormat = availableFormats[0]?.key || 'midi';
    const formatToUse = format || selectedFormat || defaultFormat;
    const audioSources = [];
    
    // Try local files first (always, regardless of environment)
    if (formatToUse === 'mp3' && hymnalRef.music.mp3) {
      audioSources.push(`/data/sources/audio/${hymnalRef.id}/${hymn.number}.mp3`);
    }
    if (formatToUse === 'midi' && hymnalRef.music.midi) {
      audioSources.push(`/data/sources/audio/${hymnalRef.id}/${hymn.number}.mid`);
    }
    
    // Add external URLs as fallback only if local files might not exist
    if (formatToUse === 'mp3' && hymnalRef.music.mp3) {
      audioSources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3`);
    }
    if (formatToUse === 'midi' && hymnalRef.music.midi) {
      const midiUrls = Array.isArray(hymnalRef.music.midi) 
        ? hymnalRef.music.midi 
        : [hymnalRef.music.midi];
      
      midiUrls.forEach(url => {
        audioSources.push(`${url}/${hymn.number}.mid`);
      });
    }

    if (audioSources.length === 0) {
      alert(`No ${formatToUse.toUpperCase()} files available for this hymn.`);
      return;
    }

    // Try to play the first available audio source
    tryPlayAudio(audioSources, 0);
  };

  const playMidiFile = async (midiUrl: string) => {
    try {
      // Load html-midi-player library (modern 2024 solution using Google Magenta.js)
      if (typeof window !== 'undefined' && !customElements.get('midi-player')) {
        // Load the html-midi-player library from CDN
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/combine/npm/tone@14.7.58,npm/@magenta/music@1.23.1/es6/core.js,npm/focus-visible@5,npm/html-midi-player@1.4.0';
        script.async = true;
        document.head.appendChild(script);
        
        await new Promise((resolve, reject) => {
          script.onload = resolve;
          script.onerror = () => reject(new Error('Failed to load MIDI player library'));
        });
        
        // Wait a bit for the custom elements to be registered
        await new Promise(resolve => setTimeout(resolve, 500));
      }

      // Create a hidden MIDI player element
      let midiPlayer = document.getElementById('hidden-midi-player') as any;
      if (!midiPlayer) {
        midiPlayer = document.createElement('midi-player');
        midiPlayer.id = 'hidden-midi-player';
        midiPlayer.style.display = 'none';
        document.body.appendChild(midiPlayer);
      }

      // Set the MIDI file source and play
      midiPlayer.src = midiUrl;
      
      // Wait for the player to load
      await new Promise((resolve, reject) => {
        midiPlayer.addEventListener('load', resolve, { once: true });
        midiPlayer.addEventListener('error', reject, { once: true });
      });

      // Start playback
      midiPlayer.start();
      console.log('Playing MIDI file:', midiUrl);
      
    } catch (error) {
      console.error('Failed to play MIDI file:', error);
      
      // Fallback options
      const userChoice = window.confirm(
        `Unable to load MIDI player. Would you like to:

• Click "OK" to download the MIDI file and play it with your system's default MIDI player
• Click "Cancel" to try MP3 format (if available)

Download the MIDI file?`
      );
      
      if (userChoice) {
        // Download the MIDI file
        const link = document.createElement('a');
        link.href = midiUrl;
        link.download = `${hymnalRef?.id || 'hymn'}-${hymn.number}.mid`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      } else {
        // Try to switch to MP3 if available
        const availableFormats = getAvailableFormats();
        const mp3Format = availableFormats.find(f => f.key === 'mp3');
        if (mp3Format) {
          setSelectedFormat('mp3');
          handlePlayAudio('mp3');
        } else {
          alert('No alternative audio format available for this hymn.');
        }
      }
    }
  };

  const tryPlayAudio = (sources: string[], index: number) => {
    if (index >= sources.length) {
      alert('Audio file could not be loaded for this hymn.');
      return;
    }

    const currentSource = sources[index];
    
    // Special handling for MIDI files
    if (currentSource.endsWith('.mid')) {
      playMidiFile(currentSource);
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

  const generateYouTubeUrl = (input?: string): string => {
    if (!input) {
      // Default to adventhymnals channel
      return 'https://youtube.com/@adventhymnals';
    }

    // If it's already a full URL, return as is
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }

    // Handle @channel format
    if (input.startsWith('@')) {
      return `https://youtube.com/${input}`;
    }

    // Handle watch?v= format
    if (input.includes('watch?v=') || input.includes('youtu.be/')) {
      return input.startsWith('http') ? input : `https://youtube.com/${input}`;
    }

    // Handle video ID directly
    if (input.match(/^[a-zA-Z0-9_-]{11}$/)) {
      return `https://youtube.com/watch?v=${input}`;
    }

    // Handle channel name or other formats
    if (input.includes('/')) {
      return input.startsWith('http') ? input : `https://youtube.com/${input}`;
    }

    // Default: treat as channel handle
    return `https://youtube.com/@${input}`;
  };

  const handleYouTube = () => {
    // Get YouTube URL from hymn metadata or use default
    const youtubeInput = hymn.metadata?.youtube;
    const youtubeUrl = generateYouTubeUrl(youtubeInput);
    
    // Open YouTube in new tab
    window.open(youtubeUrl, '_blank', 'noopener,noreferrer');
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
  
  // Ensure selectedFormat is always valid - default to first available format
  const validSelectedFormat = availableFormats.find(f => f.key === selectedFormat) 
    ? selectedFormat 
    : availableFormats[0]?.key || 'midi';
  
  const currentFormat = availableFormats.find(f => f.key === validSelectedFormat);

  return (
    <div className="mt-8 flex flex-wrap justify-center gap-2 sm:gap-4 action-buttons no-print">
      {/* Audio Play Button with Format Selector */}
      <div className="relative" ref={dropdownRef}>
          <div className="flex">
            <button 
              onClick={() => handlePlayAudio()}
              disabled={availableFormats.length === 0}
              className={`inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 font-medium transition-colors duration-200 text-xs sm:text-sm ${
                availableFormats.length > 1 ? 'rounded-l-lg' : 'rounded-lg'
              } ${
                availableFormats.length === 0 ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              <PlayIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="sm:hidden">Play</span>
              <span className="hidden sm:inline">
                {availableFormats.length === 0 
                  ? 'No Audio' 
                  : `Play ${currentFormat?.label}`
                }
              </span>
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
                    validSelectedFormat === format.key ? 'bg-primary-50 text-primary-600 font-medium' : 'text-gray-700'
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
      
      {/* YouTube Button */}
      <button 
        onClick={handleYouTube}
        className="inline-flex items-center px-2 py-1.5 sm:px-4 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
      >
        <svg className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" fill="currentColor" viewBox="0 0 24 24">
          <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136C4.495 20.455 12 20.455 12 20.455s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
        </svg>
        YouTube
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