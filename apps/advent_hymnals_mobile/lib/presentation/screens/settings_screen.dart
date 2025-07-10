import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (!settingsProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Theme & Appearance
                _buildSectionHeader(context, 'Theme & Appearance', Icons.palette),
                _buildThemeSettings(context, settingsProvider),
                _buildLanguageSettings(context, settingsProvider),
                _buildFontSizeSettings(context, settingsProvider),
                _buildDisplaySettings(context, settingsProvider),
                
                const SizedBox(height: AppSizes.spacing24),
                
                // Audio & Playback
                _buildSectionHeader(context, 'Audio & Playback', Icons.volume_up),
                _buildAudioSettings(context, settingsProvider),
                
                const SizedBox(height: AppSizes.spacing24),
                
                // Downloads & Offline
                _buildSectionHeader(context, 'Downloads & Offline', Icons.download),
                _buildDownloadSettings(context, settingsProvider),
                
                const SizedBox(height: AppSizes.spacing24),
                
                // Screen & Device
                _buildSectionHeader(context, 'Screen & Device', Icons.phone_android),
                _buildDeviceSettings(context, settingsProvider),
                
                const SizedBox(height: AppSizes.spacing24),
                
                // Data & Storage
                _buildSectionHeader(context, 'Data & Storage', Icons.storage),
                _buildDataSettings(context, settingsProvider),
                
                const SizedBox(height: AppSizes.spacing24),
                
                // About
                _buildSectionHeader(context, 'About', Icons.info),
                _buildAboutSettings(context),
                
                const SizedBox(height: AppSizes.spacing32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing20,
        AppSizes.spacing24,
        AppSizes.spacing20,
        AppSizes.spacing12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(AppColors.primaryBlue),
            size: 20,
          ),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Color(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Theme'),
            subtitle: Text(_getThemeDisplayName(provider.settings.theme)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showThemeDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.language,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Language'),
            subtitle: Text(provider.languageDisplayName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.text_fields,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Font Size'),
            subtitle: Text(_getFontSizeDisplayName(provider.settings.fontSize)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showFontSizeDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              Icons.view_compact,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Compact Mode'),
            subtitle: const Text('Show more content in less space'),
            value: provider.settings.compactMode,
            onChanged: (value) => provider.setCompactMode(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.numbers,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Show Hymn Numbers'),
            subtitle: const Text('Display hymn numbers in lists'),
            value: provider.settings.showNumbers,
            onChanged: (value) => provider.setShowNumbers(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.accessibility,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Large Text Mode'),
            subtitle: const Text('Increase text size for better readability'),
            value: provider.settings.largeTextMode,
            onChanged: (value) => provider.setLargeTextMode(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.my_library_music,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Show Chords'),
            subtitle: const Text('Display chord symbols when available'),
            value: provider.settings.showChords,
            onChanged: (value) => provider.setShowChords(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.info_outline,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Show Metadata'),
            subtitle: const Text('Display hymn details and information'),
            value: provider.settings.showMetadata,
            onChanged: (value) => provider.setShowMetadata(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              Icons.volume_up,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Sound Effects'),
            subtitle: const Text('Enable app sounds and notifications'),
            value: provider.settings.soundEnabled,
            onChanged: (value) => provider.setSoundEnabled(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.vibration,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Vibration'),
            subtitle: const Text('Enable haptic feedback'),
            value: provider.settings.vibrationEnabled,
            onChanged: (value) => provider.setVibrationEnabled(value),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.speed,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Playback Speed'),
            subtitle: Text('${provider.settings.playbackSpeed}x'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPlaybackSpeedDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              Icons.download,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Auto Download'),
            subtitle: const Text('Automatically download hymns for offline use'),
            value: provider.settings.autoDownload,
            onChanged: (value) => provider.setAutoDownload(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(
              Icons.offline_pin,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Offline Mode'),
            subtitle: const Text('Use only downloaded content'),
            value: provider.settings.offlineMode,
            onChanged: (value) => provider.setOfflineMode(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              Icons.screen_lock_portrait,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Keep Screen On'),
            subtitle: const Text('Prevent screen from turning off while reading'),
            value: provider.settings.keepScreenOn,
            onChanged: (value) => provider.setKeepScreenOn(value),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.timer,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Auto Lock Timeout'),
            subtitle: Text('${provider.settings.autoLockTimeout} seconds'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAutoLockDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(BuildContext context, SettingsProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Reset Settings'),
            subtitle: const Text('Restore default settings'),
            onTap: () => _showResetDialog(context, provider),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Color(AppColors.errorRed),
            ),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: Color(AppColors.errorRed)),
            ),
            subtitle: const Text('Delete all app data and settings'),
            onTap: () => _showClearDataDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info,
              color: Color(AppColors.gray600),
            ),
            title: const Text('About'),
            subtitle: const Text('Advent Hymnals Mobile v1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Privacy Policy'),
            onTap: () => _showPrivacyDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.gavel,
              color: Color(AppColors.gray600),
            ),
            title: const Text('Terms of Service'),
            onTap: () => _showTermsDialog(context),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((theme) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeDisplayName(theme)),
              value: theme,
              groupValue: provider.settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: SupportedLanguage.values.map((language) {
              return RadioListTile<SupportedLanguage>(
                title: Text(_getLanguageDisplayName(language)),
                value: language,
                groupValue: provider.settings.language,
                onChanged: (value) {
                  if (value != null) {
                    provider.setLanguage(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FontSizePreference.values.map((fontSize) {
            return RadioListTile<FontSizePreference>(
              title: Text(_getFontSizeDisplayName(fontSize)),
              value: fontSize,
              groupValue: provider.settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  provider.setFontSize(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPlaybackSpeedDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
            return RadioListTile<double>(
              title: Text('${speed}x'),
              value: speed,
              groupValue: provider.settings.playbackSpeed,
              onChanged: (value) {
                if (value != null) {
                  provider.setPlaybackSpeed(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAutoLockDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Lock Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 60, 120, 300].map((timeout) {
            return RadioListTile<int>(
              title: Text('${timeout} seconds'),
              value: timeout,
              groupValue: provider.settings.autoLockTimeout,
              onChanged: (value) {
                if (value != null) {
                  provider.setAutoLockTimeout(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all app data including settings, favorites, and downloads. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(AppColors.errorRed),
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Advent Hymnals Mobile',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.book, size: 48),
      children: [
        const Text('A mobile app for accessing Seventh-day Adventist hymns and songs.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and love for the Adventist community.'),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This app respects your privacy. All data is stored locally on your device. '
            'No personal information is collected or transmitted to external servers.'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to use it for personal, non-commercial purposes. '
            'The hymns and songs are provided for worship and educational use.'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getThemeDisplayName(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  String _getLanguageDisplayName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.en:
        return 'English';
      case SupportedLanguage.sw:
        return 'Kiswahili';
      case SupportedLanguage.luo:
        return 'Luo';
      case SupportedLanguage.fr:
        return 'Français';
      case SupportedLanguage.es:
        return 'Español';
      case SupportedLanguage.de:
        return 'Deutsch';
      case SupportedLanguage.pt:
        return 'Português';
      case SupportedLanguage.it:
        return 'Italiano';
    }
  }

  String _getFontSizeDisplayName(FontSizePreference fontSize) {
    switch (fontSize) {
      case FontSizePreference.small:
        return 'Small';
      case FontSizePreference.medium:
        return 'Medium';
      case FontSizePreference.large:
        return 'Large';
      case FontSizePreference.extraLarge:
        return 'Extra Large';
    }
  }
}