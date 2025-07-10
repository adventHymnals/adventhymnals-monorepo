import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/hymn.dart';

class AudioPlayerWidget extends StatelessWidget {
  final bool isMinimized;
  final VoidCallback? onExpand;
  final VoidCallback? onMinimize;

  const AudioPlayerWidget({
    super.key,
    this.isMinimized = false,
    this.onExpand,
    this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentHymn == null) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isMinimized ? 80 : null,
          child: Material(
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppColors.primaryBlue),
                    Color(AppColors.secondaryBlue),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isMinimized ? _buildMinimizedPlayer(context, audioProvider) : _buildFullPlayer(context, audioProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimizedPlayer(BuildContext context, AudioPlayerProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppSizes.spacing12),
          
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  audioProvider.currentHymn!.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (audioProvider.currentHymn!.author != null)
                  Text(
                    audioProvider.currentHymn!.author!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Play/pause button
          IconButton(
            onPressed: () {
              if (audioProvider.isPlaying) {
                audioProvider.pause();
              } else {
                audioProvider.resume();
              }
            },
            icon: Icon(
              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          // Expand button
          IconButton(
            onPressed: onExpand,
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer(BuildContext context, AudioPlayerProvider audioProvider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing20),
        child: Column(
          children: [
            // Header with minimize button
            Row(
              children: [
                IconButton(
                  onPressed: onMinimize,
                  icon: Icon(
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
                  icon: Icon(
                    Icons.queue_music,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.spacing32),
            
            // Album art
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
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 80,
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing32),
            
            // Track info
            Text(
              audioProvider.currentHymn!.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: AppSizes.spacing8),
            
            if (audioProvider.currentHymn!.author != null)
              Text(
                audioProvider.currentHymn!.author!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: AppSizes.spacing32),
            
            // Progress slider
            _buildProgressSlider(context, audioProvider),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Control buttons
            _buildControlButtons(context, audioProvider),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Additional controls
            _buildAdditionalControls(context, audioProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, AudioPlayerProvider audioProvider) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            trackHeight: 4,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                audioProvider.durationText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous button
        IconButton(
          onPressed: audioProvider.hasPrevious ? audioProvider.playPrevious : null,
          icon: Icon(
            Icons.skip_previous,
            color: audioProvider.hasPrevious ? Colors.white : Colors.white.withOpacity(0.5),
            size: 40,
          ),
        ),
        
        // Seek backward button
        IconButton(
          onPressed: audioProvider.seekBackward,
          icon: Icon(
            Icons.replay_10,
            color: Colors.white,
            size: 32,
          ),
        ),
        
        // Play/pause button
        Container(
          width: 72,
          height: 72,
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
              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Color(AppColors.primaryBlue),
              size: 40,
            ),
          ),
        ),
        
        // Seek forward button
        IconButton(
          onPressed: audioProvider.seekForward,
          icon: Icon(
            Icons.forward_10,
            color: Colors.white,
            size: 32,
          ),
        ),
        
        // Next button
        IconButton(
          onPressed: audioProvider.hasNext ? audioProvider.playNext : null,
          icon: Icon(
            Icons.skip_next,
            color: audioProvider.hasNext ? Colors.white : Colors.white.withOpacity(0.5),
            size: 40,
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
            color: audioProvider.isShuffleEnabled ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
        
        // Repeat button
        IconButton(
          onPressed: audioProvider.toggleRepeat,
          icon: Icon(
            audioProvider.repeatMode == RepeatMode.one
                ? Icons.repeat_one
                : Icons.repeat,
            color: audioProvider.repeatMode != RepeatMode.off ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
        
        // Volume button
        IconButton(
          onPressed: () => _showVolumeSlider(context, audioProvider),
          icon: Icon(
            audioProvider.volume > 0.5
                ? Icons.volume_up
                : audioProvider.volume > 0
                    ? Icons.volume_down
                    : Icons.volume_off,
            color: Colors.white,
          ),
        ),
        
        // Speed button
        IconButton(
          onPressed: () => _showSpeedSelector(context, audioProvider),
          icon: Icon(
            Icons.speed,
            color: Colors.white,
          ),
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

  void _showVolumeSlider(BuildContext context, AudioPlayerProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: audioProvider.volume,
                    onChanged: audioProvider.setVolume,
                  ),
                ),
                Icon(Icons.volume_up),
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

  void _showSpeedSelector(BuildContext context, AudioPlayerProvider audioProvider) {
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
              groupValue: 1.0, // Would need to track current speed
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
                  'Playing Queue',
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
          
          // Playlist
          Expanded(
            child: ListView.builder(
              itemCount: audioProvider.playlist.length,
              itemBuilder: (context, index) {
                final hymn = audioProvider.playlist[index];
                final isCurrentTrack = index == audioProvider.currentIndex;
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrentTrack 
                          ? Color(AppColors.primaryBlue)
                          : Color(AppColors.gray300),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Icon(
                      isCurrentTrack && audioProvider.isPlaying
                          ? Icons.volume_up
                          : Icons.music_note,
                      color: isCurrentTrack ? Colors.white : Color(AppColors.gray600),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    hymn.title,
                    style: TextStyle(
                      fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentTrack ? Color(AppColors.primaryBlue) : null,
                    ),
                  ),
                  subtitle: hymn.author != null ? Text(hymn.author!) : null,
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'play',
                        child: Text('Play'),
                      ),
                      PopupMenuItem(
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