import { notFound } from 'next/navigation';
import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import AuthorDetailClient from './AuthorDetailClient';

interface HymnData {
  id: string;
  number: number;
  title: string;
  author?: string;
  hymnal: {
    id: string;
    name: string;
    url_slug: string;
    abbreviation: string;
  };
}

interface AuthorDetailProps {
  params: {
    author: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions directly instead of API fetch during build
    const { loadHymnalReferences, loadHymnalHymns } = await import('@/lib/data-server');
    const hymnalReferences = await loadHymnalReferences();
    const authorSet = new Set<string>();

    // Load hymns from all hymnals to get unique authors
    for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
      try {
        const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
        hymns.forEach((hymn: { author?: string }) => {
          if (hymn.author) {
            authorSet.add(hymn.author);
          }
        });
      } catch (error) {
        console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
      }
    }

    return Array.from(authorSet).map((author: string) => ({
      author: encodeURIComponent(author)
    }));
  } catch (error) {
    console.error('Error generating static params for authors:', error);
    return [];
  }
}

export async function generateMetadata({ params }: AuthorDetailProps): Promise<Metadata> {
  const decodedAuthor = decodeURIComponent(params.author);
  
  // Get some basic stats about the author
  const hymnalReferences = await loadHymnalReferences();
  const { loadHymnalHymns } = await import('@/lib/data-server');
  let hymnCount = 0;
  const hymnalSet = new Set<string>();
  
  // Count hymns and hymnals for this author
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      const authorHymns = hymns.filter((hymn: any) => hymn.author === decodedAuthor);
      if (authorHymns.length > 0) {
        hymnCount += authorHymns.length;
        hymnalSet.add(hymnalRef.abbreviation);
      }
    } catch (error) {
      console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
    }
  }
  
  const hymnalList = Array.from(hymnalSet).join(', ');
  const title = `${decodedAuthor} - Hymn Author | Advent Hymnals`;
  const description = `Browse ${hymnCount} hymns written by ${decodedAuthor} across ${hymnalSet.size} hymnal collections (${hymnalList}). Explore Adventist hymnody with full text, themes, and musical information.`;
  
  // Determine site URL
  const siteUrl = process.env.SITE_URL || 
    (process.env.NEXT_OUTPUT === 'export' ? 'https://adventhymnals.github.io' : 'https://adventhymnals.org');
  
  return {
    title,
    description,
    keywords: [
      decodedAuthor,
      'hymn author',
      'Adventist hymns',
      'church music',
      'worship music',
      'Christian music',
      'hymnal',
      ...Array.from(hymnalSet)
    ],
    openGraph: {
      title,
      description,
      type: 'profile',
      url: `${siteUrl}/authors/${encodeURIComponent(decodedAuthor)}`,
      images: [
        {
          url: `${siteUrl}/og-image.jpg`,
          width: 1200,
          height: 630,
          alt: `${decodedAuthor} - Hymn Author on Advent Hymnals`,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [`${siteUrl}/og-image.jpg`],
    },
  };
}

export default async function AuthorDetailPage({ params }: AuthorDetailProps) {
  const decodedAuthor = decodeURIComponent(params.author);
  const hymnalReferences = await loadHymnalReferences();
  
  // Use server-side data loading directly instead of API fetch
  const { loadHymnalHymns } = await import('@/lib/data-server');
  const hymns: HymnData[] = [];
  
  // Load hymns from all hymnals to find author's hymns
  for (const hymnalRef of Object.values(hymnalReferences.hymnals)) {
    try {
      const { hymns: hymnalHymns } = await loadHymnalHymns(hymnalRef.id, 1, 1000);
      hymnalHymns.forEach((hymn: any) => {
        if (hymn.author === decodedAuthor) {
          hymns.push({
            id: hymn.id,
            number: hymn.number,
            title: hymn.title,
            author: hymn.author,
            hymnal: {
              id: hymnalRef.id,
              name: hymnalRef.name,
              url_slug: hymnalRef.url_slug,
              abbreviation: hymnalRef.abbreviation
            }
          });
        }
      });
    } catch (error) {
      console.warn(`Failed to load hymns for ${hymnalRef.id}:`, error);
    }
  }
  
  if (hymns.length === 0) {
    notFound();
  }

  return (
    <AuthorDetailClient 
      hymns={hymns}
      decodedAuthor={decodedAuthor}
      hymnalReferences={hymnalReferences}
    />
  );
}