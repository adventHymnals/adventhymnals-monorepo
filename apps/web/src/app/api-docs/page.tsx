import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';
import { CodeBracketIcon, DocumentTextIcon, GlobeAltIcon, KeyIcon } from '@heroicons/react/24/outline';

export const metadata: Metadata = {
  title: 'API Documentation - Advent Hymnals',
  description: 'Developer documentation for the Advent Hymnals API. Access hymnal data programmatically for your applications.',
  keywords: ['API documentation', 'developer tools', 'hymnal API', 'REST API'],
};

const endpoints = [
  {
    method: 'GET',
    path: '/api/hymnals',
    description: 'Get all hymnal collections',
    response: 'Array of hymnal metadata objects'
  },
  {
    method: 'GET', 
    path: '/api/hymnals/{id}',
    description: 'Get specific hymnal collection',
    response: 'Hymnal object with metadata and hymn list'
  },
  {
    method: 'GET',
    path: '/api/hymns/{id}',
    description: 'Get specific hymn data',
    response: 'Complete hymn object with verses, metadata, and musical information'
  },
  {
    method: 'GET',
    path: '/api/search',
    description: 'Search hymns across collections',
    response: 'Array of matching hymns with relevance scores'
  }
];

export default async function ApiDocsPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
                API Documentation
              </h1>
              <p className="mt-6 text-lg leading-8 text-primary-100">
                Access Advent Hymnals data programmatically for your applications
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
            {/* Main Content */}
            <div className="lg:col-span-2 space-y-8">
              {/* Getting Started */}
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <div className="flex items-center mb-6">
                  <CodeBracketIcon className="h-6 w-6 text-primary-600 mr-3" />
                  <h2 className="text-2xl font-bold text-gray-900">Getting Started</h2>
                </div>
                
                <div className="prose max-w-none">
                  <p className="text-gray-600 mb-4">
                    The Advent Hymnals API provides RESTful access to our complete database of hymnal collections, 
                    individual hymns, and associated metadata.
                  </p>
                  
                  <div className="bg-gray-50 rounded-lg p-4 mb-6">
                    <h4 className="font-semibold text-gray-900 mb-2">Base URL</h4>
                    <code className="text-sm bg-gray-100 px-2 py-1 rounded">
                      https://adventhymnals.com/api
                    </code>
                  </div>

                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                    <h4 className="font-semibold text-blue-900 mb-2">🚧 API Under Development</h4>
                    <p className="text-blue-800 text-sm">
                      Our public API is currently under development. Documentation and endpoints 
                      will be available soon for developers who want to integrate hymnal data 
                      into their applications.
                    </p>
                  </div>
                </div>
              </div>

              {/* Planned Endpoints */}
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <div className="flex items-center mb-6">
                  <GlobeAltIcon className="h-6 w-6 text-primary-600 mr-3" />
                  <h2 className="text-2xl font-bold text-gray-900">Planned Endpoints</h2>
                </div>

                <div className="space-y-4">
                  {endpoints.map((endpoint, index) => (
                    <div key={index} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center justify-between mb-2">
                        <div className="flex items-center space-x-3">
                          <span className={`px-2 py-1 text-xs font-medium rounded ${
                            endpoint.method === 'GET' ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'
                          }`}>
                            {endpoint.method}
                          </span>
                          <code className="text-sm font-mono text-gray-900">{endpoint.path}</code>
                        </div>
                      </div>
                      <p className="text-gray-600 text-sm mb-1">{endpoint.description}</p>
                      <p className="text-xs text-gray-500">Returns: {endpoint.response}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Use Cases */}
              <div className="bg-white rounded-xl shadow-sm border p-8">
                <div className="flex items-center mb-6">
                  <DocumentTextIcon className="h-6 w-6 text-primary-600 mr-3" />
                  <h2 className="text-2xl font-bold text-gray-900">Use Cases</h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="border-l-4 border-primary-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">Worship Planning Apps</h3>
                    <p className="text-sm text-gray-600">
                      Integrate hymnal data into church management software for service planning and hymn selection.
                    </p>
                  </div>
                  <div className="border-l-4 border-green-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">Academic Research</h3>
                    <p className="text-sm text-gray-600">
                      Access structured data for musicological research and historical analysis of hymn collections.
                    </p>
                  </div>
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">Mobile Applications</h3>
                    <p className="text-sm text-gray-600">
                      Build mobile apps with offline hymnal access and synchronization capabilities.
                    </p>
                  </div>
                  <div className="border-l-4 border-purple-500 pl-4">
                    <h3 className="font-semibold text-gray-900 mb-2">Educational Tools</h3>
                    <p className="text-sm text-gray-600">
                      Create learning platforms for music education and hymn study resources.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1 space-y-6">
              <div className="bg-white rounded-xl shadow-sm border p-6">
                <div className="flex items-center mb-4">
                  <KeyIcon className="h-5 w-5 text-primary-600 mr-2" />
                  <h3 className="text-lg font-semibold text-gray-900">API Access</h3>
                </div>
                <div className="space-y-4 text-sm text-gray-600">
                  <p>
                    API access will be free for educational and non-commercial use.
                  </p>
                  <p>
                    Commercial usage will require API keys and may have rate limiting.
                  </p>
                  <div className="bg-gray-50 rounded-lg p-3">
                    <p className="text-xs text-gray-500">
                      Interested in early access? Contact us at developer@adventhymnals.com
                    </p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Data Formats</h3>
                <div className="space-y-3 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-600">Response Format</span>
                    <span className="font-mono bg-gray-100 px-2 py-1 rounded text-xs">JSON</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Character Encoding</span>
                    <span className="font-mono bg-gray-100 px-2 py-1 rounded text-xs">UTF-8</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">API Version</span>
                    <span className="font-mono bg-gray-100 px-2 py-1 rounded text-xs">v1</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl shadow-sm border p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Resources</h3>
                <div className="space-y-2">
                  <a href="https://github.com/adventhymnals" className="block text-sm text-primary-600 hover:text-primary-700">
                    GitHub Repository →
                  </a>
                  <a href="/contact" className="block text-sm text-primary-600 hover:text-primary-700">
                    Contact Developers →
                  </a>
                  <a href="/contribute" className="block text-sm text-primary-600 hover:text-primary-700">
                    Contribute to Project →
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}