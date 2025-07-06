import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.library_music,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Advent Hymnals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Digital Hymnal Collection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Hymnals'),
            onTap: () {
              Navigator.pop(context);
              context.go('/hymnals');
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () {
              Navigator.pop(context);
              context.go('/search');
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Browse'),
            onTap: () {
              Navigator.pop(context);
              context.go('/browse');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.slideshow),
            title: const Text('Projection Mode'),
            subtitle: const Text('For worship services'),
            onTap: () {
              Navigator.pop(context);
              _showProjectionInfo(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showProjectionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Projection Mode'),
        content: const Text(
          'To use projection mode, navigate to any hymn and tap the projection button. This will display the hymn in fullscreen format suitable for worship services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/search');
            },
            child: const Text('Find a Hymn'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Advent Hymnals',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.library_music,
        size: 48,
      ),
      children: [
        const Text(
          'A comprehensive digital hymnal collection providing access to traditional and contemporary hymns for worship services and personal devotion.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features include:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Browse multiple hymnal collections'),
        const Text('• Search by title, author, or lyrics'),
        const Text('• Projection mode for worship services'),
        const Text('• Cross-platform support'),
        const Text('• Dark and light themes'),
      ],
    );
  }
}