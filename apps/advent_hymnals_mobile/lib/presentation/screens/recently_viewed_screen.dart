import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../domain/entities/hymn.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  @override
  void initState() {
    super.initState();
    // Load recently viewed data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RecentlyViewedProvider>(context, listen: false);
      provider.loadRecentlyViewed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.go('/home');
            } catch (e) {
              print('❌ [RecentlyViewedScreen] Navigation error: $e');
              // Fallback to Navigator.pop if context.go fails
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          tooltip: 'Back to Home',
        ),
        actions: [
          Consumer<RecentlyViewedProvider>(
            builder: (context, provider, child) {
              if (provider.recentlyViewed.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _showClearDialog(context, provider),
                  tooltip: 'Clear All',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<RecentlyViewedProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Color(AppColors.errorRed),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    Text(
                      'Error Loading Recently Viewed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Text(
                      provider.errorMessage ?? 'Unknown error occurred',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.gray500),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacing24),
                    ElevatedButton(
                      onPressed: () => provider.loadRecentlyViewed(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.recentlyViewed.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            itemCount: provider.recentlyViewed.length,
            itemBuilder: (context, index) {
              final hymn = provider.recentlyViewed[index];
              return _buildHymnCard(context, hymn, index);
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 80,
              color: Color(AppColors.gray400),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'No Recent History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Hymns you view will appear here for quick access.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(AppColors.gray500),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing24),
            ElevatedButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Hymns'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnCard(BuildContext context, Hymn hymn, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                hymn.collectionAbbreviation != null 
                  ? '${hymn.collectionAbbreviation}\n${hymn.hymnNumber}'
                  : hymn.hymnNumber.toString(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(AppColors.primaryBlue),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
              ),
            ),
          ),
        ),
        title: Text(
          hymn.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hymn.author != null)
              Text(
                'by ${hymn.author}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppColors.gray600),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Color(AppColors.gray500),
                ),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(hymn.lastViewed ?? DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray500),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'remove':
                context.read<RecentlyViewedProvider>().removeFromRecent(hymn);
                break;
              case 'favorite':
                _addToFavorites(context, hymn);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'favorite',
              child: ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('Add to Favorites'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.remove_circle_outline),
                title: Text('Remove from History'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to hymn detail with source context for proper back navigation
          final collectionParam = hymn.collectionAbbreviation;
          final route = collectionParam != null 
            ? '/hymn/${hymn.hymnNumber}?collection=$collectionParam&from=recent'
            : '/hymn/${hymn.hymnNumber}?from=recent';
          context.go(route);
        },
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _addToFavorites(BuildContext context, Hymn hymn) async {
    try {
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      await favoritesProvider.addFavorite(hymn.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${hymn.title}" to favorites'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await favoritesProvider.removeFavorite(hymn.id);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add "${hymn.title}" to favorites'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
        );
      }
    }
  }

  void _showClearDialog(BuildContext context, RecentlyViewedProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recently Viewed'),
        content: const Text('Are you sure you want to clear all recently viewed hymns?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recently viewed history cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}