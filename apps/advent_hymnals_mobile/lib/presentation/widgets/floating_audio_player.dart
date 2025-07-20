import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../providers/audio_player_provider.dart';

class FloatingAudioPlayer extends StatelessWidget {
  const FloatingAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentHymn == null || 
            (!audioProvider.isPlaying && !audioProvider.isPaused)) {
          return const SizedBox.shrink();
        }

        print('🎵 [FloatingAudioPlayer] Showing mini player for: ${audioProvider.currentHymn!.title}');

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Navigate to full audio player
                Navigator.pushNamed(context, '/audio-player');
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Album art / icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primaryBlue).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Color(AppColors.primaryBlue),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            audioProvider.currentHymn!.title,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hymn ${audioProvider.currentHymn!.hymnNumber}',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    IconButton(
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      onPressed: () {
                        if (audioProvider.isPlaying) {
                          print('🎵 [FloatingAudioPlayer] Pausing from mini player');
                          audioProvider.pause();
                        } else {
                          print('🎵 [FloatingAudioPlayer] Resuming from mini player');
                          audioProvider.resume();
                        }
                      },
                    ),
                    
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      onPressed: () {
                        print('🎵 [FloatingAudioPlayer] Stopping from mini player');
                        audioProvider.stop();
                      },
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