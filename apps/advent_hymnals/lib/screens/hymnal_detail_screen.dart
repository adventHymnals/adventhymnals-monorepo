import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/hymnal_provider.dart';
import '../models/hymn.dart';
import '../models/hymnal.dart';
import '../widgets/search_bar_widget.dart';

class HymnalDetailScreen extends StatefulWidget {
  final String hymnalId;

  const HymnalDetailScreen({
    super.key,
    required this.hymnalId,
  });

  @override
  State<HymnalDetailScreen> createState() => _HymnalDetailScreenState();
}

class _HymnalDetailScreenState extends State<HymnalDetailScreen> {
  String _searchQuery = '';
  String _sortBy = 'number';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HymnalProvider>().loadHymnalHymns(widget.hymnalId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HymnalProvider>(
      builder: (context, provider, child) {
        final hymnalRef = provider.getHymnalReference(widget.hymnalId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(hymnalRef?.abbreviation ?? 'Hymnal'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.go('/search'),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'number',
                    child: Text('Sort by Number'),
                  ),
                  const PopupMenuItem(
                    value: 'title',
                    child: Text('Sort by Title'),
                  ),
                  const PopupMenuItem(
                    value: 'author',
                    child: Text('Sort by Author'),
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(context, provider, hymnalRef),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HymnalProvider provider, HymnalReference? hymnalRef) {
    if (provider.isLoadingHymns) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.hymnsError != null) {
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
              'Error Loading Hymns',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.hymnsError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadHymnalHymns(widget.hymnalId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (hymnalRef == null) {
      return const Center(
        child: Text('Hymnal not found'),
      );
    }

    final hymns = _getFilteredAndSortedHymns(provider.currentHymnalHymns);

    return Column(
      children: [
        // Hymnal header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hymnalRef.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        icon: Icons.music_note,
                        label: '${hymnalRef.totalSongs} songs',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        icon: Icons.calendar_today,
                        label: '${hymnalRef.year}',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        icon: Icons.language,
                        label: hymnalRef.languageName,
                      ),
                    ],
                  ),
                  if (hymnalRef.compiler != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Compiled by: ${hymnalRef.compiler}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchBarWidget(
            onSearch: () {
              // Handle search within this hymnal
            },
          ),
        ),

        const SizedBox(height: 16),

        // Results count
        if (hymns.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${hymns.length} hymn${hymns.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _scrollToTop(),
                  icon: const Icon(Icons.keyboard_arrow_up),
                  label: const Text('Top'),
                ),
              ],
            ),
          ),

        // Hymns list
        Expanded(
          child: hymns.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hymns found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: hymns.length,
                  itemBuilder: (context, index) {
                    final hymn = hymns[index];
                    return _buildHymnCard(context, hymn);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHymnCard(BuildContext context, Hymn hymn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/hymnals/${widget.hymnalId}/hymn/${hymn.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Hymn number
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${hymn.number}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Hymn details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hymn.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hymn.author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'by ${hymn.author}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (hymn.tune != null || hymn.meter != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (hymn.tune != null) ...[
                            Icon(
                              Icons.music_note,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hymn.tune!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                          if (hymn.tune != null && hymn.meter != null)
                            Text(
                              ' • ',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          if (hymn.meter != null)
                            Text(
                              hymn.meter!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<Hymn> _getFilteredAndSortedHymns(List<Hymn> hymns) {
    var filtered = hymns.where((hymn) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return hymn.title.toLowerCase().contains(query) ||
               (hymn.author?.toLowerCase().contains(query) ?? false) ||
               (hymn.tune?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        filtered.sort((a, b) {
          final authorA = a.author ?? '';
          final authorB = b.author ?? '';
          return authorA.compareTo(authorB);
        });
        break;
      case 'number':
      default:
        filtered.sort((a, b) => a.number.compareTo(b.number));
        break;
    }

    return filtered;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}