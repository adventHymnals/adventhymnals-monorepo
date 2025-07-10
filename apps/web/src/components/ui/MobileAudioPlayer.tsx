'use client';

import { useState, useEffect, useRef } from 'react';
import { PlayIcon, PauseIcon, StopIcon, SpeakerWaveIcon, SpeakerXMarkIcon } from '@heroicons/react/24/outline';

interface MobileAudioPlayerProps {
  audioSources: string[];
  title: string;
  onPlay?: () => void;
  onPause?: () => void;
  onError?: (error: string) => void;
}

type PlayerState = 'idle' | 'loading' | 'playing' | 'paused' | 'error';

export default function MobileAudioPlayer({
  audioSources,
  title,
  onPlay,
  onPause,
  onError
}: MobileAudioPlayerProps) {
  const [playerState, setPlayerState] = useState<PlayerState>('idle');
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(1);
  const [isMuted, setIsMuted] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentSourceIndex, setCurrentSourceIndex] = useState(0);
  
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const progressBarRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    // Create audio element
    const audio = new Audio();
    audioRef.current = audio;

    // Set up event listeners
    audio.addEventListener('loadstart', () => setPlayerState('loading'));
    audio.addEventListener('loadedmetadata', () => setDuration(audio.duration));
    audio.addEventListener('canplay', () => {
      if (playerState === 'loading') {
        setPlayerState('idle');
      }
    });
    audio.addEventListener('play', () => {
      setPlayerState('playing');
      onPlay?.();
    });
    audio.addEventListener('pause', () => {
      setPlayerState('paused');
      onPause?.();
    });
    audio.addEventListener('ended', () => {
      setPlayerState('idle');
      setCurrentTime(0);
      onPause?.();
    });
    audio.addEventListener('timeupdate', () => {
      setCurrentTime(audio.currentTime);
    });
    audio.addEventListener('error', handleAudioError);
    audio.addEventListener('stalled', () => {
      console.warn('Audio stalled, trying next source...');
      tryNextSource();
    });

    // Mobile-specific optimizations
    audio.preload = 'metadata'; // Don't preload full audio on mobile
    audio.volume = volume;
    audio.muted = isMuted;

    return () => {
      audio.removeEventListener('loadstart', () => setPlayerState('loading'));
      audio.removeEventListener('loadedmetadata', () => setDuration(audio.duration));
      audio.removeEventListener('canplay', () => setPlayerState('idle'));
      audio.removeEventListener('play', () => setPlayerState('playing'));
      audio.removeEventListener('pause', () => setPlayerState('paused'));
      audio.removeEventListener('ended', () => setPlayerState('idle'));
      audio.removeEventListener('timeupdate', () => setCurrentTime(audio.currentTime));
      audio.removeEventListener('error', handleAudioError);
      audio.removeEventListener('stalled', () => tryNextSource());
      audio.pause();
      audio.src = '';
    };
  }, []);

  const handleAudioError = () => {
    const audio = audioRef.current;
    if (!audio) return;

    let errorMessage = 'Unknown audio error';
    if (audio.error) {
      switch (audio.error.code) {
        case audio.error.MEDIA_ERR_ABORTED:
          errorMessage = 'Audio loading was aborted';
          break;
        case audio.error.MEDIA_ERR_NETWORK:
          errorMessage = 'Network error while loading audio';
          break;
        case audio.error.MEDIA_ERR_DECODE:
          errorMessage = 'Audio format not supported';
          break;
        case audio.error.MEDIA_ERR_SRC_NOT_SUPPORTED:
          errorMessage = 'Audio source not supported';
          break;
      }
    }

    console.error('Audio error:', errorMessage);
    
    // Try next source if available
    if (currentSourceIndex < audioSources.length - 1) {
      tryNextSource();
    } else {
      setPlayerState('error');
      setError(errorMessage);
      onError?.(errorMessage);
    }
  };

  const tryNextSource = () => {
    if (currentSourceIndex < audioSources.length - 1) {
      const nextIndex = currentSourceIndex + 1;
      setCurrentSourceIndex(nextIndex);
      loadAudioSource(audioSources[nextIndex]);
    }
  };

  const loadAudioSource = (source: string) => {
    const audio = audioRef.current;
    if (!audio) return;

    setPlayerState('loading');
    setError(null);
    audio.src = source;
    audio.load();
  };

  const handlePlay = async () => {
    const audio = audioRef.current;
    if (!audio) return;

    try {
      // Load first source if not already loaded
      if (!audio.src && audioSources.length > 0) {
        loadAudioSource(audioSources[0]);
        // Wait for metadata to load
        await new Promise((resolve, reject) => {
          const handleLoad = () => {
            audio.removeEventListener('loadedmetadata', handleLoad);
            audio.removeEventListener('error', handleError);
            resolve(void 0);
          };
          const handleError = () => {
            audio.removeEventListener('loadedmetadata', handleLoad);
            audio.removeEventListener('error', handleError);
            reject(new Error('Failed to load audio'));
          };
          audio.addEventListener('loadedmetadata', handleLoad);
          audio.addEventListener('error', handleError);
        });
      }

      // Mobile browsers require user interaction to enable audio
      // This play() call should be triggered by a user gesture
      await audio.play();
    } catch (err) {
      console.error('Play failed:', err);
      if (err instanceof Error) {
        if (err.name === 'NotAllowedError') {
          setError('Audio playback requires user interaction on mobile devices');
        } else {
          setError('Failed to play audio');
        }
      }
      setPlayerState('error');
      onError?.(err instanceof Error ? err.message : 'Play failed');
    }
  };

  const handlePause = () => {
    const audio = audioRef.current;
    if (audio) {
      audio.pause();
    }
  };

  const handleStop = () => {
    const audio = audioRef.current;
    if (audio) {
      audio.pause();
      audio.currentTime = 0;
      setCurrentTime(0);
    }
  };

  const handleSeek = (event: React.MouseEvent<HTMLDivElement>) => {
    const audio = audioRef.current;
    const progressBar = progressBarRef.current;
    if (!audio || !progressBar || duration === 0) return;

    const rect = progressBar.getBoundingClientRect();
    const clickX = event.clientX - rect.left;
    const newTime = (clickX / rect.width) * duration;
    
    audio.currentTime = Math.max(0, Math.min(newTime, duration));
  };

  const handleVolumeChange = (newVolume: number) => {
    const audio = audioRef.current;
    if (audio) {
      audio.volume = newVolume;
      setVolume(newVolume);
      setIsMuted(newVolume === 0);
    }
  };

  const toggleMute = () => {
    const audio = audioRef.current;
    if (audio) {
      const newMuted = !isMuted;
      audio.muted = newMuted;
      setIsMuted(newMuted);
    }
  };

  const formatTime = (time: number): string => {
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const progressPercentage = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4 shadow-sm">
      <div className="mb-3">
        <h4 className="text-sm font-medium text-gray-900 truncate">{title}</h4>
        {error && (
          <p className="text-xs text-red-600 mt-1">{error}</p>
        )}
      </div>

      {/* Main Controls */}
      <div className="flex items-center space-x-3 mb-3">
        {playerState === 'loading' ? (
          <div className="w-8 h-8 border-2 border-gray-300 border-t-blue-600 rounded-full animate-spin" />
        ) : (
          <button
            onClick={playerState === 'playing' ? handlePause : handlePlay}
            disabled={playerState === 'error'}
            className="w-8 h-8 flex items-center justify-center bg-blue-600 text-white rounded-full hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {playerState === 'playing' ? (
              <PauseIcon className="w-4 h-4" />
            ) : (
              <PlayIcon className="w-4 h-4 ml-0.5" />
            )}
          </button>
        )}

        <button
          onClick={handleStop}
          disabled={playerState === 'idle' || playerState === 'error'}
          className="w-8 h-8 flex items-center justify-center text-gray-600 hover:text-gray-900 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <StopIcon className="w-4 h-4" />
        </button>

        {/* Time display */}
        <div className="text-xs text-gray-500 min-w-0 flex-1">
          {formatTime(currentTime)} / {formatTime(duration)}
        </div>

        {/* Volume control */}
        <button
          onClick={toggleMute}
          className="w-6 h-6 flex items-center justify-center text-gray-600 hover:text-gray-900"
        >
          {isMuted || volume === 0 ? (
            <SpeakerXMarkIcon className="w-4 h-4" />
          ) : (
            <SpeakerWaveIcon className="w-4 h-4" />
          )}
        </button>
      </div>

      {/* Progress Bar */}
      <div className="mb-2">
        <div
          ref={progressBarRef}
          onClick={handleSeek}
          className="w-full h-2 bg-gray-200 rounded-full cursor-pointer"
        >
          <div
            className="h-full bg-blue-600 rounded-full transition-all duration-100"
            style={{ width: `${progressPercentage}%` }}
          />
        </div>
      </div>

      {/* Volume slider (mobile-friendly) */}
      <div className="flex items-center space-x-2">
        <span className="text-xs text-gray-500">Volume:</span>
        <input
          type="range"
          min="0"
          max="1"
          step="0.1"
          value={isMuted ? 0 : volume}
          onChange={(e) => handleVolumeChange(parseFloat(e.target.value))}
          className="flex-1 h-1 bg-gray-200 rounded-lg appearance-none cursor-pointer"
        />
        <span className="text-xs text-gray-500 min-w-8">
          {Math.round((isMuted ? 0 : volume) * 100)}%
        </span>
      </div>

      {/* Source indicator for debugging */}
      {audioSources.length > 1 && (
        <div className="mt-2 text-xs text-gray-400">
          Source: {currentSourceIndex + 1} of {audioSources.length}
        </div>
      )}
    </div>
  );
}