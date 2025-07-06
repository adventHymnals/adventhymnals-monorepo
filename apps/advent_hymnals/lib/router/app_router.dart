import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/hymnals_screen.dart';
import '../screens/hymnal_detail_screen.dart';
import '../screens/hymn_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/browse_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/projection_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/hymnals',
        name: 'hymnals',
        builder: (context, state) => const HymnalsScreen(),
        routes: [
          GoRoute(
            path: '/:hymnalId',
            name: 'hymnal-detail',
            builder: (context, state) {
              final hymnalId = state.pathParameters['hymnalId']!;
              return HymnalDetailScreen(hymnalId: hymnalId);
            },
            routes: [
              GoRoute(
                path: '/hymn/:hymnId',
                name: 'hymn-detail',
                builder: (context, state) {
                  final hymnalId = state.pathParameters['hymnalId']!;
                  final hymnId = state.pathParameters['hymnId']!;
                  return HymnDetailScreen(
                    hymnId: hymnId,
                    hymnalId: hymnalId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchScreen(initialQuery: query);
        },
      ),
      GoRoute(
        path: '/browse',
        name: 'browse',
        builder: (context, state) => const BrowseScreen(),
        routes: [
          GoRoute(
            path: '/authors/:author',
            name: 'browse-author',
            builder: (context, state) {
              final author = state.pathParameters['author']!;
              return BrowseScreen(
                category: 'authors',
                selectedItem: Uri.decodeComponent(author),
              );
            },
          ),
          GoRoute(
            path: '/composers/:composer',
            name: 'browse-composer',
            builder: (context, state) {
              final composer = state.pathParameters['composer']!;
              return BrowseScreen(
                category: 'composers',
                selectedItem: Uri.decodeComponent(composer),
              );
            },
          ),
          GoRoute(
            path: '/themes/:theme',
            name: 'browse-theme',
            builder: (context, state) {
              final theme = state.pathParameters['theme']!;
              return BrowseScreen(
                category: 'themes',
                selectedItem: Uri.decodeComponent(theme),
              );
            },
          ),
          GoRoute(
            path: '/tunes/:tune',
            name: 'browse-tune',
            builder: (context, state) {
              final tune = state.pathParameters['tune']!;
              return BrowseScreen(
                category: 'tunes',
                selectedItem: Uri.decodeComponent(tune),
              );
            },
          ),
          GoRoute(
            path: '/meters/:meter',
            name: 'browse-meter',
            builder: (context, state) {
              final meter = state.pathParameters['meter']!;
              return BrowseScreen(
                category: 'meters',
                selectedItem: Uri.decodeComponent(meter),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/projection/:hymnId',
        name: 'projection',
        builder: (context, state) {
          final hymnId = state.pathParameters['hymnId']!;
          return ProjectionScreen(hymnId: hymnId);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" could not be found.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}