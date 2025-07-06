import { Metadata } from 'next';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data';
import { HeartIcon, UserGroupIcon, BookOpenIcon, CodeBracketIcon } from '@heroicons/react/24/outline';

export const metadata: Metadata = {
  title: 'Attribution - Advent Hymnals',
  description: 'Acknowledgments and attributions for the Advent Hymnals project.',
};

const contributors = [
  {
    category: 'Project Leadership',
    people: [
      { name: 'Gospel Sounders Team', role: 'Project coordination and oversight' },
      { name: 'Community Volunteers', role: 'Content digitization and verification' }
    ]
  },
  {
    category: 'Technical Development', 
    people: [
      { name: 'Development Team', role: 'Website development and maintenance' },
      { name: 'Claude (Anthropic)', role: 'AI-assisted development and optimization' }
    ]
  },
  {
    category: 'Content Sources',
    people: [
      { name: 'Seventh-day Adventist Church', role: 'Original hymnal publications' },
      { name: 'Historical Archives', role: 'Digitized source materials' },
      { name: 'Community Contributors', role: 'Corrections and improvements' }
    ]
  }
];

const technologies = [
  { name: 'Next.js', description: 'React framework for web development' },
  { name: 'TypeScript', description: 'Type-safe JavaScript development' },
  { name: 'Tailwind CSS', description: 'Utility-first CSS framework' },
  { name: 'Heroicons', description: 'Beautiful hand-crafted SVG icons' },
  { name: 'Vercel', description: 'Deployment and hosting platform' },
];

export default async function AttributionPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-white">
        <div className="mx-auto max-w-4xl px-6 py-16 lg:px-8">
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
              Attribution & Acknowledgments
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Recognizing the contributions that make Advent Hymnals possible
            </p>
          </div>

          <div className="space-y-12">
            {/* Project Mission */}
            <div className="bg-primary-50 border border-primary-200 rounded-xl p-8">
              <div className="flex items-center mb-4">
                <HeartIcon className="h-6 w-6 text-primary-600 mr-3" />
                <h2 className="text-2xl font-bold text-primary-900">Our Mission</h2>
              </div>
              <p className="text-primary-800 leading-relaxed">
                Advent Hymnals is an independent educational project dedicated to preserving 
                and providing digital access to the rich musical heritage of Adventist hymnody. 
                Our goal is to make these historical collections accessible for worship, 
                research, and educational purposes worldwide.
              </p>
            </div>

            {/* Contributors */}
            <div>
              <div className="flex items-center mb-6">
                <UserGroupIcon className="h-6 w-6 text-primary-600 mr-3" />
                <h2 className="text-2xl font-bold text-gray-900">Contributors</h2>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {contributors.map((group) => (
                  <div key={group.category} className="bg-gray-50 rounded-lg p-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">{group.category}</h3>
                    <div className="space-y-3">
                      {group.people.map((person, index) => (
                        <div key={index}>
                          <h4 className="font-medium text-gray-900">{person.name}</h4>
                          <p className="text-sm text-gray-600">{person.role}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Original Publishers */}
            <div>
              <div className="flex items-center mb-6">
                <BookOpenIcon className="h-6 w-6 text-primary-600 mr-3" />
                <h2 className="text-2xl font-bold text-gray-900">Original Publishers & Sources</h2>
              </div>
              
              <div className="prose prose-lg max-w-none">
                <p className="text-gray-600 mb-6">
                  We gratefully acknowledge the original publishers and compilers of the 
                  hymnal collections preserved in this archive:
                </p>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="border-l-4 border-blue-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Seventh-day Adventist Church</h3>
                    <p className="text-sm text-gray-600">
                      Official church publications including the Seventh-day Adventist Hymnal 
                      and various historical collections.
                    </p>
                  </div>
                  <div className="border-l-4 border-green-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Early Adventist Publishers</h3>
                    <p className="text-sm text-gray-600">
                      Historic publishers of early Adventist hymnals including James White, 
                      Uriah Smith, and other pioneers.
                    </p>
                  </div>
                  <div className="border-l-4 border-purple-500 pl-4">
                    <h3 className="font-semibold text-gray-900">International Contributors</h3>
                    <p className="text-sm text-gray-600">
                      Publishers and translators of hymnal collections in Kiswahili, 
                      Dholuo, and other languages.
                    </p>
                  </div>
                  <div className="border-l-4 border-amber-500 pl-4">
                    <h3 className="font-semibold text-gray-900">Academic Institutions</h3>
                    <p className="text-sm text-gray-600">
                      Libraries and archives that have preserved historical materials 
                      for digitization and research.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Technology Credits */}
            <div>
              <div className="flex items-center mb-6">
                <CodeBracketIcon className="h-6 w-6 text-primary-600 mr-3" />
                <h2 className="text-2xl font-bold text-gray-900">Technology & Tools</h2>
              </div>
              
              <div className="bg-gray-50 rounded-lg p-6">
                <p className="text-gray-600 mb-6">
                  This project is built with modern web technologies and open-source tools:
                </p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {technologies.map((tech) => (
                    <div key={tech.name} className="flex justify-between items-center py-2">
                      <span className="font-medium text-gray-900">{tech.name}</span>
                      <span className="text-sm text-gray-600">{tech.description}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Legal Notice */}
            <div className="bg-gray-50 border border-gray-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Legal Notice</h3>
              <div className="space-y-3 text-sm text-gray-600">
                <p>
                  This is an independent educational project not officially affiliated with 
                  the Seventh-day Adventist Church or any other organization.
                </p>
                <p>
                  All hymnal content is used for educational purposes under fair use provisions. 
                  Original copyrights remain with their respective holders.
                </p>
                <p>
                  We respect intellectual property rights and will promptly address any 
                  legitimate copyright concerns.
                </p>
              </div>
            </div>

            {/* How to Contribute */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-blue-900 mb-4">Join Our Community</h3>
              <p className="text-blue-800 mb-4">
                Interested in contributing to the preservation of Adventist musical heritage?
              </p>
              <div className="space-y-2">
                <a 
                  href="/contribute" 
                  className="block text-sm text-blue-600 hover:text-blue-700 font-medium"
                >
                  Learn about contributing →
                </a>
                <a 
                  href="/contact" 
                  className="block text-sm text-blue-600 hover:text-blue-700 font-medium"
                >
                  Contact our team →
                </a>
                <a 
                  href="https://github.com/adventhymnals" 
                  className="block text-sm text-blue-600 hover:text-blue-700 font-medium"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  View on GitHub →
                </a>
              </div>
            </div>

            {/* Thank You */}
            <div className="text-center bg-gradient-to-r from-primary-600 to-primary-700 rounded-xl p-8 text-white">
              <h3 className="text-xl font-bold mb-4">Thank You</h3>
              <p className="text-primary-100 leading-relaxed">
                This project exists because of the generous contributions of time, expertise, 
                and resources from individuals and organizations who share our passion for 
                preserving Adventist musical heritage. We are deeply grateful for your support.
              </p>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}