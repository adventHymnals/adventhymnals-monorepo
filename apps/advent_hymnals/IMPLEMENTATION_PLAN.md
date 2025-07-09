# Advent Hymnals Mobile App Implementation Plan

## 📋 Project Overview

**Project**: Advent Hymnals Flutter Mobile App  
**Target Platform**: Android & iOS (Flutter)  
**Timeline**: 12 weeks (3 months)  
**Team Size**: 2-3 developers  
**Architecture**: Clean Architecture with Provider state management

## 🎯 Project Goals

### Primary Objectives
- Create a comprehensive hymnal browsing mobile app
- Implement offline-first design with local SQLite database
- Support media download and playback (audio, MIDI, PDF)
- Provide intuitive browsing by authors, topics, tunes, meters, scripture
- Enable personal favorites and recently viewed tracking

### Success Metrics
- 18 complete screens implemented
- SQLite database with 892+ hymns
- Media download system for 4 file types
- 5-tab navigation with global search
- Offline capability for core features

## 🏗️ Technical Architecture

### Tech Stack
```
Frontend: Flutter 3.13+ (Dart 3.0+)
State Management: Provider 6.0+
Database: SQLite (sqflite 2.3+)
Storage: SharedPreferences + path_provider
HTTP: dio 5.0+
Audio: audioplayers 5.0+
PDF: flutter_pdfview 1.3+
Navigation: go_router 12.0+
```

### Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── database/
│   ├── errors/
│   ├── network/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── theme/
└── main.dart
```

## 📅 Implementation Timeline

### Phase 1: Foundation (Weeks 1-3)
**Goal**: Core architecture and basic functionality

#### Week 1: Project Setup & Architecture
- [ ] Flutter project initialization
- [ ] Dependency configuration
- [ ] Core folder structure
- [ ] Database schema implementation
- [ ] Basic models and entities

#### Week 2: Core Data Layer
- [ ] SQLite database helper
- [ ] Data models (Hymn, Author, Topic, etc.)
- [ ] Repository pattern implementation
- [ ] Local storage services
- [ ] Network layer setup

#### Week 3: Basic UI Foundation
- [ ] Theme configuration (Material 3)
- [ ] Bottom navigation setup
- [ ] Basic screen scaffolds
- [ ] Provider setup for state management
- [ ] Routing configuration

### Phase 2: Core Features (Weeks 4-6)
**Goal**: Essential browsing and navigation

#### Week 4: Home & Browse Screens
- [ ] Home screen with quick actions
- [ ] Browse hub navigation
- [ ] Collections browse screen
- [ ] Basic hymn listing
- [ ] Search functionality

#### Week 5: Essential Browse Categories
- [ ] Authors browse screen
- [ ] Topics browse screen
- [ ] Tunes browse screen
- [ ] Meters browse screen
- [ ] Scripture browse screen

#### Week 6: Hymn Detail & Search
- [ ] Hymn detail screen
- [ ] Advanced search implementation
- [ ] Global search overlay
- [ ] Search history tracking
- [ ] Filter implementation

### Phase 3: User Features (Weeks 7-9)
**Goal**: Personal features and media handling

#### Week 7: Favorites & Recently Viewed
- [ ] Favorites system implementation
- [ ] Recently viewed tracking
- [ ] Favorites screen with management
- [ ] Recently viewed screen
- [ ] Bulk operations

#### Week 8: Media Download System
- [ ] Media storage architecture
- [ ] Download service implementation
- [ ] Progress tracking
- [ ] Download screen
- [ ] Media download sheet

#### Week 9: Audio & Media Playback
- [ ] Audio player integration
- [ ] MIDI file handling
- [ ] PDF viewer integration
- [ ] Media controls
- [ ] Playback history

### Phase 4: Polish & Testing (Weeks 10-12)
**Goal**: Performance optimization and testing

#### Week 10: Settings & Configuration
- [ ] Settings screen
- [ ] Theme customization
- [ ] Storage management
- [ ] App preferences
- [ ] About/help screens

#### Week 11: Performance & Offline
- [ ] Offline mode implementation
- [ ] Caching optimization
- [ ] Performance testing
- [ ] Memory management
- [ ] Battery optimization

#### Week 12: Testing & Deployment
- [ ] Unit tests for core logic
- [ ] Widget tests for UI
- [ ] Integration tests
- [ ] Platform-specific testing
- [ ] App store preparation

## 🗄️ Database Implementation

### SQLite Schema
```sql
-- Core hymns table
CREATE TABLE hymns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hymn_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    author_id INTEGER,
    composer_id INTEGER,
    tune_name TEXT,
    meter TEXT,
    collection_id INTEGER,
    lyrics TEXT,
    theme_tags TEXT, -- JSON array
    scripture_refs TEXT, -- JSON array
    first_line TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(id),
    FOREIGN KEY (composer_id) REFERENCES composers(id),
    FOREIGN KEY (collection_id) REFERENCES collections(id)
);

-- Authors table
CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    birth_year INTEGER,
    death_year INTEGER,
    nationality TEXT,
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Collections table
CREATE TABLE collections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    abbreviation TEXT NOT NULL,
    year INTEGER,
    language TEXT DEFAULT 'English',
    total_hymns INTEGER DEFAULT 0,
    color_hex TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Favorites table
CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hymn_id INTEGER NOT NULL,
    user_id TEXT DEFAULT 'default',
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    play_count INTEGER DEFAULT 0,
    last_played TIMESTAMP,
    FOREIGN KEY (hymn_id) REFERENCES hymns(id),
    UNIQUE(hymn_id, user_id)
);

-- Recently viewed table
CREATE TABLE recently_viewed (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hymn_id INTEGER NOT NULL,
    user_id TEXT DEFAULT 'default',
    last_viewed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    view_count INTEGER DEFAULT 1,
    session_duration INTEGER DEFAULT 0,
    FOREIGN KEY (hymn_id) REFERENCES hymns(id),
    UNIQUE(hymn_id, user_id)
);

-- Download cache table
CREATE TABLE download_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hymn_id INTEGER NOT NULL,
    file_type TEXT NOT NULL, -- 'audio', 'midi', 'pdf', 'image'
    file_path TEXT NOT NULL,
    file_size INTEGER,
    quality TEXT,
    download_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_offline_available BOOLEAN DEFAULT 1,
    FOREIGN KEY (hymn_id) REFERENCES hymns(id)
);

-- Topics table
CREATE TABLE topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT, -- 'worship', 'seasonal', 'theological', etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hymn-topic mapping
CREATE TABLE hymn_topics (
    hymn_id INTEGER NOT NULL,
    topic_id INTEGER NOT NULL,
    PRIMARY KEY (hymn_id, topic_id),
    FOREIGN KEY (hymn_id) REFERENCES hymns(id),
    FOREIGN KEY (topic_id) REFERENCES topics(id)
);

-- Search history
CREATE TABLE search_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    query TEXT NOT NULL,
    result_count INTEGER DEFAULT 0,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id TEXT DEFAULT 'default'
);
```

## 📂 File Storage Architecture

### Directory Structure
```
/app_documents/
├── database/
│   └── hymns.db
├── media/
│   ├── audio/
│   │   └── {hymn_id}/
│   │       ├── high_quality.mp3
│   │       ├── standard_quality.mp3
│   │       └── low_quality.mp3
│   ├── midi/
│   │   └── {hymn_id}/
│   │       ├── full_arrangement.mid
│   │       └── melody_only.mid
│   ├── images/
│   │   └── {hymn_id}/
│   │       ├── sheet_music.jpg
│   │       └── hymnal_page.png
│   └── pdf/
│       └── {hymn_id}/
│           ├── full_score.pdf
│           └── lyrics_only.pdf
├── cache/
│   ├── thumbnails/
│   └── temp_downloads/
└── user_data/
    ├── favorites_backup.json
    └── app_settings.json
```

## 🔧 Key Implementation Details

### State Management Architecture
```dart
// Main Provider Classes
class HymnProvider extends ChangeNotifier {
  List<Hymn> _hymns = [];
  List<Hymn> _searchResults = [];
  bool _isLoading = false;
  
  // Core hymn operations
  Future<void> loadHymns() async { ... }
  Future<void> searchHymns(String query) async { ... }
  Future<Hymn?> getHymnById(int id) async { ... }
}

class FavoritesProvider extends ChangeNotifier {
  List<Hymn> _favorites = [];
  
  Future<void> addToFavorites(Hymn hymn) async { ... }
  Future<void> removeFromFavorites(int hymnId) async { ... }
  bool isFavorite(int hymnId) { ... }
}

class RecentlyViewedProvider extends ChangeNotifier {
  List<RecentHymn> _recentlyViewed = [];
  
  Future<void> addToRecentlyViewed(Hymn hymn) async { ... }
  Future<void> clearHistory() async { ... }
}

class DownloadProvider extends ChangeNotifier {
  Map<int, DownloadProgress> _downloads = {};
  
  Future<void> downloadMedia(int hymnId, MediaType type) async { ... }
  Future<void> pauseDownload(int hymnId) async { ... }
  bool isDownloaded(int hymnId, MediaType type) { ... }
}
```

### Database Helper Implementation
```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final documentsPath = await getApplicationDocumentsDirectory();
    final path = join(documentsPath.path, 'hymns.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    // Execute all CREATE TABLE statements
    await db.execute('''CREATE TABLE hymns (...);''');
    await db.execute('''CREATE TABLE authors (...);''');
    // ... other tables
  }
  
  // CRUD operations
  Future<List<Hymn>> getHymns() async { ... }
  Future<List<Hymn>> searchHymns(String query) async { ... }
  Future<void> addFavorite(int hymnId) async { ... }
  Future<List<Hymn>> getFavorites() async { ... }
}
```

### Media Storage Manager
```dart
class MediaStorageManager {
  static const String _mediaFolder = 'media';
  
  Future<String> getAppDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  Future<String> downloadAudio(int hymnId, AudioQuality quality) async {
    final documentsPath = await getAppDocumentsPath();
    final audioPath = '$documentsPath/$_mediaFolder/audio/$hymnId/';
    
    // Create directory if it doesn't exist
    await Directory(audioPath).create(recursive: true);
    
    // Download file from API
    final fileName = '${quality.name}_quality.mp3';
    final filePath = '$audioPath$fileName';
    
    // Use dio to download file
    await _downloadFile(apiUrl, filePath);
    
    // Update database cache record
    await DatabaseHelper.instance.addDownloadCache(
      hymnId, 'audio', filePath, quality.name
    );
    
    return filePath;
  }
  
  Future<bool> isMediaAvailableOffline(int hymnId, MediaType type) async {
    final file = await _getMediaFile(hymnId, type);
    return file != null && await file.exists();
  }
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
// Database tests
test('should insert and retrieve hymn correctly', () async {
  final hymn = Hymn(title: 'Amazing Grace', author: 'John Newton');
  await DatabaseHelper.instance.insertHymn(hymn);
  
  final retrieved = await DatabaseHelper.instance.getHymnById(hymn.id);
  expect(retrieved?.title, equals('Amazing Grace'));
});

// Provider tests
test('should add hymn to favorites', () async {
  final provider = FavoritesProvider();
  final hymn = Hymn(id: 1, title: 'Test Hymn');
  
  await provider.addToFavorites(hymn);
  expect(provider.isFavorite(1), isTrue);
});
```

### Widget Tests
```dart
testWidgets('should display hymn list correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HymnListScreen(hymns: testHymns),
    ),
  );
  
  expect(find.text('Amazing Grace'), findsOneWidget);
  expect(find.byType(HymnCard), findsNWidgets(testHymns.length));
});
```

### Integration Tests
```dart
testWidgets('should complete search flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap search tab
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();
  
  // Enter search query
  await tester.enterText(find.byType(TextField), 'Amazing Grace');
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
  
  // Verify results
  expect(find.text('Amazing Grace'), findsWidgets);
});
```

## 📦 Dependencies Configuration

### pubspec.yaml
```yaml
name: advent_hymnals
description: A comprehensive hymnal mobile app
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Network
  dio: ^5.3.2
  connectivity_plus: ^4.0.2
  
  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Audio/Media
  audioplayers: ^5.2.1
  flutter_pdfview: ^1.3.2
  
  # UI
  material_symbols_icons: ^4.2719.3
  cached_network_image: ^3.3.0
  
  # Navigation
  go_router: ^12.1.1
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## 🚀 Deployment Preparation

### Android Configuration
```yaml
# android/app/build.gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

### iOS Configuration
```yaml
# ios/Runner/Info.plist
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice search</string>
<key>NSDocumentUsageDescription</key>
<string>This app needs document access to save hymn media files</string>
```

## 📊 Performance Targets

### App Performance
- **Cold start time**: < 3 seconds
- **Screen transition**: < 300ms
- **Search response**: < 500ms
- **Database query**: < 100ms
- **Memory usage**: < 150MB

### Storage Targets
- **App size**: < 50MB
- **Database size**: ~10MB (for 892 hymns)
- **Cache limit**: 500MB (configurable)
- **Offline hymns**: 100+ hymns cached

## 🔍 Quality Assurance

### Code Quality
- **Test coverage**: > 80%
- **Code review**: All PRs reviewed
- **Linting**: Flutter lints + custom rules
- **Performance**: Profile builds tested

### User Experience
- **Accessibility**: Screen reader support
- **Offline mode**: Core features available
- **Error handling**: Graceful degradation
- **Loading states**: Clear user feedback

## 📈 Success Metrics

### User Engagement
- **Daily active users**: Track usage patterns
- **Feature adoption**: Monitor favorites, downloads
- **Session duration**: Average time spent
- **Search success rate**: Query to result ratio

### Technical Metrics
- **App crashes**: < 1% crash rate
- **API response time**: < 2 seconds
- **Database performance**: < 100ms queries
- **Battery usage**: Optimized for long sessions

## 🎯 MVP Definition

### Core Features (Must Have)
- [ ] Browse hymns by collections, authors, topics
- [ ] Search functionality with filters
- [ ] Favorites system
- [ ] Recently viewed tracking
- [ ] Basic media download
- [ ] Offline hymn viewing

### Enhanced Features (Should Have)
- [ ] Audio playback
- [ ] MIDI file support
- [ ] PDF viewing
- [ ] Global search
- [ ] Settings screen

### Advanced Features (Nice to Have)
- [ ] Voice search
- [ ] Playlist creation
- [ ] Social sharing
- [ ] Advanced filters
- [ ] Personalization

This implementation plan provides a systematic approach to building the Advent Hymnals mobile app with clear milestones, technical architecture, and quality standards.