import { Hymn, ProjectionSlide, ProjectionSettings } from './types';

export function generateProjectionSlides(
  hymn: Hymn, 
  settings: ProjectionSettings
): ProjectionSlide[] {
  const slides: ProjectionSlide[] = [];

  // Title slide
  slides.push({
    id: `${hymn.id}-title`,
    type: 'title',
    content: hymn.title,
    metadata: {
      title: hymn.title,
      author: hymn.author,
    },
  });

  // Generate verse and chorus slides
  for (const verse of hymn.verses) {
    // Add verse slide
    slides.push({
      id: `${hymn.id}-verse-${verse.number}`,
      type: 'verse',
      content: verse.text,
      number: verse.number,
      metadata: {
        verseNumber: verse.number,
        isChorus: false,
      },
    });

    // Add chorus after each verse if enabled and chorus exists
    if (settings.showChorusAfterEachVerse && hymn.chorus) {
      slides.push({
        id: `${hymn.id}-chorus-after-${verse.number}`,
        type: 'chorus',
        content: hymn.chorus.text,
        metadata: {
          verseNumber: verse.number,
          isChorus: true,
        },
      });
    }
  }

  // Add final chorus if not shown after each verse
  if (!settings.showChorusAfterEachVerse && hymn.chorus) {
    slides.push({
      id: `${hymn.id}-chorus-final`,
      type: 'chorus',
      content: hymn.chorus.text,
      metadata: {
        isChorus: true,
      },
    });
  }

  // Add metadata slide if enabled
  if (settings.showMetadata) {
    const metadataContent = [
      hymn.author && `Words: ${hymn.author}`,
      hymn.composer && `Music: ${hymn.composer}`,
      hymn.tune && `Tune: ${hymn.tune}`,
      hymn.meter && `Meter: ${hymn.meter}`,
      hymn.metadata?.year && `Year: ${hymn.metadata.year}`,
      hymn.metadata?.copyright && `© ${hymn.metadata.copyright}`,
    ].filter(Boolean).join('\n');

    if (metadataContent) {
      slides.push({
        id: `${hymn.id}-metadata`,
        type: 'metadata',
        content: metadataContent,
      });
    }
  }

  return slides;
}

export function formatSlideContent(
  slide: ProjectionSlide,
  settings: ProjectionSettings
): string {
  let content = slide.content;

  // Add verse number prefix if enabled
  if (settings.showVerseNumbers && slide.type === 'verse' && slide.number) {
    content = `${slide.number}.\n${content}`;
  }

  // Add chorus label if it's a chorus slide
  if (slide.type === 'chorus') {
    content = `Chorus\n${content}`;
  }

  return content;
}

export function getSlideTitle(slide: ProjectionSlide): string {
  switch (slide.type) {
    case 'title':
      return 'Title';
    case 'verse':
      return `Verse ${slide.number}`;
    case 'chorus':
      return 'Chorus';
    case 'metadata':
      return 'Information';
    default:
      return 'Slide';
  }
}

export function getProjectionThemeClasses(theme: ProjectionSettings['theme']): {
  container: string;
  text: string;
  background: string;
} {
  switch (theme) {
    case 'dark':
      return {
        container: 'bg-gray-900 text-white',
        text: 'text-white',
        background: 'bg-gray-900',
      };
    case 'high-contrast':
      return {
        container: 'bg-black text-white',
        text: 'text-white',
        background: 'bg-black',
      };
    case 'light':
    default:
      return {
        container: 'bg-white text-gray-900',
        text: 'text-gray-900',
        background: 'bg-white',
      };
  }
}

export function getFontSizeClasses(fontSize: ProjectionSettings['fontSize']): string {
  switch (fontSize) {
    case 'small':
      return 'text-2xl md:text-3xl lg:text-4xl';
    case 'medium':
      return 'text-3xl md:text-4xl lg:text-5xl';
    case 'large':
      return 'text-4xl md:text-5xl lg:text-6xl';
    case 'extra-large':
      return 'text-5xl md:text-6xl lg:text-7xl xl:text-8xl';
    default:
      return 'text-3xl md:text-4xl lg:text-5xl';
  }
}

export function splitSlideIntoLines(content: string, maxLinesPerSlide: number = 4): string[] {
  const lines = content.split('\n').filter(line => line.trim() !== '');
  
  if (lines.length <= maxLinesPerSlide) {
    return [content];
  }

  const slides: string[] = [];
  for (let i = 0; i < lines.length; i += maxLinesPerSlide) {
    const slideLines = lines.slice(i, i + maxLinesPerSlide);
    slides.push(slideLines.join('\n'));
  }

  return slides;
}

export function getKeyboardShortcuts(): Array<{ key: string; description: string; action: string }> {
  return [
    { key: 'Space / →', description: 'Next slide', action: 'next' },
    { key: '← / Backspace', description: 'Previous slide', action: 'previous' },
    { key: 'Home', description: 'First slide', action: 'first' },
    { key: 'End', description: 'Last slide', action: 'last' },
    { key: 'F', description: 'Toggle fullscreen', action: 'fullscreen' },
    { key: 'Esc', description: 'Exit projection', action: 'exit' },
    { key: 'S', description: 'Settings', action: 'settings' },
    { key: '1-9', description: 'Jump to verse', action: 'jump-verse' },
    { key: 'C', description: 'Jump to chorus', action: 'jump-chorus' },
  ];
}

export function createProjectionURL(hymnId: string, slideIndex?: number): string {
  const baseUrl = `/projection/${hymnId}`;
  return slideIndex !== undefined ? `${baseUrl}?slide=${slideIndex}` : baseUrl;
}