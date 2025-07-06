'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  Bars3Icon, 
  XMarkIcon, 
  MagnifyingGlassIcon,
  ChevronDownIcon,
  BookOpenIcon,
  MusicalNoteIcon
} from '@heroicons/react/24/outline';
import { HymnalCollection } from '@advent-hymnals/shared';
import { classNames } from '@advent-hymnals/shared';
import SearchDropdown from '../ui/SearchDropdown';

interface HeaderProps {
  hymnalReferences?: HymnalCollection;
}

export default function Header({ hymnalReferences }: HeaderProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [hymnalsDropdownOpen, setHymnalsDropdownOpen] = useState(false);
  const [searchDropdownOpen, setSearchDropdownOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [hymnalSearchQuery, setHymnalSearchQuery] = useState('');
  const pathname = usePathname();

  // Close mobile menu when route changes
  useEffect(() => {
    setMobileMenuOpen(false);
    setHymnalsDropdownOpen(false);
    setSearchDropdownOpen(false);
    setHymnalSearchQuery('');
  }, [pathname]);

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as HTMLElement;
      
      // Close hymnal dropdown if clicking outside its container
      if (!target.closest('.hymnal-dropdown-container')) {
        setHymnalsDropdownOpen(false);
        setHymnalSearchQuery('');
      }
      
      // Close search dropdown if clicking outside its container
      if (!target.closest('.search-dropdown-container')) {
        setSearchDropdownOpen(false);
      }
    };
    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, []);

  const navigation = [
    { name: 'Home', href: '/', current: pathname === '/' },
    { name: 'Search', href: '/search', current: pathname === '/search' },
    { name: 'Download', href: '/download', current: pathname === '/download' },
    { name: 'About', href: '/about', current: pathname === '/about' },
    { name: 'Contribute', href: '/contribute', current: pathname === '/contribute' },
  ];

  const allHymnals = hymnalReferences ? Object.values(hymnalReferences.hymnals) : [];
  
  // Filter and sort hymnals for dropdown with search functionality
  const dropdownHymnals = allHymnals
    .filter(hymnal => {
      if (!hymnal.url_slug) return false;
      if (!hymnalSearchQuery.trim()) return true;
      
      const query = hymnalSearchQuery.toLowerCase();
      return hymnal.name.toLowerCase().includes(query) ||
             hymnal.site_name?.toLowerCase().includes(query) ||
             hymnal.abbreviation.toLowerCase().includes(query) ||
             hymnal.language_name.toLowerCase().includes(query) ||
             hymnal.year.toString().includes(query);
    })
    .sort((a, b) => b.year - a.year);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim() && typeof window !== 'undefined') {
      window.location.href = `/search?q=${encodeURIComponent(searchQuery.trim())}`;
    }
  };

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
      <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8" aria-label="Top">
        <div className="flex h-16 items-center justify-between">
          {/* Logo */}
          <div className="flex items-center">
            <Link href="/" className="flex items-center space-x-2">
              <MusicalNoteIcon className="h-8 w-8 text-primary-600" />
              <div className="text-xl font-bold text-gray-900">
                Advent Hymnals
              </div>
            </Link>
          </div>

          {/* Desktop Navigation */}
          <div className="hidden lg:flex lg:items-center lg:space-x-8">
            {/* Main Navigation */}
            <div className="flex items-center space-x-8">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className={classNames(
                    item.current
                      ? 'text-primary-600 font-medium'
                      : 'text-gray-700 hover:text-primary-600',
                    'text-sm font-medium transition-colors duration-200'
                  )}
                >
                  {item.name}
                </Link>
              ))}

              {/* Hymnals Dropdown */}
              <div className="relative hymnal-dropdown-container">
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setHymnalsDropdownOpen(!hymnalsDropdownOpen);
                  }}
                  className={classNames(
                    pathname.includes('/seventh-day-adventist-hymnal') ||
                    pathname.includes('/christ-in-song') ||
                    pathname.includes('/church-hymnal') ||
                    pathname.includes('/nyimbo-za-kristo')
                      ? 'text-primary-600 font-medium'
                      : 'text-gray-700 hover:text-primary-600',
                    'flex items-center space-x-1 text-sm font-medium transition-colors duration-200'
                  )}
                >
                  <BookOpenIcon className="h-4 w-4" />
                  <span>Hymnals</span>
                  <ChevronDownIcon className="h-4 w-4" />
                </button>

                {hymnalsDropdownOpen && (
                  <div className="absolute left-0 mt-2 w-80 bg-white rounded-lg shadow-lg border border-gray-200 z-50">
                    <div className="p-3 flex flex-col max-h-96">
                      {/* Search Input */}
                      <div className="relative mb-3 flex-shrink-0">
                        <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <input
                          type="text"
                          value={hymnalSearchQuery}
                          onChange={(e) => setHymnalSearchQuery(e.target.value)}
                          placeholder="Search hymnals..."
                          className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                          onClick={(e) => e.stopPropagation()}
                        />
                      </div>
                      
                      {/* Scrollable Hymnal List */}
                      <div className="flex-1 overflow-y-auto space-y-1 min-h-0 custom-scrollbar">
                        {dropdownHymnals.length > 0 ? (
                          dropdownHymnals.map((hymnal) => (
                            <Link
                              key={hymnal.id}
                              href={`/${hymnal.url_slug}`}
                              className="block p-2 rounded-md hover:bg-gray-50 transition-colors duration-200"
                              onClick={() => {
                                setHymnalsDropdownOpen(false);
                                setHymnalSearchQuery('');
                              }}
                            >
                              <div className="flex items-center justify-between">
                                <div className="min-w-0 flex-1">
                                  <div className="text-sm font-medium text-gray-900 truncate">
                                    {hymnal.site_name || hymnal.name}
                                  </div>
                                  <div className="text-xs text-gray-500">
                                    {hymnal.year} • {hymnal.total_songs} hymns • {hymnal.language_name}
                                  </div>
                                </div>
                              </div>
                            </Link>
                          ))
                        ) : (
                          <div className="text-center py-4 text-gray-500">
                            <p className="text-sm">No hymnals found</p>
                          </div>
                        )}
                      </div>
                      
                      {/* Footer - Always visible */}
                      <div className="mt-3 pt-3 border-t border-gray-200 flex-shrink-0">
                        <Link
                          href="/hymnals"
                          className="text-sm text-primary-600 hover:text-primary-700 font-medium"
                          onClick={() => {
                            setHymnalsDropdownOpen(false);
                            setHymnalSearchQuery('');
                          }}
                        >
                          View all {allHymnals.length} collections →
                        </Link>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Search Bar */}
            <div className="relative search-dropdown-container">
              <form onSubmit={handleSearchSubmit} className="flex items-center">
                <div className="relative">
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    onFocus={() => setSearchDropdownOpen(true)}
                    placeholder="Search hymns..."
                    className="w-64 pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                  />
                  <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                </div>
              </form>
              <SearchDropdown
                isOpen={searchDropdownOpen}
                onClose={() => setSearchDropdownOpen(false)}
                searchQuery={searchQuery}
                onQueryChange={setSearchQuery}
              />
            </div>
          </div>

          {/* Mobile menu button */}
          <div className="lg:hidden">
            <button
              type="button"
              className="inline-flex items-center justify-center rounded-md p-2 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-primary-500"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              <span className="sr-only">Open main menu</span>
              {mobileMenuOpen ? (
                <XMarkIcon className="block h-6 w-6" aria-hidden="true" />
              ) : (
                <Bars3Icon className="block h-6 w-6" aria-hidden="true" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {mobileMenuOpen && (
          <div className="lg:hidden border-t border-gray-200 bg-white">
            <div className="space-y-1 px-2 pb-3 pt-2">
              {/* Mobile Search */}
              <form onSubmit={handleSearchSubmit} className="mb-4">
                <div className="relative">
                  <input
                    type="text"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    placeholder="Search hymns..."
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                  />
                  <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                </div>
              </form>

              {/* Mobile Navigation */}
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className={classNames(
                    item.current
                      ? 'bg-primary-50 text-primary-600 font-medium'
                      : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900',
                    'block px-3 py-2 rounded-md text-base font-medium'
                  )}
                >
                  {item.name}
                </Link>
              ))}

              {/* Mobile Hymnals Section */}
              <div className="pt-4 border-t border-gray-200">
                <div className="text-sm font-medium text-gray-900 px-3 py-2">
                  Hymnal Collections
                </div>
                {dropdownHymnals.slice(0, 5).map((hymnal) => (
                  <Link
                    key={hymnal.id}
                    href={`/${hymnal.url_slug}`}
                    className="block px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900"
                  >
                    <div className="font-medium">{hymnal.site_name || hymnal.name}</div>
                    <div className="text-xs text-gray-500">
                      {hymnal.year} • {hymnal.total_songs} hymns
                    </div>
                  </Link>
                ))}
                <Link
                  href="/hymnals"
                  className="block px-3 py-2 text-sm text-primary-600 hover:text-primary-700 font-medium"
                >
                  View all {allHymnals.length} collections →
                </Link>
              </div>
            </div>
          </div>
        )}
      </nav>
    </header>
  );
}