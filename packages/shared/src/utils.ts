import { Hymn, MetricalPattern, SupportedLanguage } from './types';

export function generateHymnId(hymnal: string, number: number, language: string): string {
  return `${hymnal}-${language}-${number.toString().padStart(3, '0')}`;
}

export function normalizeMetricalPattern(meter: string): string {
  return meter
    .replace(/[^\d.]/g, '')
    .split('.')
    .map(num => num.trim())
    .filter(num => num.length > 0)
    .join('.');
}

export function extractMetricalPattern(meter: string): MetricalPattern {
  const normalized = normalizeMetricalPattern(meter);
  const variations = [
    meter.trim(),
    normalized
  ].filter((v, i, arr) => arr.indexOf(v) === i);

  return {
    pattern: normalized,
    variations,
    hymns: []
  };
}

export function searchHymnText(hymn: Hymn, query: string): boolean {
  const searchTerm = query.toLowerCase();
  
  if (hymn.title.toLowerCase().includes(searchTerm)) return true;
  if (hymn.author?.toLowerCase().includes(searchTerm)) return true;
  if (hymn.composer?.toLowerCase().includes(searchTerm)) return true;
  if (hymn.tune?.toLowerCase().includes(searchTerm)) return true;
  
  for (const verse of hymn.verses) {
    if (verse.text.toLowerCase().includes(searchTerm)) return true;
  }
  
  if (hymn.chorus?.text.toLowerCase().includes(searchTerm)) return true;
  
  return false;
}

export function validateHymnStructure(hymn: Partial<Hymn>): string[] {
  const errors: string[] = [];
  
  if (!hymn.id) errors.push('Hymn ID is required');
  if (!hymn.title) errors.push('Hymn title is required');
  if (!hymn.language) errors.push('Hymn language is required');
  if (!hymn.verses || hymn.verses.length === 0) errors.push('At least one verse is required');
  
  if (hymn.verses) {
    hymn.verses.forEach((verse, index) => {
      if (!verse.text?.trim()) errors.push(`Verse ${index + 1} text is empty`);
      if (verse.number !== index + 1) errors.push(`Verse ${index + 1} number mismatch`);
    });
  }
  
  return errors;
}

export function formatHymnNumber(number: number, totalHymns: number): string {
  const digits = totalHymns.toString().length;
  return number.toString().padStart(digits, '0');
}

export function getLanguageInfo(code: string): { name: string; native_name: string; rtl: boolean } {
  const languages: Record<string, { name: string; native_name: string; rtl: boolean }> = {
    'en': { name: 'English', native_name: 'English', rtl: false },
    'sw': { name: 'Swahili', native_name: 'Kiswahili', rtl: false },
    'luo': { name: 'Luo', native_name: 'Dholuo', rtl: false },
    'fr': { name: 'French', native_name: 'Français', rtl: false },
    'es': { name: 'Spanish', native_name: 'Español', rtl: false },
    'de': { name: 'German', native_name: 'Deutsch', rtl: false },
    'pt': { name: 'Portuguese', native_name: 'Português', rtl: false },
    'it': { name: 'Italian', native_name: 'Italiano', rtl: false }
  };
  
  return languages[code] || { name: 'Unknown', native_name: 'Unknown', rtl: false };
}

export function calculateTextSimilarity(text1: string, text2: string): number {
  const normalize = (text: string) => text.toLowerCase().replace(/[^\w\s]/g, '').trim();
  const norm1 = normalize(text1);
  const norm2 = normalize(text2);
  
  if (norm1 === norm2) return 1.0;
  
  const words1 = norm1.split(/\s+/);
  const words2 = norm2.split(/\s+/);
  
  const intersection = words1.filter(word => words2.includes(word));
  const unionSet = new Set<string>();
  words1.forEach(word => unionSet.add(word));
  words2.forEach(word => unionSet.add(word));
  const union = Array.from(unionSet);
  
  return intersection.length / union.length;
}

export function extractThemes(hymn: Hymn): string[] {
  const themes: string[] = [];
  const title = hymn.title.toLowerCase();
  const allText = [
    hymn.title,
    ...hymn.verses.map(v => v.text),
    hymn.chorus?.text || ''
  ].join(' ').toLowerCase();
  
  const themeKeywords: Record<string, string[]> = {
    'praise': ['praise', 'glory', 'honor', 'worship', 'adore', 'magnify'],
    'prayer': ['pray', 'prayer', 'petition', 'intercession', 'supplication'],
    'salvation': ['save', 'salvation', 'redeem', 'redemption', 'forgive'],
    'love': ['love', 'beloved', 'dear', 'cherish', 'affection'],
    'peace': ['peace', 'calm', 'rest', 'tranquil', 'serenity'],
    'hope': ['hope', 'faith', 'trust', 'believe', 'confidence'],
    'service': ['serve', 'service', 'work', 'labor', 'ministry'],
    'christmas': ['christmas', 'nativity', 'bethlehem', 'manger', 'wise men'],
    'easter': ['easter', 'resurrection', 'cross', 'calvary', 'tomb'],
    'second_coming': ['coming', 'return', 'appear', 'clouds', 'trumpet']
  };
  
  for (const [theme, keywords] of Object.entries(themeKeywords)) {
    if (keywords.some(keyword => allText.includes(keyword))) {
      themes.push(theme);
    }
  }
  
  return themes;
}

export function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .toLowerCase();
}

// Web application utilities

export function createSlug(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

export function generateHymnSlug(hymn: Hymn): string {
  return createSlug(`hymn-${hymn.number}-${hymn.title}`);
}

export function formatHymnTitle(hymn: Hymn): string {
  return `${hymn.number}. ${hymn.title}`;
}

export function getHymnUrl(hymnalSlug: string, hymn: Hymn): string {
  return `/${hymnalSlug}/${generateHymnSlug(hymn)}`;
}

export function parseHymnNumber(slug: string): number | null {
  const match = slug.match(/hymn-(\d+)-/);
  return match ? parseInt(match[1], 10) : null;
}

export function classNames(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(' ');
}

export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength).replace(/\s+\S*$/, '') + '...';
}

export function pluralize(count: number, singular: string, plural?: string): string {
  if (count === 1) return singular;
  return plural || `${singular}s`;
}

export function formatNumber(num: number): string {
  return new Intl.NumberFormat().format(num);
}

export function getInitials(name: string): string {
  return name
    .split(' ')
    .map(part => part.charAt(0).toUpperCase())
    .join('')
    .slice(0, 2);
}

export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Note: debounce and throttle utilities moved to web app for browser-specific features

// SEO utilities

export function generateMetaDescription(hymn: Hymn, hymnal: string): string {
  const firstVerse = hymn.verses[0]?.text?.split('\n')[0] || '';
  const truncated = truncateText(firstVerse, 120);
  return `${hymn.title} - Hymn ${hymn.number} from ${hymnal}. ${truncated}`;
}

export function generateStructuredData(hymn: Hymn, hymnal: any) {
  return {
    '@context': 'https://schema.org',
    '@type': 'MusicComposition',
    name: hymn.title,
    composer: hymn.composer ? {
      '@type': 'Person',
      name: hymn.composer
    } : undefined,
    lyricist: hymn.author ? {
      '@type': 'Person', 
      name: hymn.author
    } : undefined,
    inLanguage: hymn.language,
    dateCreated: hymn.metadata?.year?.toString(),
    isPartOf: {
      '@type': 'MusicAlbum',
      name: hymnal.title,
      datePublished: hymnal.year?.toString()
    },
    keywords: hymn.metadata?.themes?.join(', '),
    text: hymn.verses.map(v => v.text).join('\n\n')
  };
}

// Note: Browser-specific utilities (localStorage, URL) moved to web app

// Date utilities

export function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  }).format(d);
}

export function formatRelativeTime(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const rtf = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });
  const diff = d.getTime() - Date.now();
  const absDiff = Math.abs(diff);
  
  if (absDiff < 60000) return rtf.format(Math.round(diff / 1000), 'second');
  if (absDiff < 3600000) return rtf.format(Math.round(diff / 60000), 'minute');
  if (absDiff < 86400000) return rtf.format(Math.round(diff / 3600000), 'hour');
  return rtf.format(Math.round(diff / 86400000), 'day');
}