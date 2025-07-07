import { NextRequest, NextResponse } from 'next/server';
import { readFile } from 'fs/promises';
import { join } from 'path';
import { existsSync } from 'fs';

export async function GET(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  try {
    // Reconstruct the path from the dynamic segments
    const audioPath = params.path.join('/');
    
    // Construct the full path to the audio file
    const fullPath = join(process.cwd(), '../../data/sources/audio', audioPath);
    
    // Security check: ensure the path doesn't escape the audio directory
    const normalizedPath = join(process.cwd(), '../../data/sources/audio');
    if (!fullPath.startsWith(normalizedPath)) {
      return new NextResponse('Access denied', { status: 403 });
    }
    
    // Check if file exists
    if (!existsSync(fullPath)) {
      return new NextResponse('Audio file not found', { status: 404 });
    }
    
    // Read the file
    const fileBuffer = await readFile(fullPath);
    
    // Determine content type based on file extension
    const ext = audioPath.split('.').pop()?.toLowerCase();
    let contentType = 'application/octet-stream';
    
    switch (ext) {
      case 'mp3':
        contentType = 'audio/mpeg';
        break;
      case 'mid':
      case 'midi':
        contentType = 'audio/midi';
        break;
      case 'wav':
        contentType = 'audio/wav';
        break;
      case 'ogg':
        contentType = 'audio/ogg';
        break;
      case 'm4a':
        contentType = 'audio/mp4';
        break;
    }
    
    // Return the audio file with appropriate headers
    return new NextResponse(fileBuffer, {
      status: 200,
      headers: {
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=31536000, immutable', // Cache for 1 year
        'Content-Length': fileBuffer.length.toString(),
        'Accept-Ranges': 'bytes', // Allow partial content for audio seeking
      },
    });
  } catch (error) {
    console.error('Error serving audio:', error);
    return new NextResponse('Internal server error', { status: 500 });
  }
}