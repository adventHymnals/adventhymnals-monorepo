import type { Metadata } from 'next';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  AcademicCapIcon, 
  ClockIcon,
  DocumentTextIcon,
  HeartIcon,
  StarIcon
} from '@heroicons/react/24/outline';

export const metadata: Metadata = {
  title: 'Hymnal Projects - Advent Hymnals',
  description: 'Preserving and creating hymnals that reflect historic Adventist theology and worship traditions. Our current project: Historic Seventh-Day Adventist Hymnal.',
  keywords: 'Adventist hymnal projects, historic Adventist hymns, Seventh-day Adventist worship, Protestant hymnal, Adventist heritage',
};

export default function HymnalProjectsPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-blue-900 to-purple-900 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center">
            <BookOpenIcon className="w-16 h-16 mx-auto mb-6 text-blue-200" />
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Hymnal Projects
            </h1>
            <p className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto">
              Preserving and creating hymnals that reflect historic Adventist theology and worship traditions
            </p>
          </div>
        </div>
      </div>

      {/* Current Project Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="bg-white rounded-lg shadow-lg overflow-hidden">
          <div className="bg-gradient-to-r from-amber-500 to-orange-500 px-8 py-6">
            <div className="flex items-center">
              <StarIcon className="w-8 h-8 text-white mr-3" />
              <h2 className="text-2xl font-bold text-white">Current Project</h2>
            </div>
          </div>
          
          <div className="p-8">
            <h3 className="text-3xl font-bold text-gray-900 mb-6">
              Historic Seventh-Day Adventist Hymnal
            </h3>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h4 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
                  <AcademicCapIcon className="w-6 h-6 mr-2 text-blue-600" />
                  Project Overview
                </h4>
                <p className="text-gray-600 mb-4">
                  The Historic Seventh-Day Adventist Hymnal is a carefully curated collection that preserves the 
                  theological distinctives and worship traditions of early Adventism. This project aims to create 
                  a hymnal that reflects the Protestant heritage and biblical foundations that shaped the 
                  Seventh-day Adventist movement.
                </p>
                <p className="text-gray-600 mb-4">
                  We are committed to scholarly research and historical accuracy, ensuring that each hymn 
                  included aligns with the theological framework established by Adventist pioneers and 
                  biblical interpretation.
                </p>
              </div>
              
              <div>
                <h4 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
                  <DocumentTextIcon className="w-6 h-6 mr-2 text-green-600" />
                  Historical Context
                </h4>
                <p className="text-gray-600 mb-4">
                  The 1985 Seventh-day Adventist Hymnal, while serving the global church, has been noted 
                  by some scholars and church members for its ecumenical approach. Our project addresses 
                  concerns raised about maintaining denominational distinctiveness in worship.
                </p>
                <p className="text-gray-600 mb-4">
                  Research has identified that the current hymnal includes:
                </p>
                <ul className="text-gray-600 ml-6 mb-4 space-y-1">
                  <li>• Hymns by authors associated with movements toward Catholic liturgical practices</li>
                  <li>• Bible translations with varying theological perspectives in responsive readings</li>
                  <li>• Liturgical terminology not traditionally used in Adventist worship</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Our Approach Section */}
      <div className="bg-gray-100 py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">Our Approach</h2>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white rounded-lg p-6 shadow-md">
              <AcademicCapIcon className="w-12 h-12 text-blue-600 mb-4" />
              <h3 className="text-xl font-semibold mb-3">Scholarly Research</h3>
              <p className="text-gray-600">
                Thorough historical and theological research into hymn authorship, doctrinal content, 
                and alignment with Adventist biblical interpretation.
              </p>
            </div>
            
            <div className="bg-white rounded-lg p-6 shadow-md">
              <HeartIcon className="w-12 h-12 text-red-600 mb-4" />
              <h3 className="text-xl font-semibold mb-3">Spiritual Discernment</h3>
              <p className="text-gray-600">
                Careful consideration of each hymn's spiritual message and its harmony with 
                fundamental Adventist beliefs and biblical truth.
              </p>
            </div>
            
            <div className="bg-white rounded-lg p-6 shadow-md">
              <ClockIcon className="w-12 h-12 text-green-600 mb-4" />
              <h3 className="text-xl font-semibold mb-3">Historical Preservation</h3>
              <p className="text-gray-600">
                Preserving the rich heritage of Adventist hymnody while maintaining theological 
                consistency with historic Protestant and Adventist principles.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Criteria Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Selection Criteria</h2>
          
          <div className="grid md:grid-cols-2 gap-8">
            <div>
              <h3 className="text-xl font-semibold text-gray-800 mb-4">Theological Alignment</h3>
              <ul className="space-y-2 text-gray-600">
                <li>• Consistency with biblical Protestant principles</li>
                <li>• Harmony with fundamental Adventist beliefs</li>
                <li>• Absence of doctrinal elements contrary to Scripture</li>
                <li>• Clear gospel message and biblical truth</li>
              </ul>
            </div>
            
            <div>
              <h3 className="text-xl font-semibold text-gray-800 mb-4">Historical Context</h3>
              <ul className="space-y-2 text-gray-600">
                <li>• Author's theological background and affiliations</li>
                <li>• Historical usage in Adventist worship</li>
                <li>• Compatibility with Protestant Reformation principles</li>
                <li>• Reflection of biblical worship patterns</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Progress and Updates */}
      <div className="bg-blue-50 py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">Project Progress</h2>
          
          <div className="bg-white rounded-lg shadow-lg p-8">
            <div className="grid md:grid-cols-3 gap-8">
              <div className="text-center">
                <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <span className="text-2xl font-bold text-blue-600">1</span>
                </div>
                <h3 className="font-semibold mb-2">Research Phase</h3>
                <p className="text-gray-600 text-sm">Currently analyzing existing hymnal content and historical sources</p>
              </div>
              
              <div className="text-center opacity-50">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <span className="text-2xl font-bold text-gray-400">2</span>
                </div>
                <h3 className="font-semibold mb-2">Curation Phase</h3>
                <p className="text-gray-600 text-sm">Selecting and organizing hymns according to established criteria</p>
              </div>
              
              <div className="text-center opacity-50">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <span className="text-2xl font-bold text-gray-400">3</span>
                </div>
                <h3 className="font-semibold mb-2">Publication Phase</h3>
                <p className="text-gray-600 text-sm">Digital and print publication for church and individual use</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Call to Action */}
      <div className="bg-gradient-to-r from-purple-900 to-blue-900 text-white py-16">
        <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold mb-6">Supporting This Project</h2>
          <p className="text-xl text-blue-100 mb-8">
            Help us preserve and promote worship resources that honor biblical truth and 
            Adventist heritage for current and future generations.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link 
              href="/contact" 
              className="bg-white text-purple-900 px-8 py-3 rounded-lg font-semibold hover:bg-blue-50 transition duration-200"
            >
              Get Involved
            </Link>
            <Link 
              href="/hymnals" 
              className="border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-purple-900 transition duration-200"
            >
              Browse Current Collections
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}