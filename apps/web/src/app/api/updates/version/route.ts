import { NextRequest, NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';

interface VersionResponse {
  data_version: string;
  app_min_version: string;
  critical_update: boolean;
  last_updated: string;
  available_collections: {
    id: string;
    name: string;
    version: string;
    size_mb: number;
    has_updates: boolean;
  }[];
}

export async function GET(request: NextRequest) {
  try {
    // Get current data version from metadata
    const metadataPath = path.join(process.cwd(), '../..', 'data/processed/metadata/collections-metadata.json');
    
    let dataVersion = '1.0.0';
    let lastUpdated = new Date().toISOString();
    
    try {
      const metadataFile = await fs.readFile(metadataPath, 'utf8');
      const metadata = JSON.parse(metadataFile);
      dataVersion = metadata.version || dataVersion;
      lastUpdated = metadata.last_updated || lastUpdated;
    } catch (e) {
      console.warn('Could not read metadata file, using defaults');
    }

    // Load collections index to provide available collections
    const collectionsPath = path.join(process.cwd(), '../..', 'data/processed/collections-index.json');
    let collections: Record<string, any> = {};
    
    try {
      const collectionsFile = await fs.readFile(collectionsPath, 'utf8');
      collections = JSON.parse(collectionsFile);
    } catch (e) {
      console.warn('Could not read collections index');
    }

    // Build available collections list
    const availableCollections = Object.entries(collections).map(([id, collection]: [string, any]) => ({
      id,
      name: collection.name || id,
      version: dataVersion,
      size_mb: Math.round((collection.total_songs || 100) * 0.01 * 100) / 100, // Estimate ~0.01MB per song
      has_updates: false // Would check against client version in real implementation
    }));

    const response: VersionResponse = {
      data_version: dataVersion,
      app_min_version: '1.0.0',
      critical_update: false,
      last_updated: lastUpdated,
      available_collections: availableCollections
    };

    return NextResponse.json(response, {
      headers: {
        'Cache-Control': 'public, max-age=300', // Cache for 5 minutes
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });

  } catch (error) {
    console.error('Error in version endpoint:', error);
    
    // Return minimal fallback response
    const fallbackResponse: VersionResponse = {
      data_version: '1.0.0',
      app_min_version: '1.0.0',
      critical_update: false,
      last_updated: new Date().toISOString(),
      available_collections: []
    };

    return NextResponse.json(fallbackResponse, { 
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });
  }
}

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}