'use client';

import { useState, useEffect } from 'react';
import { notFound } from 'next/navigation';
import HymnEditView from '@/components/hymn/HymnEditView';
import { loadHymnalReferences, loadHymn, loadHymnalHymns } from '@/lib/data';
import { HymnalReference, Hymn } from '@advent-hymnals/shared';

interface EditPageClientProps {
  params: {
    hymnal: string;
    slug: string;
  };
}

// Extract hymn number from slug like "hymn-132-o-come-all-ye-faithful"
function extractHymnNumber(slug: string): number | null {
  const match = slug.match(/^hymn-(\d+)-/);
  return match ? parseInt(match[1], 10) : null;
}

export default function EditPageClient({ params }: EditPageClientProps) {
  const [hymn, setHymn] = useState<Hymn | null>(null);
  const [hymnalRef, setHymnalRef] = useState<HymnalReference | null>(null);
  const [allHymns, setAllHymns] = useState<Hymn[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        setLoading(true);
        
        // Load hymnal references
        const hymnalReferences = await loadHymnalReferences();
        const foundHymnalRef = Object.values(hymnalReferences.hymnals).find(
          (h) => h.url_slug === params.hymnal
        );
        
        if (!foundHymnalRef) {
          setError('Hymnal not found');
          return;
        }
        
        setHymnalRef(foundHymnalRef);
        
        // Extract hymn number
        const hymnNumber = extractHymnNumber(params.slug);
        if (!hymnNumber) {
          setError('Invalid hymn format');
          return;
        }
        
        // Load hymn data
        const hymnId = `${foundHymnalRef.id}-${foundHymnalRef.language}-${hymnNumber.toString().padStart(3, '0')}`;
        const hymnData = await loadHymn(hymnId);
        
        if (!hymnData) {
          setError('Hymn not found');
          return;
        }
        
        setHymn(hymnData);
        
        // Load all hymns for navigation
        const { hymns } = await loadHymnalHymns(foundHymnalRef.id, 1, 1000);
        setAllHymns(hymns);
        
      } catch (err) {
        console.error('Failed to load edit page data:', err);
        setError('Failed to load hymn data');
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [params.hymnal, params.slug]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading hymn editor...</p>
        </div>
      </div>
    );
  }

  if (error || !hymn || !hymnalRef) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="max-w-md mx-auto bg-white rounded-lg shadow-sm border p-8 text-center">
          <h1 className="text-xl font-semibold text-gray-900 mb-3">
            {error || 'Hymn Not Found'}
          </h1>
          <p className="text-gray-600 mb-6">
            The hymn you're looking for could not be loaded.
          </p>
          <div className="space-y-3">
            <a
              href={`/${params.hymnal}`}
              className="block w-full bg-primary-600 text-white py-2 px-4 rounded-lg hover:bg-primary-700 transition-colors"
            >
              Back to Hymnal
            </a>
            <a
              href="/"
              className="block w-full bg-gray-100 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-200 transition-colors"
            >
              Back to Home
            </a>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <HymnEditView 
        hymn={hymn}
        hymnalRef={hymnalRef}
        allHymns={allHymns}
        params={params}
      />
    </div>
  );
}