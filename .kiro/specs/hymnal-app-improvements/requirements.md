# Requirements Document

## Introduction

This feature encompasses multiple improvements and bug fixes for the Advent Hymnals mobile application to enhance user experience, navigation, and functionality. The improvements focus on better hymn detail display, navigation enhancements, search functionality, audio features, and projector mode capabilities.

## Requirements

### Requirement 1: Hymn Detail Screen Header Optimization

**User Story:** As a user viewing a hymn, I want to see the hymnal abbreviation, number, and title in the top bar so that I have consistent access to key hymn information without redundant display elements.

#### Acceptance Criteria

1. WHEN a user opens a hymn detail screen THEN the top bar SHALL display hymnal abbreviated name, hymn number, and hymn title
2. WHEN the hymn detail screen loads THEN the scrollable top element containing song number, title, and hymnal SHALL be removed
3. WHEN a user scrolls through the hymn content THEN the top bar information SHALL remain visible and fixed

### Requirement 2: Hymn Detail Screen Navigation

**User Story:** As a user reading hymns, I want to navigate between hymns using swipe gestures and have a working home button so that I can efficiently browse through hymnals.

#### Acceptance Criteria

1. WHEN a user swipes left on the hymn detail screen THEN the system SHALL navigate to the next hymn in the current hymnal
2. WHEN a user swipes right on the hymn detail screen THEN the system SHALL navigate to the previous hymn in the current hymnal
3. WHEN a user clicks the home button from the hymn detail screen THEN the system SHALL navigate back to the home screen
4. WHEN reaching the first or last hymn in a hymnal THEN the system SHALL provide appropriate feedback and prevent further navigation in that direction

### Requirement 3: Verse Display Enhancement

**User Story:** As a user singing hymns, I want to see all verse labels (Verse 1, Verse 2, etc.) and have choruses displayed after each stanza so that I can follow the song structure properly.

#### Acceptance Criteria

1. WHEN a hymn has multiple verses THEN the system SHALL display labels for all verses (Verse 1, Verse 2, Verse 3, etc.)
2. WHEN a hymn has a single chorus THEN the system SHALL display the chorus after every stanza
3. WHEN a hymn has multiple choruses THEN the system SHALL display each chorus in its appropriate position within the song structure
4. WHEN displaying verse labels THEN the system SHALL use consistent formatting and styling

### Requirement 4: Navigation Back Button Implementation

**User Story:** As a user navigating through the app, I want back buttons on search, favourite, and browse screens so that I can easily return to the home screen.

#### Acceptance Criteria

1. WHEN a user is on the search screen THEN the system SHALL display a back button that navigates to the home screen
2. WHEN a user is on the favourite screen THEN the system SHALL display a back button that navigates to the home screen
3. WHEN a user is on the browse screen THEN the system SHALL display a back button that navigates to the home screen
4. WHEN a user clicks any back button THEN the system SHALL immediately navigate to the home screen

### Requirement 5: Recent Songs Display Fix

**User Story:** As a user who has viewed hymns, I want to see my recently accessed songs on the home screen so that I can quickly return to songs I've been using.

#### Acceptance Criteria

1. WHEN a user views a hymn THEN the system SHALL add that hymn to the recent songs list
2. WHEN a user returns to the home screen THEN the system SHALL display the recent songs section with recently viewed hymns
3. WHEN the recent songs list exceeds the display limit THEN the system SHALL show the most recently accessed hymns first
4. WHEN a user clicks on a recent song THEN the system SHALL navigate to that hymn's detail screen

### Requirement 6: Enhanced Search Functionality

**User Story:** As a user searching for hymns, I want to filter by hymnal using abbreviations and search within specific hymnals so that I can quickly find songs from particular collections.

#### Acceptance Criteria

1. WHEN a user types a hymnal abbreviation (e.g., "sdah") THEN the system SHALL filter results to show only hymns from that hymnal
2. WHEN a user types a hymnal abbreviation followed by a number (e.g., "sdah 125") THEN the system SHALL search for that specific hymn number within that hymnal
3. WHEN the first word in the search query matches a hymnal shortform THEN the system SHALL automatically apply hymnal filtering
4. WHEN no hymnal abbreviation is detected THEN the system SHALL search across all hymnals
5. WHEN search results are filtered by hymnal THEN the system SHALL clearly indicate the active filter to the user

### Requirement 7: Browse Collections Sorting

**User Story:** As a user browsing hymn collections, I want to sort by relevant fields and have my sorting preference saved so that the app remembers my preferred organization method.

#### Acceptance Criteria

1. WHEN a user is in the browse collections screen THEN the system SHALL provide sorting options for relevant fields (title, number, hymnal, etc.)
2. WHEN a user selects a sorting option THEN the system SHALL immediately apply that sorting to the displayed collections
3. WHEN a user selects a sorting preference THEN the system SHALL save that preference locally
4. WHEN the app is restarted THEN the system SHALL apply the previously saved sorting preference as the default
5. WHEN no previous sorting preference exists THEN the system SHALL use a sensible default sorting method

### Requirement 8: Audio Playback for Windows

**User Story:** As a Windows user, I want to play audio for hymns so that I can hear the melodies while viewing the lyrics.

#### Acceptance Criteria

1. WHEN a user is on Windows and a hymn has associated audio THEN the system SHALL display audio playback controls
2. WHEN a user clicks the play button on Windows THEN the system SHALL start playing the hymn audio
3. WHEN audio is playing on Windows THEN the system SHALL provide pause, stop, and volume controls
4. WHEN audio playback encounters an error on Windows THEN the system SHALL display an appropriate error message
5. WHEN a user navigates away from a hymn with playing audio THEN the system SHALL handle audio playback appropriately (pause or continue based on user preference)

### Requirement 9: Projector Mode Enhancement

**User Story:** As a user presenting hymns, I want projector mode to open a separate presentation window so that I can control the presentation from one window while displaying content on another screen.

#### Acceptance Criteria

1. WHEN a user activates projector mode THEN the system SHALL open a separate presentation window
2. WHEN the presentation window is open THEN the system SHALL maintain the original control window for navigation and control
3. WHEN content is changed in the control window THEN the system SHALL update the presentation window accordingly
4. WHEN the presentation window is closed THEN the system SHALL return to normal single-window mode
5. WHEN multiple displays are available THEN the system SHALL allow the user to choose which display to use for the presentation window