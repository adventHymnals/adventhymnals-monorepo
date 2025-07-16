import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/audio_player_provider.dart';
import '../../core/constants/app_constants.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentHymn == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: audioProvider.progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(AppColors.primaryBlue),
                ),
                minHeight: 2,
              ),
              
              // Player content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing12,
                    vertical: AppSizes.spacing8,
                  ),
                  child: Row(
                    children: [
                      // Album art placeholder
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryBlue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Color(AppColors.primaryBlue),
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: AppSizes.spacing12),
                      
                      // Track info
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showFullPlayer(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                audioProvider.currentHymn!.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (audioProvider.currentHymn!.author != null)
                                Text(
                                  audioProvider.currentHymn!.author!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Previous button
                      IconButton(
                        onPressed: audioProvider.hasPrevious ? audioProvider.playPrevious : null,
                        icon: Icon(
                          Icons.skip_previous,
                          color: audioProvider.hasPrevious 
                              ? Colors.grey[700] 
                              : Colors.grey[400],
                        ),
                        iconSize: 24,
                      ),
                      
                      // Play/pause button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(AppColors.primaryBlue),
                          shape: BoxShape.circle,
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
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      // Next button
                      IconButton(
                        onPressed: audioProvider.hasNext ? audioProvider.playNext : null,
                        icon: Icon(
                          Icons.skip_next,
                          color: audioProvider.hasNext 
                              ? Colors.grey[700] 
                              : Colors.grey[400],
                        ),
                        iconSize: 24,
                      ),
                      
                      // Close button
                      IconButton(
                        onPressed: () => audioProvider.stop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FullScreenAudioPlayer(),
    );
  }
}

class FullScreenAudioPlayer extends StatelessWidget {
  const FullScreenAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentHymn == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: MediaQuery.of(context).size.height,
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
                  // Header
                  Row(
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
                        onPressed: () => _showHymnDetail(context, audioProvider),
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
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
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  
                  const Spacer(),
                  
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
                  
                  const Spacer(),
                  
                  // Progress
                  _buildProgressSection(context, audioProvider),
                  
                  const SizedBox(height: AppSizes.spacing32),
                  
                  // Controls
                  _buildControls(context, audioProvider),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildControls(BuildContext context, AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          onPressed: audioProvider.toggleShuffle,
          icon: Icon(
            Icons.shuffle,
            color: audioProvider.isShuffleEnabled 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 28,
          ),
        ),
        
        // Previous
        IconButton(
          onPressed: audioProvider.hasPrevious ? audioProvider.playPrevious : null,
          icon: Icon(
            Icons.skip_previous,
            color: audioProvider.hasPrevious 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 40,
          ),
        ),
        
        // Play/pause
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
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
              size: 40,
            ),
          ),
        ),
        
        // Next
        IconButton(
          onPressed: audioProvider.hasNext ? audioProvider.playNext : null,
          icon: Icon(
            Icons.skip_next,
            color: audioProvider.hasNext 
                ? Colors.white 
                : Colors.white.withOpacity(0.5),
            size: 40,
          ),
        ),
        
        // Repeat
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
        ),
      ],
    );
  }

  void _showHymnDetail(BuildContext context, AudioPlayerProvider audioProvider) {
    Navigator.pop(context);
    context.push('/hymn/${audioProvider.currentHymn!.id}');
  }
}