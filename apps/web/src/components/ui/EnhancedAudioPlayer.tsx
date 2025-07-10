'use client';

import { useState, useEffect } from 'react';
import { getDeviceType } from '@/lib/pdf-utils';
import MobileAudioPlayer from './MobileAudioPlayer';

interface EnhancedAudioPlayerProps {
  hymn: {
    title: string;
    number: number;
  };
  hymnalRef?: {
    id: string;
    music?: {
      mp3?: string;
      midi?: string | string[];
    };
  };
  className?: string;
}

export default function EnhancedAudioPlayer({
  hymn,
  hymnalRef,
  className = ''
}: EnhancedAudioPlayerProps) {
  const [deviceType, setDeviceType] = useState<'desktop' | 'mobile'>('desktop');
  const [audioSources, setAudioSources] = useState<string[]>([]);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setDeviceType(getDeviceType());
  }, []);

  useEffect(() => {
    generateAudioSources();
  }, [hymn, hymnalRef]);

  const generateAudioSources = () => {
    if (!hymnalRef?.music) {
      setAudioSources([]);
      return;
    }

    const sources: string[] = [];

    // For mobile, prioritize MP3 over MIDI
    if (deviceType === 'mobile') {
      // Add MP3 sources first (better mobile support)
      if (hymnalRef.music.mp3) {
        // Try CDN first
        sources.push(`https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mp3`);
        
        // Try direct GitHub source
        sources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3`);
        
        // Try with raw parameter for better GitHub compatibility
        if (hymnalRef.music.mp3.includes('raw.githubusercontent.com')) {
          sources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3?raw=true`);
        }
      }

      // Add MIDI sources as fallback (limited mobile support)
      if (hymnalRef.music.midi) {
        const midiUrls = Array.isArray(hymnalRef.music.midi) 
          ? hymnalRef.music.midi 
          : [hymnalRef.music.midi];
        
        midiUrls.forEach(url => {
          sources.push(`https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mid`);
          sources.push(`${url}/${hymn.number}.mid`);
          if (url.includes('raw.githubusercontent.com')) {
            sources.push(`${url}/${hymn.number}.mid?raw=true`);
          }
        });
      }
    } else {
      // For desktop, try MIDI first (better quality), then MP3
      if (hymnalRef.music.midi) {
        const midiUrls = Array.isArray(hymnalRef.music.midi) 
          ? hymnalRef.music.midi 
          : [hymnalRef.music.midi];
        
        midiUrls.forEach(url => {
          sources.push(`https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mid`);
          sources.push(`${url}/${hymn.number}.mid`);
          if (url.includes('raw.githubusercontent.com')) {
            sources.push(`${url}/${hymn.number}.mid?raw=true`);
          }
        });
      }

      if (hymnalRef.music.mp3) {
        sources.push(`https://media.adventhymnals.org/audio/${hymnalRef.id}/${hymn.number}.mp3`);
        sources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3`);
        if (hymnalRef.music.mp3.includes('raw.githubusercontent.com')) {
          sources.push(`${hymnalRef.music.mp3}/${hymn.number}.mp3?raw=true`);
        }
      }
    }

    setAudioSources(sources);
    setIsVisible(sources.length > 0);
  };

  const handlePlayStart = () => {
    console.log(`Playing hymn ${hymn.number}: ${hymn.title}`);
  };

  const handlePlayPause = () => {
    console.log(`Paused hymn ${hymn.number}: ${hymn.title}`);
  };

  const handleError = (error: string) => {
    console.error(`Audio error for hymn ${hymn.number}:`, error);
  };

  if (!isVisible || audioSources.length === 0) {
    return null;
  }

  return (
    <div className={`${className}`}>
      {deviceType === 'mobile' ? (
        <MobileAudioPlayer
          audioSources={audioSources}
          title={`${hymn.title} - #${hymn.number}`}
          onPlay={handlePlayStart}
          onPause={handlePlayPause}
          onError={handleError}
        />
      ) : (
        // Desktop version - you can keep the existing complex audio player here
        // or create a separate DesktopAudioPlayer component
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
          <div className="text-sm text-blue-800 mb-2">
            🎵 Enhanced Audio Player (Desktop)
          </div>
          <div className="text-xs text-blue-600">
            Desktop version with full MIDI support and advanced controls
          </div>
          {/* Here you would include the existing desktop audio player logic */}
        </div>
      )}
      
      {/* Debug info in development */}
      {process.env.NODE_ENV === 'development' && (
        <details className="mt-2 text-xs text-gray-500">
          <summary>Audio Debug Info</summary>
          <div className="mt-1 space-y-1">
            <div>Device: {deviceType}</div>
            <div>Sources: {audioSources.length}</div>
            <div>Available formats: {[
              hymnalRef?.music?.mp3 ? 'MP3' : null,
              hymnalRef?.music?.midi ? 'MIDI' : null
            ].filter(Boolean).join(', ') || 'None'}</div>
          </div>
        </details>
      )}
    </div>
  );
}