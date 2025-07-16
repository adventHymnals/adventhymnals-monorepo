import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class DataLoadingScreen extends StatelessWidget {
  final String status;
  final double progress;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onSkip;

  const DataLoadingScreen({
    super.key,
    required this.status,
    this.progress = 0.0,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.background),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: const Icon(
                  Icons.library_music,
                  size: 64,
                  color: Color(AppColors.primaryBlue),
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing32),
              
              // App Title
              Text(
                AppStrings.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(AppColors.primaryBlue),
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing48),
              
              // Error State
              if (hasError) ...[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(AppColors.errorRed),
                ),
                const SizedBox(height: AppSizes.spacing16),
                Text(
                  'Import Failed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(AppColors.errorRed),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  errorMessage ?? 'An error occurred during data import',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacing24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing24,
                          vertical: AppSizes.spacing12,
                        ),
                      ),
                    ),
                    if (onSkip != null) ...[
                      const SizedBox(width: AppSizes.spacing16),
                      OutlinedButton.icon(
                        onPressed: onSkip,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Continue Anyway'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacing24,
                            vertical: AppSizes.spacing12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ]
              // Loading State
              else ...[
                // Progress indicator
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress > 0 ? progress : null,
                          strokeWidth: 8,
                          backgroundColor: const Color(AppColors.gray300),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(AppColors.primaryBlue),
                          ),
                        ),
                      ),
                      // Progress percentage
                      if (progress > 0)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: const Color(AppColors.primaryBlue),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Loading',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(AppColors.gray600),
                              ),
                            ),
                          ],
                        )
                      else
                        const Icon(
                          Icons.download,
                          size: 48,
                          color: Color(AppColors.primaryBlue),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.spacing32),
                
                // Status text
                Text(
                  status,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(AppColors.primaryBlue),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSizes.spacing16),
                
                // Description
                Text(
                  'Setting up your hymnal library for the first time.\nThis may take a few moments.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSizes.spacing32),
                
                // Additional info
                Container(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(AppColors.primaryBlue),
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spacing12),
                      Expanded(
                        child: Text(
                          'Loading hymn collections and preparing search functionality.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(AppColors.primaryBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}