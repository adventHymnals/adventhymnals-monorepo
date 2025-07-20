import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/hymn_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/hymn.dart';
import '../widgets/banner_ad_widget.dart';
import '../../core/utils/search_query_parser.dart';
import '../../core/models/search_query.dart';
import '../../core/database/database_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _searchFilters = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    // Load available collections for filtering and initialize search parser
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      hymnProvider.loadAvailableCollections();
      // Pre-load search query parser abbreviations
      _preloadSearchAbbreviations();
    });
  }

  void _preloadSearchAbbreviations() async {
    try {
      // This will cache the abbreviations for sync usage
      await SearchQueryParser.parse('');
    } catch (e) {
      print('Warning: Could not preload search abbreviations: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
    if (query.isNotEmpty) {
      hymnProvider.searchHymns(query);
    } else {
      // When search is cleared, reset to initial state
      hymnProvider.clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
    hymnProvider.clearSearch();
  }

  List<Hymn> _applySearchFilters(List<Hymn> results) {
    if (_searchFilters.isEmpty) return results;
    
    return results.where((hymn) {
      // Apply "favorites only" filter
      if (_searchFilters.contains('favorites') && !hymn.isFavorite) {
        return false;
      }
      
      // Apply "hymns only" filter (exclude other types if we had them)
      if (_searchFilters.contains('hymns')) {
        // For now, all results are hymns, so this doesn't filter anything
        // This could be extended if we had other content types
      }
      
      // Apply "with audio" filter
      if (_searchFilters.contains('audio')) {
        // TODO: Implement audio availability checking when has_audio field is added to Hymn entity
        // For now, we'll assume all hymns potentially have audio
        // This could be extended with actual audio availability checking
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.go('/home');
            } catch (e) {
              print('❌ [SearchScreen] Navigation error: $e');
              // Fallback to Navigator.pop if context.go fails
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          tooltip: 'Back to Home',
        ),
        actions: [
          // Temporarily disabled filter buttons
          // IconButton(
          //   icon: const Icon(Icons.tune),
          //   onPressed: () => _showCollectionFilterDialog(context),
          //   tooltip: 'Filter Collections',
          // ),
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   onPressed: _showFilterDialog,
          //   tooltip: 'Other Filters',
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Collection Filters
          Consumer<HymnProvider>(
            builder: (context, provider, child) {
              if (provider.selectedCollections.isNotEmpty) {
                return _buildCollectionFilters(provider);
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Hymnal Filters (from search query parsing)
          Consumer<HymnProvider>(
            builder: (context, provider, child) {
              if (provider.searchQuery.isNotEmpty) {
                final parsedQuery = SearchQueryParser.parseSync(provider.searchQuery);
                if (parsedQuery != null && parsedQuery.hasHymnalFilter) {
                  return _buildHymnalFilters(parsedQuery);
                }
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Search Filters
          if (_searchFilters.isNotEmpty) _buildSearchFilters(),
          
          // Banner Ad
          const BannerAdWidget(),
          
          // Search Results
          Expanded(
            child: Consumer<HymnProvider>(
              builder: (context, provider, child) {
                if (provider.searchQuery.isEmpty) {
                  return _buildSearchSuggestions();
                }
                
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.hasError) {
                  return _buildErrorState(provider.errorMessage ?? 'Search failed');
                }
                
                if (provider.searchResults.isEmpty) {
                  return _buildEmptyResults();
                }
                
                // Apply local filters to search results
                final filteredResults = _applySearchFilters(provider.searchResults);
                return _buildSearchResults(filteredResults);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Consumer<HymnProvider>(
        builder: (context, provider, child) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'Search hymns, authors, or first lines...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: (_searchController.text.isNotEmpty || provider.searchQuery.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _searchFilters.length,
        itemBuilder: (context, index) {
          final filter = _searchFilters[index];
          return Container(
            margin: const EdgeInsets.only(right: AppSizes.spacing8),
            child: FilterChip(
              label: Text(
                filter,
                style: const TextStyle(
                  color: Color(AppColors.primaryBlue),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onDeleted: () {
                setState(() {
                  _searchFilters.removeAt(index);
                });
              },
              deleteIcon: const Icon(
                Icons.close, 
                size: 18,
                color: Color(AppColors.primaryBlue),
              ),
              onSelected: (bool selected) {
                // Handle filter selection
              },
              selectedColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
              backgroundColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
              checkmarkColor: const Color(AppColors.primaryBlue),
              deleteIconColor: const Color(AppColors.primaryBlue),
              side: const BorderSide(
                color: Color(AppColors.primaryBlue),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Suggestions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spacing16),
          
          // Popular Searches
          _buildSuggestionSection(
            title: 'Popular Searches',
            suggestions: [
              'Amazing Grace',
              'Holy Holy Holy',
              'Great is Thy Faithfulness',
              'How Great Thou Art',
              'Jesus Loves Me',
            ],
          ),
          
          const SizedBox(height: AppSizes.spacing24),
          
          // Search by Category (Real Topics from Database)
          _buildTopicSuggestionSection(),
          
          const SizedBox(height: AppSizes.spacing24),
          
          // Search Tips
          _buildSearchTips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection({
    required String title,
    required List<String> suggestions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.spacing12),
        Wrap(
          spacing: AppSizes.spacing8,
          runSpacing: AppSizes.spacing8,
          children: suggestions.map((suggestion) {
            return ActionChip(
              label: Text(
                suggestion,
                style: const TextStyle(
                  color: Color(AppColors.gray700),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
              backgroundColor: const Color(AppColors.gray100),
              side: const BorderSide(
                color: Color(AppColors.gray300),
                width: 1,
              ),
              pressElevation: 2,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchTips() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: const Color(AppColors.background),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: const Color(AppColors.gray300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Tips',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.spacing8),
          _buildTipItem('Search by hymn number: "123"'),
          _buildTipItem('Search by author: "Charles Wesley"'),
          _buildTipItem('Search by first line: "Amazing grace how sweet"'),
          _buildTipItem('Search by topic: "praise" or "Christmas"'),
          const SizedBox(height: AppSizes.spacing12),
          // Hymnal abbreviations from database
          _buildHymnalAbbreviationsSection(),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: Color(AppColors.warningOrange),
          ),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Hymn> results) {
    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'}${_searchFilters.isNotEmpty ? ' (filtered)' : ''}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Consumer<HymnProvider>(
                builder: (context, provider, child) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      provider.setSortBy(value);
                    },
                    initialValue: provider.sortBy,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'relevance',
                    child: Text('Sort by Relevance'),
                  ),
                  const PopupMenuItem(
                    value: 'title',
                    child: Text('Sort by Title'),
                  ),
                  const PopupMenuItem(
                    value: 'author',
                    child: Text('Sort by Author'),
                  ),
                  const PopupMenuItem(
                    value: 'hymn_number',
                    child: Text('Sort by Hymn Number'),
                  ),
                  const PopupMenuItem(
                    value: 'hymnal',
                    child: Text('Sort by Hymnal'),
                  ),
                ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getSortLabel(provider.sortBy),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Icon(Icons.sort),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Results List
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final hymn = results[index];
              return _buildSearchResultItem(hymn);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(Hymn hymn) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing4,
      ),
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to hymn detail
          context.push('/hymn/${hymn.id}');
        },
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Color(AppColors.gray500),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              AppStrings.noResults,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              'Try adjusting your search terms or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(AppColors.gray500),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    // Check if this is a database initialization error
    final isDatabaseError = error.contains('databaseFactory') || 
                          error.contains('getApplicationsDirectory') ||
                          error.contains('Bad state: databaseFactory not initialized');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDatabaseError ? Icons.info_outline : Icons.error_outline,
              size: 64,
              color: isDatabaseError ? const Color(AppColors.primaryBlue) : const Color(AppColors.errorRed),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              isDatabaseError ? 'Search Information' : 'Search Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              isDatabaseError 
                  ? 'Search is currently using demonstration data. Full database functionality will be available when the hymnal database is loaded.'
                  : error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(AppColors.gray500),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing16),
            ElevatedButton(
              onPressed: () {
                _performSearch(_searchController.text);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHymnalFilters(SearchQuery parsedQuery) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing8),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: Color(AppColors.successGreen),
          ),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            'Active Filter:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.gray600),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSizes.spacing8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing4,
            ),
            decoration: BoxDecoration(
              color: const Color(AppColors.successGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: const Color(AppColors.successGreen),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.library_books,
                  size: 14,
                  color: const Color(AppColors.successGreen),
                ),
                const SizedBox(width: AppSizes.spacing4),
                Text(
                  _buildHymnalFilterText(parsedQuery),
                  style: const TextStyle(
                    color: Color(AppColors.successGreen),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing4),
                GestureDetector(
                  onTap: () => _clearHymnalFilter(),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(AppColors.successGreen),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${_getFilteredResultsCount()} results',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }

  String _buildHymnalFilterText(SearchQuery parsedQuery) {
    final hymnal = parsedQuery.hymnalAbbreviation!;
    if (parsedQuery.hymnNumber != null) {
      return '$hymnal #${parsedQuery.hymnNumber}';
    } else if (parsedQuery.searchText.isNotEmpty) {
      return '$hymnal: "${parsedQuery.searchText}"';
    } else {
      return hymnal;
    }
  }

  int _getFilteredResultsCount() {
    final provider = Provider.of<HymnProvider>(context, listen: false);
    return provider.searchResults.length;
  }

  void _clearHymnalFilter() {
    final provider = Provider.of<HymnProvider>(context, listen: false);
    final parsedQuery = SearchQueryParser.parseSync(provider.searchQuery);
    
    // If there's search text without hymnal filter, keep just the search text
    if (parsedQuery != null && parsedQuery.searchText.isNotEmpty) {
      _searchController.text = parsedQuery.searchText;
      _performSearch(parsedQuery.searchText);
    } else {
      // Clear the entire search
      _clearSearch();
    }
  }

  Widget _buildCollectionFilters(HymnProvider provider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.selectedCollections.length,
        itemBuilder: (context, index) {
          final collectionId = provider.selectedCollections[index];
          final collection = provider.availableCollections.firstWhere(
            (c) => c['id'] == collectionId,
            orElse: () => <String, dynamic>{'name': collectionId, 'abbreviation': collectionId},
          );
          
          return Container(
            margin: const EdgeInsets.only(right: AppSizes.spacing8),
            child: FilterChip(
              label: Text(
                collection['abbreviation'] ?? collection['name'],
                style: const TextStyle(
                  color: Color(AppColors.primaryBlue),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              onDeleted: () {
                final updatedCollections = List<String>.from(provider.selectedCollections);
                updatedCollections.removeAt(index);
                provider.setSelectedCollections(updatedCollections);
              },
              deleteIcon: const Icon(
                Icons.close, 
                size: 16,
                color: Color(AppColors.primaryBlue),
              ),
              onSelected: (bool selected) {
                // Handle filter selection
              },
              selectedColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
              backgroundColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
              checkmarkColor: const Color(AppColors.primaryBlue),
              deleteIconColor: const Color(AppColors.primaryBlue),
              side: const BorderSide(
                color: Color(AppColors.primaryBlue),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'title':
        return 'Title';
      case 'author':
        return 'Author';
      case 'hymn_number':
        return 'Number';
      case 'hymnal':
        return 'Hymnal';
      case 'relevance':
      default:
        return 'Relevance';
    }
  }

  void _showCollectionFilterDialog(BuildContext context) {
    final provider = Provider.of<HymnProvider>(context, listen: false);
    List<String> tempSelected = List.from(provider.selectedCollections);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Group collections by language
            final groupedCollections = <String, List<Map<String, dynamic>>>{};
            for (final collection in provider.availableCollections) {
              final language = collection['language_name'] ?? 'Unknown';
              groupedCollections.putIfAbsent(language, () => []);
              groupedCollections[language]!.add(collection);
            }

            return AlertDialog(
              title: const Text('Filter by Hymnals'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              tempSelected.clear();
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              tempSelected = provider.availableCollections
                                  .map((c) => c['id'] as String)
                                  .toList();
                            });
                          },
                          child: const Text('Select All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedCollections.entries.map((entry) {
                            final language = entry.key;
                            final collections = entry.value;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    language,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(AppColors.primaryBlue),
                                    ),
                                  ),
                                ),
                                ...collections.map((collection) {
                                  final isSelected = tempSelected.contains(collection['id']);
                                  return CheckboxListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    title: Text(
                                      '${collection['name']} (${collection['abbreviation']})',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    value: isSelected,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        if (value == true) {
                                          if (!tempSelected.contains(collection['id'])) {
                                            tempSelected.add(collection['id'] as String);
                                          }
                                        } else {
                                          tempSelected.remove(collection['id']);
                                        }
                                      });
                                    },
                                  );
                                }),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.setSelectedCollections(tempSelected);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Hymns only'),
                value: _searchFilters.contains('hymns'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _searchFilters.add('hymns');
                    } else {
                      _searchFilters.remove('hymns');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('With audio'),
                value: _searchFilters.contains('audio'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _searchFilters.add('audio');
                    } else {
                      _searchFilters.remove('audio');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Favorites only'),
                value: _searchFilters.contains('favorites'),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _searchFilters.add('favorites');
                    } else {
                      _searchFilters.remove('favorites');
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Re-run search with updated filters
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
                setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopicSuggestionSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTopicsFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.spacing16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError) {
          print('Error loading topics: ${snapshot.error}');
          // Fallback to minimal categories if database fails
          return _buildSuggestionSection(
            title: 'Search by Category',
            suggestions: [
              'Praise and Worship',
              'Communion',
              'Baptism',
            ],
          );
        }
        
        final topics = snapshot.data ?? [];
        
        if (topics.isEmpty) {
          // Fallback to minimal categories if no topics in database
          return _buildSuggestionSection(
            title: 'Search by Category',
            suggestions: [
              'Praise and Worship',
              'Communion',
              'Baptism',
            ],
          );
        }
        
        // Use real topics from database
        final topicNames = topics.map((topic) => topic['name'] as String).toList();
        
        return _buildSuggestionSection(
          title: 'Search by Category',
          suggestions: topicNames,
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getTopicsFromDatabase() async {
    try {
      final db = DatabaseHelper.instance;
      
      // First check if we have data in the database
      final database = await db.database;
      
      // Check if topics table has data
      final topicsCheck = await database.rawQuery('SELECT COUNT(*) as count FROM topics');
      final topicsCount = topicsCheck.first['count'] as int;
      
      if (topicsCount == 0) {
        print('No topics found in database');
        return [];
      }
      
      // Get topics with hymn counts
      final topics = await database.rawQuery('''
        SELECT t.id, t.name, t.category, COUNT(ht.hymn_id) as hymn_count
        FROM topics t
        LEFT JOIN hymn_topics ht ON t.id = ht.topic_id
        GROUP BY t.id, t.name, t.category
        HAVING hymn_count > 0
        ORDER BY hymn_count DESC, t.name ASC
        LIMIT 10
      ''');
      
      print('Found ${topics.length} topics from database');
      return topics;
      
    } catch (e) {
      print('Error fetching topics from database: $e');
      return [];
    }
  }

  Widget _buildHymnalAbbreviationsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getHymnalAbbreviations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 30,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hymnal Abbreviations:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacing4),
              _buildTipItem('Search in specific hymnal: "SDAH:123" or "CH:Holy"'),
            ],
          );
        }
        
        final hymnals = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hymnal Abbreviations:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Wrap(
              spacing: AppSizes.spacing8,
              runSpacing: AppSizes.spacing4,
              children: hymnals.map((hymnal) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing8,
                    vertical: AppSizes.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: const Color(AppColors.primaryBlue).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    hymnal['abbreviation'] ?? hymnal['name'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.primaryBlue),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.spacing4),
            _buildTipItem('Search in specific hymnal: "SDAH:123" or "CH:Holy"'),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getHymnalAbbreviations() async {
    try {
      final db = DatabaseHelper.instance;
      
      // Get collections with their abbreviations
      final collections = await db.database.then((database) => database.rawQuery('''
        SELECT DISTINCT name, abbreviation
        FROM collections
        ORDER BY abbreviation ASC
      '''));
      
      return collections;
      
    } catch (e) {
      print('Error fetching hymnal abbreviations: $e');
      return [];
    }
  }
}