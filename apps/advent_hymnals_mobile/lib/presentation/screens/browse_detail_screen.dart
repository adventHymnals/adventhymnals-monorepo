import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/database/database_helper.dart';
import '../../domain/entities/hymn.dart';
import '../widgets/banner_ad_widget.dart';

enum BrowseCategory {
  authors,
  composers,
  topics,
  meters,
  tunes,
  scripture,
}

class BrowseDetailScreen extends StatefulWidget {
  final BrowseCategory category;
  final String? selectedItem;

  const BrowseDetailScreen({
    super.key,
    required this.category,
    this.selectedItem,
  });

  @override
  State<BrowseDetailScreen> createState() => _BrowseDetailScreenState();
}

class _BrowseDetailScreenState extends State<BrowseDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  List<Hymn> _hymns = [];
  bool _isLoading = true;
  bool _isLoadingHymns = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (widget.selectedItem != null) {
      _loadHymnsForItem(widget.selectedItem!);
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseHelper.instance;
      final database = await db.database;

      List<Map<String, dynamic>> results = [];

      switch (widget.category) {
        case BrowseCategory.authors:
          results = await database.rawQuery('''
            SELECT author_name as name, COUNT(*) as hymn_count
            FROM hymns 
            WHERE author_name IS NOT NULL AND author_name != ''
            GROUP BY author_name
            ORDER BY hymn_count DESC, author_name ASC
          ''');
          break;
        case BrowseCategory.composers:
          results = await database.rawQuery('''
            SELECT composer as name, COUNT(*) as hymn_count
            FROM hymns 
            WHERE composer IS NOT NULL AND composer != ''
            GROUP BY composer
            ORDER BY hymn_count DESC, composer ASC
          ''');
          break;
        case BrowseCategory.topics:
          results = await database.rawQuery('''
            SELECT t.name, COUNT(ht.hymn_id) as hymn_count
            FROM topics t
            LEFT JOIN hymn_topics ht ON t.id = ht.topic_id
            GROUP BY t.id, t.name
            HAVING hymn_count > 0
            ORDER BY hymn_count DESC, t.name ASC
          ''');
          break;
        case BrowseCategory.meters:
          results = await database.rawQuery('''
            SELECT meter as name, COUNT(*) as hymn_count
            FROM hymns 
            WHERE meter IS NOT NULL AND meter != ''
            GROUP BY LOWER(REPLACE(REPLACE(meter, '.', ''), ' ', ''))
            ORDER BY hymn_count DESC, meter ASC
          ''');
          break;
        case BrowseCategory.tunes:
          results = await database.rawQuery('''
            SELECT tune_name as name, COUNT(*) as hymn_count
            FROM hymns 
            WHERE tune_name IS NOT NULL AND tune_name != ''
            GROUP BY LOWER(REPLACE(REPLACE(tune_name, '.', ''), ' ', ''))
            ORDER BY hymn_count DESC, tune_name ASC
          ''');
          break;
        case BrowseCategory.scripture:
          results = await database.rawQuery('''
            SELECT scripture_refs as name, COUNT(*) as hymn_count
            FROM hymns 
            WHERE scripture_refs IS NOT NULL AND scripture_refs != ''
            GROUP BY scripture_refs
            ORDER BY hymn_count DESC, scripture_refs ASC
          ''');
          break;
      }

      setState(() {
        _items = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ${widget.category.name}: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHymnsForItem(String itemName) async {
    setState(() {
      _isLoadingHymns = true;
    });

    try {
      final db = DatabaseHelper.instance;
      final database = await db.database;

      List<Map<String, dynamic>> results = [];

      switch (widget.category) {
        case BrowseCategory.authors:
          results = await database.rawQuery('''
            SELECT h.*, c.name as collection_name, c.abbreviation as collection_abbr,
                   CASE WHEN f.hymn_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
            FROM hymns h
            LEFT JOIN collections c ON h.collection_id = c.id
            LEFT JOIN favorites f ON h.id = f.hymn_id AND f.user_id = 'default'
            WHERE h.author_name = ?
            ORDER BY h.title ASC
          ''', [itemName]);
          break;
        case BrowseCategory.composers:
          results = await database.rawQuery('''
            SELECT h.*, c.name as collection_name, c.abbreviation as collection_abbr,
                   CASE WHEN f.hymn_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
            FROM hymns h
            LEFT JOIN collections c ON h.collection_id = c.id
            LEFT JOIN favorites f ON h.id = f.hymn_id AND f.user_id = 'default'
            WHERE h.composer = ?
            ORDER BY h.title ASC
          ''', [itemName]);
          break;
        case BrowseCategory.topics:
          results = await database.rawQuery('''
            SELECT h.*, c.name as collection_name, c.abbreviation as collection_abbr,
                   CASE WHEN f.hymn_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
            FROM hymns h
            LEFT JOIN collections c ON h.collection_id = c.id
            LEFT JOIN favorites f ON h.id = f.hymn_id AND f.user_id = 'default'
            INNER JOIN hymn_topics ht ON h.id = ht.hymn_id
            INNER JOIN topics t ON ht.topic_id = t.id
            WHERE t.name = ?
            ORDER BY h.title ASC
          ''', [itemName]);
          break;
        case BrowseCategory.meters:
          results = await database.rawQuery('''
            SELECT h.*, c.name as collection_name, c.abbreviation as collection_abbr,
                   CASE WHEN f.hymn_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
            FROM hymns h
            LEFT JOIN collections c ON h.collection_id = c.id
            LEFT JOIN favorites f ON h.id = f.hymn_id AND f.user_id = 'default'
            WHERE LOWER(REPLACE(REPLACE(h.meter, '.', ''), ' ', '')) = LOWER(REPLACE(REPLACE(?, '.', ''), ' ', ''))
            ORDER BY h.title ASC
          ''', [itemName]);
          break;
        case BrowseCategory.tunes:
          results = await database.rawQuery('''
            SELECT h.*, c.name as collection_name, c.abbreviation as collection_abbr,
                   CASE WHEN f.hymn_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
            FROM hymns h
            LEFT JOIN collections c ON h.collection_id = c.id
            LEFT JOIN favorites f ON h.id = f.hymn_id AND f.user_id = 'default'
            WHERE LOWER(REPLACE(REPLACE(h.tune_name, '.', ''), ' ', '')) = LOWER(REPLACE(REPLACE(?, '.', ''), ' ', ''))
            ORDER BY h.title ASC
          ''', [itemName]);
          break;
        case BrowseCategory.scripture:
          results = await database.rawQuery('''
            SELECT h.*, c.name as collection_name, c.abbreviation as collection_abbr,
                   CASE WHEN f.hymn_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
            FROM hymns h
            LEFT JOIN collections c ON h.collection_id = c.id
            LEFT JOIN favorites f ON h.id = f.hymn_id AND f.user_id = 'default'
            WHERE h.scripture_refs = ?
            ORDER BY h.title ASC
          ''', [itemName]);
          break;
      }

      final hymns = results.map((data) => _mapToHymn(data)).toList();

      setState(() {
        _hymns = hymns;
        _isLoadingHymns = false;
      });
    } catch (e) {
      print('Error loading hymns for ${widget.category.name}: $e');
      setState(() {
        _isLoadingHymns = false;
      });
    }
  }

  Hymn _mapToHymn(Map<String, dynamic> data) {
    return Hymn(
      id: data['id'] as int,
      hymnNumber: data['hymn_number'] as int,
      title: data['title'] as String,
      author: data['author_name'] as String?,
      composer: data['composer'] as String?,
      tuneName: data['tune_name'] as String?,
      meter: data['meter'] as String?,
      collectionId: data['collection_id'] as int?,
      collectionAbbreviation: data['collection_abbr'] as String?,
      lyrics: data['lyrics'] as String?,
      firstLine: data['first_line'] as String?,
      isFavorite: data['is_favorite'] == 1,
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_searchQuery.isEmpty) return _items;
    
    return _items.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Hymn> _getFilteredHymns() {
    if (_searchQuery.isEmpty) return _hymns;
    
    return _hymns.where((hymn) {
      final title = hymn.title.toLowerCase();
      final author = hymn.author?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return title.contains(query) || author.contains(query);
    }).toList();
  }

  String _getCategoryTitle() {
    switch (widget.category) {
      case BrowseCategory.authors:
        return 'Authors';
      case BrowseCategory.composers:
        return 'Composers';
      case BrowseCategory.topics:
        return 'Topics';
      case BrowseCategory.meters:
        return 'Meters';
      case BrowseCategory.tunes:
        return 'Tunes';
      case BrowseCategory.scripture:
        return 'Scripture';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedItem ?? _getCategoryTitle()),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.selectedItem != null) {
              // If viewing hymns for a specific item, go back to the category list
              context.go('/browse/${widget.category.name}');
            } else {
              // If viewing category list, go back to browse hub
              context.go('/browse');
            }
          },
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Go to Home',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: widget.selectedItem != null
                    ? 'Search hymns...'
                    : 'Search ${_getCategoryTitle().toLowerCase()}...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // Banner Ad
          const BannerAdWidget(),
          
          // Content
          Expanded(
            child: widget.selectedItem != null
                ? _buildHymnsList()
                : _buildItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No ${_getCategoryTitle().toLowerCase()} found'
                  : 'No results for "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final name = item['name']?.toString() ?? '';
        final hymnCount = item['hymn_count'] as int;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
          child: ListTile(
            title: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              '$hymnCount hymn${hymnCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.go('/browse/${widget.category.name}/${Uri.encodeComponent(name)}');
            },
          ),
        );
      },
    );
  }

  Widget _buildHymnsList() {
    if (_isLoadingHymns) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredHymns = _getFilteredHymns();

    if (filteredHymns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 64,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No hymns found'
                  : 'No hymns match "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: filteredHymns.length,
      itemBuilder: (context, index) {
        final hymn = filteredHymns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
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
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (hymn.firstLine != null)
                  Text(
                    hymn.firstLine!,
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
                if (hymn.isFavorite)
                  const Icon(
                    Icons.favorite,
                    color: Color(AppColors.errorRed),
                    size: 16,
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              // Pass collection information to hymn detail
              final collectionParam = hymn.collectionAbbreviation ?? hymn.collectionId?.toString();
              final route = collectionParam != null 
                ? '/hymn/${hymn.id}?collection=$collectionParam&from=browse'
                : '/hymn/${hymn.id}?from=browse';
              context.push(route);
            },
          ),
        );
      },
    );
  }
}