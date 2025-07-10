import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.moreTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        children: [
          // User Section
          _buildUserSection(context),
          
          const SizedBox(height: AppSizes.spacing24),
          
          // Quick Access
          _buildQuickAccessSection(context),
          
          const SizedBox(height: AppSizes.spacing24),
          
          // App Features
          _buildAppFeaturesSection(context),
          
          const SizedBox(height: AppSizes.spacing24),
          
          // Settings & Support
          _buildSettingsSection(context),
          
          const SizedBox(height: AppSizes.spacing24),
          
          // About
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppColors.primaryBlue),
            Color(AppColors.secondaryBlue),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'Advent Hymnals Member',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context,
                icon: Icons.history,
                title: 'Recently Viewed',
                subtitle: 'Your hymn history',
                onTap: () => context.push('/recently-viewed'),
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildQuickAccessCard(
                context,
                icon: Icons.download,
                title: 'Downloads',
                subtitle: 'Offline content',
                onTap: () => context.push('/downloads'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            children: [
              Icon(
                icon,
                size: AppSizes.iconSizeLarge,
                color: Color(AppColors.secondaryBlue),
              ),
              const SizedBox(height: AppSizes.spacing8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacing4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Features',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing16),
        _buildFeatureItem(
          context,
          icon: Icons.music_note,
          title: 'Audio Playback',
          subtitle: 'Listen to hymn recordings',
          onTap: () {
            // Show audio feature info
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.piano,
          title: 'MIDI Playback',
          subtitle: 'Play hymn melodies',
          onTap: () {
            // Show MIDI feature info
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.picture_as_pdf,
          title: 'Sheet Music',
          subtitle: 'View and download scores',
          onTap: () {
            // Show sheet music feature info
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.share,
          title: 'Share Hymns',
          subtitle: 'Share your favorite hymns',
          onTap: () {
            // Show share feature info
          },
        ),
        _buildFeatureItem(
          context,
          icon: Icons.tv,
          title: 'Projector Mode',
          subtitle: 'Display hymns for projection',
          onTap: () => context.push('/projector'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings & Support',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing16),
        _buildSettingsItem(
          context,
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences and options',
          onTap: () => context.push('/settings'),
        ),
        _buildSettingsItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help using the app',
          onTap: () {
            // Show help
          },
        ),
        _buildSettingsItem(
          context,
          icon: Icons.feedback,
          title: 'Send Feedback',
          subtitle: 'Report issues or suggestions',
          onTap: () {
            // Show feedback form
          },
        ),
        _buildSettingsItem(
          context,
          icon: Icons.star_rate,
          title: 'Rate App',
          subtitle: 'Rate us on the app store',
          onTap: () {
            // Open app store rating
          },
        ),
        const SizedBox(height: AppSizes.spacing16),
        Text(
          'Connect With Us',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildSocialRow(context),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing16),
        _buildAboutItem(
          context,
          icon: Icons.info_outline,
          title: 'About Advent Hymnals',
          subtitle: 'Learn more about our mission',
          onTap: () {
            // Show about page
          },
        ),
        _buildAboutItem(
          context,
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () {
            // Show terms of service
          },
        ),
        _buildAboutItem(
          context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Learn about data privacy',
          onTap: () {
            // Show privacy policy
          },
        ),
        _buildAboutItem(
          context,
          icon: Icons.update,
          title: 'App Version',
          subtitle: 'Version ${AppConstants.appVersion}',
          onTap: () {
            // Show version info
          },
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(AppColors.successGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            color: Color(AppColors.successGreen),
            size: AppSizes.iconSize,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(AppColors.warningOrange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            color: Color(AppColors.warningOrange),
            size: AppSizes.iconSize,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAboutItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(AppColors.gray500).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            color: Color(AppColors.gray500),
            size: AppSizes.iconSize,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialButton(
            context,
            icon: Icons.language,
            label: 'Website',
            color: Color(AppColors.primaryBlue),
            onTap: () {
              // Open website: https://adventhymnals.org
              _showWebsiteDialog(context);
            },
          ),
          _buildSocialButton(
            context,
            icon: Icons.video_library,
            label: 'YouTube',
            color: const Color(0xFFFF0000), // YouTube red
            onTap: () {
              // Open YouTube channel
              _showYouTubeDialog(context);
            },
          ),
          _buildSocialButton(
            context,
            icon: Icons.code,
            label: 'GitHub',
            color: const Color(0xFF24292e), // GitHub dark
            onTap: () {
              // Open GitHub repository
              _showGitHubDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing16,
          vertical: AppSizes.spacing12,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconSize),
            const SizedBox(height: AppSizes.spacing4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWebsiteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visit Our Website'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Visit our website to explore more hymnal resources:'),
            SizedBox(height: 16),
            SelectableText(
              'https://adventhymnals.org',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening website...')),
              );
            },
            child: const Text('Open Website'),
          ),
        ],
      ),
    );
  }

  void _showYouTubeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube Channel'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Subscribe to our YouTube channel for:'),
            SizedBox(height: 12),
            Text('• Hymn tutorials and singalongs'),
            Text('• Historical information about hymns'),
            Text('• Live streaming of services'),
            Text('• Educational content'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the YouTube channel
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening YouTube channel...')),
              );
            },
            child: const Text('Open YouTube'),
          ),
        ],
      ),
    );
  }

  void _showGitHubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Source Project'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This app is open source! Visit our GitHub to:'),
            SizedBox(height: 12),
            Text('• View the source code'),
            Text('• Report issues or bugs'),
            Text('• Contribute to development'),
            Text('• Request new features'),
            SizedBox(height: 12),
            Text('Repository: GospelSounders/adventhymnals'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the GitHub repository
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening GitHub repository...')),
              );
            },
            child: const Text('Open GitHub'),
          ),
        ],
      ),
    );
  }
}