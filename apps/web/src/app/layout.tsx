import type { Metadata } from 'next';
import { Inter, Crimson_Text } from 'next/font/google';
import GoogleAnalytics from '@/components/analytics/GoogleAnalytics';
import '../styles/globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

const crimsonText = Crimson_Text({
  weight: ['400', '600'],
  style: ['normal', 'italic'],
  subsets: ['latin'],
  variable: '--font-crimson',
  display: 'swap',
});

export const metadata: Metadata = {
  title: {
    default: 'Advent Hymnals - Digital Collection of Adventist Hymnody',
    template: '%s | Advent Hymnals',
  },
  description: 'Explore 160+ years of Adventist hymnody heritage. Search through 13 complete hymnal collections including the Seventh-day Adventist Hymnal, Christ in Song, and international collections.',
  keywords: [
    'Seventh-day Adventist Hymnal',
    'SDA Hymnal',
    'Adventist hymns',
    'Christ in Song',
    'Church Hymnal',
    'Nyimbo za Kristo',
    'hymnal search',
    'worship music',
    'religious hymns',
    'Adventist church music',
    'hymn lyrics',
    'Christian hymns',
  ],
  authors: [{ name: 'Advent Hymnals Project', url: 'https://adventhymnals.org' }],
  creator: 'Advent Hymnals Project',
  publisher: 'Advent Hymnals',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.SITE_URL || 'https://adventhymnals.org'),
  alternates: {
    canonical: '/',
    languages: {
      'en-US': '/en-US',
      'sw-KE': '/sw-KE',
      'luo-KE': '/luo-KE',
    },
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: process.env.SITE_URL || 'https://adventhymnals.org',
    siteName: 'Advent Hymnals',
    title: 'Advent Hymnals - Digital Collection of Adventist Hymnody',
    description: 'Explore 160+ years of Adventist hymnody heritage. Search through 13 complete hymnal collections.',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Advent Hymnals - Digital Hymnal Collection',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Advent Hymnals - Digital Collection of Adventist Hymnody',
    description: 'Explore 160+ years of Adventist hymnody heritage. Search through 13 complete hymnal collections.',
    images: ['/og-image.jpg'],
    creator: '@adventhymnals',
  },
  robots: {
    index: true,
    follow: true,
    nocache: true,
    googleBot: {
      index: true,
      follow: true,
      noimageindex: false,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: process.env.GOOGLE_VERIFICATION,
    yandex: process.env.YANDEX_VERIFICATION,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html 
      lang="en" 
      className={`${inter.variable} ${crimsonText.variable}`}
      suppressHydrationWarning
    >
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/icon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="manifest" href="/manifest.json" />
        <meta name="theme-color" content="#1e40af" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="Advent Hymnals" />
        <meta name="application-name" content="Advent Hymnals" />
        <meta name="msapplication-TileColor" content="#1e40af" />
      </head>
      <body className="font-sans antialiased bg-gray-50">
        <GoogleAnalytics />
        {children}
      </body>
    </html>
  );
}