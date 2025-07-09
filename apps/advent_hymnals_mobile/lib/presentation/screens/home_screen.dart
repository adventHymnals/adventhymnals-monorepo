import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/hymn_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the async loading after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final recentlyViewedProvider = Provider.of<RecentlyViewedProvider>(context, listen: false);

    // Load initial data
    await Future.wait([
      hymnProvider.loadHymns(limit: 10),
      favoritesProvider.loadFavorites(),
      recentlyViewedProvider.loadRecentlyViewed(limit: 5),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.go('/search');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Recent Hymns Section
              _buildRecentHymnsSection(),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Favorites Section
              _buildFavoritesSection(),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Browse Collections
              _buildBrowseCollections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            AppStrings.appTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Discover and explore hymns from multiple collections',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.search,
                title: 'Search',
                subtitle: 'Find hymns',
                onTap: () {
                  context.go('/search');
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.favorite,
                title: 'Favorites',
                subtitle: 'Your saved hymns',
                onTap: () {
                  context.go('/favorites');
                },
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.library_books,
                title: 'Browse',
                subtitle: 'Explore collections',
                onTap: () {
                  context.go('/browse');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
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

  Widget _buildRecentHymnsSection() {
    return Consumer<RecentlyViewedProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Viewed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (provider.recentlyViewed.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      context.go('/recently-viewed');
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing12),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.recentlyViewed.isEmpty)
              _buildEmptyState(
                icon: Icons.history,
                title: 'No Recent Hymns',
                subtitle: 'Start exploring hymns to see them here',
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.recentlyViewed.length,
                  itemBuilder: (context, index) {
                    final hymn = provider.recentlyViewed[index];
                    return _buildHymnCard(hymn);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesSection() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Favorites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (provider.favorites.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      context.go('/favorites');
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacing12),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.favorites.isEmpty)
              _buildEmptyState(
                icon: Icons.favorite_border,
                title: 'No Favorites',
                subtitle: 'Tap the heart icon to add hymns to favorites',
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.favorites.take(5).length,
                  itemBuilder: (context, index) {
                    final hymn = provider.favorites[index];
                    return _buildHymnCard(hymn);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBrowseCollections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse Collections',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing12),
        _buildCollectionCard(
          title: 'Seventh-day Adventist Hymnal',
          subtitle: 'SDAH • 695 hymns',
          color: Color(AppColors.primaryBlue),
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildCollectionCard(
          title: 'Christ in Song',
          subtitle: 'CS • 1000+ hymns',
          color: Color(AppColors.successGreen),
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildCollectionCard(
          title: 'Hymns and Tunes',
          subtitle: 'HT • 800+ hymns',
          color: Color(AppColors.purple),
        ),
      ],
    );
  }

  Widget _buildHymnCard(dynamic hymn) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: AppSizes.spacing12),
      child: Card(
        child: InkWell(
          onTap: () {
            context.go('/hymn/${hymn.hymnNumber}');
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hymn.hymnNumber.toString(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Color(AppColors.secondaryBlue),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Expanded(
                  child: Text(
                    hymn.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hymn.author != null)
                  Text(
                    hymn.author,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          context.go('/browse');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(
                  Icons.library_books,
                  color: color,
                  size: AppSizes.iconSize,
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(AppColors.gray500),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Color(AppColors.gray700),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Color(AppColors.gray500),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}