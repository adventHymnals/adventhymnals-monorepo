import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/hymn_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/data/collections_data_manager.dart';
import '../../core/database/database_helper.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/projector_control_widget.dart';

enum CollectionSortOption {
  name,
  year,
  language,
  hymnCount,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CollectionInfo> _collections = [];
  List<String> _selectedLanguages = ['en']; // Default to English only
  bool _showAudioOnly = false;
  bool _showFavoritesOnly = false;
  
  // Collection sorting state
  CollectionSortOption _sortOption = CollectionSortOption.year;
  bool _sortAscending = false; // Default to descending (newest first for year)
  
  // SharedPreferences keys
  static const String _sortOptionKey = 'collection_sort_option';
  static const String _sortAscendingKey = 'collection_sort_ascending';
  
  @override
  void initState() {
    super.initState();
    // Schedule the async loading after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSortPreferences();
      _loadData();
      _loadCollections();
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

  Future<void> _loadCollections() async {
    try {
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList(sortByYear: false);
      setState(() {
        _collections = collections;
        _sortCollections();
      });
    } catch (e) {
      print('Error loading collections: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getAvailableLanguages() async {
    try {
      final db = DatabaseHelper.instance;
      
      // Get distinct languages from collections
      final languages = await db.database.then((database) => database.rawQuery('''
        SELECT DISTINCT language, COUNT(*) as collection_count
        FROM collections
        WHERE language IS NOT NULL
        GROUP BY language
        ORDER BY collection_count DESC, language ASC
      '''));
      
      return languages;
      
    } catch (e) {
      print('Error fetching languages: $e');
      // Fallback to hardcoded languages
      return [
        {'language': 'en', 'collection_count': 1},
        {'language': 'swa', 'collection_count': 1},
        {'language': 'luo', 'collection_count': 1},
      ];
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return 'English';
      case 'swa':
        return 'Kiswahili';
      case 'luo':
        return 'Dholuo';
      default:
        return languageCode.toUpperCase();
    }
  }

  Future<void> _loadSortPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sortOptionIndex = prefs.getInt(_sortOptionKey) ?? CollectionSortOption.year.index;
      final sortAscending = prefs.getBool(_sortAscendingKey) ?? false;
      
      setState(() {
        _sortOption = CollectionSortOption.values[sortOptionIndex];
        _sortAscending = sortAscending;
      });
      
      print('🔄 [HomeScreen] Loaded sort preferences: ${_sortOption.name}, ascending: $_sortAscending');
    } catch (e) {
      print('❌ [HomeScreen] Error loading sort preferences: $e');
    }
  }

  Future<void> _saveSortPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sortOptionKey, _sortOption.index);
      await prefs.setBool(_sortAscendingKey, _sortAscending);
      
      print('💾 [HomeScreen] Saved sort preferences: ${_sortOption.name}, ascending: $_sortAscending');
    } catch (e) {
      print('❌ [HomeScreen] Error saving sort preferences: $e');
    }
  }

  void _sortCollections() {
    switch (_sortOption) {
      case CollectionSortOption.name:
        _collections.sort((a, b) => _sortAscending 
          ? a.title.compareTo(b.title) 
          : b.title.compareTo(a.title));
        break;
      case CollectionSortOption.year:
        _collections.sort((a, b) => _sortAscending 
          ? a.year.compareTo(b.year) 
          : b.year.compareTo(a.year));
        break;
      case CollectionSortOption.language:
        _collections.sort((a, b) {
          final langCompare = _sortAscending 
            ? a.language.compareTo(b.language) 
            : b.language.compareTo(a.language);
          // Secondary sort by name if languages are the same
          return langCompare != 0 ? langCompare : a.title.compareTo(b.title);
        });
        break;
      case CollectionSortOption.hymnCount:
        _collections.sort((a, b) => _sortAscending 
          ? a.hymnCount.compareTo(b.hymnCount) 
          : b.hymnCount.compareTo(a.hymnCount));
        break;
    }
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
              
              // Projector Control Widget (Desktop only)
              if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
                const ProjectorControlWidget(),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Recent Hymns Section
              _buildRecentHymnsSection(),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Banner Ad
              const BannerAdWidget(),
              
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
        gradient: const LinearGradient(
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
    final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSizes.spacing12),
        
        // Desktop: Show projector mode prominently first
        if (isDesktop) ...[
          _buildProjectorModeCard(),
          const SizedBox(height: AppSizes.spacing16),
        ],
        
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
                  context.go('/browse/collections');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectorModeCard() {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(AppColors.purple),
              Color(AppColors.darkPurple),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: InkWell(
          onTap: () {
            context.go('/projector');
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.present_to_all,
                    size: AppSizes.iconSizeLarge,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projector Mode',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        'Display hymns on projector or second screen for worship',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
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
                color: const Color(AppColors.secondaryBlue),
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
                TextButton(
                  onPressed: () {
                    context.go('/recently-viewed');
                  },
                  child: Text(provider.recentlyViewed.isNotEmpty ? 'See All' : 'View'),
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
                TextButton(
                  onPressed: () {
                    context.go('/favorites');
                  },
                  child: Text(provider.favorites.isNotEmpty ? 'See All' : 'View'),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Browse Collections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 18,
                  ),
                  label: Text('Sort: ${_getSortLabel()}'),
                ),
                TextButton.icon(
                  onPressed: _showCollectionFilters,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),
        // Collection count indicator
        if (_collections.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
            child: Text(
              '${_buildFilteredCollections().length} collections',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(AppColors.gray600),
              ),
            ),
          ),
        ...(_buildFilteredCollections()),
        const SizedBox(height: AppSizes.spacing16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/browse/collections');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore All Collections'),
          ),
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
            // Pass hymn number instead of database ID, along with collection info
            // Always prefer abbreviation over ID to avoid showing numbers like '2'
            final collectionParam = hymn.collectionAbbreviation;
            final route = collectionParam != null 
              ? '/hymn/${hymn.hymnNumber}?collection=$collectionParam&from=home'
              : '/hymn/${hymn.hymnNumber}?from=home';
            context.go(route);
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hymn.collectionAbbreviation != null 
                    ? '${hymn.collectionAbbreviation} ${hymn.hymnNumber}'
                    : hymn.hymnNumber.toString(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(AppColors.secondaryBlue),
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

  List<Widget> _buildFilteredCollections() {
    if (_collections.isEmpty) {
      return [
        const Center(child: CircularProgressIndicator()),
      ];
    }
    
    final filteredCollections = <Widget>[];
    
    for (final collection in _collections) {
      // Apply language filter
      final languageCode = _getLanguageCode(collection.language);
      if (_selectedLanguages.isNotEmpty && !_selectedLanguages.contains(languageCode)) {
        continue;
      }
      
      // Apply audio filter (mock - would check real audio availability)
      if (_showAudioOnly && !['SDAH', 'CS1900', 'CH1941'].contains(collection.id)) {
        continue;
      }
      
      // Apply favorites filter (mock - would check user favorites)
      if (_showFavoritesOnly && !['SDAH', 'CS1900'].contains(collection.id)) {
        continue;
      }
      
      filteredCollections.add(
        _buildCollectionCard(
          title: collection.title,
          subtitle: collection.subtitle,
          color: collection.color,
          collectionId: collection.id,
          isBundled: collection.bundled,
        ),
      );
      
      if (filteredCollections.length < _collections.length) {
        filteredCollections.add(const SizedBox(height: AppSizes.spacing8));
      }
    }
    
    if (filteredCollections.isEmpty) {
      filteredCollections.add(
        Container(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.filter_list_off,
                  size: 48,
                  color: Color(AppColors.gray500),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'No collections match your filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(AppColors.gray600),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'Try adjusting your language or filter settings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray500),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return filteredCollections;
  }

  String _getLanguageCode(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english':
        return 'en';
      case 'kiswahili':
        return 'swa';
      case 'dholuo':
        return 'luo';
      default:
        return languageName.toLowerCase();
    }
  }

  String _getSortLabel() {
    switch (_sortOption) {
      case CollectionSortOption.name:
        return 'Name';
      case CollectionSortOption.year:
        return 'Year';
      case CollectionSortOption.language:
        return 'Language';
      case CollectionSortOption.hymnCount:
        return 'Hymns';
    }
  }

  IconData _getSortIcon() {
    switch (_sortOption) {
      case CollectionSortOption.name:
        return Icons.sort_by_alpha;
      case CollectionSortOption.year:
        return Icons.calendar_today;
      case CollectionSortOption.language:
        return Icons.language;
      case CollectionSortOption.hymnCount:
        return Icons.numbers;
    }
  }

  Widget _buildCollectionCard({
    required String title,
    required String subtitle,
    required Color color,
    String? collectionId,
    bool isBundled = false,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          if (collectionId != null) {
            context.go('/collection/$collectionId');
          } else {
            // Show collection details dialog
            _showCollectionDetails(title, subtitle);
          }
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
              const Icon(
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
            color: const Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(AppColors.gray700),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray500),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCollectionDetails(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 16),
            const Text('This collection contains hymns for worship and praise.'),
            const SizedBox(height: 16),
            Text('Available features:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            const Text('• Search by title, author, or lyrics'),
            const Text('• Audio playback for select hymns'),
            const Text('• Favorite hymns for quick access'),
            const Text('• Print and share functionality'),
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
              context.go('/browse');
            },
            child: const Text('Browse'),
          ),
        ],
      ),
    );
  }

  void _showCollectionFilters() {
    List<String> tempSelectedLanguages = List.from(_selectedLanguages);
    bool tempShowAudioOnly = _showAudioOnly;
    bool tempShowFavoritesOnly = _showFavoritesOnly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Collections'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Languages:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                
                // Dynamic language checkboxes from database
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getAvailableLanguages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final languages = snapshot.data ?? [];
                    
                    return Column(
                      children: languages.map((language) {
                        final languageCode = language['language'] as String;
                        final collectionCount = language['collection_count'] as int;
                        
                        return CheckboxListTile(
                          title: Text('${_getLanguageDisplayName(languageCode)} ($collectionCount)'),
                          value: tempSelectedLanguages.contains(languageCode),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                tempSelectedLanguages.add(languageCode);
                              } else {
                                tempSelectedLanguages.remove(languageCode);
                              }
                            });
                          },
                          dense: true,
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Other filters
                CheckboxListTile(
                  title: const Text('Collections with audio'),
                  value: tempShowAudioOnly,
                  onChanged: (value) {
                    setState(() {
                      tempShowAudioOnly = value ?? false;
                    });
                  },
                  dense: true,
                ),
                CheckboxListTile(
                  title: const Text('Downloaded collections only'),
                  value: tempShowFavoritesOnly,
                  onChanged: (value) {
                    setState(() {
                      tempShowFavoritesOnly = value ?? false;
                    });
                  },
                  dense: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Apply the filters to the main state
                this.setState(() {
                  _selectedLanguages = tempSelectedLanguages;
                  _showAudioOnly = tempShowAudioOnly;
                  _showFavoritesOnly = tempShowFavoritesOnly;
                });
                Navigator.pop(context);
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filters applied: ${tempSelectedLanguages.isEmpty ? 'All languages' : tempSelectedLanguages.join(', ')}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Collections'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(_getSortIcon()),
              title: Text('Sort by ${_getSortLabel()}'),
              subtitle: Text(_sortAscending ? 'Ascending' : 'Descending'),
              trailing: IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: const Color(AppColors.primaryBlue),
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _sortCollections();
                  });
                  _saveSortPreferences();
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            const Text('Sort Options:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...CollectionSortOption.values.map((option) {
              final isSelected = _sortOption == option;
              return ListTile(
                leading: Icon(
                  _getSortIconForOption(option),
                  color: isSelected ? const Color(AppColors.primaryBlue) : null,
                ),
                title: Text(_getSortLabelForOption(option)),
                trailing: isSelected 
                  ? const Icon(Icons.check, color: Color(AppColors.primaryBlue))
                  : null,
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _sortOption = option;
                    _sortCollections();
                  });
                  _saveSortPreferences();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getSortLabelForOption(CollectionSortOption option) {
    switch (option) {
      case CollectionSortOption.name:
        return 'Name';
      case CollectionSortOption.year:
        return 'Year';
      case CollectionSortOption.language:
        return 'Language';
      case CollectionSortOption.hymnCount:
        return 'Hymn Count';
    }
  }

  IconData _getSortIconForOption(CollectionSortOption option) {
    switch (option) {
      case CollectionSortOption.name:
        return Icons.sort_by_alpha;
      case CollectionSortOption.year:
        return Icons.calendar_today;
      case CollectionSortOption.language:
        return Icons.language;
      case CollectionSortOption.hymnCount:
        return Icons.numbers;
    }
  }
}