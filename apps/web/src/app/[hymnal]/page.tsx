'use client';

import { useState, useEffect } from 'react';
import { notFound, useParams } from 'next/navigation';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  CalendarIcon, 
  UserIcon, 
  MusicalNoteIcon,
  HomeIcon,
  ChevronRightIcon
} from '@heroicons/react/24/outline';

import Layout from '@/components/layout/Layout';
import Breadcrumbs, { generateHymnalBreadcrumbs } from '@/components/ui/Breadcrumbs';
import HymnalSearch from '@/components/hymnal/HymnalSearch';
import { loadHymnalReferences, loadHymnal, loadHymnalHymns } from '@/lib/data';
import { formatNumber } from '@advent-hymnals/shared';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';

export default function HymnalPage() {
  const params = useParams();
  const [hymnalReferences, setHymnalReferences] = useState<any>(null);
  const [hymnalRef, setHymnalRef] = useState<any>(null);
  const [hymnsData, setHymnsData] = useState<any>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filteredHymns, setFilteredHymns] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      try {
        const references = await loadHymnalReferences();
        setHymnalReferences(references);
        
        const hymnalReference = Object.values(references.hymnals).find(
          (h: any) => h.url_slug === params.hymnal
        );
        
        if (!hymnalReference) {
          notFound();
          return;
        }
        
        setHymnalRef(hymnalReference);
        
        const hymns = await loadHymnalHymns(hymnalReference.id, 1, 1000);
        setHymnsData(hymns);
        setFilteredHymns(hymns.hymns);
      } catch (error) {
        console.error('Failed to load hymnal data:', error);
      } finally {
        setLoading(false);
      }
    };
    
    loadData();
  }, [params.hymnal]);

  useEffect(() => {
    if (!hymnsData?.hymns) return;
    
    if (!searchTerm.trim()) {
      setFilteredHymns(hymnsData.hymns);
      return;
    }
    
    const filtered = hymnsData.hymns.filter((hymn: any) =>
      hymn.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      hymn.author?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      hymn.composer?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      hymn.number.toString().includes(searchTerm) ||
      hymn.verses?.[0]?.text?.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    setFilteredHymns(filtered);
  }, [searchTerm, hymnsData]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading hymnal...</p>
        </div>
      </div>
    );
  }

  if (!hymnalRef || !hymnsData) {
    notFound();
    return null;
  }

  const breadcrumbs = [{
    label: 'Hymnals',
    href: '/hymnals'
  }, {
    label: hymnalRef.site_name,
    current: true
  }];

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-white">
        {/* Header Section */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="mx-auto max-w-4xl">
              {/* Breadcrumbs */}
              <div className="mb-6">
                <nav className="flex" aria-label="Breadcrumb">
                  <ol role="list" className="flex items-center space-x-2">
                    {/* Home icon */}
                    <li>
                      <div>
                        <Link
                          href="/"
                          className="text-primary-200 hover:text-white transition-colors duration-200"
                        >
                          <HomeIcon className="h-4 w-4 flex-shrink-0" aria-hidden="true" />
                          <span className="sr-only">Home</span>
                        </Link>
                      </div>
                    </li>

                    {/* Breadcrumb items */}
                    {breadcrumbs.map((item) => (
                      <li key={item.label}>
                        <div className="flex items-center">
                          <ChevronRightIcon
                            className="h-4 w-4 flex-shrink-0 text-primary-200"
                            aria-hidden="true"
                          />
                          {item.href && !item.current ? (
                            <Link
                              href={item.href}
                              className="ml-2 text-sm font-medium text-primary-100 hover:text-white transition-colors duration-200"
                            >
                              {item.label}
                            </Link>
                          ) : (
                            <span
                              className="ml-2 text-sm font-medium text-white"
                              aria-current={item.current ? 'page' : undefined}
                            >
                              {item.label}
                            </span>
                          )}
                        </div>
                      </li>
                    ))}
                  </ol>
                </nav>
              </div>

              {/* Hymnal Info */}
              <div className="text-center text-white">
                <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
                  {hymnalRef.site_name}
                </h1>
                
                {/* Metadata */}
                <div className="mt-8 flex flex-wrap justify-center gap-6 text-sm text-primary-200">
                  <div className="flex items-center">
                    <CalendarIcon className="mr-2 h-5 w-5" />
                    Published {hymnalRef.year}
                  </div>
                  <div className="flex items-center">
                    <BookOpenIcon className="mr-2 h-5 w-5" />
                    {formatNumber(hymnalRef.total_songs)} Hymns
                  </div>
                  <div className="flex items-center">
                    <MusicalNoteIcon className="mr-2 h-5 w-5" />
                    {hymnalRef.language_name}
                  </div>
                  {hymnalRef.compiler && (
                    <div className="flex items-center">
                      <UserIcon className="mr-2 h-5 w-5" />
                      {hymnalRef.compiler}
                    </div>
                  )}
                </div>

                {/* Search */}
                <div className="mt-8 mx-auto max-w-md">
                  <div className="relative">
                    <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <input
                      type="text"
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      placeholder={`Search ${hymnalRef.site_name}...`}
                      className="w-full pl-10 pr-4 py-3 text-lg border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent shadow-sm"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Content Section */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          {/* Controls */}
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-8">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                {searchTerm ? (
                  <>Showing {formatNumber(filteredHymns.length)} of {formatNumber(hymnsData.total)} hymns</>
                ) : (
                  <>Hymns ({formatNumber(hymnsData.total)})</>
                )}
              </h2>
              <p className="mt-1 text-gray-600">
                {searchTerm ? `Results for "${searchTerm}"` : 'All hymns in this collection'}
              </p>
            </div>
          </div>

          {/* Hymns Grid */}
          {filteredHymns.length === 0 && searchTerm ? (
            <div className="text-center py-12">
              <MagnifyingGlassIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No hymns found</h3>
              <p className="text-gray-600">Try adjusting your search terms.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {filteredHymns.map((hymn) => (
              <Link
                key={hymn.id}
                href={`/${params.hymnal}/hymn-${hymn.number}-${hymn.title.toLowerCase().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-')}`}
                className="hymnal-card p-6 hover:scale-105 transform transition-all duration-200"
              >
                <div className="flex items-center justify-between mb-4">
                  <span className="hymn-number">
                    #{hymn.number}
                  </span>
                  {hymn.metadata?.themes && hymn.metadata.themes.length > 0 && (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                      {hymn.metadata.themes[0]}
                    </span>
                  )}
                </div>
                
                <h3 className="hymn-title mb-2">
                  {hymn.title}
                </h3>
                
                {(hymn.author || hymn.composer) && (
                  <div className="text-sm text-gray-600 mb-3">
                    {hymn.author && <div>By {hymn.author}</div>}
                    {hymn.composer && <div>Music: {hymn.composer}</div>}
                  </div>
                )}
                
                {hymn.verses[0] && hymn.verses[0].text && (
                  <p className="text-sm text-gray-700 line-clamp-2">
                    {hymn.verses[0].text.split('\n')[0]}
                  </p>
                )}
              </Link>
            ))}
            </div>
          )}

        </div>
      </div>
    </Layout>
  );
}