import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ScriptureBrowseScreen extends StatefulWidget {
  const ScriptureBrowseScreen({super.key});

  @override
  State<ScriptureBrowseScreen> createState() => _ScriptureBrowseScreenState();
}

class _ScriptureBrowseScreenState extends State<ScriptureBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample scripture references data
  final List<ScriptureItem> _scriptures = [
    const ScriptureItem(reference: 'Psalm 23', fullReference: 'Psalm 23:1-6', hymnCount: 8),
    const ScriptureItem(reference: 'John 3:16', fullReference: 'John 3:16', hymnCount: 5),
    const ScriptureItem(reference: 'Isaiah 40:31', fullReference: 'Isaiah 40:31', hymnCount: 3),
    const ScriptureItem(reference: 'Psalm 46:1', fullReference: 'Psalm 46:1', hymnCount: 4),
    const ScriptureItem(reference: 'Matthew 28:19-20', fullReference: 'Matthew 28:19-20', hymnCount: 6),
    const ScriptureItem(reference: 'Revelation 4:11', fullReference: 'Revelation 4:11', hymnCount: 2),
    const ScriptureItem(reference: 'Philippians 2:5-11', fullReference: 'Philippians 2:5-11', hymnCount: 7),
    const ScriptureItem(reference: 'Luke 2:14', fullReference: 'Luke 2:14', hymnCount: 9),
    const ScriptureItem(reference: 'Romans 8:28', fullReference: 'Romans 8:28', hymnCount: 3),
    const ScriptureItem(reference: 'Psalm 100', fullReference: 'Psalm 100:1-5', hymnCount: 12),
    const ScriptureItem(reference: '1 Corinthians 15:55', fullReference: '1 Corinthians 15:55', hymnCount: 4),
    const ScriptureItem(reference: 'Ephesians 2:8-9', fullReference: 'Ephesians 2:8-9', hymnCount: 5),
    const ScriptureItem(reference: 'Psalm 95:1', fullReference: 'Psalm 95:1', hymnCount: 6),
    const ScriptureItem(reference: 'Isaiah 53:5', fullReference: 'Isaiah 53:5', hymnCount: 8),
    const ScriptureItem(reference: 'Revelation 21:4', fullReference: 'Revelation 21:4', hymnCount: 3),
    const ScriptureItem(reference: 'Galatians 2:20', fullReference: 'Galatians 2:20', hymnCount: 4),
    const ScriptureItem(reference: 'Psalm 139:23-24', fullReference: 'Psalm 139:23-24', hymnCount: 2),
    const ScriptureItem(reference: 'Acts 4:12', fullReference: 'Acts 4:12', hymnCount: 3),
    const ScriptureItem(reference: 'Hebrews 13:8', fullReference: 'Hebrews 13:8', hymnCount: 5),
    const ScriptureItem(reference: 'Psalm 27:1', fullReference: 'Psalm 27:1', hymnCount: 4),
    const ScriptureItem(reference: 'Matthew 11:28', fullReference: 'Matthew 11:28', hymnCount: 7),
    const ScriptureItem(reference: 'Revelation 22:20', fullReference: 'Revelation 22:20', hymnCount: 3),
  ];

  List<ScriptureItem> get _filteredScriptures {
    if (_searchQuery.isEmpty) return _scriptures;
    return _scriptures.where((scripture) =>
        scripture.reference.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        scripture.fullReference.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scriptureTitle),
        elevation: 0,
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
                  'Search Scripture References',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Find hymns by biblical reference',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.gray700),
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search scripture references...',
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
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: _filteredScriptures.isEmpty
                ? _buildEmptyState()
                : _buildScripturesList(),
          ),
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
            Icons.menu_book_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No scripture references found',
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

  Widget _buildScripturesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: _filteredScriptures.length,
      itemBuilder: (context, index) {
        final scripture = _filteredScriptures[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(AppColors.errorRed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Color(AppColors.errorRed),
              ),
            ),
            title: Text(
              scripture.reference,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.spacing4),
                if (scripture.fullReference != scripture.reference)
                  Text(
                    scripture.fullReference,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.gray600),
                    ),
                  ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  '${scripture.hymnCount} hymn${scripture.hymnCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.errorRed),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(AppColors.gray500),
            ),
            onTap: () {
              // Navigate to hymns with this scripture reference
              // context.push('/hymns/scripture/${scripture.reference}');
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ScriptureItem {
  final String reference;
  final String fullReference;
  final int hymnCount;

  const ScriptureItem({
    required this.reference,
    required this.fullReference,
    required this.hymnCount,
  });
}