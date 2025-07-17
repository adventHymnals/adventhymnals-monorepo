import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/comprehensive_audio_service.dart';
import '../providers/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../../domain/entities/hymn.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showQueue = true;
  bool _showLyrics = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Audio Player',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: Icon(_showLyrics ? Icons.lyrics : Icons.lyrics_outlined),
                onPressed: () {
                  setState(() {
                    _showLyrics = !_showLyrics;
                  });
                },
                tooltip: 'Toggle Lyrics',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'clear_queue':
                      audioProvider.clearPlaylist();
                      break;
                    case 'save_playlist':
                      _showSavePlaylistDialog();
                      break;
                    case 'cache_management':
                      _showCacheManagement();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_queue',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Queue'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'save_playlist',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add),
                        SizedBox(width: 8),
                        Text('Save Playlist'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cache_management',
                    child: Row(
                      children: [
                        Icon(Icons.storage),
                        SizedBox(width: 8),
                        Text('Cache Management'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Current Hymn Display
              if (audioProvider.currentHymn != null)
                _buildCurrentHymnDisplay(audioProvider),
              
              // Audio Controls
              _buildAudioControls(audioProvider),
              
              // Progress Bar
              _buildProgressBar(audioProvider),
              
              // Main Content (Tabs or Lyrics)
              Expanded(
                child: _showLyrics
                    ? _buildLyricsView(audioProvider)
                    : _buildTabContent(audioProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentHymnDisplay(AudioPlayerProvider audioProvider) {
    final hymn = audioProvider.currentHymn!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Hymn Cover/Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryBlue).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(AppColors.primaryBlue).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 8),
                Text(
                  '#${hymn.hymnNumber}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Hymn Information
          Text(
            hymn.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          if (hymn.author != null && hymn.author!.isNotEmpty)
            Text(
              hymn.author!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          
          if (hymn.collectionAbbreviation != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                hymn.collectionAbbreviation!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioControls(AudioPlayerProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: audioProvider.isShuffleEnabled
                  ? const Color(AppColors.primaryBlue)
                  : Colors.white.withOpacity(0.7),
              size: 28,
            ),
            onPressed: audioProvider.toggleShuffle,
          ),
          
          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
            onPressed: audioProvider.hasPrevious ? audioProvider.playPrevious : null,
          ),
          
          // Play/Pause
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryBlue),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primaryBlue).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {
                if (audioProvider.isPlaying) {
                  audioProvider.pause();
                } else if (audioProvider.isPaused) {
                  audioProvider.resume();
                } else if (audioProvider.currentHymn != null) {
                  audioProvider.playHymn(audioProvider.currentHymn!);
                }
              },
            ),
          ),
          
          // Next
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
            onPressed: audioProvider.hasNext ? audioProvider.playNext : null,
          ),
          
          // Repeat
          IconButton(
            icon: Icon(
              audioProvider.repeatMode == RepeatMode.off
                  ? Icons.repeat
                  : audioProvider.repeatMode == RepeatMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
              color: audioProvider.repeatMode == RepeatMode.off
                  ? Colors.white.withOpacity(0.7)
                  : const Color(AppColors.primaryBlue),
              size: 28,
            ),
            onPressed: audioProvider.toggleRepeat,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AudioPlayerProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Progress Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(AppColors.primaryBlue),
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: const Color(AppColors.primaryBlue),
              overlayColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
              trackHeight: 4,
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
          
          // Time Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  audioProvider.positionText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  audioProvider.durationText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AudioPlayerProvider audioProvider) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: const Color(0xFF1A1A1A),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(AppColors.primaryBlue),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            tabs: const [
              Tab(text: 'Queue'),
              Tab(text: 'Playlists'),
              Tab(text: 'Downloads'),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQueueTab(audioProvider),
              _buildPlaylistsTab(audioProvider),
              _buildDownloadsTab(audioProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueueTab(AudioPlayerProvider audioProvider) {
    if (audioProvider.playlist.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hymns in queue',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add hymns to start playing',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: audioProvider.playlist.length,
      onReorder: audioProvider.reorderPlaylist,
      itemBuilder: (context, index) {
        final hymn = audioProvider.playlist[index];
        final isCurrentHymn = index == audioProvider.currentIndex;
        
        return Card(
          key: ValueKey(hymn.id),
          color: isCurrentHymn 
            ? const Color(AppColors.primaryBlue).withOpacity(0.2)
            : const Color(0xFF2A2A2A),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCurrentHymn 
                ? const Color(AppColors.primaryBlue)
                : Colors.grey.withOpacity(0.3),
              child: Text(
                hymn.hymnNumber.toString(),
                style: TextStyle(
                  color: isCurrentHymn ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              hymn.title,
              style: TextStyle(
                color: isCurrentHymn ? Colors.white : Colors.grey[300],
                fontWeight: isCurrentHymn ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: hymn.author != null
                ? Text(
                    hymn.author!,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentHymn && audioProvider.isPlaying)
                  const Icon(
                    Icons.volume_up,
                    color: Color(AppColors.primaryBlue),
                  ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.grey[600],
                  onPressed: () {
                    audioProvider.removeFromPlaylist(index);
                  },
                ),
              ],
            ),
            onTap: () {
              audioProvider.playAtIndex(index);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsTab(AudioPlayerProvider audioProvider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_play,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Playlists Coming Soon',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Save and manage your custom playlists',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsTab(AudioPlayerProvider audioProvider) {
    return FutureBuilder<int>(
      future: audioProvider.getCacheSize(),
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cache Info Card
            Card(
              color: const Color(0xFF2A2A2A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storage, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Cache Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cache Size:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          snapshot.hasData 
                            ? audioProvider.formatCacheSize(snapshot.data!)
                            : 'Calculating...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await _showClearCacheDialog();
                          if (confirm) {
                            await audioProvider.clearAudioCache();
                            setState(() {}); // Refresh cache size
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Audio cache cleared'),
                                  backgroundColor: Color(AppColors.successGreen),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Clear Cache'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppColors.errorRed),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Downloaded Files Section
            const Text(
              'Downloaded Audio Files',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Card(
              color: Color(0xFF2A2A2A),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Downloaded files list coming soon.\nFiles are cached automatically when you play hymns.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLyricsView(AudioPlayerProvider audioProvider) {
    final hymn = audioProvider.currentHymn;
    
    if (hymn == null) {
      return const Center(
        child: Text(
          'No hymn selected',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hymn Title
            Text(
              hymn.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (hymn.author != null && hymn.author!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'By ${hymn.author}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Lyrics
            if (hymn.lyrics != null && hymn.lyrics!.isNotEmpty)
              Text(
                hymn.lyrics!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.6,
                ),
              )
            else
              const Text(
                'Lyrics not available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSavePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Save Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Playlist saving feature coming soon!',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCacheManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CacheManagementScreen(),
      ),
    );
  }

  Future<bool> _showClearCacheDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Clear Audio Cache',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will delete all downloaded audio files. They will need to be downloaded again for offline playback. Continue?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppColors.errorRed),
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    ) ?? false;
  }
}

class _CacheManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        title: const Text('Cache Management'),
      ),
      body: Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, child) {
          return FutureBuilder<int>(
            future: audioProvider.getCacheSize(),
            builder: (context, snapshot) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFF2A2A2A),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audio Cache Statistics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildStatRow(
                            'Total Cache Size',
                            snapshot.hasData 
                              ? audioProvider.formatCacheSize(snapshot.data!)
                              : 'Calculating...',
                          ),
                          
                          const SizedBox(height: 16),
                          
                          const Text(
                            'Cache Benefits:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          _buildBenefitItem('• Offline playback capability'),
                          _buildBenefitItem('• Faster loading times'),
                          _buildBenefitItem('• Reduced data usage'),
                          _buildBenefitItem('• Better audio quality consistency'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Card(
                    color: const Color(0xFF2A2A2A),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cache Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final confirm = await _showClearCacheDialog(context);
                                if (confirm && context.mounted) {
                                  await audioProvider.clearAudioCache();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Audio cache cleared successfully'),
                                      backgroundColor: Color(AppColors.successGreen),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.delete_sweep),
                              label: const Text('Clear All Cache'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(AppColors.errorRed),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<bool> _showClearCacheDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Clear Audio Cache',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete all downloaded audio files. They will need to be downloaded again for offline playback.\n\nThis action cannot be undone. Continue?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppColors.errorRed),
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    ) ?? false;
  }
}