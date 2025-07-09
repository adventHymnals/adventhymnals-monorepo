import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn.dart';
import '../models/media_models.dart';
import '../providers/hymnal_provider.dart';
import '../providers/media_provider.dart';
import '../widgets/hymn_content_widget.dart';
import '../widgets/media/media_download_sheet.dart';
import '../config/api_config.dart';

class HymnDetailScreenWithMedia extends StatefulWidget {
  final String hymnId;
  
  const HymnDetailScreenWithMedia({
    super.key,
    required this.hymnId,
  });
  
  @override
  State<HymnDetailScreenWithMedia> createState() => _HymnDetailScreenWithMediaState();
}

class _HymnDetailScreenWithMediaState extends State<HymnDetailScreenWithMedia> {
  Hymn? _hymn;
  MediaMetadata? _mediaMetadata;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadHymn();
  }
  
  Future<void> _loadHymn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final hymnalProvider = Provider.of<HymnalProvider>(context, listen: false);
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      
      // Load hymn data
      _hymn = await hymnalProvider.getHymn(widget.hymnId);
      
      // Load media metadata
      await mediaProvider.loadHymnMedia(widget.hymnId);
      _mediaMetadata = mediaProvider.getHymnMedia(widget.hymnId);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load hymn',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadHymn,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_hymn == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hymn not found'),
        ),
        body: const Center(
          child: Text('Hymn not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_hymn!.title),
        actions: [
          _buildMediaButton(),
          _buildMoreActionsButton(),
        ],
      ),
      body: Column(
        children: [
          // Environment indicator (for development)
          if (!ApiConfig.isProduction) _buildEnvironmentIndicator(),
          
          // Media summary bar
          _buildMediaSummaryBar(),
          
          // Hymn content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hymn metadata
                  _buildHymnMetadata(),
                  
                  const SizedBox(height: 24),
                  
                  // Hymn content
                  HymnContentWidget(hymn: _hymn!),
                  
                  const SizedBox(height: 24),
                  
                  // Quick media actions
                  _buildQuickMediaActions(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildEnvironmentIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ApiConfig.isDevelopment ? Colors.orange : Colors.blue,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ApiConfig.isDevelopment ? Icons.construction : Icons.cloud,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Environment: ${ApiConfig.isDevelopment ? 'Development' : 'Staging'} (${ApiConfig.apiBaseUrl})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMediaSummaryBar() {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        if (_mediaMetadata == null) return const SizedBox.shrink();
        
        final downloadedCount = mediaProvider.getDownloadedMediaFiles(widget.hymnId).length;
        final totalCount = _mediaMetadata!.files.length;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.library_music,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Media Files Available',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Row(
                      children: [
                        Text(
                          '$downloadedCount downloaded',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' • $totalCount total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (_mediaMetadata!.hasAudio) ...[
                          Text(' • ', style: Theme.of(context).textTheme.bodySmall),
                          Icon(Icons.music_note, size: 12, color: Colors.purple),
                          Text('Audio', style: Theme.of(context).textTheme.bodySmall),
                        ],
                        if (_mediaMetadata!.hasMidi) ...[
                          Text(' • ', style: Theme.of(context).textTheme.bodySmall),
                          Icon(Icons.piano, size: 12, color: Colors.green),
                          Text('MIDI', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (mediaProvider.isDownloadInProgress(widget.hymnId)) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: mediaProvider.getTotalDownloadProgress(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: () => _showMediaDownloadSheet(),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHymnMetadata() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hymn!.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (_hymn!.author != null) ...[
              _buildMetadataRow('Author', _hymn!.author!),
            ],
            if (_hymn!.composer != null) ...[
              _buildMetadataRow('Composer', _hymn!.composer!),
            ],
            if (_hymn!.tune != null) ...[
              _buildMetadataRow('Tune', _hymn!.tune!),
            ],
            if (_hymn!.number != null) ...[
              _buildMetadataRow('Number', _hymn!.number.toString()),
            ],
            if (_hymn!.metadata?.themes != null && _hymn!.metadata!.themes!.isNotEmpty) ...[
              _buildMetadataRow('Themes', _hymn!.metadata!.themes!.join(', ')),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickMediaActions() {
    if (_mediaMetadata == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_mediaMetadata!.hasAudio) ...[
                  _buildQuickActionChip(
                    icon: Icons.music_note,
                    label: 'Audio (${_mediaMetadata!.audioFiles.length})',
                    color: Colors.purple,
                    onTap: () => _downloadMediaType(MediaType.audio),
                  ),
                ],
                if (_mediaMetadata!.hasMidi) ...[
                  _buildQuickActionChip(
                    icon: Icons.piano,
                    label: 'MIDI (${_mediaMetadata!.midiFiles.length})',
                    color: Colors.green,
                    onTap: () => _downloadMediaType(MediaType.midi),
                  ),
                ],
                if (_mediaMetadata!.hasImages) ...[
                  _buildQuickActionChip(
                    icon: Icons.image,
                    label: 'Images (${_mediaMetadata!.imageFiles.length})',
                    color: Colors.blue,
                    onTap: () => _downloadMediaType(MediaType.image),
                  ),
                ],
                if (_mediaMetadata!.hasPdf) ...[
                  _buildQuickActionChip(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF (${_mediaMetadata!.pdfFiles.length})',
                    color: Colors.red,
                    onTap: () => _downloadMediaType(MediaType.pdf),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        return ActionChip(
          onPressed: onTap,
          avatar: Icon(icon, color: color, size: 18),
          label: Text(label),
          backgroundColor: color.withOpacity(0.1),
          side: BorderSide(color: color.withOpacity(0.3)),
        );
      },
    );
  }
  
  Widget _buildMediaButton() {
    if (_mediaMetadata == null) return const SizedBox.shrink();
    
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        final hasDownloading = mediaProvider.activeDownloads > 0;
        
        return IconButton(
          onPressed: _showMediaDownloadSheet,
          icon: Stack(
            children: [
              const Icon(Icons.file_download),
              if (hasDownloading) ...[
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
          tooltip: 'Download Media',
        );
      },
    );
  }
  
  Widget _buildMoreActionsButton() {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMoreAction(value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 8),
              Text('Refresh'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share),
              SizedBox(width: 8),
              Text('Share'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'offline',
          child: Row(
            children: [
              Icon(Icons.offline_pin),
              SizedBox(width: 8),
              Text('Download All'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFloatingActionButton() {
    return Consumer<MediaProvider>(
      builder: (context, mediaProvider, child) {
        if (mediaProvider.activeDownloads == 0) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: _showMediaDownloadSheet,
          icon: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: mediaProvider.getTotalDownloadProgress(),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          label: Text('${mediaProvider.activeDownloads} downloading'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
  
  void _showMediaDownloadSheet() {
    showMediaDownloadSheet(context, widget.hymnId, _hymn!.title);
  }
  
  Future<void> _downloadMediaType(MediaType type) async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    
    try {
      final files = await mediaProvider.getAvailableMedia(widget.hymnId, type);
      
      if (files.isEmpty) {
        _showSnackBar('No ${type.name} files available');
        return;
      }
      
      // Download all files of this type
      for (final file in files) {
        if (!await mediaProvider.isMediaDownloaded(file.id)) {
          await mediaProvider.downloadMedia(widget.hymnId, file, priority: 1);
        }
      }
      
      _showSnackBar('Started downloading ${files.length} ${type.name} file${files.length != 1 ? 's' : ''}');
    } catch (e) {
      _showSnackBar('Failed to download ${type.name} files: $e', isError: true);
    }
  }
  
  Future<void> _handleMoreAction(String action) async {
    switch (action) {
      case 'refresh':
        await _loadHymn();
        break;
      case 'share':
        _showSnackBar('Share functionality coming soon');
        break;
      case 'offline':
        await _downloadAllMedia();
        break;
    }
  }
  
  Future<void> _downloadAllMedia() async {
    if (_mediaMetadata == null) return;
    
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    
    try {
      int downloadCount = 0;
      
      for (final file in _mediaMetadata!.files) {
        if (!await mediaProvider.isMediaDownloaded(file.id)) {
          await mediaProvider.downloadMedia(widget.hymnId, file);
          downloadCount++;
        }
      }
      
      if (downloadCount > 0) {
        _showSnackBar('Started downloading $downloadCount media files');
      } else {
        _showSnackBar('All media files are already downloaded');
      }
    } catch (e) {
      _showSnackBar('Failed to download media: $e', isError: true);
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}