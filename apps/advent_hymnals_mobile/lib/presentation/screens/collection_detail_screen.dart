import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/data/collections_data_manager.dart';
import '../providers/hymn_provider.dart';
import '../../domain/entities/hymn.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionId;

  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  String _searchQuery = '';
  String _sortBy = 'hymn_number';
  List<String> _selectedLanguages = [];
  bool _showAudioOnly = false;
  CollectionInfo? _collectionInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollectionData();
    });
  }

  Future<void> _loadCollectionData() async {
    // Load collection metadata
    await _loadCollectionMetadata();
    
    // Load hymn data
    final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
    await hymnProvider.loadHymns();
  }

  Future<void> _loadCollectionMetadata() async {
    try {
      print('🔍 [CollectionDetail] Loading collection metadata for: ${widget.collectionId}');
      
      final collectionsDataManager = CollectionsDataManager();
      final collectionInfo = await collectionsDataManager.getCollectionById(widget.collectionId);
      
      setState(() {
        _collectionInfo = collectionInfo ?? _createNotFoundCollection(widget.collectionId);
      });
      
      print('🎯 [CollectionDetail] Collection info for ${widget.collectionId}: available=${_collectionInfo?.isAvailable}, title=${_collectionInfo?.title}');
    } catch (e) {
      print('❌ [CollectionDetail] Error loading collection metadata: $e');
      setState(() {
        _collectionInfo = _createNotFoundCollection(widget.collectionId);
      });
    }
  }

  CollectionInfo _createNotFoundCollection(String collectionId) {
    print('❌ [CollectionDetail] Collection not found: "$collectionId"');
    return CollectionInfo(
      id: collectionId,
      title: collectionId.toUpperCase(),
      subtitle: 'Collection not yet available',
      description: 'This hymnal collection is not currently available in the app. The collection data may be added in a future update, or it may need to be downloaded separately.',
      color: Color(AppColors.gray500),
      language: 'Unknown',
      hymnCount: 0,
      isAvailable: false,
      bundled: false,
      year: 0,
    );
  }

  List<Hymn> _getFilteredHymns(List<Hymn> hymns) {
    var filtered = hymns.where((hymn) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!hymn.title.toLowerCase().contains(query) &&
            !(hymn.author?.toLowerCase().contains(query) ?? false) &&
            !(hymn.firstLine?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filter by audio availability (mock implementation)
      if (_showAudioOnly) {
        // In a real app, this would check if the hymn has audio
        return hymn.hymnNumber % 3 == 0; // Mock: every 3rd hymn has audio
      }

      return true;
    }).toList();

    // Sort the results
    switch (_sortBy) {
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        filtered.sort((a, b) => (a.author ?? '').compareTo(b.author ?? ''));
        break;
      case 'hymn_number':
      default:
        filtered.sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final collectionInfo = _collectionInfo ?? CollectionInfo(
      id: widget.collectionId,
      title: 'Loading...',
      subtitle: 'Please wait',
      description: 'Loading collection information',
      color: Color(AppColors.primaryBlue),
      language: 'Loading',
      hymnCount: 0,
      isAvailable: true,
      bundled: false,
      year: 0,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Fallback to collections browse page since that's likely where they came from
              context.go('/browse/collections');
            }
          },
          tooltip: 'Back',
        ),
        title: Text(collectionInfo.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search Collection',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Collection Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.spacing20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  collectionInfo.color,
                  collectionInfo.color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      child: Icon(
                        Icons.library_books,
                        color: Colors.white,
                        size: AppSizes.iconSizeLarge,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collectionInfo.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacing4),
                          Text(
                            collectionInfo.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing16),
                Text(
                  collectionInfo.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Search Results or Hymn List
          Expanded(
            child: Consumer<HymnProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.hasError) {
                  return Center(
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
                          'Error Loading Collection',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Text(
                          provider.errorMessage ?? 'Unknown error occurred',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.spacing16),
                        ElevatedButton(
                          onPressed: _loadCollectionData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredHymns = _getFilteredHymns(provider.hymns);

                // Handle collection not available
                if (!collectionInfo.isAvailable) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 80,
                          color: Color(AppColors.gray400),
                        ),
                        const SizedBox(height: AppSizes.spacing20),
                        Text(
                          'Collection Not Available',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Color(AppColors.gray700),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing32),
                          child: Text(
                            'The "${collectionInfo.title}" collection is not currently available in the app.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Color(AppColors.gray600),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing32),
                          child: Text(
                            'This content may be added in a future update or may need to be downloaded separately.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Color(AppColors.gray500),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/browse'),
                              icon: const Icon(Icons.explore),
                              label: const Text('Browse Other Collections'),
                            ),
                            const SizedBox(width: AppSizes.spacing12),
                            OutlinedButton.icon(
                              onPressed: _loadCollectionData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Check Again'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                if (filteredHymns.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
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
                          'No Results Found',
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
                  );
                }
                
                // Handle empty collection (no hymns available)
                if (filteredHymns.isEmpty && _searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note_outlined,
                          size: 64,
                          color: Color(AppColors.gray400),
                        ),
                        const SizedBox(height: AppSizes.spacing16),
                        Text(
                          'No Hymns Available',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Color(AppColors.gray700),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing32),
                          child: Text(
                            'This collection doesn\'t have any hymns loaded yet. The content may be available for download or will be added in a future update.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Color(AppColors.gray500),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing16),
                        ElevatedButton.icon(
                          onPressed: _loadCollectionData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Results Summary
                    if (_searchQuery.isNotEmpty || _showAudioOnly)
                      Container(
                        padding: const EdgeInsets.all(AppSizes.spacing16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(AppColors.primaryBlue),
                            ),
                            const SizedBox(width: AppSizes.spacing8),
                            Expanded(
                              child: Text(
                                '${filteredHymns.length} hymns found',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Color(AppColors.primaryBlue),
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty || _showAudioOnly)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _showAudioOnly = false;
                                  });
                                },
                                child: const Text('Clear Filters'),
                              ),
                          ],
                        ),
                      ),

                    // Hymn List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.spacing16),
                        itemCount: filteredHymns.length,
                        itemBuilder: (context, index) {
                          final hymn = filteredHymns[index];
                          return _buildHymnCard(hymn);
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

  Widget _buildHymnCard(Hymn hymn) {
    final collectionInfo = _collectionInfo ?? CollectionInfo(
      id: widget.collectionId,
      title: widget.collectionId.toUpperCase(),
      subtitle: 'Loading...',
      description: 'Loading collection information',
      color: Color(AppColors.primaryBlue),
      language: 'Unknown',
      hymnCount: 0,
      isAvailable: true,
      bundled: false,
      year: 0,
    );
    final hasAudio = hymn.hymnNumber % 3 == 0; // Mock audio availability

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: collectionInfo.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Center(
            child: Text(
              hymn.hymnNumber.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: collectionInfo.color,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Color(AppColors.gray600),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (hasAudio) ...[
                  Icon(
                    Icons.audiotrack,
                    size: 16,
                    color: Color(AppColors.successGreen),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Audio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.successGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  collectionInfo.language,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Color(AppColors.gray500),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.go('/hymn/${hymn.id}');
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = _searchQuery;
        return AlertDialog(
          title: const Text('Search Collection'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search hymns, authors, or lyrics...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => searchText = value,
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = searchText;
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSortBy = _sortBy;
        bool tempShowAudioOnly = _showAudioOnly;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Filter & Sort'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sort by:', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  
                  RadioListTile<String>(
                    title: const Text('Hymn Number'),
                    value: 'hymn_number',
                    groupValue: tempSortBy,
                    onChanged: (value) => setState(() => tempSortBy = value!),
                    dense: true,
                  ),
                  RadioListTile<String>(
                    title: const Text('Title'),
                    value: 'title',
                    groupValue: tempSortBy,
                    onChanged: (value) => setState(() => tempSortBy = value!),
                    dense: true,
                  ),
                  RadioListTile<String>(
                    title: const Text('Author'),
                    value: 'author',
                    groupValue: tempSortBy,
                    onChanged: (value) => setState(() => tempSortBy = value!),
                    dense: true,
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  
                  CheckboxListTile(
                    title: const Text('Show hymns with audio only'),
                    value: tempShowAudioOnly,
                    onChanged: (value) => setState(() => tempShowAudioOnly = value ?? false),
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
                  this.setState(() {
                    _sortBy = tempSortBy;
                    _showAudioOnly = tempShowAudioOnly;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }
}

