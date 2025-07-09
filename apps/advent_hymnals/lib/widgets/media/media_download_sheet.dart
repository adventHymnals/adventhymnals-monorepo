import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media_models.dart';
import '../../providers/media_provider.dart';
import 'media_download_widget.dart';

class MediaDownloadSheet extends StatefulWidget {
  final String hymnId;
  final String hymnTitle;
  
  const MediaDownloadSheet({
    super.key,
    required this.hymnId,
    required this.hymnTitle,
  });
  
  @override
  State<MediaDownloadSheet> createState() => _MediaDownloadSheetState();
}

class _MediaDownloadSheetState extends State<MediaDownloadSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<MediaType> _mediaTypes = [
    MediaType.audio,
    MediaType.midi,
    MediaType.image,
    MediaType.pdf,
    MediaType.video,
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mediaTypes.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.file_download,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download Media',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            widget.hymnTitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildHeaderActions(context),
                  ],
                ),
              ),
              
              // Stats bar
              _buildStatsBar(context),
              
              // Tab bar
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _mediaTypes.map((type) => Tab(
                    icon: Icon(_getIconForType(type)),
                    text: type.name.toUpperCase(),
                  )).toList(),
                ),
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _mediaTypes.map((type) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: MediaDownloadWidget(
                      hymnId: widget.hymnId,
                      filterType: type,
                      showHeader: false,
                      onDownloadComplete: () {
                        // Optional: Show success message or update UI
                      },
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeaderActions(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mediaProvider.activeDownloads > 0) ...[
              IconButton(
                onPressed: () => mediaProvider.pauseAllDownloads(),
                icon: const Icon(Icons.pause_circle_filled),
                tooltip: 'Pause all downloads',
              ),
            ],
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, mediaProvider, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_queue',
                  enabled: mediaProvider.downloadQueueLength > 0,
                  child: const Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: 8),
                      Text('Clear Queue'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'storage_info',
                  child: const Row(
                    children: [
                      Icon(Icons.storage),
                      SizedBox(width: 8),
                      Text('Storage Info'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'cleanup',
                  child: const Row(
                    children: [
                      Icon(Icons.cleaning_services),
                      SizedBox(width: 8),
                      Text('Cleanup Old Files'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: const Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Downloads', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatsBar(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              _buildStatChip(
                context,
                Icons.download_done,
                'Downloaded',
                mediaProvider.totalDownloadedFiles.toString(),
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                Icons.downloading,
                'Active',
                mediaProvider.activeDownloads.toString(),
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                Icons.queue,
                'Queue',
                mediaProvider.downloadQueueLength.toString(),
                Colors.blue,
              ),
              const Spacer(),
              _buildStatChip(
                context,
                Icons.storage,
                'Storage',
                mediaProvider.formattedTotalSize,
                Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleMenuAction(
    BuildContext context,
    MediaProvider mediaProvider,
    String action,
  ) async {
    switch (action) {
      case 'clear_queue':
        mediaProvider.clearDownloadQueue();
        _showSnackBar(context, 'Download queue cleared');
        break;
      
      case 'storage_info':
        await _showStorageInfo(context, mediaProvider);
        break;
      
      case 'cleanup':
        await _showCleanupDialog(context, mediaProvider);
        break;
      
      case 'clear_all':
        await _showClearAllDialog(context, mediaProvider);
        break;
    }
  }
  
  Future<void> _showStorageInfo(BuildContext context, MediaProvider mediaProvider) async {
    await mediaProvider.refreshStorageStats();
    
    if (!context.mounted) return;
    
    final stats = mediaProvider.storageStats;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Total Files', stats?.totalFiles.toString() ?? '0'),
              _buildInfoRow('Total Size', stats?.formattedTotalSize ?? '0 B'),
              const SizedBox(height: 16),
              const Text('By Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (stats != null) ...{
                for (final entry in stats.countByType.entries)
                  _buildInfoRow(
                    entry.key.name.toUpperCase(),
                    '${entry.value} files',
                  ),
              },
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Future<void> _showCleanupDialog(BuildContext context, MediaProvider mediaProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cleanup Old Files'),
        content: const Text(
          'This will remove files that haven\'t been accessed in the last 30 days. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await mediaProvider.cleanupOldFiles();
        if (context.mounted) {
          _showSnackBar(context, 'Old files cleaned up');
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(context, 'Failed to cleanup: $e', isError: true);
        }
      }
    }
  }
  
  Future<void> _showClearAllDialog(BuildContext context, MediaProvider mediaProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text(
          'This will delete all downloaded media files. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await mediaProvider.clearAllMedia();
        if (context.mounted) {
          _showSnackBar(context, 'All downloads cleared');
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(context, 'Failed to clear downloads: $e', isError: true);
        }
      }
    }
  }
  
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
  
  IconData _getIconForType(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return Icons.music_note;
      case MediaType.image:
        return Icons.image;
      case MediaType.pdf:
        return Icons.picture_as_pdf;
      case MediaType.midi:
        return Icons.piano;
      case MediaType.video:
        return Icons.videocam;
    }
  }
}

// Utility function to show the media download sheet
void showMediaDownloadSheet(BuildContext context, String hymnId, String hymnTitle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MediaDownloadSheet(
      hymnId: hymnId,
      hymnTitle: hymnTitle,
    ),
  );
}