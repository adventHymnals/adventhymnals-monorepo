import { NextResponse } from 'next/server';

const ALLOWED_ORIGINS = [
  'http://localhost:8080', // Flutter app
  'http://localhost:3000', // Next.js app
];

export function corsHeaders(origin?: string | null) {
  const headers: Record<string, string> = {
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
  }

  return headers;
}

export function withCors(response: NextResponse, origin?: string | null) {
  const headers = corsHeaders(origin);
  Object.entries(headers).forEach(([key, value]) => {
    response.headers.set(key, value);
  });
  return response;
}

export function handleOptionsRequest(request: Request) {
  const origin = request.headers.get('origin');
  const response = new NextResponse(null, { status: 200 });
  return withCors(response, origin);
}