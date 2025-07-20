import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../../core/services/projector_service.dart';
import '../../domain/entities/hymn.dart';

/// A widget for selecting hymns to project
class HymnSelectionWidget extends StatefulWidget {
  final VoidCallback? onHymnSelected;
  
  const HymnSelectionWidget({
    super.key,
    this.onHymnSelected,
  });

  @override
  State<HymnSelectionWidget> createState() => _HymnSelectionWidgetState();
}

class _HymnSelectionWidgetState extends State<HymnSelectionWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Hymn> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Perform search
    _performSearch(_searchController.text);
  }

  Future<void> _performSearch(String query) async {
    try {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      await hymnProvider.searchHymns(query);
      
      if (mounted) {
        setState(() {
          _searchResults = hymnProvider.searchResults;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),
        const SizedBox(height: 16),
        
        // Show search results if searching
        if (_searchController.text.isNotEmpty)
          _buildSearchResults()
        else
          _buildTabView(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search hymns by title, number, or lyrics...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Search Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _buildHymnList(_searchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return Expanded(
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Recent'),
                Tab(text: 'Favorites'),
                Tab(text: 'Popular'),
                Tab(text: 'All'),
              ],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentTab(),
                _buildFavoritesTab(),
                _buildPopularTab(),
                _buildAllHymnsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTab() {
    return Consumer<RecentlyViewedProvider>(
      builder: (context, provider, child) {
        if (provider.recentlyViewed.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'No Recent Hymns',
            message: 'Hymns you view will appear here',
          );
        }

        return _buildHymnList(provider.recentlyViewed);
      },
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        if (provider.favorites.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorites',
            message: 'Mark hymns as favorites to see them here',
          );
        }

        return _buildHymnList(provider.favorites);
      },
    );
  }

  Widget _buildPopularTab() {
    return Consumer<HymnProvider>(
      builder: (context, provider, child) {
        // For now, show all hymns as popular
        // In a real app, this would be based on usage statistics
        return _buildHymnList(provider.hymns);
      },
    );
  }

  Widget _buildAllHymnsTab() {
    return Consumer<HymnProvider>(
      builder: (context, provider, child) {
        return _buildHymnList(provider.hymns);
      },
    );
  }

  Widget _buildHymnList(List<Hymn> hymns) {
    if (hymns.isEmpty) {
      return _buildEmptyState(
        icon: Icons.music_note,
        title: 'No Hymns',
        message: 'No hymns available',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymns[index];
        return _buildHymnCard(hymn);
      },
    );
  }

  Widget _buildHymnCard(Hymn hymn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            hymn.hymnNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          hymn.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hymn.author != null) ...[
              const SizedBox(height: 4),
              Text(
                'By ${hymn.author}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (hymn.themeTags?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: hymn.themeTags!.take(3).map((tag) {
                  return Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () => _previewHymn(hymn),
              tooltip: 'Preview',
            ),
            ElevatedButton.icon(
              onPressed: () => _selectHymn(hymn),
              icon: const Icon(Icons.cast),
              label: const Text('Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        onTap: () => _selectHymn(hymn),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _selectHymn(Hymn hymn) {
    final projectorService = ProjectorService();
    projectorService.startProjector(hymn.id);
    
    // Add to recently viewed
    final recentlyViewedProvider = Provider.of<RecentlyViewedProvider>(context, listen: false);
    recentlyViewedProvider.addRecentlyViewed(hymn.id);
    
    // Call the callback
    widget.onHymnSelected?.call();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Projecting "${hymn.title}"'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Stop',
          onPressed: () {
            projectorService.stopProjector();
          },
        ),
      ),
    );
  }

  void _previewHymn(Hymn hymn) {
    showDialog(
      context: context,
      builder: (context) => _HymnPreviewDialog(hymn: hymn),
    );
  }
}

class _HymnPreviewDialog extends StatelessWidget {
  final Hymn hymn;

  const _HymnPreviewDialog({required this.hymn});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(hymn.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hymn.author != null) ...[
              Text(
                'By ${hymn.author}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (hymn.lyrics != null) ...[
              Text(
                hymn.lyrics!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else ...[
              Text(
                'No lyrics available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            final projectorService = ProjectorService();
            projectorService.startProjector(hymn.id);
          },
          icon: const Icon(Icons.cast),
          label: const Text('Project'),
        ),
      ],
    );
  }
}