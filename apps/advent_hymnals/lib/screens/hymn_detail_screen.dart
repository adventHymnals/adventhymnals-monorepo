import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/hymnal_provider.dart';
import '../models/hymn.dart';
import '../models/projection.dart';
import '../services/preferences_service.dart';
import '../widgets/hymn_content_widget.dart';

class HymnDetailScreen extends StatefulWidget {
  final String hymnId;
  final String hymnalId;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
    required this.hymnalId,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  bool _isFavorite = false;
  NotationFormat _selectedFormat = NotationFormat.lyrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHymn();
      _checkFavoriteStatus();
    });
  }

  Future<void> _loadHymn() async {
    await context.read<HymnalProvider>().loadHymn(widget.hymnId);
    await PreferencesService.instance.addToRecentlyViewed(widget.hymnId);
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await PreferencesService.instance.isFavorite(widget.hymnId);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await PreferencesService.instance.removeFromFavorites(widget.hymnId);
    } else {
      await PreferencesService.instance.addToFavorites(widget.hymnId);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HymnalProvider>(
      builder: (context, provider, child) {
        final hymn = provider.currentHymn;
        final hymnalRef = provider.getHymnalReference(widget.hymnalId);

        return Scaffold(
          appBar: AppBar(
            title: Text(hymn?.title ?? 'Loading...'),
            actions: [
              if (hymn != null) ...[
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.slideshow),
                  onPressed: () => context.go('/projection/${hymn.id}'),
                ),
                PopupMenuButton<NotationFormat>(
                  icon: const Icon(Icons.music_note),
                  onSelected: (format) => setState(() => _selectedFormat = format),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: NotationFormat.lyrics,
                      child: Text('Lyrics Only'),
                    ),
                    if (hymn.notations?.any((n) => n.format == NotationFormat.solfa) == true)
                      const PopupMenuItem(
                        value: NotationFormat.solfa,
                        child: Text('Solfa Notation'),
                      ),
                    if (hymn.notations?.any((n) => n.format == NotationFormat.staff) == true)
                      const PopupMenuItem(
                        value: NotationFormat.staff,
                        child: Text('Staff Notation'),
                      ),
                    if (hymn.notations?.any((n) => n.format == NotationFormat.chord) == true)
                      const PopupMenuItem(
                        value: NotationFormat.chord,
                        child: Text('Chord Chart'),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareHymn(hymn),
                ),
              ],
            ],
          ),
          body: _buildBody(context, provider, hymn, hymnalRef?.name),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HymnalProvider provider, Hymn? hymn, String? hymnalName) {
    if (provider.isLoadingHymn) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.hymnError != null) {
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
              'Error Loading Hymn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.hymnError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadHymn(widget.hymnId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (hymn == null) {
      return const Center(
        child: Text('Hymn not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hymn header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hymn number
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${hymn.number}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hymnalName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'from $hymnalName',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Metadata
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hymn.author != null)
                        _buildMetadataChip(
                          context,
                          icon: Icons.person,
                          label: hymn.author!,
                        ),
                      if (hymn.composer != null)
                        _buildMetadataChip(
                          context,
                          icon: Icons.music_note,
                          label: hymn.composer!,
                        ),
                      if (hymn.tune != null)
                        _buildMetadataChip(
                          context,
                          icon: Icons.queue_music,
                          label: hymn.tune!,
                        ),
                      if (hymn.meter != null)
                        _buildMetadataChip(
                          context,
                          icon: Icons.straighten,
                          label: hymn.meter!,
                        ),
                      if (hymn.metadata?.year != null)
                        _buildMetadataChip(
                          context,
                          icon: Icons.calendar_today,
                          label: '${hymn.metadata!.year}',
                        ),
                    ],
                  ),
                  
                  if (hymn.metadata?.themes != null && hymn.metadata!.themes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Themes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: hymn.metadata!.themes!.map((theme) =>
                        Chip(
                          label: Text(theme),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        ),
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hymn content
          HymnContentWidget(
            hymn: hymn,
            format: _selectedFormat,
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.go('/projection/${hymn.id}'),
                  icon: const Icon(Icons.slideshow),
                  label: const Text('Projection Mode'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _shareHymn(hymn),
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          
          // Additional metadata
          if (hymn.metadata != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (hymn.metadata!.copyright != null)
                      _buildMetadataRow('Copyright', hymn.metadata!.copyright!),
                    
                    if (hymn.metadata!.originalLanguage != null)
                      _buildMetadataRow('Original Language', hymn.metadata!.originalLanguage!),
                    
                    if (hymn.metadata!.translator != null)
                      _buildMetadataRow('Translator', hymn.metadata!.translator!),
                    
                    if (hymn.metadata!.tuneSource != null)
                      _buildMetadataRow('Tune Source', hymn.metadata!.tuneSource!),
                    
                    if (hymn.metadata!.scriptureReferences != null && 
                        hymn.metadata!.scriptureReferences!.isNotEmpty)
                      _buildMetadataRow(
                        'Scripture References', 
                        hymn.metadata!.scriptureReferences!.join(', '),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataChip(BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
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

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _shareHymn(Hymn hymn) {
    // In a real app, this would use the share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${hymn.title}"'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}