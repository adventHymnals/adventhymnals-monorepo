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
}