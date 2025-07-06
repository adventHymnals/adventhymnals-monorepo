import { NextResponse } from 'next/server';
import { generateRobotsTxt } from '@/lib/seo';

export async function GET() {
  const robotsTxt = generateRobotsTxt();

  return new NextResponse(robotsTxt, {
    headers: {
      'Content-Type': 'text/plain',
      'Cache-Control': 'public, max-age=86400, s-maxage=86400',
    },
  });
}