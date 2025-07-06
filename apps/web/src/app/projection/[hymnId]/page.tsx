'use client';

import { useEffect, useState, useCallback } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { 
  ProjectionSlide, 
  ProjectionSettings
} from '@advent-hymnals/shared';
import {
  generateProjectionSlides,
  formatSlideContent,
  getSlideTitle,
  getProjectionThemeClasses,
  getFontSizeClasses,
  getKeyboardShortcuts
} from '@advent-hymnals/shared';
import { loadHymn, loadHymnalReferences, loadHymnalHymns } from '@/lib/data';
import { classNames } from '@/lib/utils';
import { 
  ChevronLeftIcon, 
  ChevronRightIcon, 
  HomeIcon, 
  Cog6ToothIcon,
  QuestionMarkCircleIcon,
  XMarkIcon,
  ListBulletIcon,
  MagnifyingGlassIcon
} from '@heroicons/react/24/outline';

interface ProjectionPageProps {
  params: {
    hymnId: string;
  };
}

const defaultSettings: ProjectionSettings = {
  showVerseNumbers: true,
  showChorusAfterEachVerse: true,
  fontSize: 'large',
  theme: 'light',
  showMetadata: true,
  autoAdvance: false,
};

export default function ProjectionPage({ params }: ProjectionPageProps) {
  const searchParams = useSearchParams();
  const router = useRouter();
  const [hymn, setHymn] = useState<any>(null);
  const [slides, setSlides] = useState<ProjectionSlide[]>([]);
  const [currentSlide, setCurrentSlide] = useState(0);
  const [settings, setSettings] = useState<ProjectionSettings>(defaultSettings);
  const [showControls, setShowControls] = useState(true);
  const [showHelp, setShowHelp] = useState(false);
  const [showIndex, setShowIndex] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [autoAdvanceTimer, setAutoAdvanceTimer] = useState<NodeJS.Timeout | null>(null);
  const [hymnalData, setHymnalData] = useState<any>(null);
  const [allHymns, setAllHymns] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState('');

  // Auto-enter fullscreen on mount
  useEffect(() => {
    const enterFullscreen = async () => {
      try {
        if (!document.fullscreenElement) {
          await document.documentElement.requestFullscreen();
          setIsFullscreen(true);
        }
      } catch (error) {
        console.warn('Could not enter fullscreen:', error);
        // Try alternative method for older browsers
        try {
          const elem = document.documentElement as any;
          if (elem.webkitRequestFullscreen) {
            await elem.webkitRequestFullscreen();
            setIsFullscreen(true);
          } else if (elem.mozRequestFullScreen) {
            await elem.mozRequestFullScreen();
            setIsFullscreen(true);
          } else if (elem.msRequestFullscreen) {
            await elem.msRequestFullscreen();
            setIsFullscreen(true);
          }
        } catch (fallbackError) {
          console.warn('Fallback fullscreen also failed:', fallbackError);
        }
      }
    };
    
    // Add user interaction handler for browsers that require it
    const handleClick = () => {
      if (!document.fullscreenElement) {
        enterFullscreen();
      }
      document.removeEventListener('click', handleClick);
    };
    
    // Try immediately, and if that fails, wait for user interaction
    enterFullscreen().catch(() => {
      console.log('Waiting for user interaction to enter fullscreen...');
      document.addEventListener('click', handleClick);
    });
    
    return () => {
      document.removeEventListener('click', handleClick);
    };
  }, []);

  // Load hymn and hymnal data
  useEffect(() => {
    const loadData = async () => {
      try {
        const hymnData = await loadHymn(params.hymnId);
        setHymn(hymnData);
        
        // Extract hymnal ID from hymn ID (e.g., "SDAH-en-001" -> "SDAH")
        const hymnalId = params.hymnId.split('-')[0];
        
        // Load hymnal references and hymns
        const references = await loadHymnalReferences();
        const hymnalRef = references.hymnals[hymnalId];
        if (hymnalRef) {
          setHymnalData(hymnalRef);
          
          // Load all hymns from this hymnal
          const hymnsData = await loadHymnalHymns(hymnalId, 1, 1000); // Load first 1000 hymns
          setAllHymns(hymnsData.hymns);
        }
      } catch (error) {
        console.error('Failed to load data:', error);
      }
    };

    loadData();
  }, [params.hymnId]);

  // Parse settings from URL
  useEffect(() => {
    const settingsParam = searchParams.get('settings');
    if (settingsParam) {
      try {
        const parsedSettings = JSON.parse(settingsParam);
        setSettings({ ...defaultSettings, ...parsedSettings });
      } catch (error) {
        console.error('Failed to parse settings:', error);
      }
    }

    const slideParam = searchParams.get('slide');
    if (slideParam) {
      const slideIndex = parseInt(slideParam, 10);
      if (!isNaN(slideIndex)) {
        setCurrentSlide(slideIndex);
      }
    }
  }, [searchParams]);

  // Generate slides when hymn or settings change
  useEffect(() => {
    if (hymn) {
      const generatedSlides = generateProjectionSlides(hymn, settings);
      setSlides(generatedSlides);
    }
  }, [hymn, settings]);

  // Auto advance functionality
  useEffect(() => {
    if (settings.autoAdvance && settings.autoAdvanceDelay) {
      const timer = setTimeout(() => {
        nextSlide();
      }, settings.autoAdvanceDelay * 1000);
      
      setAutoAdvanceTimer(timer);
      
      return () => {
        if (timer) clearTimeout(timer);
      };
    }
  }, [currentSlide, settings.autoAdvance, settings.autoAdvanceDelay]);

  // Navigation functions
  const nextSlide = useCallback(() => {
    setCurrentSlide(prev => (prev < slides.length - 1 ? prev + 1 : prev));
  }, [slides.length]);

  const previousSlide = useCallback(() => {
    setCurrentSlide(prev => (prev > 0 ? prev - 1 : prev));
  }, []);

  const goToSlide = useCallback((index: number) => {
    if (index >= 0 && index < slides.length) {
      setCurrentSlide(index);
    }
  }, [slides.length]);

  const goToFirstSlide = useCallback(() => {
    setCurrentSlide(0);
  }, []);

  const goToLastSlide = useCallback(() => {
    setCurrentSlide(slides.length - 1);
  }, [slides.length]);

  const toggleFullscreen = useCallback(() => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen();
      setIsFullscreen(true);
    } else {
      document.exitFullscreen();
      setIsFullscreen(false);
    }
  }, []);

  // Navigate to different hymn
  const goToHymn = useCallback((hymnId: string) => {
    const settingsParam = encodeURIComponent(JSON.stringify(settings));
    router.push(`/projection/${hymnId}?settings=${settingsParam}`);
    setShowIndex(false);
  }, [router, settings]);

  // Filter hymns for search
  const filteredHymns = allHymns.filter(h => 
    h.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    h.id.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      // Don't handle keyboard shortcuts when modals are open or user is typing
      const isTyping = (event.target as HTMLElement)?.tagName === 'INPUT';
      const isTextarea = (event.target as HTMLElement)?.tagName === 'TEXTAREA';
      const isContentEditable = (event.target as HTMLElement)?.contentEditable === 'true';
      
      // Disable all keyboard shortcuts when index modal is open or user is typing
      if (showIndex || showHelp || isTyping || isTextarea || isContentEditable) {
        return;
      }
      
      switch (event.key) {
        case ' ':
        case 'ArrowRight':
          event.preventDefault();
          nextSlide();
          break;
        case 'ArrowLeft':
        case 'Backspace':
          event.preventDefault();
          previousSlide();
          break;
        case 'Home':
          event.preventDefault();
          goToFirstSlide();
          break;
        case 'End':
          event.preventDefault();
          goToLastSlide();
          break;
        case 'f':
        case 'F':
          event.preventDefault();
          toggleFullscreen();
          break;
        case 'Escape':
          event.preventDefault();
          if (isFullscreen) {
            document.exitFullscreen();
            setIsFullscreen(false);
          } else {
            window.close();
          }
          break;
        case 'h':
        case 'H':
        case '?':
          event.preventDefault();
          setShowHelp(!showHelp);
          break;
        case 'i':
        case 'I':
          event.preventDefault();
          setShowIndex(!showIndex);
          break;
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
          event.preventDefault();
          const verseNumber = parseInt(event.key);
          const verseSlide = slides.findIndex(slide => 
            slide.type === 'verse' && slide.number === verseNumber
          );
          if (verseSlide !== -1) {
            goToSlide(verseSlide);
          }
          break;
        case 'c':
        case 'C':
          event.preventDefault();
          const chorusSlide = slides.findIndex(slide => slide.type === 'chorus');
          if (chorusSlide !== -1) {
            goToSlide(chorusSlide);
          }
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [nextSlide, previousSlide, goToFirstSlide, goToLastSlide, toggleFullscreen, isFullscreen, showHelp, showIndex, slides, goToSlide]);

  // Hide controls after inactivity
  useEffect(() => {
    let timer: NodeJS.Timeout;
    
    const resetTimer = () => {
      setShowControls(true);
      clearTimeout(timer);
      timer = setTimeout(() => setShowControls(false), 3000);
    };

    const handleMouseMove = () => resetTimer();
    const handleMouseClick = () => resetTimer();

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('click', handleMouseClick);
    
    resetTimer();

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('click', handleMouseClick);
      clearTimeout(timer);
    };
  }, []);

  if (!hymn || slides.length === 0) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-white text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
          <p>Loading hymn...</p>
        </div>
      </div>
    );
  }

  const currentSlideData = slides[currentSlide];
  const themeClasses = getProjectionThemeClasses(settings.theme);
  const fontSizeClasses = getFontSizeClasses(settings.fontSize);
  const slideContent = formatSlideContent(currentSlideData, settings);

  return (
    <div className={classNames(
      'min-h-screen flex flex-col relative',
      themeClasses.container
    )}>
      {/* Watermark */}
      <div className="absolute bottom-4 right-4 opacity-30 text-xs">
        <div className={classNames(
          'font-medium',
          settings.theme === 'light' ? 'text-gray-500' : 'text-gray-400'
        )}>
          Advent Hymnals
        </div>
      </div>

      {/* Main Slide Content */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="text-center max-w-6xl w-full">
          {currentSlideData.type === 'title' && (
            <>
              <h1 className={classNames(
                'font-bold mb-8',
                fontSizeClasses,
                themeClasses.text
              )}>
                {hymn.title}
              </h1>
              {settings.showMetadata && (
                <div className={classNames(
                  'text-2xl md:text-3xl lg:text-4xl space-y-2',
                  settings.theme === 'light' ? 'text-gray-600' : 'text-gray-300'
                )}>
                  {hymn.author && <div>Words: {hymn.author}</div>}
                  {hymn.composer && <div>Music: {hymn.composer}</div>}
                  {hymn.tune && <div>Tune: {hymn.tune}</div>}
                </div>
              )}
            </>
          )}
          
          {(currentSlideData.type === 'verse' || currentSlideData.type === 'chorus') && (
            <>
              {currentSlideData.type === 'verse' && settings.showVerseNumbers && (
                <div className={classNames(
                  'text-xl md:text-2xl lg:text-3xl mb-4 font-semibold',
                  settings.theme === 'light' ? 'text-gray-600' : 'text-gray-300'
                )}>
                  Verse {currentSlideData.number}
                </div>
              )}
              
              {currentSlideData.type === 'chorus' && (
                <div className={classNames(
                  'text-xl md:text-2xl lg:text-3xl mb-4 font-semibold',
                  settings.theme === 'light' ? 'text-gray-600' : 'text-gray-300'
                )}>
                  Chorus
                </div>
              )}
              
              <div className={classNames(
                'leading-relaxed whitespace-pre-line',
                fontSizeClasses,
                themeClasses.text
              )}>
                {slideContent}
              </div>
            </>
          )}
          
          {currentSlideData.type === 'metadata' && (
            <>
              <h2 className={classNames(
                'text-3xl md:text-4xl lg:text-5xl font-semibold mb-8',
                themeClasses.text
              )}>
                Hymn Information
              </h2>
              <div className={classNames(
                'text-xl md:text-2xl lg:text-3xl leading-relaxed whitespace-pre-line',
                themeClasses.text
              )}>
                {slideContent}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Controls */}
      <div className={classNames(
        'absolute bottom-0 left-0 right-0 p-4 transition-opacity duration-300',
        showControls ? 'opacity-100' : 'opacity-0 pointer-events-none'
      )}>
        <div className="flex items-center justify-between bg-black bg-opacity-75 rounded-lg p-4">
          <div className="flex items-center space-x-4">
            <button
              onClick={previousSlide}
              disabled={currentSlide === 0}
              className="p-2 text-white hover:bg-white hover:bg-opacity-20 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronLeftIcon className="h-6 w-6" />
            </button>
            
            <div className="text-white text-sm">
              {currentSlide + 1} / {slides.length}
            </div>
            
            <button
              onClick={nextSlide}
              disabled={currentSlide === slides.length - 1}
              className="p-2 text-white hover:bg-white hover:bg-opacity-20 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronRightIcon className="h-6 w-6" />
            </button>
          </div>

          <div className="text-white text-sm font-medium">
            {getSlideTitle(currentSlideData)}
          </div>

          <div className="flex items-center space-x-2">
            <button
              onClick={() => setShowHelp(true)}
              className="p-2 text-white hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
              title="Help"
            >
              <QuestionMarkCircleIcon className="h-6 w-6" />
            </button>
            
            <button
              onClick={() => setShowIndex(true)}
              className="p-2 text-white hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
              title="Hymn Index (I)"
            >
              <ListBulletIcon className="h-6 w-6" />
            </button>
            
            <button
              onClick={toggleFullscreen}
              className="p-2 text-white hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
              title="Toggle Fullscreen (F)"
            >
              <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" />
              </svg>
            </button>
            
            <button
              onClick={() => window.close()}
              className="p-2 text-white hover:bg-white hover:bg-opacity-20 rounded-lg transition-colors"
              title="Close"
            >
              <XMarkIcon className="h-6 w-6" />
            </button>
          </div>
        </div>
      </div>

      {/* Help Modal */}
      {showHelp && (
        <>
          <div 
            className="fixed inset-0 bg-black bg-opacity-75 z-50"
            onClick={() => setShowHelp(false)}
          />
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
              <div className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-semibold text-gray-900">Keyboard Shortcuts</h3>
                  <button
                    onClick={() => setShowHelp(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <XMarkIcon className="h-6 w-6" />
                  </button>
                </div>
                
                <div className="space-y-2">
                  {[
                    { key: 'Space/→', description: 'Next slide' },
                    { key: '←/Backspace', description: 'Previous slide' },
                    { key: 'Home', description: 'First slide' },
                    { key: 'End', description: 'Last slide' },
                    { key: 'F', description: 'Toggle fullscreen' },
                    { key: 'I', description: 'Show hymn index' },
                    { key: 'H/?', description: 'Show help' },
                    { key: 'Esc', description: 'Exit fullscreen/Close' },
                    { key: '1-9', description: 'Jump to verse' },
                    { key: 'C', description: 'Jump to chorus' }
                  ].map((shortcut, index) => (
                    <div key={index} className="flex justify-between">
                      <span className="font-mono text-sm bg-gray-100 px-2 py-1 rounded">
                        {shortcut.key}
                      </span>
                      <span className="text-sm text-gray-600">{shortcut.description}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </>
      )}

      {/* Hymn Index Modal */}
      {showIndex && (
        <>
          <div 
            className="fixed inset-0 bg-black bg-opacity-75 z-50"
            onClick={() => setShowIndex(false)}
          />
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[80vh] flex flex-col">
              <div className="p-6 border-b">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-xl font-semibold text-gray-900">
                    {hymnalData?.name || 'Hymnal'} - Select Hymn
                  </h3>
                  <button
                    onClick={() => setShowIndex(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <XMarkIcon className="h-6 w-6" />
                  </button>
                </div>
                
                <div className="relative">
                  <MagnifyingGlassIcon className="h-5 w-5 absolute left-3 top-3 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Search hymns..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
              </div>
              
              <div className="flex-1 overflow-y-auto p-6">
                <div className="grid gap-2">
                  {filteredHymns.slice(0, 100).map((h) => (
                    <button
                      key={h.id}
                      onClick={() => goToHymn(h.id)}
                      className={`p-3 text-left rounded-lg border transition-colors hover:bg-blue-50 hover:border-blue-300 ${
                        h.id === params.hymnId 
                          ? 'bg-blue-100 border-blue-500' 
                          : 'bg-gray-50 border-gray-200'
                      }`}
                    >
                      <div className="font-medium text-gray-900">
                        {h.number ? `${h.number}. ` : ''}{h.title}
                      </div>
                      {h.author && (
                        <div className="text-sm text-gray-600 mt-1">
                          {h.author}
                        </div>
                      )}
                    </button>
                  ))}
                  
                  {filteredHymns.length === 0 && (
                    <div className="text-center py-8 text-gray-500">
                      No hymns found matching your search.
                    </div>
                  )}
                  
                  {filteredHymns.length > 100 && (
                    <div className="text-center py-4 text-gray-500">
                      Showing first 100 results. Refine your search to see more.
                    </div>
                  )}
                </div>
              </div>
              
              <div className="p-6 border-t bg-gray-50 text-sm text-gray-600">
                <div className="flex justify-between items-center">
                  <span>Press <kbd className="bg-white px-2 py-1 rounded border">I</kbd> to toggle this index</span>
                  <span>{filteredHymns.length} hymns available</span>
                </div>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}