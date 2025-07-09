import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';
import Breadcrumbs, { generateSearchBreadcrumbs } from '@/components/ui/Breadcrumbs';
import SearchPageClient from '@/components/search/SearchPageClient';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Search Hymns - Advent Hymnals',
  description: 'Search through 13 complete hymnal collections with over 5,000 hymns. Find hymns by title, number, composer, author, or theme.',
  keywords: ['hymn search', 'Adventist hymns', 'hymnal search', 'worship music', 'Christian songs'],
};

export async function generateStaticParams() {
  // Global search page has no dynamic params, return empty array
  return [];
}

export default async function SearchPage() {
  const hymnalReferences = await loadHymnalReferences();
  const breadcrumbs = generateSearchBreadcrumbs();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      {/* Header */}
      <div className="bg-gradient-to-r from-primary-600 to-primary-700">
        <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
          <Breadcrumbs items={breadcrumbs} className="mb-6" />
          <div className="text-center">
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
              Search Hymns
            </h1>
            <p className="mt-6 text-lg leading-8 text-primary-100">
              Search through 13 complete hymnal collections with over 5,000 hymns
            </p>
          </div>
        </div>
      </div>

      <SearchPageClient hymnalReferences={hymnalReferences} />
    </Layout>
  );
}