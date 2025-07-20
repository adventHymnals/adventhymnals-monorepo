# 🧪 Advent Hymnals Mobile App - Comprehensive Testing Guide

This guide documents the critical functionality that needs to be tested across ALL screens, based on real issues encountered during development and user testing.

## 📋 **Testing Philosophy**

### **Focus Areas:**
1. **Navigation & State Management** - Ensure proper back navigation and state preservation
2. **Search Functionality** - Dynamic abbreviation recognition and filtering
3. **Database Integration** - Proper data loading and error handling
4. **User Interactions** - Sort, filter, and favorite operations
5. **Performance** - Loading states and error recovery
6. **UI Consistency** - Consistent styling and behavior across screens
7. **Error Recovery** - Graceful handling of edge cases and errors

---

## 🔍 **1. Search Screen Testing**

### **Core Search Functionality**
- [ ] **Basic Search**: Enter search terms and verify results appear
- [ ] **Empty Search**: Clear search and verify state resets properly
- [ ] **Search Loading**: Verify loading indicators during search
- [ ] **Search Errors**: Test error handling for database/network issues
- [ ] **Author Search**: Confirm author search is implemented and working

### **🚨 KNOWN ISSUES TO TEST:**

#### **Other Filters Dialog Issues:**
- [ ] **Checkbox State Bug**: When clicking "Other Filters", checkboxes should show current state
- [ ] **Multiple Selection**: Should be able to select multiple filters (favorites + hymns only)
- [ ] **Cancel Button Bug**: Clicking cancel should NOT preserve changes that weren't applied
- [ ] **Filter Application**: Selected filters should actually filter the results
- [ ] **Favorites Filter**: When selecting "favourites", list should show ONLY favorites, not whole list

#### **Collection Filter Issues:**
- [ ] **OrElse Type Error**: Fix `type '() => Map<String, dynamic>' is not a subtype of type '(() => Map<String, String>)?'`
- [ ] **Hymnal Abbreviation**: Test all abbreviations work in collection filtering

#### **Favorites + Search Issue:**
- [ ] **Favorites Only + Search**: "favourites only" + "19" should find SDAH 19 if it's in favorites
- [ ] **Combined Filters**: Test favorites filter combined with search terms

### **Dynamic Hymnal Abbreviation Recognition**
Test all hymnal abbreviations work correctly:

#### **🚨 CRITICAL: Test These Specific Cases:**
- [ ] `sdah` → SDAH (WORKING)
- [ ] `ch` → CH1941 (WORKING)
- [ ] `cs1900` → CS1900 (NOT WORKING - FIX NEEDED)
- [ ] `cs` → CS1900 (TEST NEEDED)
- [ ] `ht1869` → HT1869 (TEST NEEDED)
- [ ] `ht1876` → HT1876 (TEST NEEDED)
- [ ] `ht1886` → HT1886 (TEST NEEDED)
- [ ] `cm2000` → CM2000 (TEST NEEDED)
- [ ] `nzk` → NZK (TEST NEEDED)
- [ ] `wn` → WN (TEST NEEDED)

#### **Search Query Patterns:**
- [ ] `SDAH 125` → Find hymn 125 from SDAH
- [ ] `cs1900 50` → Find hymn 50 from CS1900
- [ ] `ch 200` → Find hymn 200 from CH1941
- [ ] `SDAH amazing grace` → Search "amazing grace" in SDAH
- [ ] `cs1900 holy` → Search "holy" in CS1900
- [ ] `SDAH` → Show all hymns from SDAH

### **Search Results & Sorting**
- [ ] **Result Count**: Verify accurate result counts displayed
- [ ] **Sort Options**: Test all sort options (relevance, title, author, number, hymnal)
- [ ] **Result Navigation**: Click results to navigate to hymn detail
- [ ] **Result Data**: Verify hymn number, title, author, collection info displayed

---

## ❤️ **2. Favorites Screen Testing**

### **Favorites Loading & Display**
- [ ] **Initial Load**: Verify favorites load on screen open
- [ ] **Empty State**: Test empty favorites display
- [ ] **Loading State**: Verify loading indicators
- [ ] **Error Handling**: Test database connection errors

### **Favorites Sorting (FIXED)**
- [ ] **Date Added (Newest First)**: Most recent favorites appear first
- [ ] **Date Added (Oldest First)**: Oldest favorites appear first
- [ ] **Title (A-Z)**: Alphabetical order by hymn title
- [ ] **Title (Z-A)**: Reverse alphabetical order
- [ ] **Author (A-Z)**: Alphabetical order by author name
- [ ] **Author (Z-A)**: Reverse alphabetical by author
- [ ] **Hymn Number (Low to High)**: Sorted by hymn number ascending
- [ ] **Hymn Number (High to Low)**: Sorted by hymn number descending

### **Favorites Management**
- [ ] **Add/Remove**: Heart icon toggles favorite status
- [ ] **Undo Remove**: Test undo functionality in snackbar
- [ ] **Clear All**: Remove all favorites with confirmation
- [ ] **Search Within Favorites**: Search box filters favorites

### **Navigation**
- [ ] **Back Button**: Returns to home screen
- [ ] **Hymn Detail**: Click favorite navigates to hymn detail
- [ ] **Navigation Context**: Verify `from=favorites` parameter

---

## 📚 **3. Collections Browse Screen Testing**

### **🚨 KNOWN ISSUES TO TEST:**

#### **Sort Dialog Issues:**
- [ ] **Title vs Alphabetical**: What's the difference? Should be clarified or merged
- [ ] **Sort Order Selection**: Need ascending/descending options for each sort type
- [ ] **Best Practice UI**: Research and implement better sort dialog UI
- [ ] **Apply to All Screens**: This sorting pattern should be consistent across all screens

### **Collections Loading & Display**
- [ ] **Initial Load**: All collections display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Collection Cards**: Proper display of collection info

### **Collections Filtering**
- [ ] **Language Filter**: Filter by language (English, Kiswahili, etc.)
- [ ] **Multiple Languages**: Select multiple languages
- [ ] **Clear Filters**: Remove all language filters

### **Collections Sorting (NEEDS IMPROVEMENT)**
Current sort options to test:
- [ ] **Title A-Z**: Alphabetical by collection name
- [ ] **Title Z-A**: Reverse alphabetical
- [ ] **Year (Oldest First)**: Chronological order
- [ ] **Year (Newest First)**: Reverse chronological
- [ ] **Language A-Z**: Alphabetical by language
- [ ] **Language Z-A**: Reverse alphabetical by language
- [ ] **Hymn Count (Fewest First)**: Ascending by hymn count
- [ ] **Hymn Count (Most First)**: Descending by hymn count
- [ ] **Abbreviation A-Z**: Alphabetical by abbreviation
- [ ] **Abbreviation Z-A**: Reverse alphabetical by abbreviation

### **Collections Navigation**
- [ ] **Collection Detail**: Click collection to view hymns
- [ ] **Back Navigation**: Return to collections list
- [ ] **Navigation Context**: Proper context preservation

---

## 🕒 **4. Recently Viewed Screen Testing**

### **🚨 KNOWN ISSUES TO TEST:**

#### **Navigation Issues:**
- [ ] **Missing Back Button**: Should have back button in app bar
- [ ] **Missing Bottom Nav**: Should have bottom navigation bar

#### **Favorites Integration:**
- [ ] **Favorite State Detection**: If hymn is in favorites, should NOT show "Add to favourites"
- [ ] **State Updates**: After adding to favorites, should update UI immediately
- [ ] **Visual Distinction**: Recently viewed items that are favorites should have visual indicator

#### **UI Consistency:**
- [ ] **Hymnal Number Container**: Should have same rounding as favorites screen, not fully rounded
- [ ] **Layout Consistency**: Should match favorites screen styling

### **Recently Viewed Functionality**
- [ ] **Loading**: Verify recently viewed items load properly
- [ ] **Chronological Order**: Items should be in last-viewed order
- [ ] **Item Limit**: Test handling of large recently viewed lists
- [ ] **Clear History**: If implemented, test clear functionality

### **Recently Viewed Interactions**
- [ ] **Hymn Navigation**: Click item to navigate to hymn detail
- [ ] **Favorite Toggle**: Add/remove from favorites
- [ ] **State Persistence**: Recently viewed should persist across app restarts

---

## 📖 **5. Hymn Detail Screen Testing**

### **🚨 KNOWN ISSUES TO TEST:**

#### **Layout Issues:**
- [ ] **Chorus Width Bug**: Hymns WITH chorus have full-width elements
- [ ] **No Chorus Width Bug**: Hymns WITHOUT chorus should also have full-width elements
- [ ] **Consistent Formatting**: All hymns should have consistent layout

#### **Fullscreen Mode:**
- [ ] **Hide Bottom Nav**: When going fullscreen, bottom navbar should be hidden
- [ ] **Fullscreen Toggle**: Should be able to enter/exit fullscreen mode
- [ ] **Fullscreen Controls**: Proper controls available in fullscreen

#### **Navigation Buttons (CRITICAL BUG):**
- [ ] **Back Button Disabled**: Back navigation buttons are disabled for all hymnals
- [ ] **Forward Button Disabled**: Forward navigation buttons are disabled for all hymnals
- [ ] **Collection Loading**: Error shows "Found 0 hymns in collection SDAH"
- [ ] **Abbreviation Matching**: Navigation may not be using proper abbreviation matching
- [ ] **Database vs JSON**: Check if navigation uses same data source as hymn loading

**Debug Info to Investigate:**
```
flutter: 🔍 [Navigation] _canNavigateToPrevious: current hymn 19, collection: SDAH
flutter: 🔍 [Navigation] Found 0 hymns in collection SDAH
flutter: 🔍 [Navigation] Current index: -1, can navigate previous: false
```

### **Hymn Loading & Display**
- [ ] **Direct Navigation**: Navigate via URL/route
- [ ] **Search Navigation**: Navigate from search results
- [ ] **Favorites Navigation**: Navigate from favorites
- [ ] **Collection Navigation**: Navigate from collection browsing
- [ ] **Basic Info**: Title, author, hymn number displayed
- [ ] **Collection Info**: Collection name and abbreviation
- [ ] **Lyrics Display**: Proper verse/chorus formatting
- [ ] **Metadata**: Composer, tune name, meter info

### **Hymn Interactions**
- [ ] **Favorite Toggle**: Heart icon toggles favorite status
- [ ] **Audio Playback**: Play/pause audio if available
- [ ] **Projector Mode**: Project hymn for display
- [ ] **Format Switching**: Switch between lyrics/sheet music
- [ ] **Share Functionality**: If implemented, test sharing

---

## 🏠 **6. Home Screen Testing**

### **Home Screen Layout**
- [ ] **Welcome Message**: Displays correctly
- [ ] **Quick Actions**: All navigation buttons functional
- [ ] **Recent Activity**: Shows recently viewed hymns
- [ ] **Favorites Preview**: Shows favorite hymns
- [ ] **Statistics**: Display current counts (if implemented)

### **Home Navigation**
- [ ] **Search Button**: Navigate to search screen
- [ ] **Browse Button**: Navigate to collections/browse hub
- [ ] **Favorites Button**: Navigate to favorites
- [ ] **Recently Viewed Button**: Navigate to recently viewed
- [ ] **More Button**: Navigate to more screen

### **Home Screen Data**
- [ ] **Dynamic Content**: Recently viewed updates dynamically
- [ ] **Favorites Count**: Accurate favorite count display
- [ ] **Performance**: Home screen loads quickly

---

## 🎯 **7. Browse Hub Screen Testing**

### **Browse Hub Layout**
- [ ] **Navigation Options**: All browse categories displayed
- [ ] **Category Icons**: Proper icons for each category
- [ ] **Category Descriptions**: Clear descriptions for each option

### **Browse Hub Navigation**
- [ ] **Collections**: Navigate to collections browse
- [ ] **Authors**: Navigate to authors browse
- [ ] **Topics**: Navigate to topics browse
- [ ] **First Lines**: Navigate to first lines browse
- [ ] **Scripture**: Navigate to scripture browse
- [ ] **Tunes**: Navigate to tunes browse
- [ ] **Meters**: Navigate to meters browse
- [ ] **Back Navigation**: Return to home screen

---

## 👤 **8. Authors Browse Screen Testing**

### **Authors Loading & Display**
- [ ] **Initial Load**: All authors display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Author Info**: Name, hymn count, other details

### **Authors Filtering & Sorting**
- [ ] **Search Authors**: Search functionality for authors
- [ ] **Alphabetical Sorting**: Sort authors alphabetically
- [ ] **Hymn Count Sorting**: Sort by number of hymns
- [ ] **Filter Options**: Filter by letter, etc.

### **Authors Navigation**
- [ ] **Author Detail**: Click author to view their hymns
- [ ] **Hymn Navigation**: Navigate to specific hymns
- [ ] **Back Navigation**: Return to browse hub

---

## 📚 **9. Topics Browse Screen Testing**

### **Topics Loading & Display**
- [ ] **Initial Load**: All topics display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Topic Categories**: Proper categorization of topics

### **Topics Filtering & Sorting**
- [ ] **Search Topics**: Search functionality for topics
- [ ] **Category Filtering**: Filter by topic category
- [ ] **Alphabetical Sorting**: Sort topics alphabetically
- [ ] **Hymn Count Sorting**: Sort by number of hymns per topic

### **Topics Navigation**
- [ ] **Topic Detail**: Click topic to view related hymns
- [ ] **Hymn Navigation**: Navigate to specific hymns
- [ ] **Back Navigation**: Return to browse hub

---

## 📝 **10. First Lines Browse Screen Testing**

### **First Lines Loading & Display**
- [ ] **Initial Load**: All first lines display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **First Line Text**: Proper display of first line text

### **First Lines Filtering & Sorting**
- [ ] **Search First Lines**: Search functionality for first lines
- [ ] **Alphabetical Sorting**: Sort first lines alphabetically
- [ ] **Collection Filtering**: Filter by collection
- [ ] **Quick Jump**: Jump to specific letters

### **First Lines Navigation**
- [ ] **Hymn Navigation**: Click first line to navigate to hymn
- [ ] **Back Navigation**: Return to browse hub

---

## 📖 **11. Scripture Browse Screen Testing**

### **Scripture Loading & Display**
- [ ] **Initial Load**: All scripture references display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Scripture Format**: Proper formatting of scripture references

### **Scripture Filtering & Sorting**
- [ ] **Search Scripture**: Search functionality for scripture
- [ ] **Book Filtering**: Filter by book of the Bible
- [ ] **Book Order**: Sort by biblical book order
- [ ] **Reference Sorting**: Sort by chapter and verse

### **Scripture Navigation**
- [ ] **Scripture Detail**: Click reference to view related hymns
- [ ] **Hymn Navigation**: Navigate to specific hymns
- [ ] **Back Navigation**: Return to browse hub

---

## 🎵 **12. Tunes Browse Screen Testing**

### **Tunes Loading & Display**
- [ ] **Initial Load**: All tunes display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Tune Information**: Name, meter, origin details

### **Tunes Filtering & Sorting**
- [ ] **Search Tunes**: Search functionality for tunes
- [ ] **Alphabetical Sorting**: Sort tunes alphabetically
- [ ] **Meter Filtering**: Filter by meter
- [ ] **Origin Filtering**: Filter by tune origin

### **Tunes Navigation**
- [ ] **Tune Detail**: Click tune to view related hymns
- [ ] **Hymn Navigation**: Navigate to specific hymns
- [ ] **Back Navigation**: Return to browse hub

---

## 📏 **13. Meters Browse Screen Testing**

### **Meters Loading & Display**
- [ ] **Initial Load**: All meters display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Meter Format**: Proper display of meter notation

### **Meters Filtering & Sorting**
- [ ] **Search Meters**: Search functionality for meters
- [ ] **Alphabetical Sorting**: Sort meters alphabetically
- [ ] **Hymn Count Sorting**: Sort by number of hymns per meter
- [ ] **Common Meters**: Filter by common meters

### **Meters Navigation**
- [ ] **Meter Detail**: Click meter to view related hymns
- [ ] **Hymn Navigation**: Navigate to specific hymns
- [ ] **Back Navigation**: Return to browse hub

---

## 📑 **14. Collection Detail Screen Testing**

### **Collection Detail Loading**
- [ ] **Initial Load**: Collection hymns display on load
- [ ] **Loading State**: Loading indicators during data fetch
- [ ] **Error Handling**: Network/database error handling
- [ ] **Collection Info**: Name, description, hymn count

### **Collection Detail Functionality**
- [ ] **Hymn List**: All hymns in collection displayed
- [ ] **Hymn Search**: Search within collection
- [ ] **Hymn Sorting**: Sort hymns within collection
- [ ] **Pagination**: Handle large collections efficiently

### **Collection Detail Navigation**
- [ ] **Hymn Detail**: Click hymn to view detail
- [ ] **Back Navigation**: Return to collections browse
- [ ] **Navigation Context**: Proper context preservation

---

## 🎵 **15. Player Screen Testing**

### **Audio Player Functionality**
- [ ] **Play/Pause**: Basic playback controls
- [ ] **Volume Control**: Volume adjustment
- [ ] **Seek Control**: Seek to specific position
- [ ] **Track Info**: Display current hymn info
- [ ] **Playlist**: Handle playlist of hymns

### **Player Navigation**
- [ ] **Previous/Next**: Navigate between hymns
- [ ] **Repeat Mode**: Toggle repeat options
- [ ] **Shuffle Mode**: Toggle shuffle if available
- [ ] **Back Navigation**: Return to previous screen

### **Player Integration**
- [ ] **Background Play**: Continue playing in background
- [ ] **Notification**: Media notification controls
- [ ] **Lock Screen**: Lock screen media controls

---

## 📺 **16. Projector Screen Testing**

### **Projector Functionality**
- [ ] **Display Mode**: Proper projection display
- [ ] **Verse Navigation**: Navigate between verses
- [ ] **Chorus Display**: Proper chorus handling
- [ ] **Text Size**: Adjustable text size
- [ ] **Background**: Proper background display

### **Projector Controls**
- [ ] **Previous/Next**: Navigate between hymns
- [ ] **Verse Controls**: Navigate between verses
- [ ] **Display Options**: Toggle metadata display
- [ ] **Fullscreen**: Enter/exit fullscreen mode

### **Projector Integration**
- [ ] **External Display**: Connect to external display
- [ ] **Keyboard Controls**: Keyboard shortcuts
- [ ] **Remote Control**: If implemented, test remote control

---

## 🔧 **17. Settings Screen Testing**

### **Settings Categories**
- [ ] **General Settings**: App preferences
- [ ] **Display Settings**: Theme, font size, etc.
- [ ] **Audio Settings**: Audio preferences
- [ ] **Data Settings**: Data management options
- [ ] **About**: App version, credits, etc.

### **Settings Functionality**
- [ ] **Theme Toggle**: Light/dark theme switching
- [ ] **Font Size**: Adjustable font sizes
- [ ] **Data Management**: Clear cache, reset data
- [ ] **Backup/Restore**: If implemented, test backup features

### **Settings Navigation**
- [ ] **Setting Categories**: Navigate to sub-settings
- [ ] **Back Navigation**: Return to more screen
- [ ] **Apply Changes**: Settings changes take effect

---

## 📱 **18. More Screen Testing**

### **More Screen Layout**
- [ ] **Settings Link**: Navigate to settings
- [ ] **About Link**: Navigate to about screen
- [ ] **Help Link**: Navigate to help/support
- [ ] **Feedback Link**: Send feedback functionality
- [ ] **Rate App**: Link to app store rating

### **More Screen Functionality**
- [ ] **Version Info**: Display current app version
- [ ] **License Info**: Display licenses and credits
- [ ] **Privacy Policy**: Display privacy policy
- [ ] **Terms of Service**: Display terms of service

### **More Screen Navigation**
- [ ] **External Links**: Open external links properly
- [ ] **Back Navigation**: Return to home screen
- [ ] **Share App**: Share app functionality

---

## 📥 **19. Downloads Screen Testing**

### **Downloads Functionality**
- [ ] **Download List**: Display available downloads
- [ ] **Download Progress**: Show download progress
- [ ] **Download Management**: Pause/resume downloads
- [ ] **Storage Info**: Display storage usage

### **Downloads Navigation**
- [ ] **Download Detail**: View download details
- [ ] **Downloaded Content**: Access downloaded hymns
- [ ] **Back Navigation**: Return to more screen

---

## 🔄 **20. Data Loading Screen Testing**

### **Data Loading Functionality**
- [ ] **Initial Load**: Display during app initialization
- [ ] **Progress Indicator**: Show loading progress
- [ ] **Error Handling**: Handle loading errors gracefully
- [ ] **Retry Mechanism**: Retry failed data loading

### **Data Loading States**
- [ ] **Database Loading**: Loading from database
- [ ] **JSON Fallback**: Fallback to JSON data
- [ ] **Network Loading**: Loading from network
- [ ] **Cache Loading**: Loading from cache

---

## 🪟 **21. Projector Window Screen Testing**

### **Projector Window Functionality**
- [ ] **Window Management**: Proper window handling
- [ ] **Display Output**: Correct content display
- [ ] **Synchronization**: Sync with main projector screen
- [ ] **Multi-Monitor**: Handle multiple monitors

### **Projector Window Controls**
- [ ] **Window Controls**: Minimize, maximize, close
- [ ] **Content Updates**: Real-time content updates
- [ ] **Display Options**: Toggle display options

---

## 🎯 **Cross-Screen Testing**

### **Navigation Flow Testing**
Test complete user journeys across all screens:

#### **Search → Detail → Back Flow:**
- [ ] Search for hymn → Click result → View detail → Back to search
- [ ] Verify search state preserved
- [ ] Verify correct result highlighted

#### **Browse → Detail → Back Flow:**
- [ ] Browse collections → Select collection → View hymn → Back to collection
- [ ] Browse authors → Select author → View hymn → Back to author
- [ ] Browse topics → Select topic → View hymn → Back to topic

#### **Favorites → Detail → Back Flow:**
- [ ] View favorites → Click hymn → View detail → Back to favorites
- [ ] Verify favorites list unchanged
- [ ] Verify sort settings preserved

### **State Management Testing**
- [ ] **Search State**: Search query preserved across navigation
- [ ] **Sort State**: Sort preferences maintained across screens
- [ ] **Filter State**: Filter settings preserved across screens
- [ ] **Favorite State**: Favorite status updates across all screens
- [ ] **Recently Viewed**: Updates across all screens

### **Bottom Navigation Testing**
- [ ] **Navigation Bar**: Present on all appropriate screens
- [ ] **Active Tab**: Correct tab highlighted
- [ ] **Tab Switching**: Smooth tab switching
- [ ] **State Preservation**: Tab state preserved during navigation

---

## 🚨 **Critical Bug Testing**

### **High Priority Issues**
Based on user reports, these are critical issues that must be tested:

#### **Search Screen:**
- [ ] **Filter Dialog State**: Fix checkbox state persistence
- [ ] **Favorites Filter**: Ensure favorites-only filter works
- [ ] **OrElse Type Error**: Fix collection filter type error
- [ ] **Abbreviation Recognition**: Fix cs1900 and other abbreviations

#### **Recently Viewed Screen:**
- [ ] **Back Button**: Add missing back button
- [ ] **Bottom Navigation**: Add missing bottom navigation
- [ ] **Favorite State**: Fix favorite state detection
- [ ] **UI Consistency**: Fix container rounding

#### **Hymn Detail Screen:**
- [ ] **Width Consistency**: Fix full-width layout for all hymns
- [ ] **Navigation Buttons**: Fix disabled back/forward buttons
- [ ] **Collection Loading**: Fix collection hymn loading
- [ ] **Fullscreen Mode**: Fix bottom nav hiding

#### **Collections Screen:**
- [ ] **Sort Options**: Clarify title vs alphabetical sorting
- [ ] **Sort Direction**: Add ascending/descending options
- [ ] **Sort UI**: Improve sort dialog UI

### **Medium Priority Issues**
- [ ] **Performance**: Optimize loading times
- [ ] **Memory Usage**: Monitor memory consumption
- [ ] **Error Handling**: Improve error message clarity
- [ ] **UI Polish**: Consistent styling across screens

---

## 🧪 **Automated Testing Implementation**

### **Test Categories to Implement**

#### **Unit Tests:**
- [ ] **Search Query Parser**: Test abbreviation recognition
- [ ] **Favorites Provider**: Test sorting functionality
- [ ] **Database Helper**: Test query methods
- [ ] **Navigation Logic**: Test navigation button state

#### **Widget Tests:**
- [ ] **Search Screen**: Test filter dialog behavior
- [ ] **Favorites Screen**: Test sorting and navigation
- [ ] **Hymn Detail Screen**: Test layout and buttons
- [ ] **Collection Screen**: Test sorting dialog

#### **Integration Tests:**
- [ ] **Search Flow**: Complete search to detail flow
- [ ] **Favorites Flow**: Add/remove favorites flow
- [ ] **Navigation Flow**: Cross-screen navigation
- [ ] **Data Loading**: Database and JSON fallback

### **Test Data Requirements**
- [ ] **Sample Hymns**: Representative hymn data
- [ ] **Sample Collections**: All hymnal collections
- [ ] **Sample Authors**: Author data with hymns
- [ ] **Sample Topics**: Topic data with hymns

---

## 📊 **Testing Metrics**

### **Success Criteria**
- [ ] **Functional Coverage**: 100% of critical features tested
- [ ] **Bug Regression**: All known bugs addressed
- [ ] **Performance**: App responsive within acceptable limits
- [ ] **User Experience**: Intuitive and consistent across screens

### **Test Execution Tracking**
- [ ] **Test Results**: Document pass/fail for each test
- [ ] **Bug Reports**: Link to bug tracking system
- [ ] **Performance Metrics**: Track loading times and memory usage
- [ ] **User Feedback**: Incorporate user testing feedback

---

## 🎯 **Test Execution Guidelines**

### **Test Environment Setup**
1. **Fresh Installation**: Test with clean app install
2. **Data Scenarios**: Test with empty, partial, and full data
3. **Network Conditions**: Test online and offline scenarios
4. **Device Variations**: Test on different screen sizes and platforms

### **Test Execution Order**
1. **Core Functionality**: Basic app functionality first
2. **Screen-by-Screen**: Systematic testing of each screen
3. **Integration Testing**: Cross-screen functionality
4. **Edge Cases**: Error conditions and unusual scenarios
5. **Performance Testing**: Load and stress testing

### **Bug Reporting**
- **Reproduction Steps**: Clear steps to reproduce
- **Expected vs Actual**: What should happen vs what happens
- **Screenshots**: Visual evidence of issues
- **Log Information**: Console logs and error messages
- **Device Information**: Platform, version, screen size

---

**Last Updated**: 2025-01-17  
**Version**: 2.0.0  
**Maintainer**: Development Team

## 📝 **Notes for Developers**

This testing guide should be used as a checklist for:
- **Pre-release Testing**: Before any release
- **Feature Development**: When adding new features
- **Bug Fixes**: Regression testing after fixes
- **Code Reviews**: Ensuring test coverage
- **User Testing**: Guiding user acceptance testing

The guide will be updated as new issues are discovered and features are added.