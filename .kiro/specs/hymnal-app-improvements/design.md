# Design Document

## Overview

This design document outlines the technical approach for implementing multiple improvements and bug fixes to the Advent Hymnals mobile application. The improvements focus on enhancing user experience through better navigation, display optimization, search functionality, and platform-specific features.

The application is built using Flutter with a clean architecture pattern, utilizing Provider for state management and Go Router for navigation. The current structure includes presentation layers, domain entities, core services, and data management components.

## Architecture

### Current Architecture Analysis

The app follows a layered architecture:
- **Presentation Layer**: Screens, widgets, and providers for state management
- **Domain Layer**: Business entities (Hymn, Collection)
- **Core Layer**: Services, data managers, and utilities
- **Data Layer**: Local database and JSON file management

### Key Components Affected

1. **HymnDetailScreen**: Primary screen requiring header optimization and navigation enhancements
2. **HomeScreen**: Needs recent songs display fix and navigation improvements
3. **SearchScreen**: Requires enhanced filtering and hymnal-specific search
4. **Navigation System**: Go Router configuration for back button functionality
5. **ProjectorService**: Needs enhancement for separate window functionality
6. **AudioPlayerProvider**: Windows audio playback re-enablement

## Components and Interfaces

### 1. Hymn Detail Screen Header Optimization

**Component**: `HymnDetailScreen`
**File**: `lib/presentation/screens/hymn_detail_screen.dart`

**Current Implementation Issues**:
- Header shows redundant information in scrollable section
- Top bar only displays hymn title
- Scrollable header element duplicates information

**Design Changes**:
```dart
// New AppBar structure
AppBar(
  title: Row(
    children: [
      Text(hymnalAbbreviation), // e.g., "SDAH"
      SizedBox(width: 8),
      Text("#${hymnNumber}"), // e.g., "#123"
      SizedBox(width: 8),
      Expanded(child: Text(hymnTitle)),
    ],
  ),
  // Remove existing _buildHeader() widget
)
```

**Interface Changes**:
- Remove `_buildHeader()` method
- Modify AppBar title to include hymnal abbreviation and number
- Update layout to eliminate redundant information display

### 2. Hymn Detail Navigation Enhancement

**Component**: `HymnDetailScreen` with gesture detection
**Dependencies**: `HymnProvider`, navigation context

**Design Approach**:
```dart
// Wrap main content in GestureDetector
GestureDetector(
  onHorizontalDragEnd: (DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Swipe right - previous hymn
      _navigateToPreviousHymn();
    } else if (details.primaryVelocity! < 0) {
      // Swipe left - next hymn
      _navigateToNextHymn();
    }
  },
  child: // existing content
)
```

**Navigation Logic**:
- Determine current hymnal collection
- Find adjacent hymns within the same collection
- Handle edge cases (first/last hymn)
- Provide user feedback for navigation limits

**Home Button Fix**:
- Investigate current `_buildBackButton()` implementation
- Ensure proper context.go('/') navigation
- Add error handling for navigation failures

### 3. Verse Display Enhancement

**Component**: `_buildLyricsContent()` method in `HymnDetailScreen`

**Current Issues**:
- Only "Verse 1" label is shown
- Chorus placement logic missing
- Verse parsing needs improvement

**Design Solution**:
```dart
class LyricsParser {
  static List<LyricsSection> parseLyrics(String lyrics) {
    // Parse lyrics into structured sections
    // Identify verses, choruses, bridges
    // Return ordered list with proper labels
  }
}

class LyricsSection {
  final String type; // "verse", "chorus", "bridge"
  final int number; // verse number
  final String content;
  final bool repeatAfterVerse; // for chorus placement
}
```

**Chorus Placement Logic**:
- Detect single vs. multiple choruses
- Insert chorus after each verse when appropriate
- Handle special cases (chorus only after certain verses)

### 4. Navigation Back Button Implementation

**Component**: Multiple screens requiring back buttons
**Files**: `search_screen.dart`, `favorites_screen.dart`, `browse_hub_screen.dart`

**Design Pattern**:
```dart
// Standardized back button implementation
Widget _buildBackButton() {
  return IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      // Always navigate to home, not just pop
      context.go('/');
    },
  );
}
```

**Implementation Strategy**:
- Add consistent back button to all specified screens
- Use `context.go('/')` instead of `Navigator.pop()`
- Ensure proper AppBar leading widget configuration

### 5. Recent Songs Display Fix

**Component**: `RecentlyViewedProvider` and `HomeScreen`
**File**: `lib/presentation/providers/recently_viewed_provider.dart`

**Current Issue Analysis**:
- Recent songs not appearing on home screen
- Possible data persistence or loading issues

**Design Solution**:
```dart
// Enhanced RecentlyViewedProvider
class RecentlyViewedProvider extends ChangeNotifier {
  Future<void> addRecentlyViewed(int hymnId) async {
    // Ensure proper database insertion
    // Trigger immediate UI update
    // Persist to local storage
    notifyListeners();
  }
  
  Future<void> loadRecentlyViewed({int limit = 5}) async {
    // Load from database with proper error handling
    // Update UI state
    notifyListeners();
  }
}
```

**Home Screen Integration**:
- Ensure provider is properly initialized
- Add debug logging for troubleshooting
- Implement fallback UI states

### 6. Enhanced Search Functionality

**Component**: `SearchScreen` and `HymnProvider`
**Files**: `search_screen.dart`, `hymn_provider.dart`

**Hymnal Filtering Logic**:
```dart
class SearchQueryParser {
  static SearchQuery parseQuery(String input) {
    final words = input.trim().split(' ');
    final firstWord = words.first.toLowerCase();
    
    // Check if first word matches hymnal abbreviation
    final hymnalAbbrev = _getHymnalAbbreviation(firstWord);
    if (hymnalAbbrev != null) {
      return SearchQuery(
        hymnal: hymnalAbbrev,
        query: words.skip(1).join(' '),
        hymnNumber: _extractNumber(words),
      );
    }
    
    return SearchQuery(query: input);
  }
}
```

**Search Enhancement Features**:
- Hymnal abbreviation detection ("sdah", "ch1941", etc.)
- Number extraction for specific hymn lookup
- Filtered search results by hymnal
- Clear indication of active filters

### 7. Browse Collections Sorting

**Component**: `BrowseHubScreen` and collections management
**Dependencies**: Local storage for preferences

**Sorting Implementation**:
```dart
enum CollectionSortBy {
  title,
  year,
  language,
  hymnCount,
  lastUsed,
}

class CollectionSortingService {
  static const String _sortPreferenceKey = 'collection_sort_preference';
  
  Future<CollectionSortBy> getSavedSortPreference() async {
    // Load from SharedPreferences
  }
  
  Future<void> saveSortPreference(CollectionSortBy sortBy) async {
    // Save to SharedPreferences
  }
  
  List<Collection> sortCollections(List<Collection> collections, CollectionSortBy sortBy) {
    // Apply sorting logic
  }
}
```

### 8. Windows Audio Playback

**Component**: `AudioPlayerProvider`
**File**: `lib/presentation/providers/audio_player_provider.dart`

**Platform-Specific Implementation**:
```dart
class WindowsAudioService {
  static bool get isSupported => Platform.isWindows;
  
  Future<void> initializeWindowsAudio() async {
    if (!isSupported) return;
    
    // Windows-specific audio initialization
    // Configure audio session
    // Set up media controls
  }
}
```

**Integration Strategy**:
- Conditional audio service initialization
- Windows-specific audio file handling
- Error handling for unsupported formats

### 9. Projector Mode Enhancement

**Component**: `ProjectorService` enhancement
**File**: `lib/core/services/projector_service.dart`

**Separate Window Implementation**:
```dart
class ProjectorWindowService {
  static const MethodChannel _channel = MethodChannel('projector_window');
  
  Future<void> openProjectorWindow() async {
    if (Platform.isWindows || Platform.isLinux) {
      await _channel.invokeMethod('openSecondaryWindow', {
        'title': 'Hymnal Projector',
        'fullscreen': true,
        'monitor': 'secondary',
      });
    }
  }
  
  Future<void> updateProjectorContent(ProjectorContent content) async {
    await _channel.invokeMethod('updateContent', content.toJson());
  }
}
```

**Platform Channel Requirements**:
- Windows: Win32 API for window management
- Linux: GTK window creation
- Monitor detection and positioning

## Data Models

### Enhanced Hymn Model

```dart
class Hymn {
  // Existing fields...
  
  // New fields for enhanced functionality
  final String? hymnalAbbreviation;
  final List<LyricsSection>? structuredLyrics;
  final bool hasAudio;
  final String? audioPath;
  
  // Navigation helpers
  int? get nextHymnNumber;
  int? get previousHymnNumber;
}
```

### Search Query Model

```dart
class SearchQuery {
  final String query;
  final String? hymnal;
  final int? hymnNumber;
  final List<String> filters;
  
  bool get isHymnalSpecific => hymnal != null;
  bool get isNumberSearch => hymnNumber != null;
}
```

### Projector Content Model

```dart
class ProjectorContent {
  final String hymnTitle;
  final String hymnNumber;
  final String hymnalName;
  final LyricsSection currentSection;
  final ProjectorSettings settings;
  
  Map<String, dynamic> toJson();
}
```

## Error Handling

### Navigation Error Handling

```dart
class NavigationErrorHandler {
  static void handleNavigationError(Object error, StackTrace stackTrace) {
    // Log error
    // Show user-friendly message
    // Fallback to home screen
  }
}
```

### Audio Playback Error Handling

```dart
class AudioErrorHandler {
  static void handleAudioError(AudioError error) {
    switch (error.type) {
      case AudioErrorType.fileNotFound:
        // Show "Audio not available" message
        break;
      case AudioErrorType.platformNotSupported:
        // Show platform-specific message
        break;
      case AudioErrorType.permissionDenied:
        // Request permissions
        break;
    }
  }
}
```

## Testing Strategy

### Unit Tests

1. **LyricsParser Tests**
   - Verse detection and labeling
   - Chorus placement logic
   - Edge cases (no verses, chorus only)

2. **SearchQueryParser Tests**
   - Hymnal abbreviation detection
   - Number extraction
   - Query parsing accuracy

3. **Navigation Logic Tests**
   - Next/previous hymn calculation
   - Edge case handling
   - Collection boundary detection

### Integration Tests

1. **Search Functionality**
   - End-to-end search flow
   - Filter application
   - Result accuracy

2. **Navigation Flow**
   - Screen transitions
   - Back button functionality
   - Swipe gesture recognition

3. **Audio Playback**
   - Platform-specific playback
   - Error handling
   - State management

### Widget Tests

1. **HymnDetailScreen**
   - Header display optimization
   - Verse rendering
   - Gesture detection

2. **SearchScreen**
   - Filter UI components
   - Result display
   - Empty states

3. **HomeScreen**
   - Recent songs display
   - Collection sorting
   - Quick actions

## Performance Considerations

### Memory Management

- Efficient lyrics parsing and caching
- Proper disposal of audio resources
- Gesture detector optimization

### Database Optimization

- Indexed search queries
- Efficient recent songs tracking
- Batch operations for favorites

### UI Responsiveness

- Asynchronous data loading
- Progressive rendering for large hymn lists
- Smooth gesture animations

## Platform-Specific Considerations

### Windows

- Audio codec support
- Window management APIs
- File system permissions

### Linux

- GTK integration for projector windows
- Audio system compatibility
- Desktop environment considerations

### Mobile Platforms

- Gesture sensitivity tuning
- Battery optimization for audio playback
- Memory constraints for large collections

## Migration Strategy

### Phase 1: Core Fixes
- Home button navigation fix
- Recent songs display fix
- Basic back button implementation

### Phase 2: Display Enhancements
- Hymn detail header optimization
- Verse display improvements
- Search filtering enhancements

### Phase 3: Advanced Features
- Swipe navigation
- Windows audio re-enablement
- Collection sorting with persistence

### Phase 4: Projector Mode
- Separate window implementation
- Platform-specific optimizations
- Advanced projector controls

## Security Considerations

- Audio file access permissions
- Local storage data protection
- Platform channel security validation
- User preference data encryption