import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import ApiDocsClient from './ApiDocsClient';

export const metadata: Metadata = {
  title: 'API Documentation - Advent Hymnals',
  description: 'Complete developer documentation for the Advent Hymnals API. Access hymnal data programmatically for your applications.',
  keywords: ['API documentation', 'developer tools', 'hymnal API', 'REST API', 'Advent Hymnals'],
};

export default async function ApiDocsPage() {
  const hymnalReferences = await loadHymnalReferences();
  return <ApiDocsClient hymnalReferences={hymnalReferences} />;
}