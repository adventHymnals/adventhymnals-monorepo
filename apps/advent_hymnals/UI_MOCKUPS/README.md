# Flutter Web App UI Mockups

This directory contains UI mockups for the Advent Hymnals Flutter web application, featuring a bottom tab navigation design with proper color schemes matching the existing web application.

## 🎨 Design Overview

### Navigation Pattern
- **Bottom Tab Navigation** with 5 primary tabs
- **Material 3 Design System** with custom Advent Hymnals color palette
- **Responsive layout** optimized for mobile and web

### Color Scheme
Based on the existing web application design:
- **Primary Blue**: `#1e3a8a` (Navigation header)
- **Secondary Blue**: `#0284c7` (Action buttons, active states)
- **Success Green**: `#16a34a` (Download success, completed states)
- **Warning Orange**: `#f59e0b` (Development mode, in-progress states)
- **Error Red**: `#dc2626` (Delete actions, failed states)
- **Purple**: `#7c3aed` (Storage, special features)
- **Background**: `#fefce8` (Warm cream background)

## 📱 Screen Mockups

### 1. Home Screen (`01_home_screen.svg/png`)
- **Features**: Welcome interface with quick actions
- **Components**: 
  - Development environment indicator
  - Search bar
  - Quick action cards (Browse, Projection)
  - Featured hymnals with media indicators
  - Recent activity feed
- **Navigation**: Home tab active (blue highlight)

### 2. Browse Screen (`02_browse_screen.svg/png`)
- **Features**: Hymnal collection browsing
- **Components**:
  - Filter/sort controls
  - Hymnal grid layout with color-coded covers
  - Language and collection filtering
  - "View All" expansion option
- **Navigation**: Browse tab active

### 3. Search Screen (`03_search_screen.svg/png`)
- **Features**: Advanced hymn search functionality
- **Components**:
  - Active search bar with query
  - Filter chips (Hymnal, Type, Author, Theme)
  - Search results with hymnal indicators
  - Media availability icons
  - Recent searches suggestions
- **Navigation**: Search tab active

### 4. Downloads Screen (`04_downloads_screen.svg/png`)
- **Features**: Media download management
- **Components**:
  - Download statistics dashboard
  - Active downloads with progress bars
  - Downloaded files list with actions
  - Storage management controls
  - Download queue management
- **Navigation**: Downloads tab active with badge indicator

### 5. Settings Screen (`05_settings_screen.svg/png`)
- **Features**: App configuration and preferences
- **Components**:
  - User profile section
  - Theme selection (Light/Dark toggles)
  - Download preferences
  - Storage location settings
  - General app settings
- **Navigation**: Settings tab active

### 6. Hymn Detail Screen (`06_hymn_detail_screen.svg/png`)
- **Features**: Individual hymn display and interaction
- **Components**:
  - Hymn metadata card
  - Full hymn text content
  - Media summary bar
  - Quick action chips for different media types
  - Projection mode access
- **Navigation**: Standard bottom tabs

### 7. Media Download Sheet (`07_media_download_sheet.svg/png`)
- **Features**: Modal bottom sheet for media downloads
- **Components**:
  - Tabbed interface (Audio, MIDI, Image, PDF, Video)
  - Download progress indicators
  - File management controls
  - Storage statistics
  - Batch download actions
- **Navigation**: Overlay modal design

## 🔧 Technical Specifications

### Screen Dimensions
- **Width**: 390px (iPhone 12 Pro standard)
- **Height**: 844px (Full screen with status bar)
- **Export Resolution**: 2x (1688px height for PNG)

### Typography
- **Primary Font**: Inter (Sans-serif) for UI elements
- **Secondary Font**: Crimson Text (Serif) for hymn content
- **Font Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Layout System
- **Grid**: 20px margins, 8px base spacing unit
- **Card Radius**: 12px for main cards, 8px for smaller elements
- **Button Radius**: 16px for action buttons, 20px for primary buttons

### Bottom Navigation
- **Tab Width**: 78px each (5 tabs = 390px total)
- **Tab Height**: 84px (including labels)
- **Active State**: Light blue background (`#eff6ff`) with blue icon
- **Inactive State**: Gray icons with labels

## 🎯 Key Features Highlighted

### Media Download System
- **Visual Progress**: Real-time download progress bars
- **Media Types**: Audio (MP3), MIDI, Images, PDF, Video support
- **Queue Management**: Download queue with priority handling
- **Storage Tracking**: Visual storage usage indicators

### Environment Awareness
- **Development Mode**: Orange indicator bar for localhost
- **API Integration**: Visual connection status indicators
- **Offline Support**: Downloaded content indicators

### Responsive Design
- **Mobile-First**: Optimized for mobile interaction
- **Touch-Friendly**: Adequate touch targets (minimum 44px)
- **Accessibility**: High contrast colors, readable text sizes

## 🚀 Implementation Notes

### Flutter Integration
- Use `BottomNavigationBar` widget for tab navigation
- Implement `TabBarView` for media download sheet
- Use `LinearProgressIndicator` for download progress
- Apply Material 3 `ColorScheme.fromSeed()` with custom colors

### State Management
- Provider pattern for download progress
- Stream controllers for real-time updates
- Local storage for offline content

### Performance Considerations
- Lazy loading for large hymnal collections
- Progressive image loading
- Background download processing
- Smart caching strategies

## 📁 File Structure

```
UI_MOCKUPS/
├── 01_home_screen.svg           # Vector source
├── 01_home_screen.png           # High-res export
├── 02_browse_screen.svg         # Vector source  
├── 02_browse_screen.png         # High-res export
├── 03_search_screen.svg         # Vector source
├── 03_search_screen.png         # High-res export
├── 04_downloads_screen.svg      # Vector source
├── 04_downloads_screen.png      # High-res export
├── 05_settings_screen.svg       # Vector source
├── 05_settings_screen.png       # High-res export
├── 06_hymn_detail_screen.svg    # Vector source
├── 06_hymn_detail_screen.png    # High-res export
├── 07_media_download_sheet.svg  # Vector source
├── 07_media_download_sheet.png  # High-res export
└── README.md                    # This file
```

## 🎨 Usage

### For Development
- Use SVG files for reference during development
- Extract color values and measurements from SVG source
- Use as specification for Flutter widget implementation

### For Presentation
- Use PNG files for presentations and documentation
- High-resolution suitable for display on various screens
- Maintain aspect ratio when scaling

### For Design Iteration
- Modify SVG files for design changes
- Regenerate PNG files after modifications
- Version control both SVG and PNG files

---

*Created for Advent Hymnals Flutter Web App • Design System v1.0*