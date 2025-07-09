/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Ensure proper module resolution for CI environments
    config.resolve.alias = {
      ...config.resolve.alias,
      '@': require('path').resolve(__dirname, 'src'),
    };
    return config;
  },
  output: process.env.NEXT_OUTPUT === 'export' ? 'export' : 'standalone',
  distDir: process.env.NEXT_DISTDIR || '.next',
  trailingSlash: true,
  skipTrailingSlashRedirect: true,
  // For static export, disable features that require server-side functionality
  ...(process.env.NEXT_OUTPUT === 'export' && {
    // Disable image optimization for static export
    images: {
      unoptimized: true,
      domains: ['raw.githubusercontent.com'],
      formats: ['image/webp', 'image/avif'],
    },
  }),
  eslint: {
    // Disable ESLint during builds
    ignoreDuringBuilds: true,
  },
  experimental: {
    // typedRoutes: true, // Disabled temporarily due to dynamic route issues
  },
  // Images configuration - conditional based on export mode
  ...(process.env.NEXT_OUTPUT !== 'export' && {
    images: {
      domains: ['raw.githubusercontent.com'],
      formats: ['image/webp', 'image/avif'],
      minimumCacheTTL: 31536000, // 1 year
    },
  }),
  ...(process.env.NEXT_OUTPUT !== 'export' && {
    async rewrites() {
      return [
        {
          source: '/sitemap.xml',
          destination: '/api/sitemap',
        },
        {
          source: '/robots.txt',
          destination: '/api/robots',
        },
      ];
    },
    async headers() {
      return [
        {
          source: '/(.*)',
          headers: [
            {
              key: 'X-Frame-Options',
              value: 'DENY',
            },
            {
              key: 'X-Content-Type-Options',
              value: 'nosniff',
            },
            {
              key: 'Referrer-Policy',
              value: 'strict-origin-when-cross-origin',
            },
          ],
        },
      ];
    },
  }),
  env: {
    SITE_URL: process.env.SITE_URL || 
      (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 
       process.env.NEXT_OUTPUT === 'export' ? 'https://adventhymnals.github.io' : 
       'https://adventhymnals.org'),
  },
  transpilePackages: [
    '@advent-hymnals/shared',
    '@advent-hymnals/hymnal-processor',
    '@advent-hymnals/metadata-indexer',
  ],
};

module.exports = nextConfig;