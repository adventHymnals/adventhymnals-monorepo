import type { Metadata } from 'next';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  AcademicCapIcon, 
  ClockIcon,
  DocumentTextIcon,
  HeartIcon,
  CheckCircleIcon,
  ArrowLeftIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';

export const metadata: Metadata = {
  title: 'Historic Seventh-Day Adventist Hymnal Project - Advent Hymnals',
  description: 'A scholarly project creating a hymnal that preserves early Adventist theological distinctives and Protestant worship traditions, addressing concerns about Catholic influences in modern hymnals.',
  keywords: 'Historic Seventh-day Adventist Hymnal, Protestant hymnal, Adventist worship, Catholic influences SDA hymnal, denominational distinctiveness, biblical worship',
  openGraph: {
    title: 'Historic Seventh-Day Adventist Hymnal Project',
    description: 'Preserving early Adventist theological distinctives and Protestant worship traditions through scholarly hymnal curation.',
    url: '/hymnal-projects/historic-sda-hymnal',
  },
};

// For static generation
export function generateStaticParams() {
  return [];
}

export default function HistoricSDAHymnalPage() {
  return (
    <Layout>
      <div className="min-h-screen bg-gray-50">
        {/* Navigation Breadcrumb */}
        <div className="bg-white border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <Link 
              href="/hymnal-projects"
              className="inline-flex items-center text-blue-600 hover:text-blue-800 transition-colors"
            >
              <ArrowLeftIcon className="w-4 h-4 mr-2" />
              Back to Hymnal Projects
            </Link>
          </div>
        </div>

        {/* Hero Section */}
        <div className="bg-gradient-to-r from-blue-900 to-purple-900 text-white">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
            <div className="text-center">
              <div className="flex justify-center mb-6">
                <div className="bg-white/20 p-4 rounded-full">
                  <BookOpenIcon className="w-16 h-16 text-white" />
                </div>
              </div>
              <h1 className="text-4xl md:text-5xl font-bold mb-6">
                Historic Seventh-Day Adventist Hymnal
              </h1>
              <p className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto mb-8">
                Preserving the theological distinctives and worship traditions of early Adventism
              </p>
              <div className="inline-flex items-center bg-blue-500/30 text-blue-100 px-4 py-2 rounded-full text-sm font-medium border border-blue-400/30">
                <ClockIcon className="w-4 h-4 mr-2" />
                Currently in Research Phase
              </div>
            </div>
          </div>
        </div>

        {/* Project Overview */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="grid lg:grid-cols-3 gap-12">
            {/* Main Content */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
                <h2 className="text-3xl font-bold text-gray-900 mb-6">Project Overview</h2>
                
                <p className="text-lg text-gray-600 mb-6">
                  The Historic Seventh-Day Adventist Hymnal is a carefully researched project aimed at creating 
                  a worship resource that reflects the Protestant heritage and biblical foundations that shaped 
                  the early Seventh-day Adventist movement.
                </p>
                
                <p className="text-gray-600 mb-6">
                  This scholarly initiative addresses concerns raised by some church historians and members about 
                  maintaining denominational distinctiveness in worship. Through careful research and theological 
                  analysis, we aim to create a hymnal that honors both our Adventist heritage and biblical truth.
                </p>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-8">
                  <div className="flex items-start">
                    <ExclamationTriangleIcon className="w-6 h-6 text-blue-600 mr-3 mt-1 flex-shrink-0" />
                    <div>
                      <h3 className="font-semibold text-blue-900 mb-2">Important Note</h3>
                      <p className="text-blue-800 text-sm">
                        This project is approached with scholarly objectivity and respect for all Christian traditions. 
                        Our goal is historical preservation and theological consistency, not divisiveness.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Historical Context */}
              <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Historical Context</h2>
                
                <div className="space-y-6">
                  <div>
                    <h3 className="text-xl font-semibold text-gray-800 mb-3">The 1985 SDA Hymnal</h3>
                    <p className="text-gray-600 mb-4">
                      The current Seventh-day Adventist Hymnal, published in 1985, has been noted by scholars 
                      for its ecumenical approach. Research by various Adventist historians and concerned church 
                      members has identified several areas of concern:
                    </p>
                    <ul className="space-y-2 text-gray-600">
                      <li className="flex items-start">
                        <DocumentTextIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span>Use of the Roman Catholic Jerusalem Bible more frequently than Protestant translations in responsive readings</span>
                      </li>
                      <li className="flex items-start">
                        <DocumentTextIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span>Inclusion of 13 hymns by John M. Neale, associated with the Oxford Movement's Catholic influences</span>
                      </li>
                      <li className="flex items-start">
                        <DocumentTextIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span>Introduction of liturgical terminology like "canticles" not traditionally used in Adventist worship</span>
                      </li>
                      <li className="flex items-start">
                        <DocumentTextIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span>First SDA hymnal to include an entire section dedicated to Trinity doctrine</span>
                      </li>
                    </ul>
                  </div>

                  <div>
                    <h3 className="text-xl font-semibold text-gray-800 mb-3">Scholarly Concerns</h3>
                    <p className="text-gray-600 mb-4">
                      Various Adventist scholars and websites have documented these concerns, noting that:
                    </p>
                    <ul className="space-y-2 text-gray-600">
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span>The hymnal represents "the most ecumenical or inclusive book in general use in modern Adventism"</span>
                      </li>
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span>Some conservative Adventist groups have expressed concerns about maintaining denominational identity</span>
                      </li>
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span>The need for worship resources that reflect historic Protestant and Adventist principles</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

              {/* Our Approach */}
              <div className="bg-white rounded-lg shadow-lg p-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Our Scholarly Approach</h2>
                
                <div className="grid md:grid-cols-2 gap-8">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-800 mb-4">Research Methodology</h3>
                    <ul className="space-y-3">
                      <li className="flex items-start">
                        <AcademicCapIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Historical analysis of hymn authorship and theological backgrounds</span>
                      </li>
                      <li className="flex items-start">
                        <AcademicCapIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Consultation with Adventist historians and theologians</span>
                      </li>
                      <li className="flex items-start">
                        <AcademicCapIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Analysis of doctrinal content and biblical alignment</span>
                      </li>
                      <li className="flex items-start">
                        <AcademicCapIcon className="w-4 h-4 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Review of early Adventist worship practices and preferences</span>
                      </li>
                    </ul>
                  </div>
                  
                  <div>
                    <h3 className="text-lg font-semibold text-gray-800 mb-4">Selection Criteria</h3>
                    <ul className="space-y-3">
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Consistency with biblical Protestant principles</span>
                      </li>
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Harmony with fundamental Adventist principles</span>
                      </li>
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Historical usage in early Adventist worship</span>
                      </li>
                      <li className="flex items-start">
                        <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-1 flex-shrink-0" />
                        <span className="text-gray-600 text-sm">Reflection of biblical worship patterns</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>

            {/* Sidebar */}
            <div className="lg:col-span-1">
              {/* Current Phase */}
              <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Current Phase</h3>
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
                  <div className="flex items-center mb-2">
                    <ClockIcon className="w-5 h-5 text-blue-600 mr-2" />
                    <span className="font-medium text-blue-800">Research Phase</span>
                  </div>
                  <p className="text-blue-700 text-sm">Analyzing existing hymnal content and historical sources</p>
                </div>
                
                <h4 className="font-medium text-gray-800 mb-3">Current Activities:</h4>
                <ul className="space-y-2 text-sm">
                  <li className="flex items-start text-gray-600">
                    <DocumentTextIcon className="w-3 h-3 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                    Cataloging hymns by theological background
                  </li>
                  <li className="flex items-start text-gray-600">
                    <DocumentTextIcon className="w-3 h-3 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                    Researching author affiliations and movements
                  </li>
                  <li className="flex items-start text-gray-600">
                    <DocumentTextIcon className="w-3 h-3 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                    Analyzing Bible translation usage patterns
                  </li>
                  <li className="flex items-start text-gray-600">
                    <DocumentTextIcon className="w-3 h-3 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                    Documenting early Adventist worship preferences
                  </li>
                </ul>
              </div>

              {/* Project Timeline */}
              <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Project Timeline</h3>
                <div className="space-y-4">
                  <div className="flex items-center p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <CheckCircleIcon className="w-5 h-5 text-blue-600 mr-3" />
                    <div>
                      <div className="font-medium text-blue-800">Research Phase</div>
                      <div className="text-sm text-blue-600">Current - Content analysis</div>
                    </div>
                  </div>
                  
                  <div className="flex items-center p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <ClockIcon className="w-5 h-5 text-blue-600 mr-3" />
                    <div>
                      <div className="font-medium text-blue-800">Curation Phase</div>
                      <div className="text-sm text-blue-600">Next - Hymn selection</div>
                    </div>
                  </div>
                  
                  <div className="flex items-center p-3 bg-gray-50 border border-gray-200 rounded-lg">
                    <DocumentTextIcon className="w-5 h-5 text-gray-400 mr-3" />
                    <div>
                      <div className="font-medium text-gray-700">Publication Phase</div>
                      <div className="text-sm text-gray-500">Future - Digital & print</div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Support Options */}
              <div className="bg-gradient-to-br from-purple-600 to-blue-600 rounded-lg p-6 text-white">
                <h3 className="text-lg font-semibold mb-4">Support This Project</h3>
                <p className="text-purple-100 text-sm mb-6">
                  Help preserve Adventist worship heritage for future generations through scholarly research and careful curation.
                </p>
                <div className="space-y-3">
                  <Link 
                    href="/contact"
                    className="block w-full bg-white text-purple-600 text-center py-2 px-4 rounded-md font-medium hover:bg-purple-50 transition-colors"
                  >
                    Get Involved
                  </Link>
                  <Link 
                    href="/hymnal-projects"
                    className="block w-full border border-white text-white text-center py-2 px-4 rounded-md font-medium hover:bg-white/10 transition-colors"
                  >
                    View All Projects
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Resources Section */}
        <div className="bg-gray-100 py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">Research Resources</h2>
            
            <div className="grid md:grid-cols-3 gap-8">
              <div className="bg-white rounded-lg p-6 shadow-md text-center">
                <AcademicCapIcon className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                <h3 className="text-lg font-semibold mb-3">Historical Documentation</h3>
                <p className="text-gray-600 text-sm">
                  Extensive research into early Adventist worship practices, hymnal development, 
                  and theological foundations.
                </p>
              </div>
              
              <div className="bg-white rounded-lg p-6 shadow-md text-center">
                <DocumentTextIcon className="w-12 h-12 text-green-600 mx-auto mb-4" />
                <h3 className="text-lg font-semibold mb-3">Scholarly Analysis</h3>
                <p className="text-gray-600 text-sm">
                  Careful examination of hymn authorship, theological backgrounds, 
                  and alignment with biblical principles.
                </p>
              </div>
              
              <div className="bg-white rounded-lg p-6 shadow-md text-center">
                <HeartIcon className="w-12 h-12 text-red-600 mx-auto mb-4" />
                <h3 className="text-lg font-semibold mb-3">Community Input</h3>
                <p className="text-gray-600 text-sm">
                  Consultation with historians, theologians, and worship leaders 
                  throughout the research process.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}