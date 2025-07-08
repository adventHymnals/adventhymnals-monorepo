import { NextRequest, NextResponse } from 'next/server';
import { readFile } from 'fs/promises';
import { join } from 'path';
import { existsSync } from 'fs';

export async function GET(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  try {
    const path = params.path;
    
    if (!path || path.length === 0) {
      return new NextResponse('Path required', { status: 400 });
    }

    // Construct the file path
    const filePath = join(process.cwd(), '../../data/sources/images', ...path);
    
    // Security check - ensure path doesn't escape the images directory
    const imagesDir = join(process.cwd(), '../../data/sources/images');
    if (!filePath.startsWith(imagesDir)) {
      return new NextResponse('Invalid path', { status: 403 });
    }

    // Check if file exists
    if (!existsSync(filePath)) {
      return new NextResponse('Image not found', { status: 404 });
    }

    // Read the file
    const fileBuffer = await readFile(filePath);
    
    // Determine content type based on file extension
    const extension = path[path.length - 1].split('.').pop()?.toLowerCase();
    let contentType = 'application/octet-stream';
    
    switch (extension) {
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
      },
    });
  } catch (error) {
    console.error('Error serving image:', error);
    return new NextResponse('Internal server error', { status: 500 });
  }
}