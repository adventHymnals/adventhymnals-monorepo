import type { Metadata } from 'next';
import Link from 'next/link';
import { 
  BookOpenIcon, 
  AcademicCapIcon, 
  ClockIcon,
  DocumentTextIcon,
  HeartIcon,
  StarIcon,
  CheckCircleIcon,
  PlayCircleIcon
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';

export const metadata: Metadata = {
  title: 'Hymnal Projects - Advent Hymnals',
  description: 'Preserving and creating hymnals that reflect historic Adventist theology and worship traditions. Current projects include the Historic Seventh-Day Adventist Hymnal.',
  keywords: 'Adventist hymnal projects, historic Adventist hymns, Seventh-day Adventist worship, Protestant hymnal, Adventist heritage',
};

// For static generation
export function generateStaticParams() {
  return [];
}

// Project data structure
const projects = [
  {
    id: 'historic-sda-hymnal',
    title: 'Historic Seventh-Day Adventist Hymnal',
    status: 'active',
    phase: 'Research Phase',
    description: 'A carefully curated collection that preserves the theological distinctives and worship traditions of early Adventism.',
    longDescription: 'The Historic Seventh-Day Adventist Hymnal is a scholarly project aimed at creating a hymnal that reflects the Protestant heritage and biblical foundations that shaped the Seventh-day Adventist movement. This project addresses concerns raised by some scholars and church members about maintaining denominational distinctiveness in worship.',
    goals: [
      'Consistency with biblical Protestant principles',
      'Harmony with fundamental Adventist principles', 
      'Preservation of historic worship traditions',
      'Reflection of biblical worship patterns'
    ],
    currentWork: [
      'Analyzing existing hymnal content and sources',
      'Research into hymn authorship and theological backgrounds',
      'Consultation with Adventist historians and theologians',
      'Documentation of selection criteria and methodology'
    ],
    timeline: {
      phase1: { name: 'Research Phase', status: 'current', description: 'Analyzing content and historical sources' },
      phase2: { name: 'Curation Phase', status: 'upcoming', description: 'Selecting and organizing hymns' },
      phase3: { name: 'Publication Phase', status: 'future', description: 'Digital and print publication' }
    }
  },
  // Future projects can be added here
  {
    id: 'youth-hymnal',
    title: 'Traditional Adventist Youth Hymnal',
    status: 'planned',
    phase: 'Planning Phase',
    description: 'A collection designed specifically for youth and young adult worship, focusing on traditional hymns with accessible arrangements.',
    longDescription: 'This future project will focus on creating worship resources that help younger generations appreciate traditional hymnody while maintaining theological integrity and Adventist distinctives.',
    goals: [
      'Preserve traditional hymn singing for younger generations',
      'Engage younger generations in hymn singing',
      'Maintain theological and historical accuracy',
      'Provide quality musical arrangements of traditional hymns'
    ],
    currentWork: [],
    timeline: {
      phase1: { name: 'Planning Phase', status: 'planned', description: 'Research and community input' },
      phase2: { name: 'Development Phase', status: 'future', description: 'Content creation and curation' },
      phase3: { name: 'Publication Phase', status: 'future', description: 'Release and distribution' }
    }
  }
];

const statusColors = {
  active: 'bg-green-100 text-green-800 border-green-200',
  planned: 'bg-blue-100 text-blue-800 border-blue-200',
  completed: 'bg-purple-100 text-purple-800 border-purple-200'
};

const phaseIcons = {
  current: CheckCircleIcon,
  upcoming: ClockIcon,
  future: PlayCircleIcon,
  planned: DocumentTextIcon
};

export default function HymnalProjectsPage() {
  const activeProjects = projects.filter(p => p.status === 'active');
  const plannedProjects = projects.filter(p => p.status === 'planned');

  return (
    <Layout>
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

        {/* Active Projects Section */}
        {activeProjects.length > 0 && (
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
            <div className="flex items-center mb-12">
              <StarIcon className="w-8 h-8 text-amber-500 mr-3" />
              <h2 className="text-3xl font-bold text-gray-900">Current Projects</h2>
            </div>
            
            {activeProjects.map((project, index) => (
              <div key={project.id} className={`bg-white rounded-lg shadow-lg overflow-hidden ${index > 0 ? 'mt-8' : ''}`}>
                <div className="bg-gradient-to-r from-amber-500 to-orange-500 px-8 py-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <StarIcon className="w-8 h-8 text-white mr-3" />
                      <div>
                        <h3 className="text-2xl font-bold text-white">{project.title}</h3>
                        <span className={`inline-block px-3 py-1 rounded-full text-sm font-medium border ${statusColors[project.status]} bg-white/20 text-white border-white/30`}>
                          {project.phase}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <div className="p-8">
                  <div className="grid md:grid-cols-2 gap-8">
                    <div>
                      <h4 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
                        <AcademicCapIcon className="w-6 h-6 mr-2 text-blue-600" />
                        Project Overview
                      </h4>
                      <p className="text-gray-600 mb-4">{project.longDescription}</p>
                      
                      <h5 className="font-semibold text-gray-800 mb-3">Project Goals:</h5>
                      <ul className="space-y-2">
                        {project.goals.map((goal, i) => (
                          <li key={i} className="flex items-start text-gray-600">
                            <CheckCircleIcon className="w-4 h-4 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                            {goal}
                          </li>
                        ))}
                      </ul>
                    </div>
                    
                    <div>
                      <h4 className="text-xl font-semibold text-gray-800 mb-4 flex items-center">
                        <ClockIcon className="w-6 h-6 mr-2 text-green-600" />
                        Current Progress
                      </h4>
                      
                      {project.currentWork.length > 0 && (
                        <div className="mb-6">
                          <h5 className="font-semibold text-gray-800 mb-3">Current Work:</h5>
                          <ul className="space-y-2">
                            {project.currentWork.map((work, i) => (
                              <li key={i} className="flex items-start text-gray-600">
                                <DocumentTextIcon className="w-4 h-4 text-blue-500 mr-2 mt-0.5 flex-shrink-0" />
                                {work}
                              </li>
                            ))}
                          </ul>
                        </div>
                      )}
                      
                      <h5 className="font-semibold text-gray-800 mb-3">Project Timeline:</h5>
                      <div className="space-y-3">
                        {Object.entries(project.timeline).map(([key, phase]) => {
                          const IconComponent = phaseIcons[phase.status];
                          return (
                            <div key={key} className={`flex items-center p-3 rounded-lg ${
                              phase.status === 'current' ? 'bg-amber-50 border border-amber-200' : 
                              phase.status === 'upcoming' ? 'bg-blue-50 border border-blue-200' : 
                              'bg-gray-50 border border-gray-200'
                            }`}>
                              <IconComponent className={`w-5 h-5 mr-3 ${
                                phase.status === 'current' ? 'text-amber-600' :
                                phase.status === 'upcoming' ? 'text-blue-600' :
                                'text-gray-400'
                              }`} />
                              <div>
                                <div className="font-medium text-gray-900">{phase.name}</div>
                                <div className="text-sm text-gray-600">{phase.description}</div>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  </div>
                  
                  {/* Project Actions */}
                  <div className="mt-8 pt-6 border-t border-gray-200">
                    <Link
                      href={`/hymnal-projects/${project.id}`}
                      className="inline-flex items-center px-6 py-3 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 transition-colors"
                    >
                      <DocumentTextIcon className="h-5 w-5 mr-2" />
                      View Full Project Details
                    </Link>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Historical Context Section */}
        <div className="bg-gray-100 py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">Historical Context</h2>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div className="bg-white rounded-lg p-6 shadow-md">
                <DocumentTextIcon className="w-12 h-12 text-blue-600 mb-4" />
                <h3 className="text-xl font-semibold mb-3">The 1985 SDA Hymnal</h3>
                <p className="text-gray-600 mb-4">
                  The current Seventh-day Adventist Hymnal has been noted by scholars for its ecumenical approach. 
                  Research has identified concerns among some church members about maintaining denominational distinctiveness.
                </p>
                <ul className="text-gray-600 space-y-1 text-sm">
                  <li>• Hymns by authors associated with Catholic liturgical movements</li>
                  <li>• Use of various Bible translations in responsive readings</li>
                  <li>• Introduction of liturgical terminology not traditionally used in Adventist worship</li>
                </ul>
              </div>
              
              <div className="bg-white rounded-lg p-6 shadow-md">
                <HeartIcon className="w-12 h-12 text-red-600 mb-4" />
                <h3 className="text-xl font-semibold mb-3">Our Response</h3>
                <p className="text-gray-600 mb-4">
                  Our projects aim to address these concerns through careful scholarship and historical research, 
                  creating resources that honor both our Adventist heritage and biblical truth.
                </p>
                <ul className="text-gray-600 space-y-1 text-sm">
                  <li>• Thorough theological and historical research</li>
                  <li>• Alignment with fundamental Adventist principles</li>
                  <li>• Preservation of Protestant Reformation principles</li>
                  <li>• Respect for biblical worship patterns</li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        {/* Planned Projects Section */}
        {plannedProjects.length > 0 && (
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
            <h2 className="text-3xl font-bold text-gray-900 mb-12">Future Projects</h2>
            
            <div className="grid md:grid-cols-2 gap-8">
              {plannedProjects.map((project) => (
                <div key={project.id} className="bg-white rounded-lg shadow-md p-6 border-l-4 border-blue-500">
                  <div className="flex items-center mb-4">
                    <BookOpenIcon className="w-8 h-8 text-blue-600 mr-3" />
                    <div>
                      <h3 className="text-xl font-semibold text-gray-900">{project.title}</h3>
                      <span className={`inline-block px-2 py-1 rounded text-xs font-medium border ${statusColors[project.status]}`}>
                        {project.phase}
                      </span>
                    </div>
                  </div>
                  
                  <p className="text-gray-600 mb-4">{project.longDescription}</p>
                  
                  <h5 className="font-semibold text-gray-800 mb-2">Planned Goals:</h5>
                  <ul className="space-y-1">
                    {project.goals.slice(0, 3).map((goal, i) => (
                      <li key={i} className="flex items-start text-gray-600 text-sm">
                        <ClockIcon className="w-3 h-3 text-blue-500 mr-2 mt-1 flex-shrink-0" />
                        {goal}
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Call to Action */}
        <div className="bg-gradient-to-r from-purple-900 to-blue-900 text-white py-16">
          <div className="max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
            <h2 className="text-3xl font-bold mb-6">Supporting These Projects</h2>
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
    </Layout>
  );
}