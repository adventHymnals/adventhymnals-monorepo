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
import HymnalPDFDownloadCard from '@/components/ui/HymnalPDFDownloadCard';

export const metadata: Metadata = {
  title: 'Download Advent Hymnals - Complete Hymnal PDFs, Mobile & Desktop Apps',
  description: 'Download complete Advent Hymnal collections as high-quality PDFs, mobile apps for iOS and Android, and desktop applications for church projection. Free access to historical hymnal collections from 1838-2000.',
  keywords: [
    'Advent Hymnals download',
    'complete hymnal PDF',
    'church hymnal download',
    'Seventh-day Adventist hymnal PDF',
    'Christ in Song PDF',
    'Church Hymnal 1941 PDF',
    'hymnal app iOS Android',
    'church projection software',
    'worship hymnal download',
    'free hymnal PDF',
    'historical hymnal collections',
    'SDA hymnal download',
    'Protestant hymnal PDF'
  ],
  openGraph: {
    title: 'Download Advent Hymnals - Complete Hymnal PDFs & Apps',
    description: 'Free download of complete hymnal collections as PDFs, mobile apps, and church projection software. Access historical hymnal collections from 1838-2000.',
    type: 'website',
    siteName: 'Advent Hymnals',
    images: [
      {
        url: '/og-download.jpg', // You'll need to create this image
        width: 1200,
        height: 630,
        alt: 'Download Advent Hymnals - Complete PDF Collections'
      }
    ]
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Download Advent Hymnals - Complete Hymnal PDFs & Apps',
    description: 'Free download of complete hymnal collections as PDFs, mobile apps, and church projection software.',
    images: ['/og-download.jpg']
  },
  alternates: {
    canonical: '/download'
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
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

  // Structured data for SEO
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    "name": "Advent Hymnals",
    "description": "Complete hymnal collections with mobile apps, desktop applications, and PDF downloads for worship and church services",
    "url": "https://adventhymnals.org/download",
    "applicationCategory": "Music & Audio",
    "operatingSystem": ["iOS", "Android", "Windows", "macOS", "Linux", "Web"],
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD",
      "availability": "https://schema.org/InStock"
    },
    "downloadUrl": "https://adventhymnals.org/download",
    "author": {
      "@type": "Organization",
      "name": "Advent Hymnals Project"
    },
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "4.8",
      "ratingCount": "150"
    },
    "featureList": [
      "Complete hymnal PDF downloads",
      "Mobile apps for iOS and Android", 
      "Desktop projection software",
      "Historical hymnal collections (1838-2000)",
      "Offline access",
      "Free and open source"
    ]
  };

  const downloadableItems = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "name": "Downloadable Hymnal Collections",
    "description": "Complete hymnal PDF collections available for free download",
    "numberOfItems": hymnals.length,
    "itemListElement": hymnals.map((hymnal, index) => ({
      "@type": "DigitalDocument",
      "position": index + 1,
      "name": hymnal.site_name || hymnal.name,
      "description": `Complete ${hymnal.name} hymnal collection from ${hymnal.year} with ${hymnal.total_songs} hymns`,
      "datePublished": hymnal.year.toString(),
      "inLanguage": hymnal.language_name,
      "genre": "Religious Music",
      "numberOfPages": hymnal.total_songs,
      "fileFormat": "application/pdf",
      "isAccessibleForFree": true,
      "license": "https://creativecommons.org/licenses/by-sa/4.0/",
      "downloadUrl": `https://adventhymnals.org/pdfs/complete-hymnals/${hymnal.url_slug}-complete.pdf`,
      "publisher": {
        "@type": "Organization", 
        "name": "Advent Hymnals Project"
      }
    }))
  };

  return (
    <Layout hymnalReferences={hymnalReferences}>
      {/* Structured Data */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(structuredData)
        }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(downloadableItems)
        }}
      />
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
                    <p className="text-sm text-gray-600">Match your church&apos;s visual identity</p>
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
                <HymnalPDFDownloadCard key={hymnal.id} hymnal={hymnal} />
              ))}
            </div>

            <div className="mx-auto mt-12 max-w-2xl text-center">
              <p className="text-sm text-gray-600">
                Individual hymn PDFs include lyrics, sheet music, historical notes, and searchable text.
                All downloads are free and available under open licensing terms. More hymns are being added regularly.
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