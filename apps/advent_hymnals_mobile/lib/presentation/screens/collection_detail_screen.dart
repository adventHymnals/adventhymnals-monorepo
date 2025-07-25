import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/data/collections_data_manager.dart';
import '../providers/hymn_provider.dart';
import '../../domain/entities/hymn.dart';
import '../widgets/banner_ad_widget.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'hymn_number';
  final List<String> _selectedLanguages = [];
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
    
    // Load hymn data for this specific collection
    final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
    print('🔄 [CollectionDetail] Loading hymns for collection: ${widget.collectionId}');
    await hymnProvider.loadHymnsByCollectionAbbreviation(widget.collectionId);
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
      color: const Color(AppColors.gray500),
      language: 'Unknown',
      hymnCount: 0,
      isAvailable: false,
      bundled: false,
      year: 0,
    );
  }

  List<Hymn> _getFilteredHymns(List<Hymn> hymns) {
    var filtered = hymns.where((hymn) {
      // Filter by search query - search in title, author, composer, tune, meter, lyrics, hymn number
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final searchableText = [
          hymn.title.toLowerCase(),
          hymn.author?.toLowerCase() ?? '',
          hymn.composer?.toLowerCase() ?? '',
          hymn.tuneName?.toLowerCase() ?? '',
          hymn.meter?.toLowerCase() ?? '',
          hymn.firstLine?.toLowerCase() ?? '',
          hymn.lyrics?.toLowerCase() ?? '',
          hymn.hymnNumber.toString(),
        ].join(' ');
        
        if (!searchableText.contains(query)) {
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
      case 'composer':
        filtered.sort((a, b) => (a.composer ?? '').compareTo(b.composer ?? ''));
        break;
      case 'tune':
        filtered.sort((a, b) => (a.tuneName ?? '').compareTo(b.tuneName ?? ''));
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
      color: const Color(AppColors.primaryBlue),
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
                      child: const Icon(
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

          // Search Section
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            color: const Color(AppColors.background),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, composer, tune, meter, number...',
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
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spacing8),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(AppColors.primaryBlue),
                      ),
                      const SizedBox(width: AppSizes.spacing4),
                      Text(
                        'Searching in: title, author, composer, tune, meter, lyrics, number',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(AppColors.gray600),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Banner Ad
          const BannerAdWidget(),

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
                        const Icon(
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
                        const Icon(
                          Icons.library_books_outlined,
                          size: 80,
                          color: Color(AppColors.gray400),
                        ),
                        const SizedBox(height: AppSizes.spacing20),
                        Text(
                          'Collection Not Available',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(AppColors.gray700),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing32),
                          child: Text(
                            'The "${collectionInfo.title}" collection is not currently available in the app.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(AppColors.gray600),
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
                              color: const Color(AppColors.gray500),
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
                        const Icon(
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
                            color: const Color(AppColors.gray500),
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
                        const Icon(
                          Icons.music_note_outlined,
                          size: 64,
                          color: Color(AppColors.gray400),
                        ),
                        const SizedBox(height: AppSizes.spacing16),
                        Text(
                          'No Hymns Available',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(AppColors.gray700),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing32),
                          child: Text(
                            'This collection doesn\'t have any hymns loaded yet. The app may be using demonstration data or the database content is not yet available.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(AppColors.gray500),
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
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(AppColors.primaryBlue),
                            ),
                            const SizedBox(width: AppSizes.spacing8),
                            Expanded(
                              child: Text(
                                '${filteredHymns.length} hymns found',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(AppColors.primaryBlue),
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
      color: const Color(AppColors.primaryBlue),
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
                  color: const Color(AppColors.gray600),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (hasAudio) ...[
                  const Icon(
                    Icons.audiotrack,
                    size: 16,
                    color: Color(AppColors.successGreen),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Audio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.successGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  collectionInfo.language,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray500),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.go('/hymn/${hymn.id}?collection=${widget.collectionId}');
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  RadioListTile<String>(
                    title: const Text('Composer'),
                    value: 'composer',
                    groupValue: tempSortBy,
                    onChanged: (value) => setState(() => tempSortBy = value!),
                    dense: true,
                  ),
                  RadioListTile<String>(
                    title: const Text('Tune'),
                    value: 'tune',
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

