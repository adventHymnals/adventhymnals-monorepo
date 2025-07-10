'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Layout from '@/components/layout/Layout';
import { HymnalCollection } from '@advent-hymnals/shared';
import { 
  UserGroupIcon,
  MusicalNoteIcon,
  CheckIcon,
  ExclamationTriangleIcon,
  ArrowLeftIcon,
  MagnifyingGlassIcon
} from '@heroicons/react/24/outline';

interface ChoirRegistrationFormProps {
  hymnalReferences: HymnalCollection;
}

interface FormData {
  choirName: string;
  contactName: string;
  email: string;
  phone: string;
  location: string;
  churchAffiliation: string;
  choirSize: string;
  experience: string;
  equipment: string;
  selectedHymns: string[];
  additionalInfo: string;
  preferredTimeline: string;
}

interface HymnData {
  id: string;
  title: string;
  number: number;
  hymnalName: string;
  hymnalId: string;
}

export default function ChoirRegistrationForm({ hymnalReferences }: ChoirRegistrationFormProps) {
  const [formData, setFormData] = useState<FormData>({
    choirName: '',
    contactName: '',
    email: '',
    phone: '',
    location: '',
    churchAffiliation: '',
    choirSize: '',
    experience: '',
    equipment: '',
    selectedHymns: [],
    additionalInfo: '',
    preferredTimeline: ''
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [hymnSearch, setHymnSearch] = useState('');
  const [selectedHymnal, setSelectedHymnal] = useState<string>('all');
  const [searchResults, setSearchResults] = useState<HymnData[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [totalHymnsCount, setTotalHymnsCount] = useState<number>(0);

  // Load total hymns count on mount
  useEffect(() => {
    const loadTotalCount = () => {
      const total = Object.values(hymnalReferences.hymnals)
        .reduce((sum, hymnal) => sum + (hymnal.total_songs || 0), 0);
      setTotalHymnsCount(total);
    };

    loadTotalCount();
  }, [hymnalReferences]);

  // Search hymns when search term changes
  useEffect(() => {
    const searchHymns = async () => {
      if (!hymnSearch.trim()) {
        setSearchResults([]);
        setIsSearching(false);
        return;
      }

      setIsSearching(true);
      try {
        const hymnalParam = selectedHymnal === 'all' ? '' : `&hymnal=${selectedHymnal}`;
        const response = await fetch(`/api/search?q=${encodeURIComponent(hymnSearch)}&limit=50${hymnalParam}`);
        
        if (response.ok) {
          const data = await response.json();
          const hymnsData: HymnData[] = data.map((result: any) => ({
            id: result.hymn.id,
            title: result.hymn.title || 'Untitled',
            number: result.hymn.number || 0,
            hymnalName: result.hymnal.name,
            hymnalId: result.hymnal.id
          }));
          setSearchResults(hymnsData);
        } else {
          setSearchResults([]);
        }
      } catch (error) {
        console.error('Failed to search hymns:', error);
        setSearchResults([]);
      } finally {
        setIsSearching(false);
      }
    };

    // Debounce search
    const timeoutId = setTimeout(searchHymns, 300);
    return () => clearTimeout(timeoutId);
  }, [hymnSearch, selectedHymnal]);

  // Use search results as the hymns to display
  const displayHymns = searchResults;

  const handleInputChange = (field: keyof FormData, value: string | string[]) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleHymnToggle = (hymnId: string) => {
    setFormData(prev => ({
      ...prev,
      selectedHymns: prev.selectedHymns.includes(hymnId)
        ? prev.selectedHymns.filter(id => id !== hymnId)
        : [...prev.selectedHymns, hymnId]
    }));
  };

  const getSelectedHymnDetails = () => {
    return formData.selectedHymns.map(hymnId => {
      const hymn = searchResults.find(h => h.id === hymnId);
      return hymn ? `${hymn.hymnalId}-${hymn.number}: ${hymn.title}` : hymnId;
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitStatus('idle');

    try {
      // Build URL parameters for GET request
      const params = new URLSearchParams({
        choirName: formData.choirName,
        contactName: formData.contactName,
        email: formData.email,
        phone: formData.phone,
        location: formData.location,
        churchAffiliation: formData.churchAffiliation,
        choirSize: formData.choirSize,
        experience: formData.experience,
        equipment: formData.equipment,
        preferredTimeline: formData.preferredTimeline,
        selectedHymnsCount: formData.selectedHymns.length.toString(),
        selectedHymnsDetails: getSelectedHymnDetails().join(' | '),
        additionalInfo: formData.additionalInfo,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent,
        referer: window.location.href
      });

      // Send directly to Google Apps Script
      const googleScriptUrl = process.env.NEXT_PUBLIC_GOOGLE_CHOIR_SCRIPT_URL;
      
      console.log('Using Google Apps Script URL:', googleScriptUrl);
      
      const response = await fetch(`${googleScriptUrl}?${params.toString()}`);

      if (response.ok) {
        const result = await response.json();
        if (result.success) {
          setSubmitStatus('success');
          // Reset form
          setFormData({
            choirName: '',
            contactName: '',
            email: '',
            phone: '',
            location: '',
            churchAffiliation: '',
            choirSize: '',
            experience: '',
            equipment: '',
            selectedHymns: [],
            additionalInfo: '',
            preferredTimeline: ''
          });
        } else {
          setSubmitStatus('error');
        }
      } else {
        setSubmitStatus('error');
      }
    } catch (error) {
      console.error('Registration error:', error);
      setSubmitStatus('error');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-8 lg:px-8">
            <div className="flex items-center">
              <Link
                href="/choir-project"
                className="inline-flex items-center text-primary-600 hover:text-primary-700 mr-4"
              >
                <ArrowLeftIcon className="h-5 w-5 mr-2" />
                Back to Choir Project
              </Link>
            </div>
            <div className="mt-4">
              <h1 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Register Your Choir
              </h1>
              <p className="mt-4 text-lg text-gray-600">
                Join our mission to preserve Adventist hymnody through collaborative recordings. 
                Fill out the form below to register your choir and select hymns you&apos;d like to record.
              </p>
            </div>
          </div>
        </div>

        {/* Form Content */}
        <div className="mx-auto max-w-4xl px-6 py-12 lg:px-8">
          {submitStatus === 'success' ? (
            <div className="bg-green-50 border border-green-200 rounded-lg p-8 text-center">
              <CheckIcon className="mx-auto h-12 w-12 text-green-600 mb-4" />
              <h2 className="text-2xl font-bold text-green-900 mb-4">Registration Successful!</h2>
              <p className="text-green-800 mb-6">
                Thank you for registering your choir! We&apos;ve received your information and hymn selections. 
                Our team will review your submission and contact you within 1-2 weeks to discuss next steps.
              </p>
              <div className="space-y-4">
                <Link
                  href="/choir-project"
                  className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
                >
                  Return to Choir Project
                </Link>
                <p className="text-sm text-green-700">
                  In the meantime, feel free to{' '}
                  <a href="https://www.youtube.com/@adventhymnals" target="_blank" rel="noopener noreferrer" className="underline">
                    subscribe to our YouTube channel
                  </a>{' '}
                  to stay updated with our latest recordings.
                </p>
              </div>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-8">
              {/* Basic Information */}
              <div className="bg-white rounded-xl shadow-sm p-8">
                <div className="flex items-center mb-6">
                  <UserGroupIcon className="h-6 w-6 text-primary-600 mr-3" />
                  <h2 className="text-xl font-bold text-gray-900">Choir Information</h2>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label htmlFor="choirName" className="block text-sm font-medium text-gray-700 mb-2">
                      Choir Name *
                    </label>
                    <input
                      type="text"
                      id="choirName"
                      required
                      value={formData.choirName}
                      onChange={(e) => handleInputChange('choirName', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="e.g., First Church Choir"
                    />
                  </div>
                  
                  <div>
                    <label htmlFor="contactName" className="block text-sm font-medium text-gray-700 mb-2">
                      Contact Person *
                    </label>
                    <input
                      type="text"
                      id="contactName"
                      required
                      value={formData.contactName}
                      onChange={(e) => handleInputChange('contactName', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="Choir director or contact person"
                    />
                  </div>
                  
                  <div>
                    <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                      Email Address *
                    </label>
                    <input
                      type="email"
                      id="email"
                      required
                      value={formData.email}
                      onChange={(e) => handleInputChange('email', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="contact@example.com"
                    />
                  </div>
                  
                  <div>
                    <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                      Phone Number
                    </label>
                    <input
                      type="tel"
                      id="phone"
                      value={formData.phone}
                      onChange={(e) => handleInputChange('phone', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="+1 (555) 123-4567"
                    />
                  </div>
                  
                  <div>
                    <label htmlFor="location" className="block text-sm font-medium text-gray-700 mb-2">
                      Location *
                    </label>
                    <input
                      type="text"
                      id="location"
                      required
                      value={formData.location}
                      onChange={(e) => handleInputChange('location', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="City, Country"
                    />
                  </div>
                  
                  <div>
                    <label htmlFor="churchAffiliation" className="block text-sm font-medium text-gray-700 mb-2">
                      Church/Organization
                    </label>
                    <input
                      type="text"
                      id="churchAffiliation"
                      value={formData.churchAffiliation}
                      onChange={(e) => handleInputChange('churchAffiliation', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="Church or organization name"
                    />
                  </div>
                </div>
              </div>

              {/* Choir Details */}
              <div className="bg-white rounded-xl shadow-sm p-8">
                <h2 className="text-xl font-bold text-gray-900 mb-6">Choir Details</h2>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label htmlFor="choirSize" className="block text-sm font-medium text-gray-700 mb-2">
                      Choir Size *
                    </label>
                    <select
                      id="choirSize"
                      required
                      value={formData.choirSize}
                      onChange={(e) => handleInputChange('choirSize', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    >
                      <option value="">Select choir size</option>
                      <option value="Small (5-15 members)">Small (5-15 members)</option>
                      <option value="Medium (16-35 members)">Medium (16-35 members)</option>
                      <option value="Large (36-60 members)">Large (36-60 members)</option>
                      <option value="Very Large (60+ members)">Very Large (60+ members)</option>
                    </select>
                  </div>
                  
                  <div>
                    <label htmlFor="experience" className="block text-sm font-medium text-gray-700 mb-2">
                      Recording Experience *
                    </label>
                    <select
                      id="experience"
                      required
                      value={formData.experience}
                      onChange={(e) => handleInputChange('experience', e.target.value)}
                      className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    >
                      <option value="">Select experience level</option>
                      <option value="None - First time recording">None - First time recording</option>
                      <option value="Limited - Some recording experience">Limited - Some recording experience</option>
                      <option value="Moderate - Regular recording experience">Moderate - Regular recording experience</option>
                      <option value="Extensive - Professional recording experience">Extensive - Professional recording experience</option>
                    </select>
                  </div>
                </div>

                <div className="mt-6">
                  <label htmlFor="equipment" className="block text-sm font-medium text-gray-700 mb-2">
                    Available Recording Equipment *
                  </label>
                  <textarea
                    id="equipment"
                    required
                    value={formData.equipment}
                    onChange={(e) => handleInputChange('equipment', e.target.value)}
                    rows={3}
                    className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Describe your available recording equipment (microphones, audio interface, recording space, etc.)"
                  />
                </div>

                <div className="mt-6">
                  <label htmlFor="preferredTimeline" className="block text-sm font-medium text-gray-700 mb-2">
                    Preferred Timeline *
                  </label>
                  <select
                    id="preferredTimeline"
                    required
                    value={formData.preferredTimeline}
                    onChange={(e) => handleInputChange('preferredTimeline', e.target.value)}
                    className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="">Select preferred timeline</option>
                    <option value="Immediate (1-2 months)">Immediate (1-2 months)</option>
                    <option value="Short-term (3-6 months)">Short-term (3-6 months)</option>
                    <option value="Medium-term (6-12 months)">Medium-term (6-12 months)</option>
                    <option value="Long-term (12+ months)">Long-term (12+ months)</option>
                    <option value="Flexible">Flexible</option>
                  </select>
                </div>
              </div>

              {/* Hymn Selection */}
              <div className="bg-white rounded-xl shadow-sm p-8">
                <div className="flex items-center mb-6">
                  <MusicalNoteIcon className="h-6 w-6 text-primary-600 mr-3" />
                  <h2 className="text-xl font-bold text-gray-900">Hymn Selection</h2>
                </div>

                <p className="text-gray-600 mb-6">
                  Select the hymns your choir would like to record. You can choose from any of our {totalHymnsCount.toLocaleString()} hymns 
                  across all collections. Use the search box below to find specific hymns.
                </p>

                {!hymnSearch.trim() && (
                  <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                    <p className="text-blue-800 text-sm">
                      💡 <strong>Tip:</strong> Start typing to search for hymns by title, number, author, or composer.
                    </p>
                  </div>
                )}

                {/* Search and Filter */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                  <div className="relative">
                    <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                    <input
                      type="text"
                      placeholder="Search hymns by title, number, author, or composer..."
                      value={hymnSearch}
                      onChange={(e) => setHymnSearch(e.target.value)}
                      className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    />
                  </div>
                  
                  <select
                    value={selectedHymnal}
                    onChange={(e) => setSelectedHymnal(e.target.value)}
                    className="px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="all">All Hymnals</option>
                    {Object.values(hymnalReferences.hymnals).map(hymnal => (
                      <option key={hymnal.id} value={hymnal.id}>{hymnal.name}</option>
                    ))}
                  </select>
                </div>

                {/* Selected Hymns Count */}
                <div className="mb-4 p-3 bg-primary-50 rounded-lg">
                  <p className="text-primary-800">
                    <strong>{formData.selectedHymns.length}</strong> hymns selected
                    {formData.selectedHymns.length > 0 && (
                      <button
                        type="button"
                        onClick={() => handleInputChange('selectedHymns', [])}
                        className="ml-4 text-primary-600 hover:text-primary-700 underline"
                      >
                        Clear all
                      </button>
                    )}
                  </p>
                </div>

                {/* Hymn List */}
                <div className="max-h-96 overflow-y-auto border border-gray-200 rounded-lg">
                  {isSearching ? (
                    <div className="p-8 text-center text-gray-500">
                      <div className="animate-pulse">Searching hymns...</div>
                    </div>
                  ) : !hymnSearch.trim() ? (
                    <div className="p-8 text-center text-gray-500">
                      <div className="space-y-2">
                        <MagnifyingGlassIcon className="h-12 w-12 mx-auto text-gray-400" />
                        <p>Start typing to search and select hymns</p>
                        <p className="text-xs">Search by title, number, author, or composer</p>
                      </div>
                    </div>
                  ) : displayHymns.length === 0 ? (
                    <div className="p-8 text-center text-gray-500">
                      No hymns found matching "{hymnSearch}". Try a different search term.
                    </div>
                  ) : (
                    <div className="divide-y divide-gray-200">
                      {displayHymns.map(hymn => (
                        <label
                          key={hymn.id}
                          className="flex items-center p-4 hover:bg-gray-50 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={formData.selectedHymns.includes(hymn.id)}
                            onChange={() => handleHymnToggle(hymn.id)}
                            className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                          />
                          <div className="ml-3 flex-1">
                            <div className="text-sm font-medium text-gray-900">
                              {hymn.title}
                            </div>
                            <div className="text-sm text-gray-500">
                              {hymn.hymnalName} #{hymn.number} ({hymn.id})
                            </div>
                          </div>
                        </label>
                      ))}
                      {displayHymns.length >= 50 && (
                        <div className="p-4 text-center text-gray-500">
                          Showing first 50 results. Refine your search for more specific results.
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>

              {/* Additional Information */}
              <div className="bg-white rounded-xl shadow-sm p-8">
                <h2 className="text-xl font-bold text-gray-900 mb-6">Additional Information</h2>
                
                <div>
                  <label htmlFor="additionalInfo" className="block text-sm font-medium text-gray-700 mb-2">
                    Additional Comments or Questions
                  </label>
                  <textarea
                    id="additionalInfo"
                    value={formData.additionalInfo}
                    onChange={(e) => handleInputChange('additionalInfo', e.target.value)}
                    rows={4}
                    className="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Tell us about your choir, special arrangements you might have, or any questions about the project..."
                  />
                </div>
              </div>

              {/* Submit */}
              <div className="text-center">
                {submitStatus === 'error' && (
                  <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                    <div className="flex items-center">
                      <ExclamationTriangleIcon className="h-5 w-5 text-red-600 mr-2" />
                      <span className="text-red-800">
                        There was an error submitting your registration. Please try again.
                      </span>
                    </div>
                  </div>
                )}
                
                <button
                  type="submit"
                  disabled={isSubmitting || formData.selectedHymns.length === 0}
                  className="inline-flex items-center px-8 py-4 border border-transparent text-lg font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  <UserGroupIcon className="h-6 w-6 mr-3" />
                  {isSubmitting ? 'Submitting...' : 'Register Choir'}
                </button>
                
                <p className="mt-4 text-sm text-gray-600">
                  * Required fields. We&apos;ll contact you within 1-2 weeks to discuss your submission.
                </p>
              </div>
            </form>
          )}
        </div>
      </div>
    </Layout>
  );
}