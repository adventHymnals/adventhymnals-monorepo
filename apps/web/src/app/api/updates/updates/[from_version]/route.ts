import { NextRequest, NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';

interface DataUpdate {
  id: string;
  action: 'add' | 'update' | 'delete';
  collection: string;
  hymn_id?: string;
  file_url: string;
  file_path: string;
  from_version: string;
  to_version: string;
  file_size_bytes?: number;
  description: string;
}

interface UpdatesResponse {
  from_version: string;
  to_version: string;
  has_updates: boolean;
  total_updates: number;
  estimated_size_mb: number;
  updates: DataUpdate[];
}

export async function GET(
  request: NextRequest,
  { params }: { params: { from_version: string } }
) {
  try {
    const fromVersion = params.from_version;
    const { searchParams } = new URL(request.url);
    const collectionFilter = searchParams.get('collection');
    
    // Get current version
    const metadataPath = path.join(process.cwd(), '../..', 'data/processed/metadata/collections-metadata.json');
    let currentVersion = '1.0.0';
    
    try {
      const metadataFile = await fs.readFile(metadataPath, 'utf8');
      const metadata = JSON.parse(metadataFile);
      currentVersion = metadata.version || currentVersion;
    } catch (e) {
      console.warn('Could not read metadata file, using defaults');
    }

    // Check if update is needed
    if (fromVersion === currentVersion) {
      return NextResponse.json({
        from_version: fromVersion,
        to_version: currentVersion,
        has_updates: false,
        total_updates: 0,
        estimated_size_mb: 0,
        updates: []
      } as UpdatesResponse);
    }

    // Load collections to generate updates
    const collectionsPath = path.join(process.cwd(), '../..', 'data/processed/collections-index.json');
    let collections: Record<string, any> = {};
    
    try {
      const collectionsFile = await fs.readFile(collectionsPath, 'utf8');
      collections = JSON.parse(collectionsFile);
    } catch (e) {
      console.warn('Could not read collections index');
    }

    // Get base URL from request
    const baseUrl = `${request.nextUrl.protocol}//${request.nextUrl.host}`;

    // Generate updates based on collection and content changes
    const updates: DataUpdate[] = await generateUpdatesList(fromVersion, currentVersion, collections, baseUrl, collectionFilter);

    // Helper function to generate comprehensive updates list
    async function generateUpdatesList(
      fromVer: string, 
      toVer: string, 
      currentCollections: Record<string, any>, 
      apiBaseUrl: string, 
      filter?: string | null
    ): Promise<DataUpdate[]> {
      const updatesList: DataUpdate[] = [];
      
      // 1. Always update the main collections index
      updatesList.push({
        id: `collections-index-${Date.now()}`,
        action: 'update',
        collection: 'system',
        file_url: `${apiBaseUrl}/api/collections`,
        file_path: 'collections-index.json',
        from_version: fromVer,
        to_version: toVer,
        file_size_bytes: 1024 * 10, // ~10KB
        description: 'Updated collections index with latest collection information'
      });

      // 2. Load previous collections state to detect changes
      let previousCollections: Record<string, any> = {};
      try {
        // In a real implementation, this would load from a versioned storage
        // For now, we'll simulate by checking if collections exist
        previousCollections = await getPreviousCollectionsState(fromVer);
      } catch (e) {
        console.warn('Could not load previous collections state, treating all as updates');
      }

      // 3. Detect collection-level changes
      const previousCollectionIds = new Set(Object.keys(previousCollections));
      const currentCollectionIds = new Set(Object.keys(currentCollections));

      // 3a. Detect new collections (added)
      for (const collectionId of currentCollectionIds) {
        if (!previousCollectionIds.has(collectionId)) {
          const collection = currentCollections[collectionId];
          updatesList.push({
            id: `collection-add-${collectionId}-${Date.now()}`,
            action: 'add',
            collection: collectionId,
            file_url: `${apiBaseUrl}/api/hymnals/${collectionId}`,
            file_path: `collections/${collectionId}-collection.json`,
            from_version: fromVer,
            to_version: toVer,
            file_size_bytes: 1024 * 100, // ~100KB for new collection
            description: `Added new collection: ${collection.name || collectionId}`
          });
        }
      }

      // 3b. Detect removed collections (deleted)
      for (const collectionId of previousCollectionIds) {
        if (!currentCollectionIds.has(collectionId)) {
          updatesList.push({
            id: `collection-delete-${collectionId}-${Date.now()}`,
            action: 'delete',
            collection: collectionId,
            file_url: '',
            file_path: `collections/${collectionId}-collection.json`,
            from_version: fromVer,
            to_version: toVer,
            file_size_bytes: 0,
            description: `Removed collection: ${collectionId}`
          });
        }
      }

      // 4. Process existing collections for updates
      for (const [collectionId, collection] of Object.entries(currentCollections)) {
        // Skip if collection filter is specified and doesn't match
        if (filter && collectionId !== filter) {
          continue;
        }

        const collectionData = collection as any;
        
        // Check if collection metadata changed
        const hasMetadataChanges = await checkCollectionMetadataChanges(
          collectionId, 
          collectionData, 
          previousCollections[collectionId]
        );

        if (hasMetadataChanges) {
          updatesList.push({
            id: `${collectionId}-metadata-${Date.now()}`,
            action: 'update',
            collection: collectionId,
            file_url: `${apiBaseUrl}/api/hymnals/${collectionId}`,
            file_path: `collections/${collectionId}-collection.json`,
            from_version: fromVer,
            to_version: toVer,
            file_size_bytes: 1024 * 50, // ~50KB for metadata
            description: `Updated metadata for ${collectionData.name || collectionId}`
          });
        }

        // 5. Add hymn-level updates for major collections
        if (['SDAH', 'CS1900', 'CH1941'].includes(collectionId)) {
          const hymnUpdates = await generateHymnUpdates(
            collectionId, 
            fromVer, 
            toVer, 
            apiBaseUrl
          );
          updatesList.push(...hymnUpdates);
        }
      }

      return updatesList;
    }

    // Helper function to simulate previous collections state
    async function getPreviousCollectionsState(version: string): Promise<Record<string, any>> {
      // In a real implementation, this would:
      // 1. Query a versioned database
      // 2. Load from git history
      // 3. Use a changelog system
      
      // For now, simulate some previous state
      const samplePreviousState: Record<string, any> = {
        'SDAH': { name: 'Seventh-day Adventist Hymnal', total_songs: 694 }, // One less hymn
        'CS1900': { name: 'Christ in Song', total_songs: 949 },
        // Note: Missing newer collections like CM2000, simulating they were added
      };
      
      return samplePreviousState;
    }

    // Helper function to check if collection metadata changed
    async function checkCollectionMetadataChanges(
      collectionId: string, 
      current: any, 
      previous: any
    ): Promise<boolean> {
      if (!previous) return true; // New collection
      
      // Check key fields for changes
      return (
        current.name !== previous.name ||
        current.total_songs !== previous.total_songs ||
        current.year !== previous.year ||
        current.bundled !== previous.bundled
      );
    }

    // Helper function to generate hymn-level updates
    async function generateHymnUpdates(
      collectionId: string, 
      fromVer: string, 
      toVer: string, 
      apiBaseUrl: string
    ): Promise<DataUpdate[]> {
      const hymnUpdates: DataUpdate[] = [];
      
      // Simulate some hymn updates - in real implementation, this would:
      // 1. Compare hymn files between versions
      // 2. Check modification timestamps
      // 3. Generate checksums to detect changes
      
      for (let i = 1; i <= 2; i++) {
        const hymnId = `${collectionId}-en-${String(i).padStart(3, '0')}`;
        hymnUpdates.push({
          id: `${hymnId}-update-${Date.now()}-${i}`,
          action: 'update',
          collection: collectionId,
          hymn_id: hymnId,
          file_url: `${apiBaseUrl}/api/hymns/${hymnId}`,
          file_path: `hymns/${collectionId}/${hymnId}.json`,
          from_version: fromVer,
          to_version: toVer,
          file_size_bytes: 1024 * 5, // ~5KB per hymn
          description: `Updated lyrics and metadata for hymn ${i}`
        });
      }
      
      return hymnUpdates;
    }

    // Calculate total estimated size
    const totalSizeBytes = updates.reduce((sum, update) => sum + (update.file_size_bytes || 0), 0);
    const estimatedSizeMB = Math.round((totalSizeBytes / (1024 * 1024)) * 100) / 100;

    const response: UpdatesResponse = {
      from_version: fromVersion,
      to_version: currentVersion,
      has_updates: updates.length > 0,
      total_updates: updates.length,
      estimated_size_mb: estimatedSizeMB,
      updates
    };

    return NextResponse.json(response, {
      headers: {
        'Cache-Control': 'public, max-age=60', // Cache for 1 minute
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });

  } catch (error) {
    console.error('Error in updates endpoint:', error);
    
    return NextResponse.json({
      from_version: params.from_version,
      to_version: params.from_version,
      has_updates: false,
      total_updates: 0,
      estimated_size_mb: 0,
      updates: [],
      error: 'Failed to check for updates'
    } as UpdatesResponse & { error: string }, { 
      status: 500,
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