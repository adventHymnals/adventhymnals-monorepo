import { Metadata } from 'next';
import { loadHymnalReferences } from '@/lib/data-server';
import ChoirRegistrationForm from './ChoirRegistrationForm';

export const metadata: Metadata = {
  title: 'Register Your Choir - Advent Hymnals',
  description: 'Join our choir collaboration project. Register your choir and select hymns you would like to record for our YouTube channel.',
  keywords: ['choir registration', 'hymn recording', 'Adventist choir', 'music collaboration', 'sacred music'],
};

export async function generateStaticParams() {
  // Static page with no dynamic params
  return [];
}

export default async function ChoirRegistrationPage() {
  const hymnalReferences = await loadHymnalReferences();
  
  return <ChoirRegistrationForm hymnalReferences={hymnalReferences} />;
}