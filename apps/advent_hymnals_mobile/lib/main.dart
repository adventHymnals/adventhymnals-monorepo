import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'presentation/theme/app_theme.dart';
import 'presentation/providers/hymn_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/recently_viewed_provider.dart';
import 'presentation/providers/download_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/audio_player_provider.dart';
import 'core/services/church_mode_service.dart';
import 'core/services/projector_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/browse_hub_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/favorites_screen.dart';
import 'presentation/screens/more_screen.dart';
import 'presentation/screens/hymn_detail_screen.dart';
import 'presentation/screens/authors_browse_screen.dart';
import 'presentation/screens/topics_browse_screen.dart';
import 'presentation/screens/collections_browse_screen.dart';
import 'presentation/screens/tunes_browse_screen.dart';
import 'presentation/screens/meters_browse_screen.dart';
import 'presentation/screens/scripture_browse_screen.dart';
import 'presentation/screens/first_lines_browse_screen.dart';
import 'presentation/screens/recently_viewed_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/downloads_screen.dart';
import 'presentation/screens/collection_detail_screen.dart';
import 'presentation/screens/projector_screen.dart';
import 'presentation/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite for desktop platforms
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize church mode service
  await ChurchModeService().initialize();
  
  runApp(const AdventHymnalsApp());
}

class AdventHymnalsApp extends StatelessWidget {
  const AdventHymnalsApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          return MaterialApp.router(
            title: 'Advent Hymnals',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
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
          path: '/hymn/:id',
          builder: (context, state) {
            final hymnId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return HymnDetailScreen(hymnId: hymnId);
          },
        ),
      ],
    ),
    
    // Screens without bottom navigation
    
    GoRoute(
      path: '/browse/authors',
      builder: (context, state) => const AuthorsBrowseScreen(),
    ),
    
    GoRoute(
      path: '/browse/topics',
      builder: (context, state) => const TopicsBrowseScreen(),
    ),
    
    GoRoute(
      path: '/browse/collections',
      builder: (context, state) => const CollectionsBrowseScreen(),
    ),
    
    GoRoute(
      path: '/browse/tunes',
      builder: (context, state) => const TunesBrowseScreen(),
    ),
    
    GoRoute(
      path: '/browse/meters',
      builder: (context, state) => const MetersBrowseScreen(),
    ),
    
    GoRoute(
      path: '/browse/scripture',
      builder: (context, state) => const ScriptureBrowseScreen(),
    ),
    
    GoRoute(
      path: '/browse/first-lines',
      builder: (context, state) => const FirstLinesBrowseScreen(),
    ),
    
    GoRoute(
      path: '/recently-viewed',
      builder: (context, state) => const RecentlyViewedScreen(),
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
  ],
);