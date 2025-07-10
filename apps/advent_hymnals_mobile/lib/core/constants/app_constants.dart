class AppConstants {
  static const String appName = 'Advent Hymnals';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'hymns.db';
  static const int databaseVersion = 1;
  
  // API
  static const String apiBaseUrl = 'https://adventhymnals.org/api';
  static const String devApiUrl = 'http://localhost:3000/api';
  static const String stagingApiUrl = 'https://staging.adventhymnals.org/api';
  
  // Storage
  static const String mediaFolder = 'media';
  static const String cacheFolder = 'cache';
  static const String userDataFolder = 'user_data';
  
  // Media Types
  static const String audioFolder = 'audio';
  static const String midiFolder = 'midi';
  static const String imageFolder = 'images';
  static const String pdfFolder = 'pdf';
  
  // Audio Quality
  static const String highQuality = 'high_quality';
  static const String standardQuality = 'standard_quality';
  static const String lowQuality = 'low_quality';
  
  // Cache limits
  static const int maxCacheSize = 500 * 1024 * 1024; // 500MB
  static const int maxRecentlyViewed = 100;
  static const int maxSearchHistory = 50;
  
  // Download settings
  static const int maxConcurrentDownloads = 3;
  static const int downloadTimeoutSeconds = 30;
}

class AppStrings {
  // App
  static const String appTitle = 'Advent Hymnals';
  static const String appDescription = 'Comprehensive hymnal mobile app';
  
  // Navigation
  static const String homeTitle = 'Home';
  static const String browseTitle = 'Browse';
  static const String searchTitle = 'Search';
  static const String favoritesTitle = 'Favorites';
  static const String moreTitle = 'More';
  
  // Browse Categories
  static const String collectionsTitle = 'Collections';
  static const String authorsTitle = 'Authors';
  static const String topicsTitle = 'Topics';
  static const String tunesTitle = 'Tunes';
  static const String metersTitle = 'Meters';
  static const String scriptureTitle = 'Scripture';
  static const String firstLinesTitle = 'First Lines';
  
  // Actions
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String download = 'Download';
  static const String play = 'Play';
  static const String share = 'Share';
  static const String search = 'Search';
  static const String clearHistory = 'Clear History';
  
  // Messages
  static const String noResults = 'No results found';
  static const String noFavorites = 'No Favorites';
  static const String noRecentlyViewed = 'No recently viewed hymns';
  static const String downloadComplete = 'Download complete';
  static const String downloadFailed = 'Download failed';
  static const String offlineMode = 'Offline mode';
  static const String internetRequired = 'Internet connection required';
}

class AppColors {
  // Primary Colors
  static const int primaryBlue = 0xFF1E3A8A;
  static const int secondaryBlue = 0xFF0284C7;
  static const int successGreen = 0xFF16A34A;
  static const int warningOrange = 0xFFF59E0B;
  static const int errorRed = 0xFFDC2626;
  static const int purple = 0xFF7C3AED;
  static const int darkPurple = 0xFF6D28D9;
  static const int infoBlue = 0xFF0EA5E9;
  static const int background = 0xFFFEFCE8;
  
  // Neutral Colors
  static const int black = 0xFF000000;
  static const int white = 0xFFFFFFFF;
  static const int gray100 = 0xFFF3F4F6;
  static const int gray300 = 0xFFD1D5DB;
  static const int gray400 = 0xFF9CA3AF;
  static const int gray500 = 0xFF6B7280;
  static const int gray600 = 0xFF4B5563;
  static const int gray700 = 0xFF374151;
  static const int gray900 = 0xFF111827;
}

class AppFonts {
  static const String inter = 'Roboto';
  static const String crimsonText = 'serif';
}

class AppSizes {
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Touch Targets
  static const double minTouchTarget = 44.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Screen Dimensions
  static const double screenWidth = 390.0;
  static const double screenHeight = 844.0;
}