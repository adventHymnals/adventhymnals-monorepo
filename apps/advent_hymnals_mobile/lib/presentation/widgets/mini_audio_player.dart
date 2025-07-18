import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../providers/audio_player_provider.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentHymn == null || 
            (!audioProvider.isPlaying && !audioProvider.isPaused)) {
          return const SizedBox.shrink();
        }

        final hymn = audioProvider.currentHymn!;
        
        print('🎵 [MiniAudioPlayer] Showing mini player for: ${hymn.title}, state: ${audioProvider.isPlaying ? "playing" : "paused"}');
        
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                context.push('/player');
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar
                    LinearProgressIndicator(
                      value: audioProvider.progress.clamp(0.0, 1.0),
                      backgroundColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(AppColors.primaryBlue),
                      ),
                      minHeight: 2,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Main Content
                    Row(
                      children: [
                        // Hymn Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(AppColors.primaryBlue).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(AppColors.primaryBlue).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                                size: 20,
                              ),
                              Text(
                                '#${hymn.hymnNumber}',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Hymn Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hymn.title,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hymn.author ?? hymn.collectionAbbreviation ?? 'Unknown',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Control Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Play/Pause Button
                            GestureDetector(
                              onTap: () {
                                if (audioProvider.isPlaying) {
                                  print('🎵 [MiniAudioPlayer] Pausing from mini player');
                                  audioProvider.pause();
                                } else if (audioProvider.isPaused) {
                                  print('🎵 [MiniAudioPlayer] Resuming from mini player');
                                  audioProvider.resume();
                                } else {
                                  print('🎵 [MiniAudioPlayer] Starting playback from mini player');
                                  audioProvider.playHymn(hymn);
                                }
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(AppColors.primaryBlue),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Next Button
                            GestureDetector(
                              onTap: audioProvider.hasNext ? audioProvider.playNext : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: audioProvider.hasNext 
                                    ? Colors.white.withOpacity(0.2) 
                                    : Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.skip_next,
                                  color: audioProvider.hasNext 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.5),
                                  size: 18,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Close Button
                            GestureDetector(
                              onTap: () {
                                audioProvider.stop();
                                audioProvider.clearPlaylist();
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MiniAudioPlayerWrapper extends StatelessWidget {
  final Widget child;
  
  const MiniAudioPlayerWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        final hasCurrentHymn = audioProvider.currentHymn != null;
        
        return Scaffold(
          body: this.child,
          bottomSheet: hasCurrentHymn ? const MiniAudioPlayer() : null,
        );
      },
    );
  }
}