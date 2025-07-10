import { Metadata } from 'next';
import Link from 'next/link';
import { 
  MusicalNoteIcon,
  PlayIcon,
  MicrophoneIcon,
  UserGroupIcon,
  SparklesIcon,
  HeartIcon,
  CalendarIcon,
  GlobeAltIcon
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Choir Project - Advent Hymnals',
  description: 'Join our mission to bring all Adventist hymns to life through collaborative choir recordings. Partner with us to preserve centuries of sacred music.',
  keywords: ['choir project', 'Adventist hymns', 'choral music', 'YouTube channel', 'sacred music', 'hymn recordings'],
};

export default async function ChoirProjectPage() {
  const hymnalReferences = await loadHymnalReferences();

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center text-white">
              <div className="flex justify-center mb-6">
                <div className="bg-white/10 p-4 rounded-full">
                  <MusicalNoteIcon className="h-12 w-12 text-primary-100" />
                </div>
              </div>
              <h1 className="text-4xl font-bold tracking-tight sm:text-5xl mb-6">
                Advent Hymnals Choir Project
              </h1>
              <p className="text-xl leading-8 text-primary-100 max-w-3xl mx-auto mb-8">
                Bringing centuries of sacred music to life through collaborative choir recordings and cutting-edge AI technology
              </p>
              <div className="flex flex-col sm:flex-row justify-center gap-4">
                <a
                  href="https://www.youtube.com/@adventhymnals"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-primary-700 bg-white hover:bg-gray-50 transition-colors"
                >
                  <PlayIcon className="h-5 w-5 mr-2" />
                  Visit Our YouTube Channel
                </a>
                <Link
                  href="#register"
                  className="inline-flex items-center px-6 py-3 border border-white text-base font-medium rounded-md text-white hover:bg-white/10 transition-colors"
                >
                  <UserGroupIcon className="h-5 w-5 mr-2" />
                  Join as a Choir
                </Link>
              </div>
            </div>
          </div>
        </div>

        {/* Mission Statement */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Our Mission</h2>
              <p className="text-xl text-gray-600 max-w-4xl mx-auto leading-relaxed">
                We believe that the beautiful hymns in our collections deserve to be heard, not just read. 
                These timeless compositions have sustained faith for centuries—unlike contemporary songs that 
                come and go, hymns endure through generations. Our goal is to create high-quality audio and 
                video recordings of every hymn in our database, preserving this sacred musical heritage for 
                current and future generations.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              <div className="text-center p-6 bg-blue-50 rounded-xl">
                <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-full bg-blue-100 mb-4">
                  <HeartIcon className="h-6 w-6 text-blue-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Timeless Heritage</h3>
                <p className="text-gray-600">
                  Preserving hymns that have strengthened faith for over 160 years, ensuring they continue 
                  to inspire future generations.
                </p>
              </div>

              <div className="text-center p-6 bg-green-50 rounded-xl">
                <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-full bg-green-100 mb-4">
                  <UserGroupIcon className="h-6 w-6 text-green-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Collaborative Spirit</h3>
                <p className="text-gray-600">
                  Partnering with choirs worldwide to create authentic, heartfelt recordings that capture 
                  the spirit of congregational worship.
                </p>
              </div>

              <div className="text-center p-6 bg-purple-50 rounded-xl">
                <div className="mx-auto h-12 w-12 flex items-center justify-center rounded-full bg-purple-100 mb-4">
                  <SparklesIcon className="h-6 w-6 text-purple-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">Innovation Meets Tradition</h3>
                <p className="text-gray-600">
                  Combining AI technology with human artistry to ensure every hymn is beautifully represented, 
                  regardless of complexity.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Current Approach */}
        <div className="bg-gray-50">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Our Multi-Faceted Approach</h2>
              <p className="text-lg text-gray-600 max-w-3xl mx-auto">
                We&apos;re using both traditional choir collaborations and cutting-edge AI technology to 
                ensure comprehensive coverage of our hymnal collections.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              <div className="bg-white rounded-xl p-8 shadow-sm">
                <div className="flex items-center mb-6">
                  <div className="bg-blue-100 p-3 rounded-lg mr-4">
                    <UserGroupIcon className="h-8 w-8 text-blue-600" />
                  </div>
                  <h3 className="text-2xl font-bold text-gray-900">Choir Collaborations</h3>
                </div>
                
                <div className="space-y-4">
                  <div className="flex items-start">
                    <MicrophoneIcon className="h-5 w-5 text-blue-600 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Professional Recordings</h4>
                      <p className="text-gray-600">Partner with choirs to create authentic, high-quality recordings</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <HeartIcon className="h-5 w-5 text-blue-600 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Human Touch</h4>
                      <p className="text-gray-600">Capture the emotion and spiritual depth that only human voices can provide</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <GlobeAltIcon className="h-5 w-5 text-blue-600 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Global Reach</h4>
                      <p className="text-gray-600">Connect with choirs worldwide to represent diverse musical traditions</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-xl p-8 shadow-sm">
                <div className="flex items-center mb-6">
                  <div className="bg-purple-100 p-3 rounded-lg mr-4">
                    <SparklesIcon className="h-8 w-8 text-purple-600" />
                  </div>
                  <h3 className="text-2xl font-bold text-gray-900">AI-Assisted Production</h3>
                </div>
                
                <div className="space-y-4">
                  <div className="flex items-start">
                    <MusicalNoteIcon className="h-5 w-5 text-purple-600 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Advanced Text-to-Speech</h4>
                      <p className="text-gray-600">Exploring cutting-edge TTS technology that can actually sing in tune</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <PlayIcon className="h-5 w-5 text-purple-600 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Video Generation</h4>
                      <p className="text-gray-600">Creating visual content with state-of-the-art tools like Veo3</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <CalendarIcon className="h-5 w-5 text-purple-600 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold text-gray-900">Scalable Production</h4>
                      <p className="text-gray-600">Efficiently produce recordings for hymns that are difficult for human choirs</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* YouTube Channel Section */}
        <div className="bg-white">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Our YouTube Channel</h2>
              <p className="text-lg text-gray-600 max-w-3xl mx-auto mb-8">
                Subscribe to our channel to hear the latest recordings and follow our progress as we bring 
                these beautiful hymns to life.
              </p>
              
              <div className="bg-red-50 border border-red-200 rounded-lg p-6 max-w-2xl mx-auto">
                <div className="flex items-center justify-center mb-4">
                  <PlayIcon className="h-8 w-8 text-red-600 mr-3" />
                  <h3 className="text-xl font-semibold text-red-900">@adventhymnals</h3>
                </div>
                <p className="text-red-800 mb-4">
                  Experience the beauty of traditional Adventist hymnody through our growing collection 
                  of choir recordings and AI-assisted performances.
                </p>
                <a
                  href="https://www.youtube.com/@adventhymnals"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-red-600 hover:bg-red-700 transition-colors"
                >
                  <PlayIcon className="h-5 w-5 mr-2" />
                  Subscribe to Our Channel
                </a>
              </div>
            </div>
          </div>
        </div>

        {/* Call to Action for Choirs */}
        <div className="bg-primary-50" id="register">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-primary-900 mb-6">
                Join Our Choir Network
              </h2>
              <p className="text-lg text-primary-800 max-w-3xl mx-auto">
                We&apos;re seeking talented choirs to partner with us in this meaningful project. 
                Whether you&apos;re a church choir, community group, or professional ensemble, 
                we&apos;d love to collaborate with you.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
              <div className="bg-white rounded-lg p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">What We Provide</h3>
                <ul className="space-y-2 text-gray-600">
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Sheet music and arrangements
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Technical recording guidance
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Post-production support
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Full attribution and credit
                  </li>
                </ul>
              </div>

              <div className="bg-white rounded-lg p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">What We Need</h3>
                <ul className="space-y-2 text-gray-600">
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Quality audio recordings
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Commitment to project timeline
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Willingness to collaborate
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Basic recording equipment
                  </li>
                </ul>
              </div>

              <div className="bg-white rounded-lg p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">The Impact</h3>
                <ul className="space-y-2 text-gray-600">
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Preserve sacred music heritage
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Reach global Adventist community
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Support worship and devotion
                  </li>
                  <li className="flex items-start">
                    <span className="h-1.5 w-1.5 bg-primary-600 rounded-full mt-2 mr-3 flex-shrink-0"></span>
                    Build lasting legacy
                  </li>
                </ul>
              </div>
            </div>

            <div className="text-center">
              <Link
                href="/choir-project/register"
                className="inline-flex items-center px-8 py-4 border border-transparent text-lg font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 transition-colors"
              >
                <UserGroupIcon className="h-6 w-6 mr-3" />
                Register Your Choir
              </Link>
              <p className="text-sm text-primary-700 mt-4">
                Ready to be part of something meaningful? Join us in preserving centuries of sacred music.
              </p>
            </div>
          </div>
        </div>

        {/* Technical Innovation Section */}
        <div className="bg-gray-900 text-white">
          <div className="mx-auto max-w-7xl px-6 py-16 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold mb-6">Technical Innovation</h2>
              <p className="text-lg text-gray-300 max-w-3xl mx-auto">
                We&apos;re at the forefront of AI-assisted music production, exploring the latest 
                technologies to ensure every hymn can be beautifully represented.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              <div>
                <h3 className="text-xl font-semibold mb-4">Current Research Areas</h3>
                <div className="space-y-4">
                  <div className="flex items-start">
                    <SparklesIcon className="h-5 w-5 text-blue-400 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold">Advanced TTS (Text-to-Speech)</h4>
                      <p className="text-gray-300 text-sm">Exploring Google&apos;s latest models and other cutting-edge systems that can sing with proper pitch and emotion</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <PlayIcon className="h-5 w-5 text-blue-400 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold">Video Generation</h4>
                      <p className="text-gray-300 text-sm">Investigating tools like Veo3 for creating compelling visual accompaniments to our audio recordings</p>
                    </div>
                  </div>
                  
                  <div className="flex items-start">
                    <MusicalNoteIcon className="h-5 w-5 text-blue-400 mt-1 mr-3 flex-shrink-0" />
                    <div>
                      <h4 className="font-semibold">SVS (Singing Voice Synthesis)</h4>
                      <p className="text-gray-300 text-sm">Monitoring advances in SVS technology for future implementation when quality improves</p>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-xl font-semibold mb-4">Past & Present</h3>
                <div className="space-y-4">
                  <div className="bg-gray-800 rounded-lg p-4">
                    <h4 className="font-semibold text-yellow-400 mb-2">Early Experiments</h4>
                    <p className="text-gray-300 text-sm">
                      We previously experimented with Harmony Assistant for MIDI-based renditions, 
                      but the quality wasn&apos;t suitable for our standards.
                    </p>
                  </div>
                  
                  <div className="bg-gray-800 rounded-lg p-4">
                    <h4 className="font-semibold text-green-400 mb-2">Current Focus</h4>
                    <p className="text-gray-300 text-sm">
                      Prioritizing human choir collaborations while researching AI technologies 
                      that can meet our quality requirements for sacred music.
                    </p>
                  </div>
                  
                  <div className="bg-gray-800 rounded-lg p-4">
                    <h4 className="font-semibold text-blue-400 mb-2">Future Vision</h4>
                    <p className="text-gray-300 text-sm">
                      Developing affordable, scalable solutions for mass production while 
                      maintaining the reverent quality these hymns deserve.
                    </p>
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