#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  print('🔄 Copying hymnal data to assets...');
  
  // Paths
  final projectRoot = Directory.current;
  final dataSourcePath = Directory('${projectRoot.parent.parent.path}/data/processed');
  final assetsPath = Directory('${projectRoot.path}/assets/data');
  
  // Verify source data exists
  if (!await dataSourcePath.exists()) {
    print('❌ Source data not found at: ${dataSourcePath.path}');
    print('   Make sure you\'re running this from the mobile app directory');
    print('   Expected: advent-hymnals-mono-repo/data/processed');
    exit(1);
  }
  
  // Create assets directory
  if (!await assetsPath.exists()) {
    await assetsPath.create(recursive: true);
  }
  
  try {
    // Copy essential data for bundling
    await copyEssentialData(dataSourcePath, assetsPath);
    
    // Generate app-specific metadata
    await generateAppMetadata(dataSourcePath, assetsPath);
    
    print('✅ Data copying completed successfully!');
    print('📊 Check assets/data/ for bundled hymnal data');
    
  } catch (e) {
    print('❌ Error copying data: $e');
    exit(1);
  }
}

Future<void> copyEssentialData(Directory source, Directory assets) async {
  print('📋 Copying essential hymnal data...');
  
  // Copy hymnals reference
  final metadataSource = Directory('${source.path}/metadata');
  final metadataTarget = Directory('${assets.path}/metadata');
  await metadataTarget.create(recursive: true);
  
  final hymnalsRefFile = File('${metadataSource.path}/hymnals-reference.json');
  if (await hymnalsRefFile.exists()) {
    await hymnalsRefFile.copy('${metadataTarget.path}/hymnals-reference.json');
    print('  ✓ Copied hymnals-reference.json');
  }
  
  // Copy essential hymnal collections (SDAH, CS1900 for demo)
  final hymnalsSource = Directory('${source.path}/hymnals');
  final hymnalsTarget = Directory('${assets.path}/hymnals');
  await hymnalsTarget.create(recursive: true);
  
  final essentialHymnals = ['SDAH-collection.json', 'CS1900-collection.json'];
  for (final filename in essentialHymnals) {
    final sourceFile = File('${hymnalsSource.path}/$filename');
    if (await sourceFile.exists()) {
      await sourceFile.copy('${hymnalsTarget.path}/$filename');
      print('  ✓ Copied $filename');
    }
  }
  
  // Copy sample hymns from essential collections
  final hymnsSource = Directory('${source.path}/hymns');
  final hymnsTarget = Directory('${assets.path}/hymns');
  await hymnsTarget.create(recursive: true);
  
  // Copy sample SDAH hymns (first 50)
  await copySampleHymns(hymnsSource, hymnsTarget, 'SDAH', 50);
  
  // Copy sample CS1900 hymns (first 30)
  await copySampleHymns(hymnsSource, hymnsTarget, 'CS1900', 30);
}

Future<void> copySampleHymns(Directory source, Directory target, String collection, int maxCount) async {
  final sourceCollection = Directory('${source.path}/$collection');
  if (!await sourceCollection.exists()) {
    print('  ⚠️ Collection $collection not found in source');
    return;
  }
  
  final targetCollection = Directory('${target.path}/$collection');
  await targetCollection.create(recursive: true);
  
  final hymnFiles = await sourceCollection.list()
      .where((entity) => entity is File && entity.path.endsWith('.json'))
      .cast<File>()
      .take(maxCount)
      .toList();
  
  int copied = 0;
  for (final file in hymnFiles) {
    final filename = file.path.split('/').last;
    await file.copy('${targetCollection.path}/$filename');
    copied++;
  }
  
  print('  ✓ Copied $copied hymns from $collection');
}

Future<void> generateAppMetadata(Directory source, Directory assets) async {
  print('🏗️ Generating app-specific metadata...');
  
  try {
    // Read the hymnals reference
    final refFile = File('${source.path}/metadata/hymnals-reference.json');
    if (!await refFile.exists()) {
      print('  ⚠️ Hymnals reference not found, creating minimal metadata');
      return;
    }
    
    final refContent = await refFile.readAsString();
    final refData = json.decode(refContent) as Map<String, dynamic>;
    final hymnals = refData['hymnals'] as Map<String, dynamic>;
    
    // Generate app configuration
    final appConfig = {
      'version': '1.0.0',
      'data_version': DateTime.now().toIso8601String(),
      'bundled_collections': ['SDAH', 'CS1900'],
      'available_collections': hymnals.keys.toList(),
      'languages': refData['languages'] ?? {},
      'update_policy': {
        'check_interval_hours': 24,
        'auto_download': false,
        'wifi_only': true,
      },
      'features': {
        'offline_mode': true,
        'audio_playback': true,
        'search': true,
        'favorites': true,
        'recently_viewed': true,
        'projector_mode': true,
      }
    };
    
    final configFile = File('${assets.path}/app-config.json');
    await configFile.writeAsString(json.encode(appConfig));
    print('  ✓ Generated app-config.json');
    
    // Generate collection index for quick access
    final collectionIndex = <String, Map<String, dynamic>>{};
    for (final entry in hymnals.entries) {
      final hymnalData = entry.value as Map<String, dynamic>;
      collectionIndex[entry.key] = {
        'id': entry.key,
        'name': hymnalData['name'],
        'abbreviation': hymnalData['abbreviation'],
        'language': hymnalData['language'],
        'total_songs': hymnalData['total_songs'],
        'year': hymnalData['year'],
        'bundled': ['SDAH', 'CS1900'].contains(entry.key),
      };
    }
    
    final indexFile = File('${assets.path}/collections-index.json');
    await indexFile.writeAsString(json.encode(collectionIndex));
    print('  ✓ Generated collections-index.json');
    
    // Generate bundled hymns index
    final bundledIndex = <String, List<String>>{};
    final hymnsDir = Directory('${assets.path}/hymns');
    
    if (await hymnsDir.exists()) {
      await for (final collection in hymnsDir.list()) {
        if (collection is Directory) {
          final collectionName = collection.path.split('/').last;
          final hymnFiles = <String>[];
          
          await for (final file in collection.list()) {
            if (file is File && file.path.endsWith('.json')) {
              final filename = file.path.split('/').last;
              final hymnId = filename.replaceAll('.json', '');
              hymnFiles.add(hymnId);
            }
          }
          
          bundledIndex[collectionName] = hymnFiles;
        }
      }
    }
    
    final bundledIndexFile = File('${assets.path}/bundled-hymns-index.json');
    await bundledIndexFile.writeAsString(json.encode(bundledIndex));
    print('  ✓ Generated bundled-hymns-index.json');
    
  } catch (e) {
    print('  ❌ Error generating metadata: $e');
  }
}

// Helper functions
String formatFileSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
}

Future<void> printDataStats(Directory assetsDir) async {
  int totalFiles = 0;
  int totalSize = 0;
  
  await for (final entity in assetsDir.list(recursive: true)) {
    if (entity is File) {
      totalFiles++;
      totalSize += await entity.length();
    }
  }
  
  print('📊 Data Statistics:');
  print('   Files: $totalFiles');
  print('   Total size: ${formatFileSize(totalSize)}');
}