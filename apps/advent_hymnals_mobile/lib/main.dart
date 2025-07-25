import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

// Main entry point for Advent Hymnals mobile application
// Debug: Testing Windows build workflow trigger

import 'presentation/theme/app_theme.dart';
import 'presentation/providers/hymn_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/recently_viewed_provider.dart';
import 'presentation/providers/download_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/audio_player_provider.dart';
import 'core/services/church_mode_service.dart';
import 'core/services/projector_service.dart';
import 'core/services/admob_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/browse_hub_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/more_screen.dart';
import 'presentation/screens/hymn_detail_screen.dart';
import 'presentation/widgets/app_initializer.dart';
import 'presentation/screens/collections_browse_screen.dart';
import 'presentation/screens/browse_detail_screen.dart';
import 'presentation/screens/recently_viewed_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/downloads_screen.dart';
import 'presentation/screens/collection_detail_screen.dart';
import 'presentation/screens/projector_screen.dart';
import 'presentation/screens/projector_window_screen.dart';
import 'presentation/screens/audio_player_screen.dart';
import 'presentation/widgets/main_navigation.dart';
import 'core/services/windows_debug_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register the projector window entry point
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      // Handle method calls from secondary windows
      if (call.method == 'projectorWindowReady') {
        print('🎥 [Main] Projector window ready (ID: $fromWindowId)');
      }
    });
  }
  
  // Enhanced Windows logging and debug sound
  if (Platform.isWindows && kDebugMode) {
    debugPrint('🪟 [Windows] Advent Hymnals starting...');
    await WindowsDebugService.debugMilestone('App main() started');
  }
  
  // Initialize sqflite for desktop platforms
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    if (Platform.isWindows && kDebugMode) {
      debugPrint('🪟 [Windows] SQLite FFI initialized');
      await WindowsDebugService.debugMilestone('SQLite FFI initialized');
    }
  }
  
  // Initialize church mode service
  try {
    await ChurchModeService().initialize();
    if (Platform.isWindows && kDebugMode) {
      debugPrint('🪟 [Windows] Church mode service initialized');
      await WindowsDebugService.debugMilestone('Church mode service initialized');
    }
  } catch (e) {
    if (Platform.isWindows && kDebugMode) {
      debugPrint('🪟 [Windows] Church mode service failed: $e');
      await WindowsDebugService.debugMilestone('Church mode service FAILED: $e', soundFreq: 400);
    }
  }
  
  // Initialize AdMob (mobile platforms only)
  if (Platform.isAndroid || Platform.isIOS) {
    await AdMobService.initialize();
  }
  
  if (Platform.isWindows && kDebugMode) {
    debugPrint('🪟 [Windows] Starting AdventHymnalsApp...');
    await WindowsDebugService.debugMilestone('About to call runApp()');
  }
  
  runApp(const AdventHymnalsApp());
}

class AdventHymnalsApp extends StatelessWidget {
  final bool skipDataLoading;
  
  const AdventHymnalsApp({super.key, this.skipDataLoading = false});

  @override
  Widget build(BuildContext context) {
    // Debug: Widget build started
    if (Platform.isWindows && kDebugMode) {
      debugPrint('🪟 [Windows] AdventHymnalsApp.build() called');
      WindowsDebugService.debugMilestone('AdventHymnalsApp.build() started');
    }
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HymnProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ProjectorService()),
        ChangeNotifierProxyProvider<SettingsProvider, AudioPlayerProvider>(
          create: (context) => AudioPlayerProvider(context.read<SettingsProvider>()),
          update: (context, settings, previous) => previous ?? AudioPlayerProvider(settings),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          // Debug: Consumer builder called
          if (Platform.isWindows && kDebugMode) {
            debugPrint('🪟 [Windows] Consumer<SettingsProvider> builder called');
            WindowsDebugService.debugMilestone('Consumer<SettingsProvider> builder called');
          }
          
          return MaterialApp.router(
            title: 'Advent Hymnals',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Debug: MaterialApp builder called
              if (Platform.isWindows && kDebugMode) {
                debugPrint('🪟 [Windows] MaterialApp.router builder called');
                WindowsDebugService.debugMilestone('MaterialApp.router builder called');
              }
              // Skip data loading if requested (for debugging)
              if (skipDataLoading) {
                if (Platform.isWindows && kDebugMode) {
                  debugPrint('🪟 [Windows] Skipping data loading for debugging');
                  WindowsDebugService.debugMilestone('Skipping data loading - returning child directly');
                }
                return child ?? const SizedBox();
              }
              
              // Debug: About to create AppInitializer
              if (Platform.isWindows && kDebugMode) {
                debugPrint('🪟 [Windows] Creating AppInitializer');
                WindowsDebugService.debugMilestone('Creating AppInitializer with child');
              }
              
              return AppInitializer(child: child ?? const SizedBox());
            },
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/browse',
          builder: (context, state) => const BrowseHubScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreScreen(),
        ),
        
        // Collection and hymn detail screens (with bottom navigation)
        GoRoute(
          path: '/collection/:collectionId',
          builder: (context, state) {
            final collectionId = state.pathParameters['collectionId'] ?? '';
            return CollectionDetailScreen(collectionId: collectionId);
          },
        ),
        
        
        GoRoute(
          path: '/browse/collections',
          builder: (context, state) => const CollectionsBrowseScreen(),
        ),
        
        GoRoute(
          path: '/recently-viewed',
          builder: (context, state) => const RecentlyViewedScreen(),
        ),
      ],
    ),
    
    // Screens without bottom navigation
    
    GoRoute(
      path: '/browse/authors',
      builder: (context, state) => const BrowseDetailScreen(category: BrowseCategory.authors),
    ),
    
    GoRoute(
      path: '/browse/authors/:author',
      builder: (context, state) {
        final author = Uri.decodeComponent(state.pathParameters['author'] ?? '');
        return BrowseDetailScreen(category: BrowseCategory.authors, selectedItem: author);
      },
    ),
    
    GoRoute(
      path: '/browse/composers',
      builder: (context, state) => const BrowseDetailScreen(category: BrowseCategory.composers),
    ),
    
    GoRoute(
      path: '/browse/composers/:composer',
      builder: (context, state) {
        final composer = Uri.decodeComponent(state.pathParameters['composer'] ?? '');
        return BrowseDetailScreen(category: BrowseCategory.composers, selectedItem: composer);
      },
    ),
    
    GoRoute(
      path: '/browse/topics',
      builder: (context, state) => const BrowseDetailScreen(category: BrowseCategory.topics),
    ),
    
    GoRoute(
      path: '/browse/topics/:topic',
      builder: (context, state) {
        final topic = Uri.decodeComponent(state.pathParameters['topic'] ?? '');
        return BrowseDetailScreen(category: BrowseCategory.topics, selectedItem: topic);
      },
    ),
    
    GoRoute(
      path: '/browse/tunes',
      builder: (context, state) => const BrowseDetailScreen(category: BrowseCategory.tunes),
    ),
    
    GoRoute(
      path: '/browse/tunes/:tune',
      builder: (context, state) {
        final tune = Uri.decodeComponent(state.pathParameters['tune'] ?? '');
        return BrowseDetailScreen(category: BrowseCategory.tunes, selectedItem: tune);
      },
    ),
    
    GoRoute(
      path: '/browse/meters',
      builder: (context, state) => const BrowseDetailScreen(category: BrowseCategory.meters),
    ),
    
    GoRoute(
      path: '/browse/meters/:meter',
      builder: (context, state) {
        final meter = Uri.decodeComponent(state.pathParameters['meter'] ?? '');
        return BrowseDetailScreen(category: BrowseCategory.meters, selectedItem: meter);
      },
    ),
    
    GoRoute(
      path: '/browse/scripture',
      builder: (context, state) => const BrowseDetailScreen(category: BrowseCategory.scripture),
    ),
    
    GoRoute(
      path: '/browse/scripture/:scripture',
      builder: (context, state) {
        final scripture = Uri.decodeComponent(state.pathParameters['scripture'] ?? '');
        return BrowseDetailScreen(category: BrowseCategory.scripture, selectedItem: scripture);
      },
    ),
    
    GoRoute(
      path: '/hymn/:id',
      builder: (context, state) {
        final hymnId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        final collectionId = state.uri.queryParameters['collection'];
        final fromSource = state.uri.queryParameters['from'];
        return HymnDetailScreen(
          hymnId: hymnId,
          collectionId: collectionId,
          fromSource: fromSource,
        );
      },
    ),
    
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    
    GoRoute(
      path: '/downloads',
      builder: (context, state) => const DownloadsScreen(),
    ),
    
    GoRoute(
      path: '/projector',
      builder: (context, state) {
        final hymnId = state.uri.queryParameters['hymn'];
        return ProjectorScreen(
          initialHymnId: hymnId != null ? int.tryParse(hymnId) : null,
        );
      },
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const AudioPlayerScreen(),
    ),
    GoRoute(
      path: '/projector-window',
      builder: (context, state) {
        final hymnId = state.uri.queryParameters['hymn'];
        return ProjectorWindowScreen(
          hymnId: hymnId != null ? int.tryParse(hymnId) : null,
        );
      },
    ),
  ],
);// Debug trigger Wed, Jul 16, 2025 10:37:02 AM
