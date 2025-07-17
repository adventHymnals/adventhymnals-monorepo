import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/data/collections_data_manager.dart';
import '../../core/services/collection_sorting_service.dart';
import '../../core/database/database_helper.dart';

// Using the same enum as home screen for consistency
enum CollectionSortOption {
  name,
  year,
  language,
  hymnCount,
}

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
  bool _showAudioOnly = false;
  bool _showFavoritesOnly = false;
  bool _isLoading = true;
  
  // Collection sorting state - same as home screen
  CollectionSortOption _sortOption = CollectionSortOption.year;
  bool _sortAscending = false; // Default to descending (newest first for year)
  
  // SharedPreferences keys - same as home screen
  static const String _sortOptionKey = 'collection_sort_option';
  static const String _sortAscendingKey = 'collection_sort_ascending';
  static const String _selectedLanguagesKey = 'collection_selected_languages';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
      _loadCollections();
    });
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sortOptionIndex = prefs.getInt(_sortOptionKey) ?? CollectionSortOption.year.index;
      final sortAscending = prefs.getBool(_sortAscendingKey) ?? false;
      final selectedLanguages = prefs.getStringList(_selectedLanguagesKey) ?? [];
      
      setState(() {
        _sortOption = CollectionSortOption.values[sortOptionIndex];
        _sortAscending = sortAscending;
        _selectedLanguages = selectedLanguages;
      });
      
      print('🔄 [CollectionsBrowse] Loaded preferences: sort=${_sortOption.name}, ascending=$_sortAscending, languages=$_selectedLanguages');
    } catch (e) {
      print('❌ [CollectionsBrowse] Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sortOptionKey, _sortOption.index);
      await prefs.setBool(_sortAscendingKey, _sortAscending);
      await prefs.setStringList(_selectedLanguagesKey, _selectedLanguages);
      
      print('💾 [CollectionsBrowse] Saved preferences: sort=${_sortOption.name}, ascending=$_sortAscending, languages=$_selectedLanguages');
    } catch (e) {
      print('❌ [CollectionsBrowse] Error saving preferences: $e');
    }
  }

  Future<void> _loadCollections() async {
    try {
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList();
      
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
      
      // Sort collections with current preferences
      _sortCollections();
    } catch (e) {
      print('❌ [CollectionsBrowse] Error loading collections: $e');
      setState(() {
        _isLoading = false;
      });
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

  List<CollectionInfo> get _filteredCollections {
    var filtered = _collections;
    
    // Apply language filter - if no languages selected, show all
    if (_selectedLanguages.isNotEmpty) {
      filtered = filtered.where((collection) {
        final languageCode = _getLanguageCode(collection.language);
        return _selectedLanguages.contains(languageCode);
      }).toList();
    }
    
    // Apply audio filter (mock - would check real audio availability)
    if (_showAudioOnly) {
      filtered = filtered.where((collection) => ['SDAH', 'CS1900', 'CH1941'].contains(collection.id)).toList();
    }
    
    // Apply favorites filter (mock - would check user favorites)
    if (_showFavoritesOnly) {
      filtered = filtered.where((collection) => ['SDAH', 'CS1900'].contains(collection.id)).toList();
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
                        _getLanguageDisplayName(lang),
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
          
          // Status Section
          if (!_isLoading) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 18,
                        color: const Color(AppColors.gray600),
                      ),
                      const SizedBox(width: AppSizes.spacing4),
                      Text(
                        'Sort: ${_getSortLabel()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(AppColors.gray600),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_filteredCollections.length} collections',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.gray600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
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


  Future<List<Map<String, dynamic>>> _getAvailableLanguages() async {
    try {
      // Get languages from the collections data manager instead of database
      // This ensures consistency with the actual collection data displayed
      final collectionsDataManager = CollectionsDataManager();
      final collections = await collectionsDataManager.getCollectionsList(sortByYear: false);
      
      // Group collections by language and count them
      final languageMap = <String, int>{};
      for (final collection in collections) {
        final languageCode = _getLanguageCode(collection.language);
        languageMap[languageCode] = (languageMap[languageCode] ?? 0) + 1;
      }
      
      // Convert to the expected format
      final languages = languageMap.entries.map((entry) => {
        'language': entry.key,
        'collection_count': entry.value,
      }).toList();
      
      // Sort by collection count (descending) then by language code
      languages.sort((a, b) {
        final countCompare = (b['collection_count'] as int).compareTo(a['collection_count'] as int);
        if (countCompare != 0) return countCompare;
        return (a['language'] as String).compareTo(b['language'] as String);
      });
      
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

  void _showSortDialog() {
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
                  _savePreferences();
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
                  _savePreferences();
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


  void _showFilterDialog() {
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
                
                // Save preferences including language filters
                _savePreferences();
                
                Navigator.pop(context);
                
                // Show confirmation with language display names instead of codes
                final languageNames = tempSelectedLanguages.map((code) => _getLanguageDisplayName(code)).toList();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filters applied: ${languageNames.isEmpty ? 'All languages' : languageNames.join(', ')}'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

