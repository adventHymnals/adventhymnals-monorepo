import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../../core/constants/app_constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _sortBy = 'date_added';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Schedule the async loading after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    await favoritesProvider.loadFavorites();
  }

  void _searchFavorites(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Date Added'),
                value: 'date_added',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.of(context).pop();
                  _applySorting();
                },
              ),
              RadioListTile<String>(
                title: const Text('Title'),
                value: 'title',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.of(context).pop();
                  _applySorting();
                },
              ),
              RadioListTile<String>(
                title: const Text('Author'),
                value: 'author',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.of(context).pop();
                  _applySorting();
                },
              ),
              RadioListTile<String>(
                title: const Text('Hymn Number'),
                value: 'hymn_number',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.of(context).pop();
                  _applySorting();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _applySorting() {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.sortFavorites(_sortBy);
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text('Are you sure you want to remove all favorites? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
                await favoritesProvider.clearAllFavorites();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.favoritesTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearAllDialog();
                  }
                },
                itemBuilder: (context) => [
                  if (provider.favorites.isNotEmpty)
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Text('Clear All'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return _buildErrorState(provider.errorMessage ?? 'Failed to load favorites');
          }

          if (provider.isEmpty) {
            return _buildEmptyState();
          }

          final favorites = _searchQuery.isEmpty
              ? provider.favorites
              : provider.searchFavorites(_searchQuery);

          return Column(
            children: [
              // Search Bar
              if (provider.favorites.isNotEmpty) _buildSearchBar(),
              
              // Favorites Count
              _buildFavoritesHeader(favorites.length, provider.totalCount),
              
              // Favorites List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final hymn = favorites[index];
                      return _buildFavoriteItem(hymn, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: TextField(
        controller: _searchController,
        onChanged: _searchFavorites,
        decoration: InputDecoration(
          hintText: 'Search favorites...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchFavorites('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFavoritesHeader(int displayCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _searchQuery.isEmpty
                ? '$totalCount favorite${totalCount == 1 ? '' : 's'}'
                : '$displayCount of $totalCount favorite${totalCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            _getSortDescription(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Color(AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortDescription() {
    switch (_sortBy) {
      case 'date_added':
        return 'Sorted by Date Added';
      case 'title':
        return 'Sorted by Title';
      case 'author':
        return 'Sorted by Author';
      case 'hymn_number':
        return 'Sorted by Hymn Number';
      default:
        return 'Sorted by Date Added';
    }
  }

  Widget _buildFavoriteItem(dynamic hymn, FavoritesProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing4,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Center(
            child: Text(
              hymn.hymnNumber.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Color(AppColors.primaryBlue),
                fontWeight: FontWeight.bold,
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
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (hymn.firstLine != null)
              Text(
                hymn.firstLine,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
                await provider.removeFavorite(hymn.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${hymn.title} removed from favorites'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await provider.addFavorite(hymn.id);
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          // Navigate to hymn detail
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Color(AppColors.gray500),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              AppStrings.noFavorites,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Tap the heart icon on any hymn to add it to your favorites',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Color(AppColors.gray500),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing24),
            ElevatedButton(
              onPressed: () {
                // Navigate to browse or home
              },
              child: const Text('Browse Hymns'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Color(AppColors.errorRed),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'Error Loading Favorites',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Color(AppColors.gray500),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing16),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}