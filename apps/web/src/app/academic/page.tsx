import { Metadata } from 'next';
import Link from 'next/link';
import { 
  AcademicCapIcon, 
  DocumentTextIcon, 
  ChartBarIcon, 
  BookOpenIcon,
  ArrowDownTrayIcon,
  MagnifyingGlassIcon 
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Academic Resources - Advent Hymnals',
  description: 'Academic tools and resources for researchers studying Adventist hymnody, including citations, datasets, and research guides.',
  keywords: ['academic research', 'hymn studies', 'musicology', 'Adventist history', 'religious music', 'research tools'],
};

const researchAreas = [
  {
    title: 'Historical Musicology',
    description: 'Study the evolution of Adventist musical traditions from 1838 to 2000',
    topics: [
      'Chronological development of hymnal content',
      'Influence of revival movements on hymn selection',
      'Cross-denominational hymn adoption patterns',
      'Regional variations in hymnal compilation'
    ]
  },
  {
    title: 'Theological Studies',
    description: 'Analyze theological themes and doctrinal emphasis in Adventist hymnody',
    topics: [
      'Second Coming themes in hymn texts',
      'Sabbath theology in worship music',
      'Salvation and grace narratives',
      'Prophetic and eschatological content'
    ]
  },
  {
    title: 'Cross-Cultural Studies',
    description: 'Examine how Adventist hymns adapted across languages and cultures',
    topics: [
      'Translation strategies and cultural adaptation',
      'Indigenous musical influence in African hymnals',
      'Language preservation through hymnody',
      'Missionary impact on musical traditions'
    ]
  },
  {
    title: 'Literary Analysis',
    description: 'Study the poetic and literary qualities of hymn texts',
    topics: [
      'Poetic structures and meter analysis',
      'Biblical allusions and references',
      'Literary devices in religious poetry',
      'Author attribution and biographical studies'
    ]
  }
];

const datasetTypes = [
  {
    title: 'Complete Hymnal Metadata',
    format: 'JSON/CSV',
    description: 'Comprehensive metadata for all 13 hymnal collections',
    includes: ['Publication details', 'Compiler information', 'Language data', 'Historical context']
  },
  {
    title: 'Hymn Text Corpus',
    format: 'JSON/TXT',
    description: 'Full text of all hymns with verse structure preserved',
    includes: ['Complete lyrics', 'Verse numbering', 'Chorus/refrain markup', 'Textual variants']
  },
  {
    title: 'Author & Composer Index',
    format: 'JSON/CSV',
    description: 'Biographical and attribution data for hymn creators',
    includes: ['Life dates', 'Biographical notes', 'Attribution confidence', 'Work catalogs']
  },
  {
    title: 'Cross-Reference Tables',
    format: 'CSV/JSON',
    description: 'Mapping of hymns across different collections',
    includes: ['Hymn number mappings', 'Text variations', 'Tune assignments', 'Collection appearances']
  }
];

export default async function AcademicPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Academic Resources
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Tools, datasets, and resources for researchers studying Adventist hymnody and religious music
              </p>
              <div className="mt-8 flex justify-center gap-8 text-sm text-gray-500">
                <div className="flex items-center">
                  <BookOpenIcon className="h-5 w-5 mr-2" />
                  <span>13 Collections</span>
                </div>
                <div className="flex items-center">
                  <DocumentTextIcon className="h-5 w-5 mr-2" />
                  <span>5,500+ Hymns</span>
                </div>
                <div className="flex items-center">
                  <ChartBarIcon className="h-5 w-5 mr-2" />
                  <span>Research-Ready Data</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Research Areas */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Research Areas</h2>
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
              {researchAreas.map((area) => (
                <div key={area.title} className="bg-white rounded-xl shadow-sm p-6">
                  <h3 className="text-xl font-semibold text-gray-900 mb-3">{area.title}</h3>
                  <p className="text-gray-600 mb-4">{area.description}</p>
                  <div>
                    <h4 className="text-sm font-semibold text-gray-900 mb-2">Research Topics:</h4>
                    <ul className="space-y-1">
                      {area.topics.map((topic, index) => (
                        <li key={index} className="flex items-start">
                          <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                          <span className="text-sm text-gray-700">{topic}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Research Tools */}
          <div className="bg-white rounded-xl shadow-sm p-8 mb-12">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Research Tools</h2>
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
              <div className="border border-gray-200 rounded-lg p-6">
                <MagnifyingGlassIcon className="h-8 w-8 text-blue-600 mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Advanced Search</h3>
                <p className="text-sm text-gray-600 mb-4">
                  Search across all collections with filters for dates, themes, authors, and more.
                </p>
                <Link
                  href="/search"
                  className="text-primary-600 hover:text-primary-700 font-medium text-sm"
                >
                  Use Search Tool →
                </Link>
              </div>

              <div className="border border-gray-200 rounded-lg p-6">
                <ChartBarIcon className="h-8 w-8 text-green-600 mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Hymnal Comparison</h3>
                <p className="text-sm text-gray-600 mb-4">
                  Compare content across different hymnal collections and time periods.
                </p>
                <Link
                  href="/compare"
                  className="text-primary-600 hover:text-primary-700 font-medium text-sm"
                >
                  Compare Hymnals →
                </Link>
              </div>

              <div className="border border-gray-200 rounded-lg p-6">
                <DocumentTextIcon className="h-8 w-8 text-purple-600 mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Citation Generator</h3>
                <p className="text-sm text-gray-600 mb-4">
                  Generate proper academic citations for hymns and collections.
                </p>
                <button className="text-primary-600 hover:text-primary-700 font-medium text-sm">
                  Generate Citations →
                </button>
              </div>
            </div>
          </div>

          {/* Datasets */}
          <div className="mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Research Datasets</h2>
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              {datasetTypes.map((dataset) => (
                <div key={dataset.title} className="bg-white rounded-xl shadow-sm p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900">{dataset.title}</h3>
                      <p className="text-sm text-gray-500">{dataset.format}</p>
                    </div>
                    <button className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                      <ArrowDownTrayIcon className="h-4 w-4 mr-2" />
                      Download
                    </button>
                  </div>
                  <p className="text-gray-600 mb-4">{dataset.description}</p>
                  <div>
                    <h4 className="text-sm font-semibold text-gray-900 mb-2">Includes:</h4>
                    <ul className="space-y-1">
                      {dataset.includes.map((item, index) => (
                        <li key={index} className="flex items-start">
                          <span className="h-1.5 w-1.5 bg-green-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                          <span className="text-sm text-gray-700">{item}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
              ))}
            </div>
            
            <div className="text-center mt-8">
              <p className="text-sm text-gray-600 mb-4">
                All datasets are provided under Creative Commons Attribution 4.0 International License
              </p>
              <Link
                href="/contact"
                className="text-primary-600 hover:text-primary-700 font-medium"
              >
                Request Custom Dataset →
              </Link>
            </div>
          </div>

          {/* Citation Guide */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-8 mb-12">
            <h2 className="text-2xl font-bold text-blue-900 mb-6">Citation Guidelines</h2>
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <div>
                <h3 className="text-lg font-semibold text-blue-800 mb-3">Citing Individual Hymns</h3>
                <div className="bg-white rounded-lg p-4 text-sm">
                  <p className="font-mono text-blue-900">
                    [Author Last Name], [First Name]. &quot;[Hymn Title].&quot; In <em>[Hymnal Name]</em>, 
                    hymn [number]. [City]: [Publisher], [Year]. Advent Hymnals Digital Collection, 
                    [URL]. Accessed [Date].
                  </p>
                </div>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-blue-800 mb-3">Citing Hymnal Collections</h3>
                <div className="bg-white rounded-lg p-4 text-sm">
                  <p className="font-mono text-blue-900">
                    [Compiler/Editor]. <em>[Hymnal Name]</em>. [City]: [Publisher], [Year]. 
                    Advent Hymnals Digital Collection, [URL]. Accessed [Date].
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Research Support */}
          <div className="bg-white rounded-xl shadow-sm p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">Research Support</h2>
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
              <div className="text-center">
                <AcademicCapIcon className="h-12 w-12 text-primary-600 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Collaborative Research</h3>
                <p className="text-gray-600 text-sm mb-4">
                  Partner with our team on research projects and publications
                </p>
                <Link
                  href="/contact"
                  className="text-primary-600 hover:text-primary-700 font-medium text-sm"
                >
                  Propose Collaboration →
                </Link>
              </div>

              <div className="text-center">
                <DocumentTextIcon className="h-12 w-12 text-green-600 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Publication Support</h3>
                <p className="text-gray-600 text-sm mb-4">
                  Get assistance with data analysis and methodology for publications
                </p>
                <Link
                  href="/contact"
                  className="text-primary-600 hover:text-primary-700 font-medium text-sm"
                >
                  Request Support →
                </Link>
              </div>

              <div className="text-center">
                <ChartBarIcon className="h-12 w-12 text-purple-600 mx-auto mb-4" />
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Data Verification</h3>
                <p className="text-gray-600 text-sm mb-4">
                  Help verify and improve our datasets through peer review
                </p>
                <Link
                  href="/contribute"
                  className="text-primary-600 hover:text-primary-700 font-medium text-sm"
                >
                  Join Verification →
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}