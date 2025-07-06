import { Metadata } from 'next';
import { Hymn, HymnalReference, BreadcrumbItem } from '@advent-hymnals/shared';
import { generateMetaDescription, generateStructuredData } from '@advent-hymnals/shared';

/**
 * Generate metadata for hymnal collection pages
 */
export function generateHymnalMetadata(hymnal: HymnalReference): Metadata {
  const title = `${hymnal.name} (${hymnal.year}) - ${hymnal.total_songs} Hymns`;
  const description = `Explore ${hymnal.total_songs} hymns from the ${hymnal.name}, published in ${hymnal.year}. Search by number, title, composer, or theme. Perfect for worship leaders and music enthusiasts.`;

  return {
    title,
    description,
    keywords: [
      hymnal.name,
      hymnal.abbreviation,
      `${hymnal.year} hymnal`,
      `${hymnal.language_name} hymns`,
      'Adventist hymnal',
      'worship music',
      'religious songs',
      hymnal.compiler || '',
    ].filter(Boolean),
    openGraph: {
      title,
      description,
      type: 'website',
      images: [
        {
          url: `/images/hymnals/${hymnal.id}-cover.jpg`,
          width: 600,
          height: 800,
          alt: `${hymnal.name} cover`,
        },
      ],
    },
    twitter: {
      title,
      description,
      images: [`/images/hymnals/${hymnal.id}-cover.jpg`],
    },
    alternates: {
      canonical: `/${hymnal.url_slug}`,
    },
  };
}

/**
 * Generate metadata for individual hymn pages
 */
export function generateHymnMetadata(
  hymn: Hymn, 
  hymnal: HymnalReference,
  hymnalSlug: string
): Metadata {
  const title = `${hymn.title} - Hymn ${hymn.number} | ${hymnal.site_name}`;
  const description = generateMetaDescription(hymn, hymnal.name);
  
  const keywords = [
    `${hymnal.abbreviation} ${hymn.number}`,
    `${hymnal.name} hymn ${hymn.number}`,
    hymn.title,
    hymn.author || '',
    hymn.composer || '',
    hymn.tune || '',
    ...(hymn.metadata?.themes || []),
    'Adventist hymn',
    'worship song',
    'Christian music',
  ].filter(Boolean);

  return {
    title,
    description,
    keywords,
    openGraph: {
      title,
      description,
      type: 'article',
      images: [
        {
          url: `/api/og/hymn?id=${hymn.id}`,
          width: 1200,
          height: 630,
          alt: `${hymn.title} - Hymn ${hymn.number}`,
        },
      ],
    },
    twitter: {
      title,
      description,
      images: [`/api/og/hymn?id=${hymn.id}`],
    },
    alternates: {
      canonical: `/${hymnalSlug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`,
    },
  };
}

/**
 * Generate structured data for hymnal collections
 */
export function generateHymnalStructuredData(hymnal: HymnalReference) {
  return {
    '@context': 'https://schema.org',
    '@type': 'MusicAlbum',
    name: hymnal.name,
    albumProductionType: 'CompilationAlbum',
    datePublished: hymnal.year.toString(),
    inLanguage: hymnal.language,
    publisher: {
      '@type': 'Organization',
      name: hymnal.compiler || 'Unknown',
    },
    numberOfTracks: hymnal.total_songs,
    genre: ['Religious Music', 'Hymns', 'Christian Music'],
    description: `A collection of ${hymnal.total_songs} hymns published in ${hymnal.year} for Adventist worship.`,
    url: `https://adventhymnals.org/${hymnal.url_slug}`,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://adventhymnals.org/${hymnal.url_slug}`,
    },
  };
}

/**
 * Generate structured data for individual hymns
 */
export function generateHymnStructuredData(
  hymn: Hymn, 
  hymnal: HymnalReference,
  hymnalSlug: string
) {
  const baseData = generateStructuredData(hymn, hymnal);
  
  return {
    ...baseData,
    url: `https://adventhymnals.org/${hymnalSlug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://adventhymnals.org/${hymnalSlug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`,
    },
    potentialAction: {
      '@type': 'ListenAction',
      target: `https://adventhymnals.org/${hymnalSlug}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`,
    },
  };
}

/**
 * Generate breadcrumb structured data
 */
export function generateBreadcrumbStructuredData(breadcrumbs: BreadcrumbItem[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: breadcrumbs.map((crumb, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: crumb.label,
      item: crumb.href ? `https://adventhymnals.org${crumb.href}` : undefined,
    })),
  };
}

/**
 * Generate FAQ structured data for hymnal pages
 */
export function generateHymnalFAQStructuredData(hymnal: HymnalReference) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: [
      {
        '@type': 'Question',
        name: `How many hymns are in the ${hymnal.name}?`,
        acceptedAnswer: {
          '@type': 'Answer',
          text: `The ${hymnal.name} contains ${hymnal.total_songs} hymns, published in ${hymnal.year}.`,
        },
      },
      {
        '@type': 'Question',
        name: `Who compiled the ${hymnal.name}?`,
        acceptedAnswer: {
          '@type': 'Answer',
          text: hymnal.compiler 
            ? `The ${hymnal.name} was compiled by ${hymnal.compiler}.`
            : `The compiler of the ${hymnal.name} is not specified in our records.`,
        },
      },
      {
        '@type': 'Question',
        name: `What language is the ${hymnal.name} in?`,
        acceptedAnswer: {
          '@type': 'Answer',
          text: `The ${hymnal.name} is primarily in ${hymnal.language_name}.`,
        },
      },
      {
        '@type': 'Question',
        name: `How can I search for hymns in the ${hymnal.name}?`,
        acceptedAnswer: {
          '@type': 'Answer',
          text: `You can search for hymns by number, title, first line, composer, author, or theme using our search feature.`,
        },
      },
    ],
  };
}

/**
 * Generate website structured data for rich snippets
 */
export function generateWebsiteStructuredData() {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'Advent Hymnals',
    description: 'Digital collection of Adventist hymnals spanning 160+ years of musical heritage',
    url: 'https://adventhymnals.org',
    potentialAction: {
      '@type': 'SearchAction',
      target: {
        '@type': 'EntryPoint',
        urlTemplate: 'https://adventhymnals.org/search?q={search_term_string}',
      },
      'query-input': 'required name=search_term_string',
    },
    publisher: {
      '@type': 'Organization',
      name: 'Advent Hymnals Project',
      url: 'https://adventhymnals.org',
      logo: {
        '@type': 'ImageObject',
        url: 'https://adventhymnals.org/images/logo.png',
        width: 600,
        height: 300,
      },
    },
    sameAs: [
      'https://github.com/adventhymnals',
      'https://twitter.com/adventhymnals',
    ],
  };
}

/**
 * Generate organization structured data
 */
export function generateOrganizationStructuredData() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'Advent Hymnals Project',
    description: 'Preserving and digitizing Adventist hymnody for current and future generations',
    url: 'https://adventhymnals.org',
    logo: {
      '@type': 'ImageObject',
      url: 'https://adventhymnals.org/images/logo.png',
      width: 600,
      height: 300,
    },
    contactPoint: {
      '@type': 'ContactPoint',
      email: 'editor@gospelsounders.org',
      contactType: 'Customer Service',
    },
    sameAs: [
      'https://github.com/adventhymnals',
      'https://twitter.com/adventhymnals',
    ],
    foundingDate: '2023',
    mission: 'To preserve and make accessible the rich musical heritage of Adventist hymnody through digital technology.',
  };
}

/**
 * Create sitemap URLs for all hymnal collections and hymns
 */
export function generateSitemapUrls(hymnals: HymnalReference[]) {
  const urls: Array<{
    url: string;
    lastModified: Date;
    changeFrequency: 'daily' | 'weekly' | 'monthly' | 'yearly';
    priority: number;
  }> = [];

  // Add homepage
  urls.push({
    url: 'https://adventhymnals.org',
    lastModified: new Date(),
    changeFrequency: 'weekly',
    priority: 1.0,
  });

  // Add main pages
  const mainPages = ['/search', '/hymnals', '/about', '/contribute'];
  mainPages.forEach(page => {
    urls.push({
      url: `https://adventhymnals.org${page}`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.8,
    });
  });

  // Add hymnal collection pages
  hymnals.forEach(hymnal => {
    urls.push({
      url: `https://adventhymnals.org/${hymnal.url_slug}`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    });
  });

  return urls;
}

/**
 * Generate robots.txt content
 */
export function generateRobotsTxt(): string {
  return `User-agent: *
Allow: /

# Sitemaps
Sitemap: https://adventhymnals.org/sitemap.xml

# Crawl delay for polite crawling
Crawl-delay: 1

# Block access to API endpoints that don't need indexing
Disallow: /api/
Allow: /api/og/

# Block access to internal build files
Disallow: /_next/
Disallow: /static/

# Allow common SEO files
Allow: /robots.txt
Allow: /sitemap.xml
Allow: /favicon.ico`;
}