import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import '../../core/constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchFilters = [];
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      hymnProvider.searchHymns(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
    hymnProvider.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Search Filters
          if (_searchFilters.isNotEmpty) _buildSearchFilters(),
          
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
                
                return _buildSearchResults(provider.searchResults);
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
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _performSearch,
        decoration: InputDecoration(
          hintText: 'Search hymns, authors, or first lines...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
        ),
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
              label: Text(filter),
              onDeleted: () {
                setState(() {
                  _searchFilters.removeAt(index);
                });
              },
              deleteIcon: const Icon(Icons.close, size: 18),
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
          
          // Search by Category
          _buildSuggestionSection(
            title: 'Search by Category',
            suggestions: [
              'Praise and Worship',
              'Christmas',
              'Easter',
              'Communion',
              'Baptism',
            ],
          ),
          
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
              label: Text(suggestion),
              onPressed: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
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
        color: Color(AppColors.background),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Color(AppColors.gray300)),
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
          Icon(
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

  Widget _buildSearchResults(List<dynamic> results) {
    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
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
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sort',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Icon(Icons.sort),
                  ],
                ),
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

  Widget _buildSearchResultItem(dynamic hymn) {
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to hymn detail
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
            Icon(
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
                color: Color(AppColors.gray500),
              ),
              textAlign: TextAlign.center,
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
              'Search Error',
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
                setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}