import { Metadata } from 'next';
import Link from 'next/link';
import { 
  DevicePhoneMobileIcon, 
  ComputerDesktopIcon, 
  DocumentArrowDownIcon,
  PlayIcon,
  DeviceTabletIcon,
  ServerIcon
} from '@heroicons/react/24/outline';
import Layout from '@/components/layout/Layout';
import { loadHymnalReferences } from '@/lib/data-server';

export const metadata: Metadata = {
  title: 'Download - Advent Hymnals',
  description: 'Download the Advent Hymnals mobile app, desktop application for church projection, and complete hymnal PDFs.',
  keywords: ['Advent Hymnals download', 'hymnal app', 'church projection', 'hymnal PDFs', 'mobile app'],
};

// Mock data for app downloads - replace with actual download links
const mobileApps = [
  {
    platform: 'iOS',
    icon: DeviceTabletIcon,
    title: 'Download for iPhone & iPad',
    description: 'Available on the App Store',
    link: '#ios-download',
    coming: true
  },
  {
    platform: 'Android',
    icon: DevicePhoneMobileIcon,
    title: 'Download for Android',
    description: 'Available on Google Play Store',
    link: '#android-download',
    coming: true
  }
];

const desktopApps = [
  {
    platform: 'Windows',
    icon: ComputerDesktopIcon,
    title: 'Windows Application',
    description: 'For church projection and worship leading',
    link: '#windows-download',
    coming: true
  },
  {
    platform: 'macOS',
    icon: ComputerDesktopIcon,
    title: 'macOS Application',
    description: 'For church projection and worship leading',
    link: '#macos-download',
    coming: true
  },
  {
    platform: 'Linux',
    icon: ServerIcon,
    title: 'Linux Application',
    description: 'For church projection and worship leading',
    link: '#linux-download',
    coming: true
  }
];

export default async function DownloadPage() {
  const hymnalReferences = await loadHymnalReferences();
  const hymnals = Object.values(hymnalReferences.hymnals)
    .filter(hymnal => hymnal.url_slug)
    .sort((a, b) => b.year - a.year);

  return (
    <Layout hymnalReferences={hymnalReferences}>
      <div className="min-h-screen bg-gray-50">
        {/* Compact Header */}
        <div className="bg-gradient-to-r from-primary-600 to-primary-700">
          <div className="mx-auto max-w-7xl px-6 py-12 lg:px-8">
            <div className="text-center">
              <h1 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
                Download Advent Hymnals
              </h1>
            </div>
          </div>
        </div>

        {/* Section Navigation */}
        <div className="bg-white shadow-sm border-b">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="flex justify-center space-x-8 py-4">
              <a
                href="#mobile-apps"
                className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50 rounded-lg transition-colors"
              >
                <DevicePhoneMobileIcon className="h-5 w-5 mr-2" />
                Mobile Apps
              </a>
              <a
                href="#desktop-apps"
                className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50 rounded-lg transition-colors"
              >
                <ComputerDesktopIcon className="h-5 w-5 mr-2" />
                Desktop Apps
              </a>
              <a
                href="#pdf-downloads"
                className="inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-gray-50 rounded-lg transition-colors"
              >
                <DocumentArrowDownIcon className="h-5 w-5 mr-2" />
                PDF Downloads
              </a>
            </div>
          </div>
        </div>

        {/* Mobile Apps Section */}
        <div id="mobile-apps" className="py-24 sm:py-32">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <DevicePhoneMobileIcon className="mx-auto h-12 w-12 text-primary-600" />
              <h2 className="mt-4 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Mobile Applications
              </h2>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Take your hymnals everywhere. Perfect for personal devotions, small groups, and on-the-go worship.
              </p>
            </div>
            
            <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:grid-cols-2 lg:max-w-4xl">
              {mobileApps.map((app) => (
                <div key={app.platform} className="relative overflow-hidden rounded-2xl bg-white p-8 shadow-lg hover:shadow-xl transition-shadow">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary-100">
                        <app.icon className="h-6 w-6 text-primary-600" />
                      </div>
                      <div>
                        <h3 className="text-lg font-semibold text-gray-900">{app.title}</h3>
                        <p className="text-sm text-gray-600">{app.description}</p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="mt-6">
                    {app.coming ? (
                      <div className="inline-flex items-center rounded-lg bg-gray-100 px-4 py-2 text-sm font-medium text-gray-600">
                        Coming Soon
                      </div>
                    ) : (
                      <Link
                        href={app.link}
                        className="inline-flex items-center rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 transition-colors"
                      >
                        Download Now
                      </Link>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Desktop Apps Section */}
        <div id="desktop-apps" className="bg-white py-24 sm:py-32">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <ComputerDesktopIcon className="mx-auto h-12 w-12 text-primary-600" />
              <h2 className="mt-4 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Desktop Applications
              </h2>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Professional church projection software with full-screen display, customizable themes, and advanced worship features.
              </p>
            </div>

            <div className="mx-auto mt-16 grid max-w-4xl grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
              {desktopApps.map((app) => (
                <div key={app.platform} className="relative overflow-hidden rounded-2xl bg-gray-50 p-8 shadow-lg hover:shadow-xl transition-shadow">
                  <div className="text-center">
                    <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-primary-100">
                      <app.icon className="h-8 w-8 text-primary-600" />
                    </div>
                    <h3 className="mt-4 text-lg font-semibold text-gray-900">{app.title}</h3>
                    <p className="mt-2 text-sm text-gray-600">{app.description}</p>
                  </div>
                  
                  <div className="mt-6 text-center">
                    {app.coming ? (
                      <div className="inline-flex items-center rounded-lg bg-gray-200 px-4 py-2 text-sm font-medium text-gray-600">
                        Coming Soon
                      </div>
                    ) : (
                      <Link
                        href={app.link}
                        className="inline-flex items-center rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 transition-colors"
                      >
                        Download
                      </Link>
                    )}
                  </div>
                </div>
              ))}
            </div>

            {/* Features */}
            <div className="mx-auto mt-16 max-w-4xl">
              <h3 className="text-center text-xl font-semibold text-gray-900 mb-8">
                Desktop Application Features
              </h3>
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <div className="flex items-start space-x-3">
                  <PlayIcon className="h-5 w-5 text-primary-600 mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium text-gray-900">Full-Screen Projection</h4>
                    <p className="text-sm text-gray-600">Perfect for church services and large gatherings</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <DocumentArrowDownIcon className="h-5 w-5 text-primary-600 mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium text-gray-900">Offline Access</h4>
                    <p className="text-sm text-gray-600">No internet connection required during services</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <DevicePhoneMobileIcon className="h-5 w-5 text-primary-600 mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium text-gray-900">Remote Control</h4>
                    <p className="text-sm text-gray-600">Control from your phone or tablet</p>
                  </div>
                </div>
                <div className="flex items-start space-x-3">
                  <ComputerDesktopIcon className="h-5 w-5 text-primary-600 mt-1 flex-shrink-0" />
                  <div>
                    <h4 className="font-medium text-gray-900">Custom Themes</h4>
                    <p className="text-sm text-gray-600">Match your church's visual identity</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* PDF Downloads Section */}
        <div id="pdf-downloads" className="py-24 sm:py-32">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <DocumentArrowDownIcon className="mx-auto h-12 w-12 text-primary-600" />
              <h2 className="mt-4 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
                Complete Hymnal PDFs
              </h2>
              <p className="mt-6 text-lg leading-8 text-gray-600">
                Download complete hymnal collections as high-quality PDFs for printing, archival, or offline reference.
              </p>
            </div>

            <div className="mx-auto mt-16 grid max-w-6xl grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {hymnals.map((hymnal) => (
                <div key={hymnal.id} className="relative overflow-hidden rounded-xl bg-white p-6 shadow-sm hover:shadow-lg transition-shadow border border-gray-200">
                  <div className="flex items-start justify-between">
                    <div className="flex-1 min-w-0">
                      <h3 className="text-lg font-semibold text-gray-900 truncate">
                        {hymnal.site_name || hymnal.name}
                      </h3>
                      <p className="text-sm text-gray-600 mt-1">
                        {hymnal.year} • {hymnal.total_songs} hymns • {hymnal.language_name}
                      </p>
                      <p className="text-xs text-gray-500 mt-2">
                        Complete hymnal with lyrics, music notation, and metadata
                      </p>
                    </div>
                    <div className="ml-4 flex-shrink-0">
                      <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                        <DocumentArrowDownIcon className="h-5 w-5 text-primary-600" />
                      </div>
                    </div>
                  </div>
                  
                  <div className="mt-4 flex items-center justify-between">
                    <span className="text-xs text-gray-500">PDF Format</span>
                    <div className="flex space-x-2">
                      <button className="inline-flex items-center rounded-md bg-gray-100 px-3 py-1 text-xs font-medium text-gray-600 hover:bg-gray-200 transition-colors">
                        Coming Soon
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <div className="mx-auto mt-12 max-w-2xl text-center">
              <p className="text-sm text-gray-600">
                PDF downloads will include complete hymnals with lyrics, sheet music, historical notes, and searchable text.
                All downloads are free and available under open licensing terms.
              </p>
            </div>
          </div>
        </div>

        {/* CTA Section */}
        <div className="bg-primary-600">
          <div className="px-6 py-16 sm:px-6 sm:py-24 lg:px-8">
            <div className="mx-auto max-w-2xl text-center">
              <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
                Stay Updated
              </h2>
              <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-primary-200">
                Be the first to know when our mobile and desktop applications are available for download.
              </p>
              <div className="mt-10 flex items-center justify-center gap-x-6">
                <Link
                  href="/about"
                  className="btn-primary bg-white text-primary-600 hover:bg-gray-50"
                >
                  Learn More
                </Link>
                <Link 
                  href="/contribute" 
                  className="text-sm font-semibold leading-6 text-white hover:text-primary-200 transition-colors"
                >
                  Contribute <span aria-hidden="true">→</span>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}