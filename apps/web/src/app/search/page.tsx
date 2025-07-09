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

export default function SearchPage() {
  // Always render client component to avoid RSC requests during navigation
  // The client component will handle data loading via external API
  return <SearchPageClient />;
}