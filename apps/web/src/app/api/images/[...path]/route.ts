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
    const imagePath = params.path.join('/');
    
    // Construct the full path to the image file
    const fullPath = join(process.cwd(), '../../data/sources/images', imagePath);
    
    // Security check: ensure the path doesn't escape the images directory
    const normalizedPath = join(process.cwd(), '../../data/sources/images');
    if (!fullPath.startsWith(normalizedPath)) {
      return new NextResponse('Access denied', { status: 403 });
    }
    
    // Check if file exists
    if (!existsSync(fullPath)) {
      return new NextResponse('Image not found', { status: 404 });
    }
    
    // Read the file
    const fileBuffer = await readFile(fullPath);
    
    // Determine content type based on file extension
    const ext = imagePath.split('.').pop()?.toLowerCase();
    let contentType = 'application/octet-stream';
    
    switch (ext) {
      case 'png':
        contentType = 'image/png';
        break;
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'gif':
        contentType = 'image/gif';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
      case 'svg':
        contentType = 'image/svg+xml';
        break;
    }
    
    // Return the image with appropriate headers
    return new NextResponse(fileBuffer, {
      status: 200,
      headers: {
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=31536000, immutable', // Cache for 1 year
        'Content-Length': fileBuffer.length.toString(),
      },
    });
  } catch (error) {
    console.error('Error serving image:', error);
    return new NextResponse('Internal server error', { status: 500 });
  }
}