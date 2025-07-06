import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/hymnal_provider.dart';
import '../models/search.dart';
import '../models/hymnal.dart';
import '../widgets/app_drawer.dart';
import '../widgets/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  final List<String> _selectedHymnals = [];
  final List<SupportedLanguage> _selectedLanguages = [];
  final List<String> _selectedThemes = [];
  SortBy _sortBy = SortBy.relevance;
  SortOrder _sortOrder = SortOrder.desc;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _performSearch();
      }
      // Load browse data for filters
      context.read<HymnalProvider>().loadBrowseData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final searchParams = SearchParams(
      query: query,
      filters: SearchFilters(
        hymnals: _selectedHymnals.isEmpty ? null : _selectedHymnals,
        languages: _selectedLanguages.isEmpty ? null : _selectedLanguages,
        themes: _selectedThemes.isEmpty ? null : _selectedThemes,
      ),
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      page: 1,
      limit: 50,
    );

    context.read<HymnalProvider>().searchHymns(searchParams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hymns'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SearchBarWidget(
                  initialQuery: widget.initialQuery,
                  onSearch: _performSearch,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SortBy>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: SortBy.values.map((sortBy) =>
                          DropdownMenuItem(
                            value: sortBy,
                            child: Text(_getSortByName(sortBy)),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                            if (_searchController.text.isNotEmpty) {
                              _performSearch();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButtonFormField<SortOrder>(
                      value: _sortOrder,
                      decoration: const InputDecoration(
                        labelText: 'Order',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: SortOrder.values.map((order) =>
                        DropdownMenuItem(
                          value: order,
                          child: Text(order == SortOrder.asc ? 'Ascending' : 'Descending'),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortOrder = value);
                          if (_searchController.text.isNotEmpty) {
                            _performSearch();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters
          if (_showFilters)
            Consumer<HymnalProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Hymnal filter
                          if (provider.hymnalsList.isNotEmpty) ...[
                            Text('Hymnals:', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: provider.hymnalsList.take(10).map((hymnal) =>
                                FilterChip(
                                  label: Text(hymnal.abbreviation),
                                  selected: _selectedHymnals.contains(hymnal.id),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedHymnals.add(hymnal.id);
                                      } else {
                                        _selectedHymnals.remove(hymnal.id);
                                      }
                                    });
                                  },
                                ),
                              ).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Language filter
                          Text('Languages:', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: SupportedLanguage.values.map((lang) =>
                              FilterChip(
                                label: Text(_getLanguageName(lang)),
                                selected: _selectedLanguages.contains(lang),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedLanguages.add(lang);
                                    } else {
                                      _selectedLanguages.remove(lang);
                                    }
                                  });
                                },
                              ),
                            ).toList(),
                          ),
                          
                          // Theme filter
                          if (provider.themes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text('Themes:', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: provider.themes.take(15).map((themeData) =>
                                FilterChip(
                                  label: Text(themeData.theme),
                                  selected: _selectedThemes.contains(themeData.theme),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedThemes.add(themeData.theme);
                                      } else {
                                        _selectedThemes.remove(themeData.theme);
                                      }
                                    });
                                  },
                                ),
                              ).toList().cast<Widget>(),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedHymnals.clear();
                                    _selectedLanguages.clear();
                                    _selectedThemes.clear();
                                  });
                                },
                                child: const Text('Clear Filters'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _performSearch,
                                child: const Text('Apply Filters'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Search results
          Expanded(
            child: Consumer<HymnalProvider>(
              builder: (context, provider, child) {
                if (provider.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.searchError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Search Error',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.searchError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _performSearch,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final searchResponse = provider.searchResponse;
                if (searchResponse == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Enter a search term to find hymns',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Search by title, author, lyrics, or tune',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (searchResponse.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term or adjust your filters',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Results header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            '${searchResponse.total} result${searchResponse.total != 1 ? 's' : ''} found',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Results list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: searchResponse.results.length,
                        itemBuilder: (context, index) {
                          final result = searchResponse.results[index];
                          return _buildSearchResultCard(context, result);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(BuildContext context, SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/hymnals/${result.hymnal.id}/hymn/${result.hymn.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Hymn number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${result.hymn.number}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Hymn details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.hymn.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'from ${result.hymnal.title}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Match type and relevance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getMatchTypeColor(context, result.matchType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getMatchTypeName(result.matchType),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(result.relevanceScore * 100).round()}% match',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Additional info
              Row(
                children: [
                  if (result.hymn.author != null) ...[
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.hymn.author!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (result.hymn.author != null && result.hymn.tune != null)
                    Text(
                      ' • ',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  if (result.hymn.tune != null) ...[
                    Icon(
                      Icons.music_note,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.hymn.tune!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortByName(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.relevance:
        return 'Relevance';
      case SortBy.title:
        return 'Title';
      case SortBy.number:
        return 'Number';
      case SortBy.year:
        return 'Year';
      case SortBy.author:
        return 'Author';
    }
  }

  String _getLanguageName(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.en:
        return 'English';
      case SupportedLanguage.sw:
        return 'Kiswahili';
      case SupportedLanguage.luo:
        return 'Dholuo';
      case SupportedLanguage.fr:
        return 'French';
      case SupportedLanguage.es:
        return 'Spanish';
      case SupportedLanguage.de:
        return 'German';
      case SupportedLanguage.pt:
        return 'Portuguese';
      case SupportedLanguage.it:
        return 'Italian';
    }
  }

  String _getMatchTypeName(MatchType matchType) {
    switch (matchType) {
      case MatchType.title:
        return 'Title';
      case MatchType.author:
        return 'Author';
      case MatchType.lyrics:
        return 'Lyrics';
      case MatchType.tune:
        return 'Tune';
      case MatchType.theme:
        return 'Theme';
    }
  }

  Color _getMatchTypeColor(BuildContext context, MatchType matchType) {
    switch (matchType) {
      case MatchType.title:
        return Colors.blue;
      case MatchType.author:
        return Colors.green;
      case MatchType.lyrics:
        return Colors.orange;
      case MatchType.tune:
        return Colors.purple;
      case MatchType.theme:
        return Colors.teal;
    }
  }
}