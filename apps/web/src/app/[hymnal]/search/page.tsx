import { notFound } from 'next/navigation';
import { Suspense } from 'react';
import HymnalSearchClient from './HymnalSearchClient';
import { loadHymnalReferences } from '@/lib/data-server';

interface HymnalSearchPageProps {
  params: {
    hymnal: string;
  };
}

export async function generateStaticParams() {
  try {
    // Use server-side functions to get all hymnal slugs
    const hymnalReferences = await loadHymnalReferences();
    
    // Generate static params for all hymnal search pages
    const staticParams = Object.values(hymnalReferences.hymnals).map(hymnal => ({
      hymnal: hymnal.url_slug
    }));
    
    console.log(`🔍 Generated ${staticParams.length} hymnal search static params`);
    return staticParams;
  } catch (error) {
    console.error('Error generating static params for hymnal search:', error);
    return [];
  }
}

export default async function HymnalSearchPage({ params }: HymnalSearchPageProps) {
  // Always render client component to avoid RSC requests during navigation
  // The client component will handle data loading via external API
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading search...</p>
        </div>
      </div>
    }>
      <HymnalSearchClient params={params} />
    </Suspense>
  );
}