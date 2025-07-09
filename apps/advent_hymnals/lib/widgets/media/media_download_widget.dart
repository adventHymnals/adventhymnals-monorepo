import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media_models.dart';
import '../../providers/media_provider.dart';

class MediaDownloadWidget extends StatefulWidget {
  final String hymnId;
  final MediaType? filterType;
  final bool showHeader;
  final bool showStats;
  final VoidCallback? onDownloadComplete;
  
  const MediaDownloadWidget({
    super.key,
    required this.hymnId,
    this.filterType,
    this.showHeader = true,
    this.showStats = false,
    this.onDownloadComplete,
  });
  
  @override
  State<MediaDownloadWidget> createState() => _MediaDownloadWidgetState();
}

class _MediaDownloadWidgetState extends State<MediaDownloadWidget> {
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadMedia();
  }
  
  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      await mediaProvider.loadHymnMedia(widget.hymnId);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load media',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMedia,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        final media = mediaProvider.getHymnMedia(widget.hymnId);
        
        if (media == null) {
          return const Center(
            child: Text('No media found'),
          );
        }
        
        final files = widget.filterType != null
            ? media.getFilesByType(widget.filterType!)
            : media.files;
        
        if (files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(widget.filterType ?? MediaType.audio),
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${widget.filterType?.name ?? 'media'} files available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader) ...[
              _buildHeader(context, media, files),
              const SizedBox(height: 16),
            ],
            if (widget.showStats) ...[
              _buildStats(context, mediaProvider),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return MediaFileDownloadTile(
                    mediaFile: file,
                    hymnId: widget.hymnId,
                    onDownloadComplete: widget.onDownloadComplete,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHeader(BuildContext context, MediaMetadata media, List<MediaFile> files) {
    return Row(
      children: [
        Icon(
          _getIconForType(widget.filterType ?? MediaType.audio),
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.filterType?.name.toUpperCase() ?? 'MEDIA'} FILES',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${files.length} file${files.length != 1 ? 's' : ''} • ${media.formattedTotalSize}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _buildHeaderActions(context),
      ],
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
                icon: const Icon(Icons.pause),
                tooltip: 'Pause all downloads',
              ),
              const SizedBox(width: 4),
            ],
            if (mediaProvider.downloadQueueLength > 0) ...[
              IconButton(
                onPressed: () => mediaProvider.clearDownloadQueue(),
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clear download queue',
              ),
              const SizedBox(width: 4),
            ],
            IconButton(
              onPressed: _loadMedia,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh media list',
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStats(BuildContext context, MediaProvider mediaProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Statistics',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Downloaded',
                    mediaProvider.totalDownloadedFiles.toString(),
                    Icons.download_done,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Queue',
                    mediaProvider.downloadQueueLength.toString(),
                    Icons.queue,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active',
                    mediaProvider.activeDownloads.toString(),
                    Icons.downloading,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Storage',
                    mediaProvider.formattedTotalSize,
                    Icons.storage,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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

class MediaFileDownloadTile extends StatelessWidget {
  final MediaFile mediaFile;
  final String hymnId;
  final VoidCallback? onDownloadComplete;
  
  const MediaFileDownloadTile({
    super.key,
    required this.mediaFile,
    required this.hymnId,
    this.onDownloadComplete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        final progress = mediaProvider.getDownloadProgress(mediaFile.id);
        final isDownloaded = mediaProvider.getLocalMediaInfo(mediaFile.id) != null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getColorForType(mediaFile.type),
              child: Icon(
                _getIconForType(mediaFile.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              mediaFile.displayName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${mediaFile.format.name.toUpperCase()} • ${mediaFile.formattedSize}',
                ),
                if (mediaFile.formattedDuration != null) ...[
                  const SizedBox(height: 4),
                  Text('Duration: ${mediaFile.formattedDuration}'),
                ],
                if (progress != null && progress.isDownloading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        progress.formattedProgress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (progress.speed != null)
                        Text(
                          progress.formattedSpeed,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: _buildTrailingWidget(context, mediaProvider, progress, isDownloaded),
            onTap: isDownloaded ? () => _openMedia(context, mediaProvider) : null,
          ),
        );
      },
    );
  }
  
  Widget _buildTrailingWidget(
    BuildContext context,
    MediaProvider mediaProvider,
    DownloadProgress? progress,
    bool isDownloaded,
  ) {
    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, mediaProvider, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new),
                    SizedBox(width: 8),
                    Text('Open'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    if (progress == null) {
      return ElevatedButton.icon(
        onPressed: () => _downloadMedia(context, mediaProvider),
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Download'),
      );
    }
    
    switch (progress.status) {
      case DownloadStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress.progress,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => mediaProvider.pauseDownload(mediaFile.id),
              icon: const Icon(Icons.pause),
              tooltip: 'Pause',
            ),
            IconButton(
              onPressed: () => mediaProvider.cancelDownload(mediaFile.id),
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),
          ],
        );
      
      case DownloadStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      
      case DownloadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _retryDownload(context, mediaProvider),
              child: const Text('Retry'),
            ),
          ],
        );
      
      case DownloadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_filled, color: Colors.orange),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _downloadMedia(context, mediaProvider),
              child: const Text('Resume'),
            ),
          ],
        );
      
      default:
        return ElevatedButton.icon(
          onPressed: () => _downloadMedia(context, mediaProvider),
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Download'),
        );
    }
  }
  
  Future<void> _downloadMedia(BuildContext context, MediaProvider mediaProvider) async {
    try {
      await mediaProvider.downloadMedia(hymnId, mediaFile);
      onDownloadComplete?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _retryDownload(BuildContext context, MediaProvider mediaProvider) async {
    try {
      await mediaProvider.retryFailedDownload(mediaFile.id, mediaFile);
      onDownloadComplete?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retry download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _openMedia(BuildContext context, MediaProvider mediaProvider) async {
    await mediaProvider.updateLastAccessed(mediaFile.id);
    
    // TODO: Implement media opening based on type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${mediaFile.filename}'),
      ),
    );
  }
  
  Future<void> _handleMenuAction(
    BuildContext context,
    MediaProvider mediaProvider,
    String action,
  ) async {
    switch (action) {
      case 'open':
        await _openMedia(context, mediaProvider);
        break;
      case 'delete':
        await _showDeleteConfirmation(context, mediaProvider);
        break;
    }
  }
  
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    MediaProvider mediaProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text('Are you sure you want to delete "${mediaFile.filename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await mediaProvider.deleteDownloadedMedia(mediaFile.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted ${mediaFile.filename}'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
  
  Color _getColorForType(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return Colors.purple;
      case MediaType.image:
        return Colors.blue;
      case MediaType.pdf:
        return Colors.red;
      case MediaType.midi:
        return Colors.green;
      case MediaType.video:
        return Colors.orange;
    }
  }
}