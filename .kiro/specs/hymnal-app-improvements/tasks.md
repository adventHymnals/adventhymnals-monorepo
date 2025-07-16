# Implementation Plan

- [x] 1. Fix critical navigation and display issues





  - Implement home button fix in hymn detail screen
  - Fix recent songs display on home screen
  - Add back buttons to search, favorites, and browse screens
  - _Requirements: 2.3, 4.1, 4.2, 4.3, 5.1, 5.2_

- [x] 1.1 Fix home button navigation in HymnDetailScreen


  - Modify `_buildBackButton()` method to use `context.go('/')` instead of `Navigator.pop()`
  - Add error handling for navigation failures
  - Test navigation from hymn detail screen to home screen
  - _Requirements: 2.3_

- [x] 1.2 Debug and fix recent songs display issue


  - Investigate `RecentlyViewedProvider.addRecentlyViewed()` method
  - Add debug logging to track when hymns are added to recent list
  - Verify database persistence and loading in `loadRecentlyViewed()` method
  - Test recent songs display on home screen after viewing hymns
  - _Requirements: 5.1, 5.2, 5.3_

- [x] 1.3 Add back buttons to navigation screens


  - Add back button to SearchScreen AppBar that navigates to home
  - Add back button to FavoritesScreen AppBar that navigates to home
  - Add back button to BrowseHubScreen AppBar that navigates to home
  - Ensure consistent back button styling across all screens
  - _Requirements: 4.1, 4.2, 4.3_

- [x] 2. Optimize hymn detail screen header and display





  - Remove redundant scrollable header element
  - Update AppBar to show hymnal abbreviation, number, and title
  - Enhance verse display with proper labeling
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2, 3.3, 3.4_

- [x] 2.1 Implement optimized hymn detail header











  - Remove `_buildHeader()` widget from HymnDetailScreen
  - Modify AppBar title to display hymnal abbreviation, hymn number, and title in compact format
  - Update header styling to fit all information in top bar
  - Test header display with various hymn titles and hymnal abbreviations
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 2.2 Create lyrics parser for structured verse display


  - Create `LyricsParser` class to parse hymn lyrics into structured sections
  - Implement `LyricsSection` model with type, number, content, and repeat properties
  - Add logic to detect verses, choruses, and bridges from lyrics text
  - Write unit tests for lyrics parsing with various hymn formats
  - _Requirements: 3.1, 3.4_

- [x] 2.3 Enhance verse display with proper labeling and chorus placement


  - Update `_buildLyricsContent()` to use structured lyrics from parser
  - Display labels for all verses (Verse 1, Verse 2, etc.) not just first verse
  - Implement chorus placement logic to show chorus after each stanza when appropriate
  - Handle multiple choruses and special placement rules
  - _Requirements: 3.1, 3.2, 3.3, 3.4_
-


- [x] 3. Implement swipe navigation in hymn detail screen

  - Add horizontal swipe gesture detection
  - Implement next/previous hymn navigation within collections
  - Handle edge cases for first and last hymns
  - _Requirements: 2.1, 2.2, 2.4_

- [x] 3.1 Add swipe gesture detection to HymnDetailScreen
  - Wrap main content in `GestureDetector` with `onHorizontalDragEnd` handler
  - Implement swipe velocity detection to distinguish left/right swipes
  - Add visual feedback for swipe gestures (optional animation or haptic feedback)
  - Test gesture sensitivity and responsiveness
  - _Requirements: 2.1, 2.2_

- [x] 3.2 Implement hymn navigation logic within collections
  - Create methods `_navigateToNextHymn()` and `_navigateToPreviousHymn()`
  - Determine current hymnal collection from hymn context
  - Find adjacent hymns within the same collection using hymn numbers
  - Navigate to next/previous hymn using proper routing with collection context
  - _Requirements: 2.1, 2.2_

- [x] 3.3 Handle navigation edge cases and user feedback
  - Detect when user is at first or last hymn in collection
  - Show appropriate feedback when no more hymns available in direction
  - Prevent navigation beyond collection boundaries
  - Add visual indicators for navigation availability
  - _Requirements: 2.4_
-

- [x] 4. Enhance search functionality with hymnal filtering

  - Implement hymnal abbreviation detection in search queries
  - Add hymnal-specific filtering capabilities
  - Create search query parser for "sdah 125" style searches
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 4.1 Create search query parser for hymnal filtering
  - Implement `SearchQueryParser` class to analyze search input
  - Add hymnal abbreviation detection for common abbreviations (sdah, ch1941, etc.)
  - Extract hymn numbers from queries like "sdah 125"
  - Create `SearchQuery` model to represent parsed search parameters
  - _Requirements: 6.1, 6.2, 6.3_

- [x] 4.2 Implement hymnal-specific search filtering
  - Modify `HymnProvider.searchHymns()` to accept hymnal filter parameter
  - Update search logic to filter results by specified hymnal when detected
  - Add database queries that filter by collection/hymnal ID
  - Test search accuracy with hymnal-specific queries
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 4.3 Update search UI to show active hymnal filters
  - Display active hymnal filter chips in SearchScreen
  - Show clear indication when search is filtered to specific hymnal
  - Add ability to clear hymnal filters from search interface
  - Show filtered results header to indicate filtered results count
  - _Requirements: 6.5_

- [x] 5. Implement browse collections sorting with persistence

  - Add sorting options for browse collections screen
  - Implement local storage for user sorting preferences
  - Apply saved sorting preference on app startup
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 5.1 Create collection sorting service and preferences
  - Implement `CollectionSortingService` with sorting options (title, year, language, etc.)
  - Add `SharedPreferences` integration for saving user sort preferences
  - Create `CollectionSortBy` enum with available sorting options
  - Implement methods to save and load sorting preferences
  - _Requirements: 7.3, 7.4, 7.5_

- [x] 5.2 Add sorting UI to browse collections screen
  - Add sorting dropdown or menu to BrowseHubScreen
  - Display current sorting option in UI
  - Implement sorting option selection with immediate visual feedback
  - Apply sorting to collections list when user changes preference
  - _Requirements: 7.1, 7.2_

- [x] 5.3 Implement collection sorting logic and persistence
  - Add sorting methods to handle different sort criteria
  - Save user sorting preference when changed
  - Load saved sorting preference on app startup
  - Test sorting functionality with various collection data
  - _Requirements: 7.2, 7.3, 7.4, 7.5_

- [x] 6. Re-enable Windows audio playback functionality

  - Investigate current Windows audio implementation issues
  - Fix audio playback controls and file handling on Windows
  - Test audio functionality across Windows versions
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 6.1 Diagnose Windows audio playback issues
  - Investigate current `AudioPlayerProvider` implementation on Windows
  - Check audio file format support and codec availability
  - Identify specific Windows audio initialization problems
  - Document current audio playback failure points
  - _Requirements: 8.1, 8.4_

- [x] 6.2 Implement Windows-specific audio service
  - Create `WindowsAudioService` class for platform-specific audio handling
  - Add Windows audio session initialization and configuration
  - Implement proper audio file loading and playback for Windows
  - Add Windows-specific error handling for audio operations
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 6.3 Update audio player provider for Windows compatibility
  - Modify `AudioPlayerProvider` to use Windows audio service when on Windows platform
  - Add conditional audio initialization based on platform detection
  - Implement Windows-specific audio controls (play, pause, stop, volume)
  - Test audio playback functionality on Windows with various hymn audio files
  - _Requirements: 8.1, 8.2, 8.3, 8.5_

- [ ] 7. Enhance projector mode with separate presentation window

  - Implement platform channels for secondary window creation
  - Create separate projector presentation window on desktop platforms
  - Maintain control window for navigation and settings
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 7.1 Create platform channel for secondary window management
  - Implement `ProjectorWindowService` with method channel communication
  - Add platform-specific code for Windows and Linux window creation
  - Create methods for opening, closing, and positioning secondary windows
  - Add monitor detection and secondary display targeting
  - _Requirements: 9.1, 9.4, 9.5_

- [ ] 7.2 Implement separate projector presentation window
  - Create dedicated projector display screen/widget for presentation content
  - Implement window management to open projector content in secondary window
  - Add fullscreen mode support for projector presentation
  - Ensure projector window displays hymn content independently from control window
  - _Requirements: 9.1, 9.2, 9.4_


- [ ] 7.3 Maintain control window functionality during projection
  - Keep original control window active for navigation and hymn selection
- [-] 8. Weitn cotpr hecsive oemts for allunewtfunctionality
between control window and projector window
  - Update projector content when user changes hymns or verses in control window
  - Add projector-specific controls in main app interface
  - _Requirements: 9.2, 9.3_

- [ ] 8. Write comprehensive tests for all new functionality

  - Create unit tests for lyrics parsing and search query parsing
  - Write integration tests for navigation flows and audio playback
  - Add widget tests for UI components and gesture detection
  - _Requirements: All requirements - testing coverage_

- [ ] 8.1 Write unit tests for core parsing and logic components
  - Test `LyricsParser` with various hymn formats and edge cases
  - Test `SearchQueryParser` for hymnal detection and number extraction
  - Test collection sorting logic with different sort criteria
  - Test navigation logic for next/previous hymn calculation
  - _Requirements: 3.1, 3.4, 6.1, 6.2, 6.3, 7.1, 7.2_

- [ ] 8.2 Create integration tests for user workflows
  - Test complete search workflow with hymnal filtering
  - Test hymn detail navigation flow including swipe gestures
  - Test recent songs functionality from viewing to home display
  - Test audio playback workflow on Windows platform
  - _Requirements: 2.1, 2.2, 5.1, 5.2, 6.1, 6.2, 8.1, 8.2, 8.3_

- [ ] 8.3 Add widget tests for UI components and interactions
  - Test HymnDetailScreen header display and gesture detection
  - Test SearchScreen filter UI and result display
  - Test HomeScreen recent songs and collection sorting display
  - Test back button functionality across all affected screens
  - _Requirements: 1.1, 1.2, 1.3, 4.1, 4.2, 4.3, 6.5, 7.1, 7.2_