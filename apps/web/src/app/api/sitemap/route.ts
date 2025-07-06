import { NextResponse } from 'next/server';
import { loadHymnalReferences } from '@/lib/data';
import { generateSitemapUrls } from '@/lib/seo';

export async function GET() {
  try {
    const hymnalReferences = await loadHymnalReferences();
    const hymnals = Object.values(hymnalReferences.hymnals);
    const urls = generateSitemapUrls(hymnals);

    const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map(url => `  <url>
    <loc>${url.url}</loc>
    <lastmod>${url.lastModified.toISOString()}</lastmod>
    <changefreq>${url.changeFrequency}</changefreq>
    <priority>${url.priority}</priority>
  </url>`).join('\n')}
</urlset>`;

    return new NextResponse(sitemap, {
      headers: {
        'Content-Type': 'application/xml',
        'Cache-Control': 'public, max-age=3600, s-maxage=3600',
      },
    });
  } catch (error) {
    console.error('Error generating sitemap:', error);
    return new NextResponse('Error generating sitemap', { status: 500 });
  }
}