import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../providers/audio_player_provider.dart';
import '../../domain/entities/hymn.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
            elevation: 0,
            title: Text(
              'Audio Player',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
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
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
                const SizedBox(height: 8),
                Text(
                  '#${hymn.hymnNumber}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
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
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
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
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
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
                  : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              size: 28,
            ),
            onPressed: audioProvider.toggleShuffle,
          ),
          
          // Previous
          IconButton(
            icon: Icon(Icons.skip_previous, color: Theme.of(context).textTheme.bodyLarge?.color, size: 36),
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
            icon: Icon(Icons.skip_next, color: Theme.of(context).textTheme.bodyLarge?.color, size: 36),
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
                  ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)
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
              inactiveTrackColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.3),
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
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  audioProvider.durationText,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(AppColors.primaryBlue),
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'No hymns in queue',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add hymns to start playing',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
            : Theme.of(context).cardColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCurrentHymn 
                ? const Color(AppColors.primaryBlue)
                : Colors.grey.withOpacity(0.3),
              child: Text(
                hymn.hymnNumber.toString(),
                style: TextStyle(
                  color: isCurrentHymn ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              hymn.title,
              style: TextStyle(
                color: isCurrentHymn ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isCurrentHymn ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: hymn.author != null
                ? Text(
                    hymn.author!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadSavedPlaylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final playlists = snapshot.data ?? [];
        
        return Column(
          children: [
            // New Playlist Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showSavePlaylistDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Save Current Queue as Playlist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.primaryBlue),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            
            // Playlists List
            Expanded(
              child: playlists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_play,
                            size: 64,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Saved Playlists',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save your current queue to create playlists',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.playlist_play),
                            title: Text(playlist['name']),
                            subtitle: Text('${playlist['hymns'].length} hymns'),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'load',
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_arrow),
                                      SizedBox(width: 8),
                                      Text('Load Playlist'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                switch (value) {
                                  case 'load':
                                    await _loadAndPlayPlaylist(playlist['id']);
                                    break;
                                  case 'delete':
                                    await _deletePlaylist(playlist['id']);
                                    setState(() {});
                                    break;
                                }
                              },
                            ),
                            onTap: () => _loadAndPlayPlaylist(playlist['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
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
            Text(
              'Downloaded Audio Files',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadDownloadedFiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final files = snapshot.data ?? [];
                
                if (files.isEmpty) {
                  return Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No downloaded files yet.\nFiles are cached automatically when you play hymns.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: files.map((file) {
                    return Card(
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(file['name']),
                        subtitle: Text('${_formatFileSize(file['size'])} • ${file['type']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFile(file['path']),
                        ),
                        onTap: () => _playFile(file['path']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLyricsView(AudioPlayerProvider audioProvider) {
    final hymn = audioProvider.currentHymn;
    
    if (hymn == null) {
      return Center(
        child: Text(
          'No hymn selected',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 18,
          ),
        ),
      );
    }

    return Container(
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hymn Title
            Text(
              hymn.title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (hymn.author != null && hymn.author!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'By ${hymn.author}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Lyrics
            if (hymn.lyrics != null && hymn.lyrics!.isNotEmpty)
              Text(
                hymn.lyrics!,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  height: 1.6,
                ),
              )
            else
              Text(
                'Lyrics not available',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSavePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Save Playlist',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter a name for your playlist',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'This will save your current queue (${context.read<AudioPlayerProvider>().playlist.length} hymns)',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await _saveCurrentPlaylist(name);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playlist saved successfully!')),
                  );
                  setState(() {}); // Refresh the playlists tab
                }
              }
            },
            child: const Text('Save'),
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

  // Playlist Management Methods
  Future<List<Map<String, dynamic>>> _loadSavedPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getStringList('saved_playlists') ?? [];
    
    return playlistsJson.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data;
    }).toList();
  }

  Future<void> _saveCurrentPlaylist(String name) async {
    final audioProvider = context.read<AudioPlayerProvider>();
    final prefs = await SharedPreferences.getInstance();
    
    final playlist = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
      'hymns': audioProvider.playlist.map((hymn) => {
        'id': hymn.id,
        'title': hymn.title,
        'hymnNumber': hymn.hymnNumber,
        'author': hymn.author,
        'composer': hymn.composer,
        'collectionId': hymn.collectionId,
        'collectionAbbreviation': hymn.collectionAbbreviation,
      }).toList(),
    };
    
    final existingPlaylists = await _loadSavedPlaylists();
    existingPlaylists.add(playlist);
    
    final playlistsJson = existingPlaylists.map((p) => jsonEncode(p)).toList();
    await prefs.setStringList('saved_playlists', playlistsJson);
  }

  Future<void> _loadAndPlayPlaylist(String playlistId) async {
    final playlists = await _loadSavedPlaylists();
    final playlist = playlists.firstWhere((p) => p['id'] == playlistId);
    
    final audioProvider = context.read<AudioPlayerProvider>();
    audioProvider.clearPlaylist();
    
    // Convert saved hymn data back to Hymn objects
    final hymns = (playlist['hymns'] as List).map((hymnData) {
      return Hymn(
        id: hymnData['id'],
        title: hymnData['title'],
        hymnNumber: hymnData['hymnNumber'],
        author: hymnData['author'],
        composer: hymnData['composer'],
        collectionId: hymnData['collectionId'],
        collectionAbbreviation: hymnData['collectionAbbreviation'],
        lyrics: '', // Will be loaded when needed
      );
    }).toList();
    
    // Clear current playlist and add new hymns
    audioProvider.clearPlaylist();
    for (final hymn in hymns) {
      audioProvider.addToPlaylist(hymn);
    }
    
    if (hymns.isNotEmpty) {
      audioProvider.playAtIndex(0);
    }
  }

  Future<void> _deletePlaylist(String playlistId) async {
    final prefs = await SharedPreferences.getInstance();
    final playlists = await _loadSavedPlaylists();
    playlists.removeWhere((p) => p['id'] == playlistId);
    
    final playlistsJson = playlists.map((p) => jsonEncode(p)).toList();
    await prefs.setStringList('saved_playlists', playlistsJson);
  }

  // Downloaded Files Methods
  Future<List<Map<String, dynamic>>> _loadDownloadedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio_cache'));
      
      if (!await audioDir.exists()) {
        return [];
      }
      
      final files = <Map<String, dynamic>>[];
      await for (final entity in audioDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          files.add({
            'name': path.basename(entity.path),
            'path': entity.path,
            'size': stat.size,
            'type': path.extension(entity.path).replaceFirst('.', '').toUpperCase(),
            'modifiedAt': stat.modified,
          });
        }
      }
      
      // Sort by modified date (newest first)
      files.sort((a, b) => (b['modifiedAt'] as DateTime).compareTo(a['modifiedAt'] as DateTime));
      return files;
    } catch (e) {
      print('Error loading downloaded files: $e');
      return [];
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  void _deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      setState(() {}); // Refresh the downloads list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting file: $e')),
        );
      }
    }
  }

  void _playFile(String filePath) {
    // TODO: Implement playing local file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing local files coming soon')),
    );
  }
}

class _CacheManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
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
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Audio Cache Statistics',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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
                            context,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            'Cache Benefits:',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          _buildBenefitItem('• Offline playback capability', context),
                          _buildBenefitItem('• Faster loading times', context),
                          _buildBenefitItem('• Reduced data usage', context),
                          _buildBenefitItem('• Better audio quality consistency', context),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cache Management',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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

  Widget _buildStatRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<bool> _showClearCacheDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Clear Audio Cache',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Text(
          'This will permanently delete all downloaded audio files. They will need to be downloaded again for offline playback.\n\nThis action cannot be undone. Continue?',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
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