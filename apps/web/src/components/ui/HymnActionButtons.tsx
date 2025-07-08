'use client';

import { useState, useEffect, useRef } from 'react';
import { PlayIcon, PauseIcon, StopIcon, ArrowPathIcon, Cog6ToothIcon, PrinterIcon, ShareIcon, PencilIcon, ChevronDownIcon } from '@heroicons/react/24/outline';

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
  const [isLoading, setIsLoading] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [loopEnabled, setLoopEnabled] = useState(false);
  const [showAdvancedPlayer, setShowAdvancedPlayer] = useState(false);
  const [currentPlayer, setCurrentPlayer] = useState<any>(null);
  const [loadingProgress, setLoadingProgress] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [pointA, setPointA] = useState<number | null>(null);
  const [pointB, setPointB] = useState<number | null>(null);
  const [isABLooping, setIsABLooping] = useState(false);
  const [channelVolumes, setChannelVolumes] = useState({
    master: 1.0,
    left: 1.0,
    right: 1.0,
    melody: 1.0,
    bass: 1.0
  });
  const [actuallyAvailableFormats, setActuallyAvailableFormats] = useState<Set<'midi' | 'mp3'>>(new Set());
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Check which audio formats actually exist for this hymn
  useEffect(() => {
    const checkFileExistence = async () => {
      const available = new Set<'midi' | 'mp3'>();
      
      if (hymnalRef?.music) {
        // Check MIDI file
        if (hymnalRef.music.midi) {
          try {
            const audioPath = `https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mid`;
            const response = await fetch(audioPath, { method: 'HEAD' });
            if (response.ok) {
              available.add('midi');
            }
          } catch (error) {
            console.log('MIDI file not available:', error);
          }
        }
        
        // Check MP3 file  
        if (hymnalRef.music.mp3) {
          try {
            const audioPath = `https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mp3`;
            const response = await fetch(audioPath, { method: 'HEAD' });
            if (response.ok) {
              available.add('mp3');
            }
          } catch (error) {
            console.log('MP3 file not available:', error);
          }
        }
      }
      
      setActuallyAvailableFormats(available);
    };
    
    checkFileExistence();
  }, [hymnalRef?.id, hymn.number]);

  // Set selectedFormat to first available format when component loads
  useEffect(() => {
    const formats = getAvailableFormats();
    if (formats.length > 0 && !formats.find(f => f.key === selectedFormat)) {
      setSelectedFormat(formats[0].key);
    }
  }, [hymnalRef, actuallyAvailableFormats]);

  // Update position dynamically when playing
  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (isPlaying && currentPlayer) {
      interval = setInterval(() => {
        if (currentPlayer.currentTime !== undefined) {
          setCurrentTime(currentPlayer.currentTime);
          setDuration(currentPlayer.duration || 0);
          
          // Handle A-B looping
          if (isABLooping && pointA !== null && pointB !== null && currentPlayer.currentTime >= pointB) {
            console.log(`A-B Loop: Jumping from ${currentPlayer.currentTime} back to ${pointA}`);
            currentPlayer.currentTime = pointA;
          }
        }
      }, 100); // Update every 100ms for smooth progress
    }
    
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isPlaying, currentPlayer, isABLooping, pointA, pointB]);

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

  // Get available formats for this hymnal and specific hymn
  const getAvailableFormats = () => {
    const formats: Array<{ key: 'midi' | 'mp3'; label: string; size: string }> = [];
    
    // Show formats based on actual file existence
    if (actuallyAvailableFormats.has('midi')) {
      formats.push({ key: 'midi', label: 'MIDI', size: '~2KB' });
    }
    
    if (actuallyAvailableFormats.has('mp3')) {
      formats.push({ key: 'mp3', label: 'MP3', size: '~2MB' });
    }
    
    // If we haven't checked yet (actuallyAvailableFormats is empty), show potential formats
    if (actuallyAvailableFormats.size === 0 && hymnalRef?.music) {
      if (hymnalRef.music.midi) {
        formats.push({ key: 'midi', label: 'MIDI (checking...)', size: '~2KB' });
      }
      if (hymnalRef.music.mp3) {
        formats.push({ key: 'mp3', label: 'MP3 (checking...)', size: '~2MB' });
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
    
    // If we know the format doesn't exist, show immediate feedback
    if (actuallyAvailableFormats.size > 0 && !actuallyAvailableFormats.has(formatToUse as 'midi' | 'mp3')) {
      const otherFormat = formatToUse === 'midi' ? 'mp3' : 'midi';
      if (actuallyAvailableFormats.has(otherFormat as 'midi' | 'mp3')) {
        alert(`${formatToUse.toUpperCase()} is not available for hymn #${hymn.number}. Try ${otherFormat.toUpperCase()} instead.`);
      } else {
        alert(`No audio files are available for hymn #${hymn.number}.`);
      }
      return;
    }
    const audioSources = [];
    
    // Try media server first (optimized for audio serving)
    if (formatToUse === 'mp3' && hymnalRef.music.mp3) {
      audioSources.push(`https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mp3`);
    }
    if (formatToUse === 'midi' && hymnalRef.music.midi) {
      audioSources.push(`https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mid`);
    }
    
    // Add external URLs as fallback only if local files might not exist
    if (formatToUse === 'mp3' && hymnalRef.music.mp3) {
      // Try GitHub raw URLs with different approaches
      const baseUrl = hymnalRef.music.mp3;
      audioSources.push(`${baseUrl}/${hymn.number}.mp3`);
      
      // Also try with explicit audio hint for better content-type detection
      if (baseUrl.includes('raw.githubusercontent.com')) {
        // Add URL parameters that might help with content type
        audioSources.push(`${baseUrl}/${hymn.number}.mp3?raw=true`);
      }
    }
    if (formatToUse === 'midi' && hymnalRef.music.midi) {
      const midiUrls = Array.isArray(hymnalRef.music.midi) 
        ? hymnalRef.music.midi 
        : [hymnalRef.music.midi];
      
      midiUrls.forEach(url => {
        audioSources.push(`${url}/${hymn.number}.mid`);
        // Also try with raw parameter for GitHub URLs
        if (url.includes('raw.githubusercontent.com')) {
          audioSources.push(`${url}/${hymn.number}.mid?raw=true`);
        }
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
      setIsLoading(true);
      setLoadingProgress(10);
      
      // Load html-midi-player library (modern 2024 solution using Google Magenta.js)
      if (typeof window !== 'undefined' && !customElements.get('midi-player')) {
        setLoadingProgress(20);
        // Load the html-midi-player library from CDN
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/combine/npm/tone@14.7.58,npm/@magenta/music@1.23.1/es6/core.js,npm/focus-visible@5,npm/html-midi-player@1.4.0';
        script.async = true;
        document.head.appendChild(script);
        
        await new Promise((resolve, reject) => {
          script.onload = resolve;
          script.onerror = () => reject(new Error('Failed to load MIDI player library'));
        });
        
        setLoadingProgress(50);
        // Wait a bit for the custom elements to be registered
        await new Promise(resolve => setTimeout(resolve, 500));
      }

      setLoadingProgress(70);
      // Create a hidden MIDI player element
      let midiPlayer = document.getElementById('hidden-midi-player') as any;
      if (!midiPlayer) {
        midiPlayer = document.createElement('midi-player');
        midiPlayer.id = 'hidden-midi-player';
        midiPlayer.style.display = 'none';
        document.body.appendChild(midiPlayer);
      }

      // Configure loop setting
      midiPlayer.loop = loopEnabled;

      setLoadingProgress(80);
      // Set the MIDI file source and play
      midiPlayer.src = midiUrl;
      
      // Wait for the player to load
      await new Promise((resolve, reject) => {
        midiPlayer.addEventListener('load', resolve, { once: true });
        midiPlayer.addEventListener('error', reject, { once: true });
      });

      setLoadingProgress(90);
      // Add event listeners for playback state
      midiPlayer.addEventListener('play', () => {
        console.log('MIDI play event fired');
        setIsPlaying(true);
        // Try to get MIDI duration
        if (midiPlayer.duration) {
          setDuration(midiPlayer.duration);
        }
      });
      midiPlayer.addEventListener('pause', () => {
        console.log('MIDI pause event fired');
        setIsPlaying(false);
      });
      midiPlayer.addEventListener('stop', () => {
        console.log('MIDI stop event fired');
        setIsPlaying(false);
      });
      midiPlayer.addEventListener('load', () => {
        console.log('MIDI load event fired');
        // Set duration when MIDI loads
        if (midiPlayer.duration) {
          setDuration(midiPlayer.duration);
        }
      });

      // Start playback
      midiPlayer.start();
      setCurrentPlayer(midiPlayer);
      
      // Manually set playing state for MIDI since events might not fire immediately
      setIsPlaying(true);
      setLoadingProgress(100);
      setIsLoading(false);
      console.log('Playing MIDI file:', midiUrl);
      
    } catch (error) {
      console.error('Failed to play MIDI file:', error);
      setIsLoading(false);
      setLoadingProgress(0);
      
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
      // Provide more specific error message based on format
      const isMP3 = sources.some(src => src.includes('.mp3'));
      const isMIDI = sources.some(src => src.includes('.mid'));
      
      let errorMessage = 'Audio file could not be loaded for this hymn.';
      if (isMP3 && selectedFormat === 'mp3') {
        errorMessage = `MP3 audio is not available for hymn #${hymn.number}. Try MIDI format instead.`;
      } else if (isMIDI && selectedFormat === 'midi') {
        errorMessage = `MIDI audio is not available for hymn #${hymn.number}.`;
      }
      
      alert(errorMessage);
      setIsLoading(false);
      setLoadingProgress(0);
      return;
    }

    const currentSource = sources[index];
    
    // Special handling for MIDI files
    if (currentSource.endsWith('.mid')) {
      playMidiFile(currentSource);
      return;
    }

    setIsLoading(true);
    setLoadingProgress(10);
    
    const audio = new Audio();
    
    // Add loop if enabled
    audio.loop = loopEnabled;
    
    // Try to handle GitHub raw URLs with incorrect content-type
    if (currentSource.includes('raw.githubusercontent.com') && currentSource.endsWith('.mp3')) {
      // Set crossOrigin to handle CORS properly
      audio.crossOrigin = 'anonymous';
    }
    
    // Enhanced progress tracking
    audio.onloadstart = () => {
      console.log('Started loading audio:', currentSource);
      setLoadingProgress(20);
    };
    
    audio.onprogress = (event) => {
      if (event.lengthComputable) {
        const percentComplete = (event.loaded / event.total) * 100;
        setLoadingProgress(Math.min(20 + (percentComplete * 0.6), 80)); // Progress from 20% to 80%
        console.log(`Download progress: ${percentComplete.toFixed(1)}%`);
      }
    };
    
    audio.onloadeddata = () => {
      console.log('Audio data loaded, attempting to play');
      setLoadingProgress(85);
      audio.play().catch((error) => {
        console.error('Error playing audio:', error);
        setIsLoading(false);
        setLoadingProgress(0);
        // Try next source instead of showing alert immediately
        tryPlayAudio(sources, index + 1);
      });
    };

    audio.oncanplaythrough = () => {
      console.log('Audio can play through');
      setLoadingProgress(100);
      setIsLoading(false);
    };
    
    // Note: ontimeout is not a standard HTMLAudioElement event
    // We'll rely on onabort and onerror for timeout handling

    audio.onplay = () => {
      console.log('MP3 play event fired');
      setIsPlaying(true);
      setCurrentPlayer(audio);
      setDuration(audio.duration || 0);
    };

    audio.onpause = () => {
      setIsPlaying(false);
    };

    audio.onended = () => {
      setIsPlaying(false);
      if (!loopEnabled) {
        setCurrentPlayer(null);
        setCurrentTime(0);
        setDuration(0);
      }
    };

    audio.onloadedmetadata = () => {
      setDuration(audio.duration || 0);
    };

    audio.onerror = (event) => {
      const error = audio.error;
      let errorMessage = 'Unknown error';
      
      if (error) {
        switch (error.code) {
          case error.MEDIA_ERR_ABORTED:
            errorMessage = 'Download aborted';
            break;
          case error.MEDIA_ERR_NETWORK:
            errorMessage = 'Network error during download';
            break;
          case error.MEDIA_ERR_DECODE:
            errorMessage = 'Audio decode error';
            break;
          case error.MEDIA_ERR_SRC_NOT_SUPPORTED:
            errorMessage = 'Audio format not supported';
            break;
        }
      }
      
      console.log(`Failed to load ${sources[index]} (${errorMessage}), trying next source...`);
      console.log('Full error details:', error);
      console.log('Response headers check needed for:', sources[index]);
      setLoadingProgress(0);
      
      // Add a small delay before trying next source to avoid rapid retries
      setTimeout(() => {
        tryPlayAudio(sources, index + 1);
      }, 500);
    };

    audio.src = sources[index];
    audio.load();
  };

  const handleStopAudio = () => {
    if (currentPlayer) {
      if (currentPlayer.pause) {
        // HTML Audio element
        currentPlayer.pause();
        currentPlayer.currentTime = 0;
      } else if (currentPlayer.stop) {
        // MIDI player
        currentPlayer.stop();
      }
      setIsPlaying(false);
      setCurrentPlayer(null);
      setCurrentTime(0);
      setDuration(0);
      setPointA(null);
      setPointB(null);
      setIsABLooping(false);
    }
  };

  const handlePauseResumeAudio = () => {
    if (currentPlayer) {
      if (isPlaying) {
        // Pause the audio
        if (currentPlayer.pause) {
          // HTML Audio element
          currentPlayer.pause();
        } else if (currentPlayer.stop) {
          // MIDI player doesn't have pause, use stop
          currentPlayer.stop();
        }
        setIsPlaying(false);
        console.log('Audio paused');
      } else {
        // Resume the audio
        if (currentPlayer.play) {
          // HTML Audio element
          currentPlayer.play();
        } else if (currentPlayer.start) {
          // MIDI player
          currentPlayer.start();
        }
        setIsPlaying(true);
        console.log('Audio resumed');
      }
    }
  };

  const toggleLoop = () => {
    const newLoopState = !loopEnabled;
    setLoopEnabled(newLoopState);
    
    // Apply loop setting to current player
    if (currentPlayer) {
      if (currentPlayer.play && currentPlayer.pause) {
        // HTML Audio element
        currentPlayer.loop = newLoopState;
        console.log('HTML Audio loop set to:', newLoopState);
      } else if (currentPlayer.start && currentPlayer.stop) {
        // MIDI player - loop property should exist
        if (currentPlayer.loop !== undefined) {
          currentPlayer.loop = newLoopState;
          console.log('MIDI player loop set to:', newLoopState);
        } else {
          console.log('MIDI player does not support loop property');
        }
      }
    }
  };

  const setLoopPointA = () => {
    if (currentPlayer && currentTime) {
      setPointA(currentTime);
      console.log('Set Point A at:', currentTime);
    }
  };

  const setLoopPointB = () => {
    if (currentPlayer && currentTime) {
      setPointB(currentTime);
      console.log('Set Point B at:', currentTime);
    }
  };

  const toggleABLoop = () => {
    if (pointA !== null && pointB !== null) {
      const newABLoopState = !isABLooping;
      setIsABLooping(newABLoopState);
      console.log('A-B Loop toggled to:', newABLoopState);
      console.log('Points A:', pointA, 'B:', pointB);
      
      if (newABLoopState && currentPlayer) {
        // Jump to point A when starting A-B loop
        currentPlayer.currentTime = pointA;
        console.log('Jumped to Point A:', pointA);
      }
    } else {
      alert('Please set both Point A and Point B first');
      console.log('A-B Loop failed - Points A:', pointA, 'B:', pointB);
    }
  };

  const clearLoopPoints = () => {
    setPointA(null);
    setPointB(null);
    setIsABLooping(false);
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
    <div className="mt-8 space-y-4 action-buttons no-print">
      {/* Progress indicator */}
      {isLoading && (
        <div className="flex justify-center">
          <div className="w-64 bg-white/10 rounded-full h-2">
            <div 
              className="bg-primary-500 h-2 rounded-full transition-all duration-300"
              style={{ width: `${loadingProgress}%` }}
            />
          </div>
        </div>
      )}

      <div className="flex flex-wrap justify-center gap-2 sm:gap-4">
        {/* Audio Controls */}
        <div className="relative" ref={dropdownRef}>
          <div className="flex">
            {/* Play Button - only show when not playing and not loading */}
            {!isPlaying && !isLoading && (
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
            )}
            
            {/* Loading Button */}
            {isLoading && (
              <button 
                disabled={true}
                className={`inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 bg-white/10 text-white border border-white/20 font-medium transition-colors duration-200 text-xs sm:text-sm opacity-50 cursor-not-allowed ${
                  availableFormats.length > 1 ? 'rounded-l-lg' : 'rounded-lg'
                }`}
              >
                <div className="animate-spin rounded-full h-3 w-3 sm:h-4 sm:w-4 border-b-2 border-white mr-1 sm:mr-2"></div>
                <span className="sm:hidden">Loading</span>
                <span className="hidden sm:inline">Loading...</span>
              </button>
            )}
            
            {/* Pause Button - only show when playing */}
            {isPlaying && (
              <button 
                onClick={handlePauseResumeAudio}
                className={`inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 font-medium transition-colors duration-200 text-xs sm:text-sm ${
                  availableFormats.length > 1 ? 'rounded-l-lg' : 'rounded-lg'
                }`}
              >
                <PauseIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
                <span className="sm:hidden">Pause</span>
                <span className="hidden sm:inline">Pause {currentFormat?.label}</span>
              </button>
            )}
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

        {/* Additional Audio Controls - only show when playing */}
        {currentPlayer && (
          <>
            <button 
              onClick={handleStopAudio}
              className="inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
            >
              <StopIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="hidden sm:inline">Stop</span>
            </button>

            <button 
              onClick={toggleLoop}
              className={`inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 border border-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm ${
                loopEnabled 
                  ? 'bg-primary-500 text-white hover:bg-primary-600' 
                  : 'bg-white/10 text-white hover:bg-white/20'
              }`}
            >
              <ArrowPathIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="hidden sm:inline">Loop</span>
            </button>

            <button 
              onClick={() => setShowAdvancedPlayer(!showAdvancedPlayer)}
              className="inline-flex items-center px-2 py-1.5 sm:px-3 sm:py-2 bg-white/10 text-white border border-white/20 hover:bg-white/20 rounded-lg font-medium transition-colors duration-200 text-xs sm:text-sm"
            >
              <Cog6ToothIcon className="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" />
              <span className="hidden sm:inline">Advanced</span>
            </button>
          </>
        )}
      
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

      {/* Advanced Player Panel */}
      {showAdvancedPlayer && currentPlayer && (
        <div className="mt-4 p-4 bg-white/5 border border-white/20 rounded-lg">
          <h4 className="text-white font-medium mb-3 text-sm">Advanced Audio Controls</h4>
          
          {/* Progress Bar (for HTML Audio and MIDI) */}
          <div className="mb-4">
            <div className="flex justify-between text-xs text-white/70 mb-1">
              <span>Position</span>
              <span>
                {duration > 0 
                  ? `${Math.floor(currentTime / 60)}:${String(Math.floor(currentTime % 60)).padStart(2, '0')} / ${Math.floor(duration / 60)}:${String(Math.floor(duration % 60)).padStart(2, '0')}`
                  : `${Math.floor(currentTime / 60)}:${String(Math.floor(currentTime % 60)).padStart(2, '0')}`
                }
              </span>
            </div>
            <div className="w-full bg-white/10 rounded-full h-2">
              <div 
                className="bg-primary-500 h-2 rounded-full transition-all duration-300 cursor-pointer"
                style={{ width: duration > 0 ? `${(currentTime / duration) * 100}%` : '0%' }}
                onClick={(e) => {
                  if (duration > 0) {
                    const rect = e.currentTarget.parentElement?.getBoundingClientRect();
                    if (rect) {
                      const clickX = e.clientX - rect.left;
                      const newTime = (clickX / rect.width) * duration;
                      if (currentPlayer && currentPlayer.currentTime !== undefined) {
                        currentPlayer.currentTime = newTime;
                      }
                    }
                  }
                }}
              />
            </div>
          </div>

          {/* Multi-Channel Mixer */}
          <div className="mb-4">
            <label className="block text-xs text-white/70 mb-2">Audio Mixer</label>
            <div className="grid grid-cols-2 gap-3">
              {/* Master Volume */}
              <div className="col-span-2">
                <div className="flex justify-between text-xs text-white/60 mb-1">
                  <span>Master</span>
                  <span>{Math.round(channelVolumes.master * 100)}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="1"
                  step="0.05"
                  value={channelVolumes.master}
                  onChange={(e) => {
                    const newVolume = parseFloat(e.target.value);
                    setChannelVolumes(prev => ({ ...prev, master: newVolume }));
                    if (currentPlayer.volume !== undefined) {
                      currentPlayer.volume = newVolume;
                    }
                  }}
                  className="w-full h-2 bg-white/10 rounded-lg appearance-none cursor-pointer"
                />
              </div>
              
              {/* Left/Right Balance for HTML Audio */}
              {currentPlayer.playbackRate !== undefined && (
                <>
                  <div>
                    <div className="flex justify-between text-xs text-white/60 mb-1">
                      <span>Left</span>
                      <span>{Math.round(channelVolumes.left * 100)}%</span>
                    </div>
                    <input
                      type="range"
                      min="0"
                      max="1"
                      step="0.05"
                      value={channelVolumes.left}
                      onChange={(e) => {
                        const newVolume = parseFloat(e.target.value);
                        setChannelVolumes(prev => ({ ...prev, left: newVolume }));
                        // Apply to audio context if available
                      }}
                      className="w-full h-1 bg-white/10 rounded-lg appearance-none cursor-pointer"
                    />
                  </div>
                  
                  <div>
                    <div className="flex justify-between text-xs text-white/60 mb-1">
                      <span>Right</span>
                      <span>{Math.round(channelVolumes.right * 100)}%</span>
                    </div>
                    <input
                      type="range"
                      min="0"
                      max="1"
                      step="0.05"
                      value={channelVolumes.right}
                      onChange={(e) => {
                        const newVolume = parseFloat(e.target.value);
                        setChannelVolumes(prev => ({ ...prev, right: newVolume }));
                        // Apply to audio context if available
                      }}
                      className="w-full h-1 bg-white/10 rounded-lg appearance-none cursor-pointer"
                    />
                  </div>
                </>
              )}
              
              {/* MIDI Channel Controls */}
              {currentPlayer.playbackRate === undefined && (
                <>
                  <div>
                    <div className="flex justify-between text-xs text-white/60 mb-1">
                      <span>Melody</span>
                      <span>{Math.round(channelVolumes.melody * 100)}%</span>
                    </div>
                    <input
                      type="range"
                      min="0"
                      max="1"
                      step="0.05"
                      value={channelVolumes.melody}
                      onChange={(e) => {
                        const newVolume = parseFloat(e.target.value);
                        setChannelVolumes(prev => ({ ...prev, melody: newVolume }));
                        // MIDI channel control would be implemented here
                      }}
                      className="w-full h-1 bg-white/10 rounded-lg appearance-none cursor-pointer"
                    />
                  </div>
                  
                  <div>
                    <div className="flex justify-between text-xs text-white/60 mb-1">
                      <span>Bass</span>
                      <span>{Math.round(channelVolumes.bass * 100)}%</span>
                    </div>
                    <input
                      type="range"
                      min="0"
                      max="1"
                      step="0.05"
                      value={channelVolumes.bass}
                      onChange={(e) => {
                        const newVolume = parseFloat(e.target.value);
                        setChannelVolumes(prev => ({ ...prev, bass: newVolume }));
                        // MIDI channel control would be implemented here
                      }}
                      className="w-full h-1 bg-white/10 rounded-lg appearance-none cursor-pointer"
                    />
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Playback Speed */}
          <div className="mb-4">
            <label className="block text-xs text-white/70 mb-1">Speed</label>
            <div className="flex gap-2">
              {[0.5, 0.75, 1, 1.25, 1.5, 2].map(speed => (
                <button
                  key={speed}
                  onClick={() => {
                    if (currentPlayer.playbackRate !== undefined) {
                      currentPlayer.playbackRate = speed;
                    }
                  }}
                  disabled={currentPlayer.playbackRate === undefined}
                  className={`px-2 py-1 text-xs rounded transition-colors ${
                    currentPlayer.playbackRate !== undefined && currentPlayer.playbackRate === speed 
                      ? 'bg-primary-500 text-white' 
                      : currentPlayer.playbackRate === undefined
                        ? 'bg-white/5 text-white/30 cursor-not-allowed'
                        : 'bg-white/10 text-white/70 hover:bg-white/20'
                  }`}
                >
                  {speed}x
                </button>
              ))}
            </div>
            {currentPlayer.playbackRate === undefined && (
              <p className="text-xs text-white/50 mt-1">Speed control not available for MIDI files</p>
            )}
          </div>

          {/* A-B Loop Section */}
          <div>
            <label className="block text-xs text-white/70 mb-1">Section Loop</label>
            <div className="flex gap-2 text-xs flex-wrap">
              <button 
                onClick={setLoopPointA}
                className="px-2 py-1 bg-white/10 text-white rounded hover:bg-white/20"
              >
                Set Point A {pointA !== null ? `(${Math.floor(pointA/60)}:${String(Math.floor(pointA%60)).padStart(2,'0')})` : ''}
              </button>
              <button 
                onClick={setLoopPointB}
                className="px-2 py-1 bg-white/10 text-white rounded hover:bg-white/20"
              >
                Set Point B {pointB !== null ? `(${Math.floor(pointB/60)}:${String(Math.floor(pointB%60)).padStart(2,'0')})` : ''}
              </button>
              <button 
                onClick={toggleABLoop}
                className={`px-2 py-1 rounded ${
                  isABLooping 
                    ? 'bg-primary-500 text-white hover:bg-primary-600' 
                    : 'bg-white/10 text-white hover:bg-white/20'
                } ${pointA === null || pointB === null ? 'opacity-50 cursor-not-allowed' : ''}`}
                disabled={pointA === null || pointB === null}
              >
                {isABLooping ? 'Stop A-B Loop' : 'Loop A-B'}
              </button>
              <button 
                onClick={clearLoopPoints}
                className="px-2 py-1 bg-white/10 text-white rounded hover:bg-white/20"
                disabled={pointA === null && pointB === null}
              >
                Clear Points
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}