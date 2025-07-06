'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { MagnifyingGlassIcon, UserIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

interface AuthorData {
  author: string;
  count: number;
  hymns: Array<{
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
  }>;
}

export default function AuthorsPage() {
  const [authors, setAuthors] = useState<AuthorData[]>([]);
  const [filteredAuthors, setFilteredAuthors] = useState<AuthorData[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [hymnalReferences, setHymnalReferences] = useState<unknown>(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        const [authorsResponse, references] = await Promise.all([
          fetch('/api/authors'),
          loadHymnalReferences()
        ]);
        
        if (!authorsResponse.ok) {
          throw new Error('Failed to fetch authors');
        }
        
        const authorsData = await authorsResponse.json();
        setAuthors(authorsData);
        setFilteredAuthors(authorsData);
        setHymnalReferences(references);
      } catch (error) {
        console.error('Failed to load authors:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  useEffect(() => {
    if (!searchTerm.trim()) {
      setFilteredAuthors(authors);
      return;
    }

    const filtered = authors.filter(authorData => {
      const normalizedAuthor = authorData.author.replace(/[.,\s\-']+/g, '').toLowerCase();
      const normalizedSearch = searchTerm.replace(/[.,\s\-']+/g, '').toLowerCase();
      return normalizedAuthor.includes(normalizedSearch);
    });
    setFilteredAuthors(filtered);
  }, [searchTerm, authors]);

  if (loading) {
    return (
      <Layout hymnalReferences={hymnalReferences}>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading authors...</p>
          </div>
        </div>
      </Layout>
    );
  }

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <UserIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                Hymn Authors
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Explore hymns organized by their authors and writers
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          {/* Search */}
          <div className="mb-8">
            <div className="relative max-w-md mx-auto">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search authors..."
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-gray-900 bg-white"
              />
            </div>
          </div>

          {/* Results Summary */}
          <div className="mb-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900">
              {searchTerm ? `Found ${filteredAuthors.length} authors` : `${authors.length} Hymn Authors`}
            </h2>
            {searchTerm && (
              <p className="mt-2 text-gray-600">Results for &quot;{searchTerm}&quot;</p>
            )}
          </div>

          {/* Authors Grid */}
          {filteredAuthors.length === 0 ? (
            <div className="text-center py-12">
              <UserIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No authors found</h3>
              <p className="text-gray-600">Try adjusting your search terms.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {filteredAuthors.map((authorData) => (
                <Link
                  key={authorData.author}
                  href={`/authors/${encodeURIComponent(authorData.author)}`}
                  className="block p-6 bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow border border-gray-200 hover:border-primary-300"
                >
                  <div className="text-center">
                    <div className="text-lg font-bold text-primary-600 mb-2">
                      {authorData.author}
                    </div>
                    <div className="text-sm text-gray-600 mb-4">
                      {authorData.count} hymn{authorData.count !== 1 ? 's' : ''}
                    </div>
                    
                    {/* Sample hymns */}
                    <div className="space-y-1">
                      {authorData.hymns.slice(0, 3).map((hymn) => (
                        <div key={hymn.id} className="text-xs text-gray-500">
                          <span className="font-medium text-primary-600">
                            {hymn.hymnal.abbreviation} #{hymn.number}
                          </span>{' '}
                          {hymn.title}
                        </div>
                      ))}
                      {authorData.count > 3 && (
                        <div className="text-xs text-gray-400">
                          +{authorData.count - 3} more
                        </div>
                      )}
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}