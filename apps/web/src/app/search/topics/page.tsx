'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { TagIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';
import { HymnalCollection } from '@advent-hymnals/shared';

interface ThemeData {
  theme: string;
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

export default function TopicsSearchPage() {
  const [themes, setThemes] = useState<ThemeData[]>([]);
  const [filteredThemes, setFilteredThemes] = useState<ThemeData[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [hymnalReferences, setHymnalReferences] = useState<HymnalCollection | undefined>(undefined);
  const [selectedThemes, setSelectedThemes] = useState<string[]>([]);
  
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    const loadData = async () => {
      try {
        const [themesResponse, references] = await Promise.all([
          fetch('/api/themes'),
          loadHymnalReferences()
        ]);
        
        if (!themesResponse.ok) {
          throw new Error('Failed to fetch themes');
        }
        
        const themesData = await themesResponse.json();
        setThemes(themesData);
        setFilteredThemes(themesData);
        setHymnalReferences(references);

        // Get initial search term from URL
        const initialSearch = searchParams.get('q') || '';
        setSearchTerm(initialSearch);
        
        // Get selected themes from URL
        const initialThemes = searchParams.get('themes')?.split(',').filter(Boolean) || [];
        setSelectedThemes(initialThemes);
      } catch (error) {
        console.error('Failed to load themes:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [searchParams]);

  useEffect(() => {
    if (!searchTerm.trim()) {
      setFilteredThemes(themes);
      return;
    }

    const filtered = themes.filter(themeData => {
      const normalizedTheme = themeData.theme.replace(/[.,\s\-'&]+/g, '').toLowerCase();
      const normalizedSearch = searchTerm.replace(/[.,\s\-'&]+/g, '').toLowerCase();
      return normalizedTheme.includes(normalizedSearch);
    });
    setFilteredThemes(filtered);
  }, [searchTerm, themes]);

  const handleThemeToggle = (theme: string) => {
    const newSelectedThemes = selectedThemes.includes(theme)
      ? selectedThemes.filter(t => t !== theme)
      : [...selectedThemes, theme];
    
    setSelectedThemes(newSelectedThemes);
    
    // Update URL
    const params = new URLSearchParams();
    if (searchTerm) params.set('q', searchTerm);
    if (newSelectedThemes.length > 0) params.set('themes', newSelectedThemes.join(','));
    
    router.push(`/search/topics?${params.toString()}`);
  };

  const handleSearchHymns = () => {
    if (selectedThemes.length === 0) return;
    
    const params = new URLSearchParams();
    if (searchTerm) params.set('q', searchTerm);
    params.set('themes', selectedThemes.join(','));
    
    router.push(`/search?${params.toString()}`);
  };

  // Handle initial theme selection from URL
  useEffect(() => {
    const urlThemes = searchParams.get('themes');
    if (urlThemes && themes.length > 0) {
      const themeList = urlThemes.split(',').filter(Boolean);
      const validThemes = themeList.filter(theme => 
        themes.some(t => t.theme === theme)
      );
      setSelectedThemes(validThemes);
    }
  }, [themes, searchParams]);

  if (loading) {
    return (
      <Layout hymnalReferences={hymnalReferences}>
        <div className="min-h-screen bg-gray-50 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Loading topics...</p>
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
              <TagIcon className="mx-auto h-12 w-12 text-white mb-4" />
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                Search by Topics
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Find hymns by selecting themes and topics from actual hymn metadata
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
                placeholder="Search topics and themes..."
                className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent text-gray-900 bg-white"
              />
            </div>
          </div>

          {/* Selected Themes */}
          {selectedThemes.length > 0 && (
            <div className="mb-8 bg-white p-6 rounded-lg shadow-sm border">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">
                Selected Topics ({selectedThemes.length})
              </h3>
              <div className="flex flex-wrap gap-2 mb-4">
                {selectedThemes.map((theme) => (
                  <button
                    key={theme}
                    onClick={() => handleThemeToggle(theme)}
                    className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-800 hover:bg-primary-200 transition-colors"
                  >
                    {theme}
                    <span className="ml-2 text-primary-600">×</span>
                  </button>
                ))}
              </div>
              <button
                onClick={handleSearchHymns}
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
              >
                <MagnifyingGlassIcon className="h-4 w-4 mr-2" />
                Search Hymns ({selectedThemes.length} topic{selectedThemes.length !== 1 ? 's' : ''})
              </button>
            </div>
          )}

          {/* Results Summary */}
          <div className="mb-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900">
              {searchTerm ? `Found ${filteredThemes.length} topics` : `${themes.length} Available Topics`}
            </h2>
            {searchTerm && (
              <p className="mt-2 text-gray-600">Results for &quot;{searchTerm}&quot;</p>
            )}
          </div>

          {/* Topics Grid */}
          {filteredThemes.length === 0 ? (
            <div className="text-center py-12">
              <TagIcon className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No topics found</h3>
              <p className="text-gray-600">Try adjusting your search terms.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {filteredThemes.map((themeData) => {
                const isSelected = selectedThemes.includes(themeData.theme);
                return (
                  <button
                    key={themeData.theme}
                    onClick={() => handleThemeToggle(themeData.theme)}
                    className={`p-4 rounded-lg border-2 transition-all duration-200 text-left ${
                      isSelected
                        ? 'border-primary-500 bg-primary-50 shadow-md'
                        : 'border-gray-200 bg-white hover:border-primary-300 hover:shadow-sm'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <h3 className={`font-medium ${isSelected ? 'text-primary-900' : 'text-gray-900'}`}>
                        {themeData.theme}
                      </h3>
                      <div className={`w-4 h-4 rounded border-2 flex items-center justify-center ${
                        isSelected 
                          ? 'border-primary-500 bg-primary-500' 
                          : 'border-gray-300'
                      }`}>
                        {isSelected && (
                          <svg className="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                          </svg>
                        )}
                      </div>
                    </div>
                    <div className={`text-sm ${isSelected ? 'text-primary-700' : 'text-gray-600'}`}>
                      {themeData.count} hymn{themeData.count !== 1 ? 's' : ''}
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}