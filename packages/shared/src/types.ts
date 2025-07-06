export interface HymnVerse {
  number: number;
  text: string;
}

export interface HymnChorus {
  text: string;
}

export interface HymnMetadata {
  year?: number;
  copyright?: string;
  themes?: string[];
  scripture_references?: string[];
  tune_source?: string;
  original_language?: string;
  translator?: string;
}

export interface Hymn {
  id: string;
  number: number;
  title: string;
  author?: string;
  composer?: string;
  tune?: string;
  meter?: string;
  language: string;
  verses: HymnVerse[];
  chorus?: HymnChorus;
  metadata?: HymnMetadata;
}

export interface HymnalEntry {
  number: number;
  hymn_id: string;
  title?: string;
  page?: number;
}

export interface HymnalMetadata {
  total_hymns: number;
  languages: string[];
  themes: string[];
  publication_info?: {
    publisher?: string;
    place?: string;
    isbn?: string;
  };
}

export interface Hymnal {
  id: string;
  title: string;
  language: string;
  year: number;
  publisher?: string;
  hymns: HymnalEntry[];
  metadata: HymnalMetadata;
}

export interface Author {
  id: string;
  name: string;
  birth_year?: number;
  death_year?: number;
  nationality?: string;
  biography?: string;
}

export interface Composer {
  id: string;
  name: string;
  birth_year?: number;
  death_year?: number;
  nationality?: string;
  biography?: string;
}

export interface Tune {
  id: string;
  name: string;
  composer_id?: string;
  meter: string;
  year?: number;
  source?: string;
}

export interface MetricalPattern {
  pattern: string;
  variations: string[];
  hymns: string[];
}

export interface ProcessingStatus {
  source_format: 'image' | 'pdf' | 'markdown' | 'json';
  processing_stage: 'raw' | 'ocr' | 'corrected' | 'reviewed' | 'finalized';
  error_count: number;
  last_updated: string;
  processed_by?: string;
}

export interface OCRResult {
  hymn_id: string;
  confidence: number;
  text: string;
  errors: OCRError[];
  status: ProcessingStatus;
}

export interface OCRError {
  type: 'spelling' | 'punctuation' | 'formatting' | 'structure';
  line: number;
  column: number;
  original: string;
  suggested?: string;
  confidence: number;
}

export interface SearchResult {
  hymn: Hymn;
  hymnal: Hymnal;
  relevance_score: number;
  match_type: 'title' | 'author' | 'lyrics' | 'tune' | 'theme';
}

export interface ComparisonResult {
  hymn_id: string;
  variations: {
    hymnal_id: string;
    differences: TextDifference[];
  }[];
}

export interface TextDifference {
  type: 'addition' | 'deletion' | 'modification';
  verse_number?: number;
  line_number: number;
  original: string;
  modified: string;
}

export type SupportedLanguage = 'en' | 'sw' | 'luo' | 'fr' | 'es' | 'de' | 'pt' | 'it';

export interface LanguageInfo {
  code: SupportedLanguage;
  name: string;
  native_name: string;
  rtl: boolean;
}

// Enhanced types for web application

export interface HymnalReference {
  id: string;
  name: string;
  abbreviation: string;
  year: number;
  total_songs: number;
  language: SupportedLanguage;
  language_name: string;
  compiler?: string;
  site_name: string;
  url_slug: string;
  parts?: {
    [key: string]: {
      type: string;
      songs: number;
    };
  };
  separate_parts?: number;
  github_link?: string;
  resources?: {
    pdf?: string;
    html?: string;
    images?: string;
  };
  music?: {
    midi?: string | string[];
    mp3?: string;
  };
  note?: string;
}

export interface HymnalCollection {
  hymnals: Record<string, HymnalReference>;
  languages: Record<string, string>;
  metadata: {
    total_hymnals: number;
    date_range: {
      earliest: number;
      latest: number;
    };
    languages_supported: SupportedLanguage[];
    total_estimated_songs: number;
    source: string;
    generated_date: string;
  };
}

// SEO and metadata types

export interface PageMetadata {
  title: string;
  description: string;
  keywords?: string[];
  canonical?: string;
  openGraph?: {
    title?: string;
    description?: string;
    images?: Array<{
      url: string;
      width?: number;
      height?: number;
      alt?: string;
    }>;
  };
  twitter?: {
    title?: string;
    description?: string;
    images?: string[];
  };
  structuredData?: Record<string, any>;
}

export interface BreadcrumbItem {
  label: string;
  href?: string;
  current?: boolean;
}

// Search and filtering types

export interface SearchFilters {
  hymnals?: string[];
  languages?: SupportedLanguage[];
  themes?: string[];
  composers?: string[];
  authors?: string[];
  years?: {
    min?: number;
    max?: number;
  };
  meters?: string[];
}

export interface SearchParams {
  query?: string;
  filters?: SearchFilters;
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'title' | 'number' | 'year' | 'author';
  sortOrder?: 'asc' | 'desc';
}

export interface SearchResponse {
  results: SearchResult[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  facets?: {
    hymnals?: Array<{ id: string; count: number }>;
    languages?: Array<{ code: string; count: number }>;
    themes?: Array<{ theme: string; count: number }>;
    composers?: Array<{ name: string; count: number }>;
  };
}

// Navigation and UI types

export interface NavigationItem {
  label: string;
  href: string;
  icon?: string;
  children?: NavigationItem[];
  external?: boolean;
}

export interface MenuItem {
  label: string;
  href: string;
  description?: string;
  featured?: boolean;
}

// Theme and appearance types

export type ThemeMode = 'light' | 'dark' | 'system';

export interface UserPreferences {
  theme: ThemeMode;
  language: SupportedLanguage;
  fontSize: 'small' | 'medium' | 'large';
  compactMode: boolean;
  showNumbers: boolean;
  favorites: string[];
  recentlyViewed: string[];
}

// Analytics and tracking types

export interface AnalyticsEvent {
  name: string;
  category: 'hymn' | 'search' | 'navigation' | 'interaction';
  properties?: Record<string, string | number | boolean>;
  timestamp?: Date;
}

// Error handling types

export interface ApiError {
  message: string;
  code: string;
  status: number;
  details?: Record<string, any>;
}

export interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
  errorInfo?: Record<string, any>;
}

// Utility types for React components

export interface ComponentWithChildren {
  children: any; // ReactNode type for shared package
}

export interface ClassNameProps {
  className?: string;
}

export interface LoadingState {
  isLoading: boolean;
  error?: string | null;
}

// Form and input types

export interface FormField {
  name: string;
  label: string;
  type: 'text' | 'email' | 'textarea' | 'select' | 'checkbox' | 'radio';
  required?: boolean;
  placeholder?: string;
  options?: Array<{ value: string; label: string }>;
  validation?: {
    pattern?: string;
    minLength?: number;
    maxLength?: number;
  };
}