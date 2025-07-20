import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/audio_player_provider.dart';
import '../providers/download_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/hymn.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentHymn == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Player')),
            body: const Center(
              child: Text('No hymn is currently playing'),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppColors.primaryBlue),
                  Color(AppColors.secondaryBlue),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing20),
                child: Column(
                  children: [
                    // Header with close, playlist, and more options
                    _buildHeader(context, audioProvider),
                    
                    const SizedBox(height: AppSizes.spacing32),
                    
                    // Album art with collection info
                    _buildAlbumArt(context, audioProvider),
                    
                    const SizedBox(height: AppSizes.spacing32),
                    
                    // Track info with hymn number and collection
                    _buildTrackInfo(context, audioProvider),
                    
                    const SizedBox(height: AppSizes.spacing32),
                    
                    // Progress slider with section markers
                    _buildProgressSection(context, audioProvider),
                    
                    const SizedBox(height: AppSizes.spacing32),
                    
                    // Main control buttons
                    _buildMainControls(context, audioProvider),
                    
                    const SizedBox(height: AppSizes.spacing24),
                    
                    // Additional controls (shuffle, repeat, speed, etc.)
                    _buildAdditionalControls(context, audioProvider),
                    
                    const SizedBox(height: AppSizes.spacing24),
                    
                    // Quick actions (download, share, add to playlist)
                    _buildQuickActions(context, audioProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AudioPlayerProvider audioProvider) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 32,
          ),
        ),
        Expanded(
          child: Text(
            'Now Playing',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => _showPlaylistSheet(context, audioProvider),
          icon: const Icon(
            Icons.queue_music,
            color: Colors.white,
          ),
          tooltip: 'Playlist',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'hymn_detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Hymn Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
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
              value: 'close',
              child: Row(
                children: [
                  Icon(Icons.close),
                  SizedBox(width: 8),
                  Text('Close Player'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, audioProvider, value),
        ),
      ],
    );
  }

  Widget _buildAlbumArt(BuildContext context, AudioPlayerProvider audioProvider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 80,
          ),
        ),
        // Collection badge
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              audioProvider.currentHymn!.collectionAbbreviation ?? 'CH1941',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(AppColors.primaryBlue),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackInfo(BuildContext context, AudioPlayerProvider audioProvider) {
    final hymn = audioProvider.currentHymn!;
    
    return Column(
      children: [
        // Hymn number and title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '#${hymn.hymnNumber}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hymn.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSizes.spacing8),
        
        // Author and composer info
        if (hymn.author != null || hymn.composer != null)
          Column(
            children: [
              if (hymn.author != null)
                Text(
                  'Words: ${hymn.author}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              if (hymn.composer != null)
                Text(
                  'Music: ${hymn.composer}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, AudioPlayerProvider audioProvider) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: audioProvider.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final position = audioProvider.duration * value;
              audioProvider.seekTo(position);
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audioProvider.positionText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                audioProvider.durationText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(BuildContext context, AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous button
        IconButton(
          onPressed: audioProvider.hasPrevious ? audioProvider.playPrevious : null,
          icon: Icon(
            Icons.skip_previous,
            color: audioProvider.hasPrevious 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 48,
          ),
        ),
        
        // Seek backward 15s
        IconButton(
          onPressed: audioProvider.seekBackward,
          icon: const Icon(
            Icons.replay_10,
            color: Colors.white,
            size: 36,
          ),
        ),
        
        // Play/pause button
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              if (audioProvider.isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.resume();
              }
            },
            icon: Icon(
              audioProvider.isLoading
                  ? Icons.hourglass_empty
                  : audioProvider.isPlaying 
                      ? Icons.pause 
                      : Icons.play_arrow,
              color: const Color(AppColors.primaryBlue),
              size: 48,
            ),
          ),
        ),
        
        // Seek forward 15s
        IconButton(
          onPressed: audioProvider.seekForward,
          icon: const Icon(
            Icons.forward_10,
            color: Colors.white,
            size: 36,
          ),
        ),
        
        // Next button
        IconButton(
          onPressed: audioProvider.hasNext ? audioProvider.playNext : null,
          icon: Icon(
            Icons.skip_next,
            color: audioProvider.hasNext 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 48,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context, AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle button
        IconButton(
          onPressed: audioProvider.toggleShuffle,
          icon: Icon(
            Icons.shuffle,
            color: audioProvider.isShuffleEnabled 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 28,
          ),
          tooltip: 'Shuffle',
        ),
        
        // Repeat button
        IconButton(
          onPressed: audioProvider.toggleRepeat,
          icon: Icon(
            audioProvider.repeatMode == RepeatMode.one
                ? Icons.repeat_one
                : Icons.repeat,
            color: audioProvider.repeatMode != RepeatMode.off 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 28,
          ),
          tooltip: 'Repeat',
        ),
        
        // Volume control
        IconButton(
          onPressed: () => _showVolumeDialog(context, audioProvider),
          icon: Icon(
            audioProvider.volume > 0.5
                ? Icons.volume_up
                : audioProvider.volume > 0
                    ? Icons.volume_down
                    : Icons.volume_off,
            color: Colors.white,
            size: 28,
          ),
          tooltip: 'Volume',
        ),
        
        // Playback speed
        IconButton(
          onPressed: () => _showSpeedDialog(context, audioProvider),
          icon: const Icon(
            Icons.speed,
            color: Colors.white,
            size: 28,
          ),
          tooltip: 'Playback Speed',
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Download button
        TextButton.icon(
          onPressed: () => _downloadHymn(context, audioProvider),
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text('Download', style: TextStyle(color: Colors.white)),
        ),
        
        // Add to favorites
        TextButton.icon(
          onPressed: () => _toggleFavorite(context, audioProvider),
          icon: Icon(
            audioProvider.currentHymn!.isFavorite 
                ? Icons.favorite 
                : Icons.favorite_border,
            color: Colors.white,
          ),
          label: const Text('Favorite', style: TextStyle(color: Colors.white)),
        ),
        
        // Share button
        TextButton.icon(
          onPressed: () => _shareHymn(context, audioProvider),
          icon: const Icon(Icons.share, color: Colors.white),
          label: const Text('Share', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showPlaylistSheet(BuildContext context, AudioPlayerProvider audioProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PlaylistSheet(audioProvider: audioProvider),
    );
  }

  void _showVolumeDialog(BuildContext context, AudioPlayerProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: audioProvider.volume,
                    onChanged: audioProvider.setVolume,
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
            Text('${(audioProvider.volume * 100).round()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context, AudioPlayerProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
            return RadioListTile<double>(
              title: Text('${speed}x'),
              value: speed,
              groupValue: 1.0, // Would need to track current speed in provider
              onChanged: (value) {
                if (value != null) {
                  audioProvider.setPlaybackRate(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, AudioPlayerProvider audioProvider, String action) {
    switch (action) {
      case 'hymn_detail':
        context.push('/hymn/${audioProvider.currentHymn!.id}');
        break;
      case 'download':
        _downloadHymn(context, audioProvider);
        break;
      case 'share':
        _shareHymn(context, audioProvider);
        break;
      case 'close':
        audioProvider.stop();
        audioProvider.clearPlaylist();
        Navigator.pop(context);
        break;
    }
  }

  void _downloadHymn(BuildContext context, AudioPlayerProvider audioProvider) {
    final hymn = audioProvider.currentHymn!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => DownloadOptionsSheet(
        hymnId: hymn.id,
        hymnNumber: hymn.hymnNumber,
        hymnTitle: hymn.title,
        collectionAbbr: hymn.collectionAbbreviation,
      ),
    );
  }

  void _toggleFavorite(BuildContext context, AudioPlayerProvider audioProvider) {
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite functionality coming soon')),
    );
  }

  void _shareHymn(BuildContext context, AudioPlayerProvider audioProvider) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
}

class PlaylistSheet extends StatelessWidget {
  final AudioPlayerProvider audioProvider;

  const PlaylistSheet({
    super.key,
    required this.audioProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSizes.spacing12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Row(
              children: [
                Text(
                  'Playing Queue (${audioProvider.playlist.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    audioProvider.clearPlaylist();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          // Loop mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: Row(
              children: [
                Icon(
                  audioProvider.repeatMode == RepeatMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: audioProvider.repeatMode != RepeatMode.off
                      ? const Color(AppColors.primaryBlue)
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  audioProvider.repeatMode == RepeatMode.off
                      ? 'No Repeat'
                      : audioProvider.repeatMode == RepeatMode.one
                          ? 'Repeat One'
                          : 'Repeat All',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Switch(
                  value: audioProvider.repeatMode != RepeatMode.off,
                  onChanged: (value) => audioProvider.toggleRepeat(),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Playlist
          Expanded(
            child: ListView.builder(
              itemCount: audioProvider.playlist.length,
              itemBuilder: (context, index) {
                final hymn = audioProvider.playlist[index];
                final isCurrentTrack = index == audioProvider.currentIndex;
                
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCurrentTrack 
                          ? const Color(AppColors.primaryBlue)
                          : const Color(AppColors.gray300),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCurrentTrack && audioProvider.isPlaying
                              ? Icons.volume_up
                              : Icons.music_note,
                          color: isCurrentTrack ? Colors.white : const Color(AppColors.gray600),
                          size: 16,
                        ),
                        Text(
                          '#${hymn.hymnNumber}',
                          style: TextStyle(
                            color: isCurrentTrack ? Colors.white : const Color(AppColors.gray600),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    hymn.title,
                    style: TextStyle(
                      fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentTrack ? const Color(AppColors.primaryBlue) : null,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (hymn.collectionAbbreviation != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            hymn.collectionAbbreviation!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.primaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (hymn.author != null)
                        Expanded(child: Text(hymn.author!)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'play',
                        child: Text('Play'),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove'),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'play':
                          audioProvider.playAtIndex(index);
                          break;
                        case 'remove':
                          audioProvider.removeFromPlaylist(index);
                          break;
                      }
                    },
                  ),
                  onTap: () => audioProvider.playAtIndex(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadOptionsSheet extends StatelessWidget {
  final int hymnId;
  final int hymnNumber;
  final String hymnTitle;
  final String? collectionAbbr;

  const DownloadOptionsSheet({
    super.key,
    required this.hymnId,
    required this.hymnNumber,
    required this.hymnTitle,
    this.collectionAbbr,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, downloadProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title
              Row(
                children: [
                  Icon(
                    Icons.download,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download Options',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${collectionAbbr ?? 'CH1941'} #$hymnNumber - $hymnTitle',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Download options
              _buildDownloadOption(
                context,
                downloadProvider,
                icon: Icons.audiotrack,
                title: 'MP3 Audio',
                subtitle: 'High quality audio file',
                fileType: 'mp3',
                isDownloaded: downloadProvider.isHymnDownloaded(hymnId, 'mp3'),
              ),
              
              const SizedBox(height: AppSizes.spacing12),
              
              _buildDownloadOption(
                context,
                downloadProvider,
                icon: Icons.piano,
                title: 'MIDI File',
                subtitle: 'Musical notation for playback',
                fileType: 'midi',
                isDownloaded: downloadProvider.isHymnDownloaded(hymnId, 'midi'),
              ),
              
              const SizedBox(height: AppSizes.spacing12),
              
              _buildDownloadOption(
                context,
                downloadProvider,
                icon: Icons.picture_as_pdf,
                title: 'Sheet Music (PDF)',
                subtitle: 'Printable sheet music',
                fileType: 'pdf',
                isDownloaded: downloadProvider.isHymnDownloaded(hymnId, 'pdf'),
              ),
              
              const SizedBox(height: AppSizes.spacing24),
              
              // Download all button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadAll(context, downloadProvider),
                  icon: const Icon(Icons.download_for_offline),
                  label: const Text('Download All Formats'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // View downloads button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/downloads');
                },
                child: const Text('View All Downloads'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOption(
    BuildContext context,
    DownloadProvider downloadProvider, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String fileType,
    required bool isDownloaded,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDownloaded ? Colors.green : Theme.of(context).primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isDownloaded
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                onPressed: () => _downloadSingle(context, downloadProvider, fileType),
                icon: const Icon(Icons.download),
              ),
        enabled: !isDownloaded,
      ),
    );
  }

  void _downloadSingle(BuildContext context, DownloadProvider downloadProvider, String fileType) async {
    try {
      switch (fileType) {
        case 'mp3':
          await downloadProvider.downloadHymnAudio(hymnId, hymnTitle, collectionAbbr: collectionAbbr);
          break;
        case 'midi':
          await downloadProvider.downloadHymnMidi(hymnId, hymnTitle, collectionAbbr: collectionAbbr);
          break;
        case 'pdf':
          await downloadProvider.downloadHymnSheet(hymnId, hymnTitle, collectionAbbr: collectionAbbr);
          break;
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileType download started')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  void _downloadAll(BuildContext context, DownloadProvider downloadProvider) async {
    try {
      await downloadProvider.downloadAllHymnFormats(hymnId, hymnTitle, collectionAbbr: collectionAbbr);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All downloads started')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }
}