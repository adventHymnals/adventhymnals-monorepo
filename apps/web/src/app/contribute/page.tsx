import { Metadata } from 'next';
import Link from 'next/link';
import { 
  HeartIcon, 
  CodeBracketIcon, 
  DocumentTextIcon, 
  MusicalNoteIcon,
  UserGroupIcon,
  CurrencyDollarIcon,
  BugAntIcon,
  AcademicCapIcon
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';

export const metadata: Metadata = {
  title: 'Contribute - Advent Hymnals',
  description: 'Help preserve Adventist hymnody for future generations. Contribute through development, research, donations, or community support.',
  keywords: ['contribute', 'volunteer', 'Adventist hymnals', 'open source', 'heritage preservation', 'community'],
};

const contributionTypes = [
  {
    title: 'Code & Development',
    icon: CodeBracketIcon,
    color: 'bg-blue-500',
    description: 'Help build and improve our platform with code contributions.',
    ways: [
      'Frontend development (React, Next.js, TypeScript)',
      'Backend API development',
      'Mobile app development',
      'Database optimization',
      'Performance improvements',
      'Security enhancements'
    ],
    cta: 'View GitHub Repository',
    href: 'https://github.com/adventhymnals'
  },
  {
    title: 'Research & Documentation',
    icon: AcademicCapIcon,
    color: 'bg-green-500',
    description: 'Help verify hymn data, research historical context, and improve metadata.',
    ways: [
      'Verify hymn lyrics and metadata',
      'Research historical background',
      'Add composer biographies',
      'Document hymnal publication details',
      'Cross-reference between collections',
      'Translate content to other languages'
    ],
    cta: 'Join Research Team',
    href: '/contact'
  },
  {
    title: 'Content & Media',
    icon: MusicalNoteIcon,
    color: 'bg-purple-500',
    description: 'Contribute audio recordings, sheet music, and multimedia content.',
    ways: [
      'Record hymn performances',
      'Provide sheet music scans',
      'Create educational videos',
      'Design graphics and artwork',
      'Write blog posts and articles',
      'Create study materials'
    ],
    cta: 'Share Content',
    href: '/contact'
  },
  {
    title: 'Quality Assurance',
    icon: BugAntIcon,
    color: 'bg-orange-500',
    description: 'Help us find and fix errors, test new features, and improve user experience.',
    ways: [
      'Report bugs and issues',
      'Test new features',
      'Suggest improvements',
      'Proofread content',
      'Verify data accuracy',
      'User experience feedback'
    ],
    cta: 'Report Issues',
    href: 'https://github.com/adventhymnals/issues'
  },
  {
    title: 'Community Building',
    icon: UserGroupIcon,
    color: 'bg-teal-500',
    description: 'Help grow our community and spread awareness of the project.',
    ways: [
      'Share on social media',
      'Present at conferences',
      'Write reviews and testimonials',
      'Organize community events',
      'Create educational workshops',
      'Build partnerships'
    ],
    cta: 'Join Community',
    href: '/contact'
  },
  {
    title: 'Financial Support',
    icon: CurrencyDollarIcon,
    color: 'bg-red-500',
    description: 'Support our mission through financial contributions for hosting, development, and preservation.',
    ways: [
      'One-time donations',
      'Monthly recurring support',
      'Sponsor specific features',
      'Support digitization costs',
      'Fund research projects',
      'Cover infrastructure costs'
    ],
    cta: 'Make a Donation',
    href: '/contact'
  }
];

export default async function ContributePage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
                Contribute to Advent Hymnals
              </h1>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Help preserve 160+ years of Adventist hymnody for current and future generations. 
                There are many ways to contribute to this important heritage preservation project.
              </p>
              <div className="mt-8 flex items-center justify-center">
                <HeartIcon className="h-8 w-8 text-red-500 mr-3" />
                <span className="text-lg font-medium text-gray-900">
                  Every contribution makes a difference
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Contribution Types */}
        <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
            {contributionTypes.map((type) => (
              <div
                key={type.title}
                className="bg-white rounded-xl shadow-sm p-8 hover:shadow-lg transition-all duration-300"
              >
                <div className="flex items-center mb-6">
                  <div className={`${type.color} p-3 rounded-lg mr-4`}>
                    <type.icon className="h-6 w-6 text-white" />
                  </div>
                  <h2 className="text-xl font-bold text-gray-900">{type.title}</h2>
                </div>
                
                <p className="text-gray-600 mb-6">{type.description}</p>
                
                <div className="mb-6">
                  <h3 className="text-sm font-semibold text-gray-900 mb-3">How you can help:</h3>
                  <ul className="space-y-2">
                    {type.ways.map((way, index) => (
                      <li key={index} className="flex items-start">
                        <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                        <span className="text-sm text-gray-700">{way}</span>
                      </li>
                    ))}
                  </ul>
                </div>
                
                <Link
                  href={type.href}
                  target={type.href.startsWith('http') ? '_blank' : undefined}
                  rel={type.href.startsWith('http') ? 'noopener noreferrer' : undefined}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
                >
                  {type.cta}
                </Link>
              </div>
            ))}
          </div>
        </div>

        {/* Get Started Section */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                Ready to Get Started?
              </h2>
              <p className="text-lg text-gray-600">
                Choose how you&apos;d like to contribute and join our community of volunteers
              </p>
            </div>

            <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
              <div className="text-center">
                <div className="mx-auto h-16 w-16 flex items-center justify-center rounded-full bg-blue-100 mb-4">
                  <DocumentTextIcon className="h-8 w-8 text-blue-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">1. Choose Your Contribution</h3>
                <p className="text-gray-600">
                  Select the type of contribution that matches your skills and interests
                </p>
              </div>

              <div className="text-center">
                <div className="mx-auto h-16 w-16 flex items-center justify-center rounded-full bg-green-100 mb-4">
                  <UserGroupIcon className="h-8 w-8 text-green-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">2. Join Our Community</h3>
                <p className="text-gray-600">
                  Connect with other contributors and get access to our collaboration tools
                </p>
              </div>

              <div className="text-center">
                <div className="mx-auto h-16 w-16 flex items-center justify-center rounded-full bg-purple-100 mb-4">
                  <HeartIcon className="h-8 w-8 text-purple-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">3. Make an Impact</h3>
                <p className="text-gray-600">
                  Start contributing and help preserve Adventist musical heritage
                </p>
              </div>
            </div>

            <div className="text-center mt-12">
              <Link
                href="/contact"
                className="inline-flex items-center px-8 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
              >
                <UserGroupIcon className="h-5 w-5 mr-2" />
                Contact Us to Get Started
              </Link>
            </div>
          </div>
        </div>

        {/* Recognition Section */}
        <div className="bg-primary-50">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="text-center">
              <h2 className="text-3xl font-bold text-primary-900 mb-8">
                Our Contributors
              </h2>
              <p className="text-lg text-primary-800 mb-8">
                We&apos;re grateful to all the volunteers, researchers, developers, and supporters 
                who make this project possible.
              </p>
              <div className="bg-white rounded-lg p-8 shadow-sm">
                <p className="text-gray-600 italic">
                  &quot;This project represents the collaborative spirit of the Adventist community, 
                  bringing together people from around the world to preserve our musical heritage 
                  for future generations.&quot;
                </p>
                <p className="text-sm text-gray-500 mt-4">
                  - Advent Hymnals Project Team
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}