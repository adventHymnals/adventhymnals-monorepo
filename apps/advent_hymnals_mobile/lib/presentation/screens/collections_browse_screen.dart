import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/data/collections_data_manager.dart';
import '../../core/services/collection_sorting_service.dart';
import '../../core/database/database_helper.dart';

class CollectionsBrowseScreen extends StatefulWidget {
  const CollectionsBrowseScreen({super.key});

  @override
  State<CollectionsBrowseScreen> createState() => _CollectionsBrowseScreenState();
}

class _CollectionsBrowseScreenState extends State<CollectionsBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<CollectionInfo> _collections = [];
  List<String> _selectedLanguages = [];
  bool _isLoading = true;
  CollectionSortBy _currentSortBy = CollectionSortBy.titleAsc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollections();
    });
  }

  Future<void> _loadCollections() async {
    try {
      // Load saved sorting preference
      final savedSortBy = await CollectionSortingService.loadSortPreference();
      
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList();
      
      setState(() {
        _currentSortBy = savedSortBy;
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [CollectionsBrowse] Error loading collections: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<CollectionInfo> get _filteredCollections {
    var filtered = _collections;
    
    // Apply language filter
    if (_selectedLanguages.isNotEmpty) {
      filtered = filtered.where((collection) {
        final languageCode = _getLanguageCode(collection.language);
        return _selectedLanguages.contains(languageCode);
      }).toList();
    }
    
    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((collection) =>
          collection.title.toLowerCase().contains(query) ||
          collection.id.toLowerCase().contains(query) || // Search by abbreviation (SDAH)
          collection.description.toLowerCase().contains(query) ||
          collection.year.toString().contains(query)
      ).toList();
    }
    
    // Apply sorting
    filtered = CollectionSortingService.sortCollections(filtered, _currentSortBy);
    
    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/browse');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text(AppStrings.collectionsTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort Collections',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Collections',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            color: const Color(AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse Collections',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Explore hymnal collections from different eras',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, abbreviation (SDAH), or year...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                // Filter chips
                if (_selectedLanguages.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spacing12),
                  Wrap(
                    spacing: 8,
                    children: _selectedLanguages.map((lang) => FilterChip(
                      label: Text(
                        _getLanguageName(lang),
                        style: const TextStyle(
                          color: Color(AppColors.primaryBlue),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onSelected: (selected) {
                        if (!selected) {
                          setState(() {
                            _selectedLanguages.remove(lang);
                          });
                        }
                      },
                      onDeleted: () {
                        setState(() {
                          _selectedLanguages.remove(lang);
                        });
                      },
                      selectedColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
                      backgroundColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
                      checkmarkColor: const Color(AppColors.primaryBlue),
                      deleteIconColor: const Color(AppColors.primaryBlue),
                      side: const BorderSide(
                        color: Color(AppColors.primaryBlue),
                        width: 1,
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredCollections.isEmpty
                    ? _buildEmptyState()
                    : _buildCollectionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSizes.spacing16),
          Text('Loading collections...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No collections found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(AppColors.gray700),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Try adjusting your search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredCollections.length,
      itemBuilder: (context, index) {
        final collection = _filteredCollections[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: InkWell(
              onTap: () {
                // Navigate to collection detail page
                print('🔍 [CollectionsBrowse] Navigating to collection: ${collection.id}');
                context.push('/collection/${collection.id}');
              },
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 80,
                    decoration: BoxDecoration(
                      color: collection.color,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: collection.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.library_books,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing4),
                        Text(
                          'Published in ${collection.year}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(AppColors.gray600),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Text(
                          collection.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(AppColors.gray700),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacing8,
                            vertical: AppSizes.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: collection.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(
                            '${collection.hymnCount} hymns',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: collection.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(AppColors.gray500),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'swa':
        return 'Kiswahili';
      case 'luo':
        return 'Dholuo';
      default:
        return code.toUpperCase();
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
      // Fallback to collection-based languages
      final uniqueLanguages = <String, int>{};
      for (var collection in _collections) {
        final langCode = _getLanguageCode(collection.language);
        uniqueLanguages[langCode] = (uniqueLanguages[langCode] ?? 0) + 1;
      }
      
      return uniqueLanguages.entries.map((entry) => {
        'language': entry.key,
        'collection_count': entry.value,
      }).toList();
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Collections'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSortSection('Title', [
                  CollectionSortBy.titleAsc,
                  CollectionSortBy.titleDesc,
                ]),
                const SizedBox(height: 16),
                _buildSortSection('Year', [
                  CollectionSortBy.yearAsc,
                  CollectionSortBy.yearDesc,
                ]),
                const SizedBox(height: 16),
                _buildSortSection('Language', [
                  CollectionSortBy.languageAsc,
                  CollectionSortBy.languageDesc,
                ]),
                const SizedBox(height: 16),
                _buildSortSection('Hymn Count', [
                  CollectionSortBy.hymnCountAsc,
                  CollectionSortBy.hymnCountDesc,
                ]),
                const SizedBox(height: 16),
                _buildSortSection('Abbreviation', [
                  CollectionSortBy.abbreviationAsc,
                  CollectionSortBy.abbreviationDesc,
                ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection(String title, List<CollectionSortBy> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(AppColors.primaryBlue),
          ),
        ),
        ...options.map((sortBy) => RadioListTile<CollectionSortBy>(
          title: Text(sortBy.displayName),
          value: sortBy,
          groupValue: _currentSortBy,
          onChanged: (value) {
            if (value != null) {
              _changeSortBy(value);
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        )),
      ],
    );
  }

  Future<void> _changeSortBy(CollectionSortBy newSortBy) async {
    setState(() {
      _currentSortBy = newSortBy;
    });
    
    // Save the preference
    await CollectionSortingService.saveSortPreference(newSortBy);
  }

  void _showFilterDialog() {
    List<String> tempSelectedLanguages = List.from(_selectedLanguages);

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
                          title: Text('${_getLanguageName(languageCode)} ($collectionCount)'),
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
                this.setState(() {
                  _selectedLanguages = tempSelectedLanguages;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

