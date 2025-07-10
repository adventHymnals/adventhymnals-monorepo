import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../../core/constants/app_constants.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDownloads();
    });
  }

  Future<void> _loadDownloads() async {
    final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    await downloadProvider.loadDownloadCache();
  }

  List<DownloadItem> _getAllDownloads(DownloadProvider provider) {
    final allDownloads = <DownloadItem>[];
    allDownloads.addAll(provider.downloadQueue);
    allDownloads.addAll(provider.activeDownloads);
    allDownloads.addAll(provider.completedDownloads);
    return allDownloads;
  }

  List<DownloadItem> _getFilteredDownloads(DownloadProvider provider) {
    final allDownloads = _getAllDownloads(provider);
    
    switch (_selectedFilter) {
      case 'downloading':
        return allDownloads.where((item) => 
          item.state == DownloadState.downloading || 
          item.state == DownloadState.idle).toList();
      case 'completed':
        return allDownloads.where((item) => item.state == DownloadState.completed).toList();
      case 'failed':
        return allDownloads.where((item) => item.state == DownloadState.failed).toList();
      case 'paused':
        return allDownloads.where((item) => item.state == DownloadState.paused).toList();
      default:
        return allDownloads;
    }
  }

  Map<String, int> _getDownloadStatistics(DownloadProvider provider) {
    final allDownloads = _getAllDownloads(provider);
    return {
      'total': allDownloads.length,
      'active': provider.activeCount + provider.queuedCount,
      'completed': provider.completedCount,
      'failed': allDownloads.where((d) => d.state == DownloadState.failed).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_completed':
                  _clearCompletedDownloads();
                  break;
                case 'clear_all':
                  _clearAllDownloads();
                  break;
                case 'settings':
                  _showDownloadSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_completed',
                child: Text('Clear Completed'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Download Settings'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, provider, child) {
          if (provider.loadingState == DownloadLoadingState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.loadingState == DownloadLoadingState.error) {
            return _buildErrorState(provider.errorMessage ?? 'Failed to load downloads');
          }

          return Column(
            children: [
              // Statistics Section
              _buildStatisticsSection(provider),
              
              // Filter Tabs
              _buildFilterTabs(provider),
              
              // Downloads List
              Expanded(
                child: _buildDownloadsList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleDownload,
        child: const Icon(Icons.add),
        tooltip: 'Add Sample Download',
      ),
    );
  }

  Widget _buildStatisticsSection(DownloadProvider provider) {
    final stats = _getDownloadStatistics(provider);
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            title: 'Total',
            value: stats['total'].toString(),
            icon: Icons.download,
            color: Color(AppColors.primaryBlue),
          ),
          _buildStatCard(
            title: 'Active',
            value: stats['active'].toString(),
            icon: Icons.download_outlined,
            color: Color(AppColors.successGreen),
          ),
          _buildStatCard(
            title: 'Completed',
            value: stats['completed'].toString(),
            icon: Icons.check_circle,
            color: Color(AppColors.successGreen),
          ),
          _buildStatCard(
            title: 'Failed',
            value: stats['failed'].toString(),
            icon: Icons.error,
            color: Color(AppColors.errorRed),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Color(AppColors.gray600),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(DownloadProvider provider) {
    final allDownloads = _getAllDownloads(provider);
    final filters = [
      {'key': 'all', 'label': 'All', 'count': allDownloads.length},
      {'key': 'downloading', 'label': 'Active', 'count': provider.activeCount + provider.queuedCount},
      {'key': 'completed', 'label': 'Done', 'count': provider.completedCount},
      {'key': 'failed', 'label': 'Failed', 'count': allDownloads.where((d) => d.state == DownloadState.failed).length},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Container(
            margin: const EdgeInsets.only(right: AppSizes.spacing8),
            child: FilterChip(
              label: Text(
                '${filter['label']} (${filter['count']})',
                style: TextStyle(
                  color: isSelected 
                    ? Color(AppColors.primaryBlue) 
                    : Color(AppColors.gray700),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key'] as String;
                });
              },
              selectedColor: Color(AppColors.primaryBlue).withOpacity(0.2),
              backgroundColor: Color(AppColors.gray100),
              checkmarkColor: Color(AppColors.primaryBlue),
              side: BorderSide(
                color: isSelected 
                  ? Color(AppColors.primaryBlue) 
                  : Color(AppColors.gray300),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadsList(DownloadProvider provider) {
    final filteredDownloads = _getFilteredDownloads(provider);

    if (filteredDownloads.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDownloads,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        itemCount: filteredDownloads.length,
        itemBuilder: (context, index) {
          final download = filteredDownloads[index];
          return _buildDownloadItem(download, provider);
        },
      ),
    );
  }

  Widget _buildDownloadItem(DownloadItem download, DownloadProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                _buildDownloadIcon(download.state),
                const SizedBox(width: AppSizes.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.hymnTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        '${download.fileType.toUpperCase()}${download.quality != null ? ' • ${download.quality}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Color(AppColors.gray600),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDownloadActions(download, provider),
              ],
            ),
            
            // Progress Bar (for active downloads)
            if (download.state == DownloadState.downloading || download.state == DownloadState.paused) ...[
              const SizedBox(height: AppSizes.spacing12),
              LinearProgressIndicator(
                value: download.progress,
                backgroundColor: Color(AppColors.gray300),
                valueColor: AlwaysStoppedAnimation<Color>(
                  download.state == DownloadState.paused 
                    ? Color(AppColors.warningOrange)
                    : Color(AppColors.primaryBlue),
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDownloadState(download),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.gray600),
                    ),
                  ),
                  Text(
                    '${(download.progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.gray600),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            // Error Message (for failed downloads)
            if (download.state == DownloadState.failed && download.errorMessage != null) ...[
              const SizedBox(height: AppSizes.spacing8),
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing8),
                decoration: BoxDecoration(
                  color: Color(AppColors.errorRed).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      size: 16,
                      color: Color(AppColors.errorRed),
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    Expanded(
                      child: Text(
                        download.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Color(AppColors.errorRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Completion Info (for completed downloads)
            if (download.state == DownloadState.completed) ...[
              const SizedBox(height: AppSizes.spacing8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(AppColors.successGreen),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    'Downloaded ${_formatDateTime(download.completedTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.successGreen),
                    ),
                  ),
                  if (download.fileSize != null) ...[
                    const SizedBox(width: AppSizes.spacing8),
                    Text(
                      '• ${_formatFileSize(download.fileSize!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(AppColors.gray600),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadIcon(DownloadState state) {
    IconData iconData;
    Color color;

    switch (state) {
      case DownloadState.downloading:
        iconData = Icons.download;
        color = Color(AppColors.primaryBlue);
        break;
      case DownloadState.completed:
        iconData = Icons.check_circle;
        color = Color(AppColors.successGreen);
        break;
      case DownloadState.failed:
        iconData = Icons.error;
        color = Color(AppColors.errorRed);
        break;
      case DownloadState.paused:
        iconData = Icons.pause_circle;
        color = Color(AppColors.warningOrange);
        break;
      default:
        iconData = Icons.download_outlined;
        color = Color(AppColors.gray500);
    }

    return Icon(iconData, color: color, size: 32);
  }

  Widget _buildDownloadActions(DownloadItem download, DownloadProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (download.state == DownloadState.downloading) ...[
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => provider.pauseDownload(download.downloadKey),
            tooltip: 'Pause',
          ),
        ] else if (download.state == DownloadState.paused) ...[
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => provider.resumeDownload(download.downloadKey),
            tooltip: 'Resume',
          ),
        ] else if (download.state == DownloadState.failed) ...[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _retryDownload(download, provider),
            tooltip: 'Retry',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _confirmRemoveDownload(download, provider),
          tooltip: 'Remove',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No downloads',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Color(AppColors.gray600),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Downloads will appear here when you download hymns',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Color(AppColors.gray500),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
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
            'Error loading downloads',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Color(AppColors.errorRed),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Color(AppColors.gray600),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing16),
          ElevatedButton(
            onPressed: _loadDownloads,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDownloadState(DownloadItem download) {
    switch (download.state) {
      case DownloadState.downloading:
        return 'Downloading...';
      case DownloadState.paused:
        return 'Paused';
      case DownloadState.completed:
        return 'Completed';
      case DownloadState.failed:
        return 'Failed';
      default:
        return 'Waiting...';
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  void _confirmRemoveDownload(DownloadItem download, DownloadProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Download'),
        content: Text('Are you sure you want to remove "${download.hymnTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeDownload(download, provider);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeDownload(DownloadItem download, DownloadProvider provider) {
    // Cancel download if active
    if (download.state == DownloadState.downloading || 
        download.state == DownloadState.paused ||
        download.state == DownloadState.idle) {
      provider.cancelDownload(download.downloadKey);
    } else if (download.state == DownloadState.completed) {
      provider.removeCompletedDownload(download.downloadKey);
    }
  }

  void _retryDownload(DownloadItem download, DownloadProvider provider) {
    provider.addToDownloadQueue(
      download.hymnId,
      download.hymnTitle,
      download.fileType,
      quality: download.quality,
    );
  }

  void _clearCompletedDownloads() {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    // Remove completed downloads one by one
    for (final download in provider.completedDownloads.toList()) {
      provider.removeCompletedDownload(download.downloadKey);
    }
  }

  void _clearAllDownloads() {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    provider.clearAllDownloads();
  }

  void _showDownloadSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Settings'),
        content: const Text('Download settings will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addSampleDownload() {
    final provider = Provider.of<DownloadProvider>(context, listen: false);
    
    // Add sample downloads for testing
    final sampleDownloads = [
      'Amazing Grace',
      'Holy Holy Holy',
      'Great is Thy Faithfulness',
      'How Great Thou Art',
      'Jesus Loves Me',
    ];
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % sampleDownloads.length;
    final title = sampleDownloads[randomIndex];
    
    provider.addToDownloadQueue(
      DateTime.now().millisecondsSinceEpoch,
      title,
      'audio',
      quality: 'high',
    );
  }
}