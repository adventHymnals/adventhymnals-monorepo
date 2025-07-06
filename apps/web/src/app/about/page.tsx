import { Metadata } from 'next';
import Link from 'next/link';
import { 
  HeartIcon, 
  ClockIcon, 
  GlobeAltIcon, 
  BookOpenIcon,
  UserIcon,
  BanknotesIcon,
  CodeBracketIcon,
  MusicalNoteIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'About - Advent Hymnals',
  description: 'Learn about the Advent Hymnals project - digitizing and preserving 160+ years of Adventist musical heritage for current and future generations.',
  keywords: ['Advent Hymnals', 'Gospel Sounders', 'Brian Onang\'o', 'Adventist hymnals', 'digital preservation', 'heritage'],
};

const timelineEvents = [
  {
    year: '2018',
    title: 'Project Launch',
    description: 'The Advent Hymnals project began with the vision to digitize and preserve historical Adventist hymnals.',
    icon: BookOpenIcon,
    color: 'bg-blue-500'
  },
  {
    year: '2019-2021',
    title: 'Early Development',
    description: 'Versions 1-3 released with growing hymn collection and basic search functionality.',
    icon: CodeBracketIcon,
    color: 'bg-green-500'
  },
  {
    year: '2022',
    title: 'Version 4 Release',
    description: 'Added improved search capabilities and enhanced user interface.',
    icon: MusicalNoteIcon,
    color: 'bg-purple-500'
  },
  {
    year: 'Dec 2023',
    title: 'Temporary Hiatus',
    description: 'Site went offline due to server costs, highlighting the need for sustainable funding.',
    icon: ClockIcon,
    color: 'bg-orange-500'
  },
  {
    year: '2025',
    title: 'Version 5 & Revival',
    description: 'Partnership with Gospel Sounders enables project revival with focus on sustainability and accessibility.',
    icon: HeartIcon,
    color: 'bg-red-500'
  }
];

const objectives = [
  {
    title: 'Preservation',
    description: 'Digitally preserve 160+ years of Adventist musical heritage',
    icon: BookOpenIcon,
    stats: '13 Collections'
  },
  {
    title: 'Accessibility',
    description: 'Make hymnals accessible through web, mobile, and print platforms',
    icon: GlobeAltIcon,
    stats: '5,500+ Hymns'
  },
  {
    title: 'Education',
    description: 'Provide historical context about Adventist music evolution',
    icon: MusicalNoteIcon,
    stats: '3 Languages'
  },
  {
    title: 'Sustainability',
    description: 'Build a sustainable platform for long-term preservation',
    icon: HeartIcon,
    stats: 'Open Source'
  }
];

const team = [
  {
    name: 'Brian Onang\'o',
    role: 'Lead Developer & Main Contributor',
    description: 'Passionate about preserving Adventist musical heritage through technology.',
    contact: 'surgbc@gmail.com',
    phone: '+254 706 662 011',
    contributions: [
      'Project vision and leadership',
      'Full-stack development',
      'Data digitization and processing',
      'Community building'
    ]
  }
];

export default async function AboutPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                About Advent Hymnals
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Preserving 160+ years of Adventist musical heritage through digital technology, 
                making it accessible for worship, education, and research worldwide.
              </p>
            </div>
          </div>
        </div>

        {/* Mission Statement */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="bg-primary-50 border border-primary-200 rounded-xl p-8 mb-12">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-primary-900 mb-6">Our Mission</h2>
              <p className="text-lg text-primary-800 mb-6">
                &quot;Digitizing and archiving historical Adventist hymnals while making them accessible 
                across multiple platforms and preserving their historical significance.&quot;
              </p>
              <p className="text-primary-700">
                We believe that the rich musical heritage of the Seventh-day Adventist Church should be 
                preserved and made accessible to current and future generations, supporting worship leaders, 
                educators, researchers, and music enthusiasts worldwide.
              </p>
            </div>
          </div>

          {/* Objectives */}
          <div className="mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Project Objectives</h2>
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-2 xl:grid-cols-4">
              {objectives.map((objective) => (
                <div key={objective.title} className="bg-white rounded-xl shadow-sm p-6 text-center">
                  <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-lg bg-primary-100 mb-4">
                    <objective.icon className="h-6 w-6 text-primary-600" />
                  </div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">{objective.title}</h3>
                  <p className="text-sm text-gray-600 mb-3">{objective.description}</p>
                  <div className="text-2xl font-bold text-primary-600">{objective.stats}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Timeline */}
          <div className="mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Our Journey</h2>
            <div className="relative">
              {/* Timeline line */}
              <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-gray-300 lg:left-1/2 lg:transform lg:-translate-x-0.5"></div>
              
              <div className="space-y-8 lg:space-y-12">
                {timelineEvents.map((event, index) => (
                  <div
                    key={event.year}
                    className={`relative flex items-center ${
                      index % 2 === 0 ? 'lg:flex-row' : 'lg:flex-row-reverse'
                    }`}
                  >
                    {/* Timeline dot */}
                    <div className="absolute left-8 w-4 h-4 bg-white border-4 border-primary-500 rounded-full lg:left-1/2 lg:transform lg:-translate-x-2"></div>
                    
                    {/* Content */}
                    <div className={`ml-20 lg:ml-0 lg:w-1/2 ${index % 2 === 0 ? 'lg:pr-8' : 'lg:pl-8'}`}>
                      <div className="bg-white rounded-xl shadow-sm p-6">
                        <div className="flex items-center mb-4">
                          <div className={`${event.color} p-2 rounded-lg mr-3`}>
                            <event.icon className="h-5 w-5 text-white" />
                          </div>
                          <div>
                            <div className="text-2xl font-bold text-gray-900">{event.year}</div>
                            <h3 className="text-lg font-semibold text-gray-900">{event.title}</h3>
                          </div>
                        </div>
                        <p className="text-gray-600">{event.description}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Sponsorship */}
          <div className="bg-white rounded-xl shadow-sm p-8 mb-12">
            <div className="text-center mb-8">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">Partnership & Sponsorship</h2>
              <p className="text-lg text-gray-600">
                Made possible through the generous support of our main sponsor
              </p>
            </div>
            
            <div className="bg-gradient-to-r from-primary-50 to-primary-100 rounded-lg p-8">
              <div className="flex items-center justify-center mb-6">
                <div className="bg-white rounded-lg p-4 shadow-sm">
                  <MusicalNoteIcon className="h-12 w-12 text-primary-600" />
                </div>
              </div>
              <div className="text-center">
                <h3 className="text-2xl font-bold text-primary-900 mb-2">Gospel Sounders</h3>
                <p className="text-primary-800 mb-4">Primary Project Sponsor</p>
                <p className="text-primary-700 mb-6">
                  Gospel Sounders (gospelsounders.org) has partnered with us to ensure the sustainability 
                  and continued development of the Advent Hymnals project, enabling us to preserve 
                  Adventist musical heritage for future generations.
                </p>
                <Link
                  href="/contribute"
                  className="inline-flex items-center px-6 py-3 border border-primary-300 text-base font-medium rounded-md text-primary-700 bg-white hover:bg-primary-50 transition-colors"
                >
                  <BanknotesIcon className="h-5 w-5 mr-2" />
                  Support Our Mission
                </Link>
              </div>
            </div>
          </div>

          {/* Team */}
          <div className="mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-8 text-center">Project Team</h2>
            <div className="grid grid-cols-1 gap-8">
              {team.map((member) => (
                <div key={member.name} className="bg-white rounded-xl shadow-sm p-8">
                  <div className="lg:flex lg:items-start lg:space-x-8">
                    <div className="flex-shrink-0 mb-6 lg:mb-0">
                      <div className="w-24 h-24 bg-primary-100 rounded-full flex items-center justify-center">
                        <UserIcon className="h-12 w-12 text-primary-600" />
                      </div>
                    </div>
                    <div className="flex-grow">
                      <div className="lg:flex lg:items-start lg:justify-between">
                        <div className="lg:flex-grow">
                          <h3 className="text-xl font-bold text-gray-900">{member.name}</h3>
                          <p className="text-primary-600 font-medium mb-3">{member.role}</p>
                          <p className="text-gray-600 mb-4">{member.description}</p>
                          
                          <div className="mb-4">
                            <h4 className="text-sm font-semibold text-gray-900 mb-2">Key Contributions:</h4>
                            <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                              {member.contributions.map((contribution, index) => (
                                <div key={index} className="flex items-center">
                                  <CheckCircleIcon className="h-4 w-4 text-green-500 mr-2 flex-shrink-0" />
                                  <span className="text-sm text-gray-700">{contribution}</span>
                                </div>
                              ))}
                            </div>
                          </div>
                        </div>
                        
                        <div className="lg:ml-8 lg:flex-shrink-0">
                          <div className="space-y-2">
                            <a
                              href={`mailto:${member.contact}`}
                              className="block text-sm text-primary-600 hover:text-primary-700"
                            >
                              {member.contact}
                            </a>
                            <a
                              href={`https://wa.me/${member.phone.replace(/\s+/g, '')}`}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="block text-sm text-green-600 hover:text-green-700"
                            >
                              {member.phone}
                            </a>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Version 5 Features */}
          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-xl p-8 mb-12">
            <h2 className="text-3xl font-bold text-blue-900 mb-6 text-center">Version 5: What&apos;s New</h2>
            <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
              <div>
                <h3 className="text-lg font-semibold text-blue-800 mb-4">Enhanced Features</h3>
                <ul className="space-y-2">
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Enhanced search functionality with advanced filters</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Multi-language support (English, Kiswahili, Dholuo)</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Mobile-responsive design and future mobile app</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Audio renditions and multimedia content</span>
                  </li>
                </ul>
              </div>
              <div>
                <h3 className="text-lg font-semibold text-blue-800 mb-4">Sustainability Focus</h3>
                <ul className="space-y-2">
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Partnership with Gospel Sounders for long-term support</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Open-source development model</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Community-driven content verification</span>
                  </li>
                  <li className="flex items-start">
                    <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2 mt-0.5 flex-shrink-0" />
                    <span className="text-blue-700">Academic research integration and support</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          {/* Call to Action */}
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Join Our Mission</h2>
            <p className="text-lg text-gray-600 mb-8">
              Help us preserve Adventist musical heritage for future generations. 
              There are many ways to get involved and make a difference.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                href="/contribute"
                className="inline-flex items-center px-8 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
              >
                <HeartIcon className="h-5 w-5 mr-2" />
                Get Involved
              </Link>
              <Link
                href="/contact"
                className="inline-flex items-center px-8 py-3 border border-primary-600 text-base font-medium rounded-md text-primary-600 bg-white hover:bg-primary-50 transition-colors"
              >
                Contact Us
              </Link>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}