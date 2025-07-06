import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeModeName(themeProvider.themeMode)),
                      trailing: DropdownButton<ThemeMode>(
                        value: themeProvider.themeMode,
                        onChanged: (ThemeMode? newTheme) {
                          if (newTheme != null) {
                            themeProvider.setThemeMode(newTheme);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Advent Hymnals'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.build),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
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