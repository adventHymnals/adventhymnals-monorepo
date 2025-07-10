'use client';

import { useState } from 'react';
import Layout from '@/components/layout/Layout';
import { HymnalCollection } from '@advent-hymnals/shared';
import { 
  CodeBracketIcon, 
  DocumentTextIcon, 
  GlobeAltIcon, 
  KeyIcon, 
  BookOpenIcon,
  MusicalNoteIcon,
  MagnifyingGlassIcon,
  UserGroupIcon,
  HeartIcon,
  ClipboardDocumentIcon
} from '@heroicons/react/24/outline';

const endpoints = [
  {
    method: 'GET',
    path: '/api/hymnals',
    description: 'Get all hymnal collections with metadata',
    response: 'Array of hymnal metadata objects with IDs, names, and descriptions',
    parameters: [],
    example: `{
  "hymnals": {
    "SDAH": {
      "id": "SDAH",
      "name": "Seventh-day Adventist Hymnal",
      "description": "Official hymnal of the Seventh-day Adventist Church",
      "year": 1985,
      "language": "English"
    }
  }
}`,
    category: 'Core Data'
  },
  {
    method: 'GET', 
    path: '/api/hymnals/{id}',
    description: 'Get specific hymnal collection with detailed information',
    response: 'Hymnal object with complete metadata and hymn list',
    parameters: [
      { name: 'id', type: 'string', required: true, description: 'Hymnal identifier (e.g., SDAH, CS1900)' }
    ],
    example: `{
  "id": "SDAH",
  "name": "Seventh-day Adventist Hymnal",
  "hymns": [...],
  "totalHymns": 695
}`,
    category: 'Core Data'
  },
  {
    method: 'GET',
    path: '/api/hymnals/{id}/hymns',
    description: 'Get paginated hymns from a specific hymnal',
    response: 'Paginated list of hymns with metadata',
    parameters: [
      { name: 'id', type: 'string', required: true, description: 'Hymnal identifier' },
      { name: 'page', type: 'number', required: false, description: 'Page number (default: 1)' },
      { name: 'limit', type: 'number', required: false, description: 'Items per page (default: 20)' }
    ],
    example: `{
  "hymns": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 695
  }
}`,
    category: 'Core Data'
  },
  {
    method: 'GET',
    path: '/api/hymnals/{id}/pdf',
    description: 'Generate and download PDF of hymnal collection',
    response: 'PDF file download',
    parameters: [
      { name: 'id', type: 'string', required: true, description: 'Hymnal identifier' }
    ],
    example: 'Binary PDF response',
    category: 'Downloads'
  },
  {
    method: 'GET',
    path: '/api/hymns/{id}',
    description: 'Get specific hymn with complete data',
    response: 'Complete hymn object with verses, metadata, and musical information',
    parameters: [
      { name: 'id', type: 'string', required: true, description: 'Hymn identifier (e.g., SDAH-en-001)' }
    ],
    example: `{
  "id": "SDAH-en-001",
  "number": 1,
  "title": "Praise to the Lord, the Almighty",
  "author": "Joachim Neander",
  "composer": "Erneuerten Gesangbuch",
  "tune": "LOBE DEN HERREN",
  "meter": "14 14 4 7 8",
  "verses": [...],
  "topics": ["Praise", "Worship"]
}`,
    category: 'Core Data'
  },
  {
    method: 'GET',
    path: '/api/hymns/{id}/related',
    description: 'Get hymns related to a specific hymn',
    response: 'Array of related hymns based on tune, author, or topic',
    parameters: [
      { name: 'id', type: 'string', required: true, description: 'Hymn identifier' }
    ],
    example: `{
  "related": [
    {
      "id": "SDAH-en-002",
      "title": "Similar Hymn",
      "relationshipType": "same_tune"
    }
  ]
}`,
    category: 'Discovery'
  },
  {
    method: 'GET',
    path: '/api/search',
    description: 'Search hymns across all collections',
    response: 'Array of matching hymns with relevance scores',
    parameters: [
      { name: 'q', type: 'string', required: true, description: 'Search query' },
      { name: 'hymnal', type: 'string', required: false, description: 'Limit search to specific hymnal' },
      { name: 'limit', type: 'number', required: false, description: 'Maximum results (default: 20)' }
    ],
    example: `{
  "hymns": [
    {
      "id": "SDAH-en-001",
      "title": "Praise to the Lord",
      "score": 0.95,
      "snippet": "Praise to the Lord, the Almighty..."
    }
  ],
  "total": 1
}`,
    category: 'Search'
  },
  {
    method: 'GET',
    path: '/api/authors',
    description: 'Get all hymn authors with their works',
    response: 'Array of authors with hymn counts and associated hymns',
    parameters: [],
    example: `[
  {
    "author": "Charles Wesley",
    "count": 45,
    "hymns": [...]
  }
]`,
    category: 'Indexes'
  },
  {
    method: 'GET',
    path: '/api/composers',
    description: 'Get all hymn composers with their works',
    response: 'Array of composers with hymn counts and associated hymns',
    parameters: [],
    example: `[
  {
    "composer": "Johann Sebastian Bach",
    "count": 12,
    "hymns": [...]
  }
]`,
    category: 'Indexes'
  },
  {
    method: 'GET',
    path: '/api/tunes',
    description: 'Get all hymn tunes with associated hymns',
    response: 'Array of tune names with hymn counts and associated hymns',
    parameters: [],
    example: `[
  {
    "tune": "AMAZING GRACE",
    "count": 8,
    "hymns": [...]
  }
]`,
    category: 'Indexes'
  },
  {
    method: 'GET',
    path: '/api/meters',
    description: 'Get all hymn meters with associated hymns',
    response: 'Array of meter patterns with hymn counts',
    parameters: [],
    example: `[
  {
    "meter": "8 6 8 6 (Common Meter)",
    "count": 156,
    "hymns": [...]
  }
]`,
    category: 'Indexes'
  },
  {
    method: 'GET',
    path: '/api/themes',
    description: 'Get all hymn themes/topics with associated hymns',
    response: 'Array of themes with hymn counts',
    parameters: [],
    example: `[
  {
    "theme": "Praise and Worship",
    "count": 98,
    "hymns": [...]
  }
]`,
    category: 'Indexes'
  },
  {
    method: 'GET',
    path: '/api/health',
    description: 'API health check endpoint',
    response: 'Service status and timestamp',
    parameters: [],
    example: `{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00Z",
  "service": "advent-hymnals-web"
}`,
    category: 'System'
  },
  {
    method: 'GET',
    path: '/api/sitemap',
    description: 'Generate XML sitemap for SEO',
    response: 'XML sitemap with all hymnal and hymn URLs',
    parameters: [],
    example: 'XML sitemap response',
    category: 'System'
  },
  {
    method: 'GET',
    path: '/api/robots',
    description: 'Generate robots.txt for web crawlers',
    response: 'robots.txt content',
    parameters: [],
    example: 'robots.txt content',
    category: 'System'
  },
  {
    method: 'POST',
    path: '/api/subscribe',
    description: 'Subscribe to project updates',
    response: 'Subscription confirmation',
    parameters: [
      { name: 'email', type: 'string', required: true, description: 'Email address' },
      { name: 'source', type: 'string', required: false, description: 'Subscription source' }
    ],
    example: `{
  "success": true,
  "message": "Subscribed successfully"
}`,
    category: 'Subscription'
  },
  {
    method: 'GET',
    path: '/api/updates/version',
    description: 'Get current API version information',
    response: 'Version and build information',
    parameters: [],
    example: `{
  "version": "1.0.10",
  "build": "2024-01-15T10:30:00Z"
}`,
    category: 'System'
  },
  {
    method: 'GET',
    path: '/api/updates/updates/{from_version}',
    description: 'Get updates available since a specific version',
    response: 'List of updates and changes',
    parameters: [
      { name: 'from_version', type: 'string', required: true, description: 'Version to check updates from' }
    ],
    example: `{
  "updates": [
    {
      "version": "1.0.10",
      "changes": ["Added new endpoints"]
    }
  ]
}`,
    category: 'System'
  }
];

interface ApiDocsClientProps {
  hymnalReferences: HymnalCollection;
}

export default function ApiDocsClient({ hymnalReferences }: ApiDocsClientProps) {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedEndpoint, setSelectedEndpoint] = useState<string | null>(null);
  
  const categories = [
    { id: 'all', name: 'All Endpoints', icon: GlobeAltIcon, count: endpoints.length },
    { id: 'Core Data', name: 'Core Data', icon: BookOpenIcon, count: endpoints.filter(e => e.category === 'Core Data').length },
    { id: 'Search', name: 'Search', icon: MagnifyingGlassIcon, count: endpoints.filter(e => e.category === 'Search').length },
    { id: 'Discovery', name: 'Discovery', icon: HeartIcon, count: endpoints.filter(e => e.category === 'Discovery').length },
    { id: 'Indexes', name: 'Indexes', icon: UserGroupIcon, count: endpoints.filter(e => e.category === 'Indexes').length },
    { id: 'Downloads', name: 'Downloads', icon: ClipboardDocumentIcon, count: endpoints.filter(e => e.category === 'Downloads').length },
    { id: 'System', name: 'System', icon: KeyIcon, count: endpoints.filter(e => e.category === 'System').length },
    { id: 'Subscription', name: 'Subscription', icon: MusicalNoteIcon, count: endpoints.filter(e => e.category === 'Subscription').length },
  ];
  
  const filteredEndpoints = selectedCategory === 'all' 
    ? endpoints 
    : endpoints.filter(e => e.category === selectedCategory);

  const getMethodColor = (method: string) => {
    switch (method) {
      case 'GET': return 'bg-green-100 text-green-800 border-green-200';
      case 'POST': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'PUT': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'DELETE': return 'bg-red-100 text-red-800 border-red-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center text-white">
              <div className="flex justify-center mb-4">
                <CodeBracketIcon className="h-12 w-12 text-primary-100" />
              </div>
              <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
                API Documentation
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                RESTful access to 160+ years of hymnal data. No API key required.
              </p>
              <div className="mt-8 flex justify-center space-x-8 text-sm text-primary-200">
                <div className="flex items-center">
                  <GlobeAltIcon className="h-5 w-5 mr-2" />
                  <span>{endpoints.length} Endpoints</span>
                </div>
                <div className="flex items-center">
                  <MusicalNoteIcon className="h-5 w-5 mr-2" />
                  <span>5,500+ Hymns</span>
                </div>
                <div className="flex items-center">
                  <BookOpenIcon className="h-5 w-5 mr-2" />
                  <span>13 Collections</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="mx-auto max-w-7xl px-6">
            <div className="flex space-x-8 overflow-x-auto">
              {categories.map((category) => {
                const Icon = category.icon;
                return (
                  <button
                    key={category.id}
                    onClick={() => setSelectedCategory(category.id)}
                    className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap ${
                      selectedCategory === category.id
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }`}
                  >
                    <Icon className="h-4 w-4" />
                    <span>{category.name}</span>
                    <span className="bg-gray-100 text-gray-600 px-2 py-1 rounded-full text-xs">
                      {category.count}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-4">
            {/* Main Content */}
            <div className="lg:col-span-3 space-y-8">
              {/* Quick Start Guide */}
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <div className="flex items-center mb-6">
                  <CodeBracketIcon className="h-6 w-6 text-blue-600 mr-3" />
                  <h2 className="text-2xl font-bold text-gray-900">Quick Start</h2>
                </div>
                
                <div className="prose max-w-none">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-semibold text-gray-900 mb-2">Base URL</h4>
                      <code className="text-sm bg-gray-800 text-green-400 px-3 py-2 rounded block">
                        https://adventhymnals.com/api
                      </code>
                    </div>
                    <div className="bg-gray-50 rounded-lg p-4">
                      <h4 className="font-semibold text-gray-900 mb-2">Response Format</h4>
                      <code className="text-sm bg-gray-800 text-green-400 px-3 py-2 rounded block">
                        Content-Type: application/json
                      </code>
                    </div>
                  </div>

                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                    <h4 className="font-semibold text-blue-900 mb-2">⚡ Example Request</h4>
                    <pre className="text-sm bg-gray-800 text-green-400 p-3 rounded overflow-x-auto">
{`curl -X GET "https://adventhymnals.com/api/hymnals" \\
     -H "Accept: application/json"`}
                    </pre>
                  </div>

                  <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                    <h4 className="font-semibold text-green-900 mb-2">✅ Try It Now</h4>
                    <p className="text-green-800 text-sm mb-2">
                      All endpoints are currently available for testing. No API key required.
                    </p>
                    <a 
                      href="/api/hymnals" 
                      target="_blank"
                      className="inline-flex items-center text-sm text-green-700 hover:text-green-900"
                    >
                      Test /api/hymnals endpoint →
                    </a>
                  </div>
                </div>
              </div>

              {/* Endpoints List */}
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center">
                    <GlobeAltIcon className="h-6 w-6 text-blue-600 mr-3" />
                    <h2 className="text-2xl font-bold text-gray-900">
                      {selectedCategory === 'all' ? 'All Endpoints' : `${selectedCategory} Endpoints`}
                    </h2>
                  </div>
                  <span className="text-sm text-gray-500">
                    {filteredEndpoints.length} endpoint{filteredEndpoints.length !== 1 ? 's' : ''}
                  </span>
                </div>

                <div className="space-y-4">
                  {filteredEndpoints.map((endpoint, index) => (
                    <div key={index} className="border border-gray-200 rounded-lg hover:border-blue-300 transition-colors">
                      <div 
                        className="p-4 cursor-pointer"
                        onClick={() => setSelectedEndpoint(selectedEndpoint === `${index}` ? null : `${index}`)}
                      >
                        <div className="flex items-center justify-between mb-2">
                          <div className="flex items-center space-x-3">
                            <span className={`px-3 py-1 text-xs font-medium rounded-full border ${getMethodColor(endpoint.method)}`}>
                              {endpoint.method}
                            </span>
                            <code className="text-sm font-mono text-gray-900 font-semibold">{endpoint.path}</code>
                          </div>
                          <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">
                            {endpoint.category}
                          </span>
                        </div>
                        <p className="text-gray-600 text-sm">{endpoint.description}</p>
                      </div>
                      
                      {selectedEndpoint === `${index}` && (
                        <div className="border-t border-gray-200 p-4 bg-gray-50">
                          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                            {/* Parameters */}
                            <div>
                              <h4 className="font-semibold text-gray-900 mb-3">Parameters</h4>
                              {endpoint.parameters.length > 0 ? (
                                <div className="space-y-2">
                                  {endpoint.parameters.map((param, paramIndex) => (
                                    <div key={paramIndex} className="bg-white p-3 rounded border">
                                      <div className="flex items-center justify-between mb-1">
                                        <code className="text-sm font-mono text-blue-600">{param.name}</code>
                                        <div className="flex space-x-2">
                                          <span className="text-xs bg-gray-100 px-2 py-1 rounded">{param.type}</span>
                                          {param.required && (
                                            <span className="text-xs bg-red-100 text-red-700 px-2 py-1 rounded">required</span>
                                          )}
                                        </div>
                                      </div>
                                      <p className="text-xs text-gray-600">{param.description}</p>
                                    </div>
                                  ))}
                                </div>
                              ) : (
                                <p className="text-sm text-gray-500">No parameters required</p>
                              )}
                              
                              <div className="mt-4">
                                <h5 className="font-medium text-gray-900 mb-2">Try it:</h5>
                                <a 
                                  href={endpoint.path.replace('{id}', 'SDAH').replace('{hymnId}', 'SDAH-en-001').replace('{from_version}', '1.0.0')}
                                  target="_blank"
                                  className="inline-flex items-center text-sm bg-blue-100 text-blue-700 hover:bg-blue-200 px-3 py-1 rounded"
                                >
                                  Test endpoint →
                                </a>
                              </div>
                            </div>
                            
                            {/* Example Response */}
                            <div>
                              <h4 className="font-semibold text-gray-900 mb-3">Example Response</h4>
                              <pre className="text-xs bg-gray-800 text-green-400 p-3 rounded overflow-x-auto max-h-64">
                                {endpoint.example}
                              </pre>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>

              {/* Use Cases */}
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <div className="flex items-center mb-6">
                  <DocumentTextIcon className="h-6 w-6 text-blue-600 mr-3" />
                  <h2 className="text-2xl font-bold text-gray-900">Use Cases & Examples</h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">🎵 Worship Planning Apps</h3>
                    <p className="text-sm text-gray-600 mb-2">
                      Integrate hymnal data into church management software for service planning and hymn selection.
                    </p>
                    <code className="text-xs bg-gray-100 p-2 rounded block">
                      GET /api/search?q=praise&hymnal=SDAH
                    </code>
                  </div>
                  <div className="border-l-4 border-green-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">📚 Academic Research</h3>
                    <p className="text-sm text-gray-600 mb-2">
                      Access structured data for musicological research and historical analysis.
                    </p>
                    <code className="text-xs bg-gray-100 p-2 rounded block">
                      GET /api/authors
                    </code>
                  </div>
                  <div className="border-l-4 border-purple-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">📱 Mobile Applications</h3>
                    <p className="text-sm text-gray-600 mb-2">
                      Build mobile apps with offline hymnal access and synchronization capabilities.
                    </p>
                    <code className="text-xs bg-gray-100 p-2 rounded block">
                      GET /api/hymnals/SDAH/hymns?limit=50
                    </code>
                  </div>
                  <div className="border-l-4 border-orange-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">🎓 Educational Tools</h3>
                    <p className="text-sm text-gray-600 mb-2">
                      Create learning platforms for music education and hymn study resources.
                    </p>
                    <code className="text-xs bg-gray-100 p-2 rounded block">
                      GET /api/meters
                    </code>
                  </div>
                </div>
              </div>
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1 space-y-6">
              <div className="bg-white rounded-xl shadow-sm border p-6">
                <div className="flex items-center mb-4">
                  <KeyIcon className="h-5 w-5 text-blue-600 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">API Access</h3>
                </div>
                <div className="space-y-4 text-sm text-gray-600">
                  <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                    <p className="text-green-800 font-medium mb-1">✅ Currently Available</p>
                    <p className="text-green-700 text-xs">
                      All endpoints are live and accessible for testing and development.
                    </p>
                  </div>
                  <p>
                    API access is free for educational and non-commercial use.
                  </p>
                  <p>
                    Commercial usage may require API keys and rate limiting in the future.
                  </p>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Response Details</h3>
                <div className="space-y-3 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-600">Format</span>
                    <span className="font-mono bg-gray-100 px-2 py-1 rounded text-xs">JSON</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Encoding</span>
                    <span className="font-mono bg-gray-100 px-2 py-1 rounded text-xs">UTF-8</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">CORS</span>
                    <span className="font-mono bg-green-100 text-green-800 px-2 py-1 rounded text-xs">Enabled</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Version</span>
                    <span className="font-mono bg-gray-100 px-2 py-1 rounded text-xs">v1</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Resources</h3>
                <div className="space-y-2">
                  <a 
                    href="https://github.com/adventhymnals" 
                    target="_blank"
                    className="block text-sm text-blue-600 hover:text-blue-700"
                  >
                    📁 GitHub Repository →
                  </a>
                  <a href="/contact" className="block text-sm text-blue-600 hover:text-blue-700">
                    💬 Contact Developers →
                  </a>
                  <a href="/contribute" className="block text-sm text-blue-600 hover:text-blue-700">
                    🤝 Contribute →
                  </a>
                  <a href="/api/health" target="_blank" className="block text-sm text-blue-600 hover:text-blue-700">
                    ❤️ API Health Check →
                  </a>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Status</h3>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center space-x-2">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span className="text-gray-700">All systems operational</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                    <span className="text-gray-700">99.9% uptime</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
                    <span className="text-gray-700">Rate limiting: None</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}