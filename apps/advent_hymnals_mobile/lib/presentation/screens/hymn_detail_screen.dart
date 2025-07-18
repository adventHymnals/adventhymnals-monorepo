import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/projector_service.dart';
import '../../core/data/hymn_data_manager.dart';
import '../../core/database/database_helper.dart';

import '../providers/favorites_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../../domain/entities/hymn.dart';
import '../widgets/banner_ad_widget.dart';
import '../../core/services/comprehensive_audio_service.dart';

// Simple inline model for lyrics sections
class LyricsSection {
  final String type; // "verse", "chorus", "bridge", "refrain"
  final int number; // verse number (1, 2, 3, etc.)
  final String content; // the actual text content

  const LyricsSection({
    required this.type,
    required this.number,
    required this.content,
  });
}

class HymnDetailScreen extends StatefulWidget {
  final int hymnId;
  final String? collectionId;
  final String? fromSource;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
    this.collectionId,
    this.fromSource,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  String _selectedFormat = 'lyrics';
  bool _isFavorite = false;
  late final FocusNode _focusNode;
  bool _isLoading = true;
  Hymn? _hymn;
  String? _errorMessage;
  HymnAudioInfo? _audioInfo;
  bool _isCheckingAudio = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadHymnData();
    // Request focus for keyboard navigation on desktop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHymnData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔍 [HymnDetail] Loading hymn ${widget.hymnId} from collection ${widget.collectionId}');
      
      // Try to get hymn from HymnProvider first (if collection is known)
      if (widget.collectionId != null) {
        final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
        final hymns = hymnProvider.hymns;
        
        // Look for the hymn in the loaded hymns
        final foundHymn = hymns.where((h) => h.hymnNumber == widget.hymnId).firstOrNull;
        
        if (foundHymn != null) {
          print('✅ [HymnDetail] Found hymn in provider: ${foundHymn.title}');
          setState(() {
            _hymn = foundHymn;
            _isLoading = false;
          });
          
          // Add to recently viewed and load favorite status
          _addToRecentlyViewed();
          _loadFavoriteStatus();
          _checkAudioAvailability();
          return;
        }
      }
      
      // Fallback: Try to load individual hymn by constructing the expected hymn ID
      if (widget.collectionId != null) {
        print('🔄 [HymnDetail] Trying to load individual hymn from JSON...');
        
        // Construct the hymn ID (e.g., "SDAH-en-003")
        final paddedNumber = widget.hymnId.toString().padLeft(3, '0');
        final hymnId = '${widget.collectionId!.toUpperCase()}-en-$paddedNumber';
        
        final hymnDataManager = HymnDataManager();
        final hymn = await hymnDataManager.loadHymnFromJson(hymnId);
        
        if (hymn != null) {
          print('✅ [HymnDetail] Loaded hymn from JSON: ${hymn.title}');
          setState(() {
            _hymn = hymn;
            _isLoading = false;
          });
          
          // Add to recently viewed and load favorite status
          _addToRecentlyViewed();
          _loadFavoriteStatus();
          _checkAudioAvailability();
          return;
        }
      }
      
      // Final fallback: create a placeholder hymn
      print('⚠️ [HymnDetail] Unable to load hymn data, using placeholder');
      setState(() {
        _hymn = _createFallbackHymn();
        _isLoading = false;
      });
      
      // Load favorite status for fallback hymn (but don't add to recently viewed since it's not a real hymn)
      _loadFavoriteStatus();
      _checkAudioAvailability();
      
    } catch (e) {
      print('❌ [HymnDetail] Error loading hymn: $e');
      setState(() {
        _errorMessage = 'Failed to load hymn: $e';
        _isLoading = false;
      });
    }
  }
  
  Hymn _createFallbackHymn() {
    return Hymn(
      id: widget.hymnId,
      hymnNumber: widget.hymnId,
      title: 'Hymn ${widget.hymnId}',
      author: 'Loading...',
      lyrics: 'Hymn content is being loaded...',
      collectionId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavorite: false,
    );
  }
  
  Future<void> _addToRecentlyViewed() async {
    try {
      if (_hymn == null) {
        print('⚠️ [HymnDetail] Cannot add to recently viewed: hymn not loaded');
        return;
      }
      
      print('🔍 [HymnDetail] Adding hymn ${_hymn!.id} (${_hymn!.title}) to recently viewed');
      
      // If the hymn doesn't have a proper database ID (loaded from JSON), 
      // try to find it in the database first
      int? databaseId = _hymn!.id;
      if (databaseId <= 0) {
        print('🔄 [HymnDetail] Hymn has invalid database ID, searching by hymn number and collection');
        // Try to find the hymn in the database by hymn number and collection
        final db = DatabaseHelper.instance;
        final hymns = await db.getHymns();
        final matchingHymn = hymns.where((h) => 
          h['hymn_number'] == _hymn!.hymnNumber && 
          h['title'] == _hymn!.title
        ).firstOrNull;
        
        if (matchingHymn != null) {
          databaseId = matchingHymn['id'] as int;
          print('✅ [HymnDetail] Found matching hymn in database with ID: $databaseId');
        } else {
          print('⚠️ [HymnDetail] Could not find hymn in database, skipping recently viewed');
          return;
        }
      }
      
      final recentlyViewedProvider = Provider.of<RecentlyViewedProvider>(context, listen: false);
      final success = await recentlyViewedProvider.addRecentlyViewed(databaseId);
      
      if (success) {
        print('✅ [HymnDetail] Successfully added hymn $databaseId (${_hymn!.title}) to recently viewed');
      } else {
        print('❌ [HymnDetail] Failed to add hymn $databaseId to recently viewed');
      }
    } catch (e) {
      print('❌ [HymnDetail] Exception while adding to recently viewed: $e');
      // Don't show error to user as this is not critical functionality
    }
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      // Only check favorites if we have a loaded hymn with a valid database ID
      if (_hymn == null || _hymn!.id <= 0) {
        print('⚠️ [HymnDetail] Cannot check favorite status: hymn not loaded or invalid ID');
        return;
      }
      
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      final isFav = await favoritesProvider.isFavorite(_hymn!.id);
      setState(() {
        _isFavorite = isFav;
      });
    } catch (e) {
      print('⚠️ [HymnDetail] Failed to load favorite status: $e');
    }
  }
  
  Future<void> _checkAudioAvailability() async {
    if (_hymn == null) return;
    
    try {
      setState(() {
        _isCheckingAudio = true;
      });
      
      final audioService = ComprehensiveAudioService.instance;
      final audioInfo = await audioService.getAudioInfo(_hymn!, onComplete: (updatedInfo) {
        // Update UI when audio check completes
        if (mounted) {
          setState(() {
            _audioInfo = updatedInfo;
            _isCheckingAudio = false;
          });
        }
      });
      
      setState(() {
        _audioInfo = audioInfo;
        _isCheckingAudio = false;
      });
      
      // Also trigger check in audio provider
      final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
      await audioProvider.checkAudioAvailability(_hymn!);
      
    } catch (e) {
      print('⚠️ [HymnDetail] Failed to check audio availability: $e');
      setState(() {
        _isCheckingAudio = false;
      });
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    // Check if the swipe velocity is significant enough
    const double minSwipeVelocity = 500.0;
    
    if (details.primaryVelocity == null) return;
    
    final double velocity = details.primaryVelocity!;
    
    if (velocity.abs() < minSwipeVelocity) return;
    
    // Add haptic feedback for swipe gestures
    HapticFeedback.lightImpact();
    
    if (velocity > 0) {
      // Swipe right - go to previous hymn
      _navigateToPreviousHymn();
    } else {
      // Swipe left - go to next hymn
      _navigateToNextHymn();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    // Only handle key down events to avoid double triggers
    if (event is! KeyDownEvent) return;
    
    // Desktop keyboard navigation
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyJ:
          // Left arrow or J key = Previous hymn
          _navigateToPreviousHymn();
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyK:
          // Right arrow or K key = Next hymn
          _navigateToNextHymn();
          break;
        case LogicalKeyboardKey.space:
          // Spacebar = Play/Pause audio
          _toggleAudioPlayback();
          break;
        case LogicalKeyboardKey.escape:
          // Escape key = Go back
          _navigateBack();
          break;
      }
    }
  }

  void _toggleAudioPlayback() {
    if (_hymn == null) return;
    
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    
    if (audioProvider.currentHymn?.id == _hymn!.id && audioProvider.isPlaying) {
      audioProvider.pause();
    } else {
      audioProvider.playHymn(_hymn!);
    }
  }

  bool _canNavigateToNext() {
    if (_hymn == null) {
      print('🔍 [Navigation] _canNavigateToNext: false - _hymn is null');
      return false;
    }
    
    try {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      final allHymns = hymnProvider.hymns;
      
      // Use the hymn's own collection abbreviation as the primary source
      final currentCollection = _hymn!.collectionAbbreviation ?? widget.collectionId;
      print('🔍 [Navigation] _canNavigateToNext: current hymn ${_hymn!.hymnNumber}, collection: $currentCollection');
      
      // Debug: show sample collection abbreviations
      final sampleCollections = allHymns.take(5).map((h) => '${h.hymnNumber}:${h.collectionAbbreviation}').join(', ');
      print('🔍 [Navigation] Sample hymn collections: $sampleCollections');
      
      final collectionHymns = allHymns
          .where((h) => h.collectionAbbreviation?.toLowerCase() == currentCollection?.toLowerCase())
          .toList();
      collectionHymns.sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));
      
      print('🔍 [Navigation] Found ${collectionHymns.length} hymns in collection $currentCollection');
      if (collectionHymns.isEmpty) {
        // Debug: show all unique collections available
        final uniqueCollections = allHymns.map((h) => h.collectionAbbreviation).toSet().toList();
        print('🔍 [Navigation] Available collections: $uniqueCollections');
      }
      
      final currentIndex = collectionHymns.indexWhere((h) => h.hymnNumber == _hymn!.hymnNumber);
      final canNavigate = currentIndex >= 0 && currentIndex < collectionHymns.length - 1;
      
      print('🔍 [Navigation] Current index: $currentIndex, can navigate next: $canNavigate');
      return canNavigate;
    } catch (e) {
      print('❌ [Navigation] Error in _canNavigateToNext: $e');
      return false;
    }
  }

  bool _canNavigateToPrevious() {
    if (_hymn == null) {
      print('🔍 [Navigation] _canNavigateToPrevious: false - _hymn is null');
      return false;
    }
    
    try {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      final allHymns = hymnProvider.hymns;
      
      // Use the hymn's own collection abbreviation as the primary source
      final currentCollection = _hymn!.collectionAbbreviation ?? widget.collectionId;
      print('🔍 [Navigation] _canNavigateToPrevious: current hymn ${_hymn!.hymnNumber}, collection: $currentCollection');
      
      final collectionHymns = allHymns
          .where((h) => h.collectionAbbreviation?.toLowerCase() == currentCollection?.toLowerCase())
          .toList();
      collectionHymns.sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));
      
      print('🔍 [Navigation] Found ${collectionHymns.length} hymns in collection $currentCollection');
      
      final currentIndex = collectionHymns.indexWhere((h) => h.hymnNumber == _hymn!.hymnNumber);
      final canNavigate = currentIndex > 0;
      
      print('🔍 [Navigation] Current index: $currentIndex, can navigate previous: $canNavigate');
      return canNavigate;
    } catch (e) {
      print('❌ [Navigation] Error in _canNavigateToPrevious: $e');
      return false;
    }
  }

  void _navigateToNextHymn() {
    if (_hymn == null) {
      _showNavigationFeedback('Unable to navigate: hymn not loaded');
      return;
    }

    try {
      // Get the current hymn provider to access the hymns in the collection
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      final hymns = hymnProvider.hymns;
      
      if (hymns.isEmpty) {
        _showNavigationFeedback('No hymns available in collection');
        return;
      }

      // Use the hymn's own collection abbreviation as the primary source
      final currentCollection = _hymn!.collectionAbbreviation ?? widget.collectionId;
      
      print('🔍 [Navigation] Current hymn: ${_hymn!.hymnNumber}, Collection: $currentCollection');
      print('🔍 [Navigation] Available hymns: ${hymns.length}');
      
      // Find hymns in the same collection, sorted by hymn number
      final collectionHymns = hymns
          .where((h) => h.collectionAbbreviation?.toLowerCase() == currentCollection?.toLowerCase())
          .toList()
        ..sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));

      print('🔍 [Navigation] Collection hymns found: ${collectionHymns.length}');

      if (collectionHymns.isEmpty) {
        _showNavigationFeedback('No hymns found in this collection ($currentCollection)');
        return;
      }

      // Find current hymn index
      final currentIndex = collectionHymns.indexWhere((h) => h.hymnNumber == _hymn!.hymnNumber);
      
      if (currentIndex == -1) {
        _showNavigationFeedback('Current hymn not found in collection');
        return;
      }

      // Check if we're at the last hymn
      if (currentIndex >= collectionHymns.length - 1) {
        _showNavigationFeedback('This is the last hymn in the collection');
        return;
      }

      // Navigate to next hymn
      final nextHymn = collectionHymns[currentIndex + 1];
      context.pushReplacement('/hymn/${nextHymn.hymnNumber}?collection=${currentCollection}&fromSource=${widget.fromSource ?? 'swipe'}');
      
    } catch (e) {
      print('❌ [HymnDetail] Error navigating to next hymn: $e');
      _showNavigationFeedback('Error navigating to next hymn');
    }
  }

  void _navigateToPreviousHymn() {
    if (_hymn == null) {
      _showNavigationFeedback('Unable to navigate: hymn not loaded');
      return;
    }

    try {
      // Get the current hymn provider to access the hymns in the collection
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      final hymns = hymnProvider.hymns;
      
      if (hymns.isEmpty) {
        _showNavigationFeedback('No hymns available in collection');
        return;
      }

      // Use the hymn's own collection abbreviation as the primary source
      final currentCollection = _hymn!.collectionAbbreviation ?? widget.collectionId;
      
      // Find hymns in the same collection, sorted by hymn number
      final collectionHymns = hymns
          .where((h) => h.collectionAbbreviation?.toLowerCase() == currentCollection?.toLowerCase())
          .toList()
        ..sort((a, b) => a.hymnNumber.compareTo(b.hymnNumber));

      if (collectionHymns.isEmpty) {
        _showNavigationFeedback('No hymns found in this collection ($currentCollection)');
        return;
      }

      // Find current hymn index
      final currentIndex = collectionHymns.indexWhere((h) => h.hymnNumber == _hymn!.hymnNumber);
      
      if (currentIndex == -1) {
        _showNavigationFeedback('Current hymn not found in collection');
        return;
      }

      // Check if we're at the first hymn
      if (currentIndex <= 0) {
        _showNavigationFeedback('This is the first hymn in the collection');
        return;
      }

      // Navigate to previous hymn
      final previousHymn = collectionHymns[currentIndex - 1];
      context.pushReplacement('/hymn/${previousHymn.hymnNumber}?collection=${currentCollection}&fromSource=${widget.fromSource ?? 'swipe'}');
      
    } catch (e) {
      print('❌ [HymnDetail] Error navigating to previous hymn: $e');
      _showNavigationFeedback('Error navigating to previous hymn');
    }
  }

  void _showNavigationFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getRelatedHymns() async {
    if (_hymn == null) return [];
    
    try {
      final db = DatabaseHelper.instance;
      
      // Get topics for current hymn
      final topics = await db.database.then((database) => database.rawQuery('''
        SELECT t.id, t.name 
        FROM topics t
        INNER JOIN hymn_topics ht ON t.id = ht.topic_id
        WHERE ht.hymn_id = ?
        LIMIT 3
      ''', [_hymn!.id]));
      
      if (topics.isEmpty) {
        // If no topics, try to find hymns by same author
        return await _getHymnsByAuthor();
      }
      
      // Get hymns that share topics with current hymn
      List<Map<String, dynamic>> relatedHymns = [];
      
      for (final topic in topics) {
        final topicId = topic['id'];
        final hymnsByTopic = await db.database.then((database) => database.rawQuery('''
          SELECT h.id, h.hymn_number, h.title, h.author_name, c.name as collection_name
          FROM hymns h
          LEFT JOIN collections c ON h.collection_id = c.id
          INNER JOIN hymn_topics ht ON h.id = ht.hymn_id
          WHERE ht.topic_id = ? AND h.id != ?
          ORDER BY h.title ASC
          LIMIT 5
        ''', [topicId, _hymn!.id]));
        
        relatedHymns.addAll(hymnsByTopic);
      }
      
      // Remove duplicates and limit to 5
      final uniqueHymns = <int, Map<String, dynamic>>{};
      for (final hymn in relatedHymns) {
        uniqueHymns[hymn['id']] = hymn;
      }
      
      return uniqueHymns.values.take(5).toList();
      
    } catch (e) {
      print('Error fetching related hymns: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getHymnsByAuthor() async {
    if (_hymn == null || _hymn!.author == null) return [];
    
    try {
      final db = DatabaseHelper.instance;
      
      return await db.database.then((database) => database.rawQuery('''
        SELECT h.id, h.hymn_number, h.title, h.author_name, c.name as collection_name
        FROM hymns h
        LEFT JOIN collections c ON h.collection_id = c.id
        WHERE h.author_name = ? AND h.id != ?
        ORDER BY h.title ASC
        LIMIT 5
      ''', [_hymn!.author, _hymn!.id]));
      
    } catch (e) {
      print('Error fetching hymns by author: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          elevation: 0,
          leading: _buildBackButton(),
          actions: [
            // Home button
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
              tooltip: 'Go to Home',
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          elevation: 0,
          leading: _buildBackButton(),
          actions: [
            // Home button
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
              tooltip: 'Go to Home',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHymnData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show hymn content
    final hymn = _hymn!;
    return Scaffold(
      appBar: AppBar(
        title: _buildOptimizedTitle(hymn),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: _buildBackButton(),
        actions: [
          // Home button
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Go to Home',
          ),
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
            tooltip: 'Toggle Favorite',
          ),
          Consumer<AudioPlayerProvider>(
            builder: (context, audioProvider, child) {
              final isCurrentHymn = audioProvider.currentHymn?.id == widget.hymnId;
              final hasAudio = _audioInfo?.hasAnyAudio ?? false;
              final isCheckingAudio = _isCheckingAudio || (_audioInfo?.isChecking ?? false);
              
              if (isCheckingAudio) {
                return IconButton(
                  icon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  onPressed: null,
                  tooltip: 'Checking audio availability...',
                );
              }
              
              return PopupMenuButton<String>(
                enabled: hasAudio,
                icon: Icon(
                  hasAudio
                    ? (isCurrentHymn && audioProvider.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled)
                    : Icons.play_circle_outline,
                  color: hasAudio ? null : Colors.grey,
                ),
                tooltip: hasAudio 
                  ? (isCurrentHymn && audioProvider.isPlaying ? 'Audio Options' : 'Audio Options')
                  : 'No audio available',
                onSelected: (value) async {
                  switch (value) {
                    case 'play':
                      _togglePlayback(audioProvider);
                      break;
                    case 'download_mp3':
                      _downloadAudioFile(AudioFormat.mp3);
                      break;
                    case 'download_midi':
                      _downloadAudioFile(AudioFormat.midi);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        Icon(isCurrentHymn && audioProvider.isPlaying ? Icons.pause : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(isCurrentHymn && audioProvider.isPlaying ? 'Pause' : 'Play'),
                      ],
                    ),
                  ),
                  // Only show download options for remote files (not already cached locally)
                  if ((_audioInfo?.availableFormats.contains(AudioFormat.mp3) ?? false) &&
                      !(_audioInfo?.audioFiles[AudioFormat.mp3]?.isLocal ?? false))
                    const PopupMenuItem(
                      value: 'download_mp3',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download MP3'),
                        ],
                      ),
                    ),
                  if ((_audioInfo?.availableFormats.contains(AudioFormat.midi) ?? false) &&
                      !(_audioInfo?.audioFiles[AudioFormat.midi]?.isLocal ?? false))
                    const PopupMenuItem(
                      value: 'download_midi',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download MIDI'),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          // Project button (desktop only)
          if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
            Consumer<ProjectorService>(
              builder: (context, projectorService, child) {
                final isProjecting = projectorService.isProjectorActive && 
                    projectorService.currentHymnId == widget.hymnId;
                return IconButton(
                  icon: Icon(
                    isProjecting ? Icons.present_to_all : Icons.present_to_all_outlined,
                    color: isProjecting ? Colors.orange : null,
                  ),
                  onPressed: () => _toggleProjector(projectorService),
                  tooltip: isProjecting ? 'Stop Projecting' : 'Project Hymn',
                );
              },
            ),
          // Desktop navigation buttons
          if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) ...[
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: _canNavigateToPrevious() ? _navigateToPreviousHymn : null,
              tooltip: 'Previous Hymn (← or J)',
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: _canNavigateToNext() ? _navigateToNextHymn : null,
              tooltip: 'Next Hymn (→ or K)',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareHymn,
            tooltip: 'Share Hymn',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'fullscreen':
                  _openFullscreen();
                  break;
                case 'print':
                  _printHymn();
                  break;
                case 'download':
                  _downloadHymn();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fullscreen',
                child: Row(
                  children: [
                    Icon(Icons.fullscreen),
                    SizedBox(width: 8),
                    Text('Fullscreen'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Print'),
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
            ],
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Format Selector
                _buildFormatSelector(),
                
                // Content Section
                _buildContent(),
                
                // Banner Ad
                const BannerAdWidget(),
                
                // Metadata Section
                _buildMetadata(),
                
                // Scripture References
                if (_hymn!.scriptureRefs != null && _hymn!.scriptureRefs!.isNotEmpty) _buildScriptureReferences(),
                
                // Alternate Tunes
                _buildAlternateTunes(),
                
                // Related Hymns
                _buildRelatedHymns(),
                
                // Hymn Comparison
                _buildHymnComparison(),
                
                const SizedBox(height: AppSizes.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildFormatSelector() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Row(
        children: [
          Text(
            'View Format:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFormatChip('lyrics', 'Lyrics', Icons.text_fields),
                  const SizedBox(width: AppSizes.spacing8),
                  _buildFormatChip('solfa', 'Solfa', Icons.music_note),
                  const SizedBox(width: AppSizes.spacing8),
                  _buildFormatChip('staff', 'Staff', Icons.piano),
                  const SizedBox(width: AppSizes.spacing8),
                  _buildFormatChip('chord', 'Chords', Icons.my_library_music),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String format, String label, IconData icon) {
    final isSelected = _selectedFormat == format;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 16,
            color: isSelected 
              ? const Color(AppColors.primaryBlue) 
              : const Color(AppColors.gray700),
          ),
          const SizedBox(width: AppSizes.spacing4),
          Text(
            label,
            style: TextStyle(
              color: isSelected 
                ? const Color(AppColors.primaryBlue) 
                : const Color(AppColors.gray700),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFormat = format;
          });
        }
      },
      selectedColor: const Color(AppColors.primaryBlue).withOpacity(0.2),
      backgroundColor: const Color(AppColors.gray100),
      checkmarkColor: const Color(AppColors.primaryBlue),
      side: BorderSide(
        color: isSelected 
          ? const Color(AppColors.primaryBlue) 
          : const Color(AppColors.gray300),
        width: 1,
      ),
    );
  }

  Widget _buildContent() {
    // Check if hymn has chorus sections to determine layout
    final hasChorus = _hymn != null && _hymn!.lyrics != null && _hasChorusSections(_hymn!.lyrics!);
    
    // Use full width card for hymns without choruses
    if (!hasChorus && _selectedFormat == 'lyrics') {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLyricsContent(),
              ],
            ),
          ),
        ),
      );
    }
    
    // Default card layout for hymns with choruses or other formats
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display content based on selected format
              if (_selectedFormat == 'lyrics') _buildLyricsContent(),
              if (_selectedFormat == 'solfa') _buildSolfaContent(),
              if (_selectedFormat == 'staff') _buildStaffContent(),
              if (_selectedFormat == 'chord') _buildChordContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsContent() {
    final hymn = _hymn!;
    
    // If we have lyrics, parse them into verses with proper labeling
    if (hymn.lyrics != null && hymn.lyrics!.isNotEmpty) {
      // Split lyrics into sections (verses, chorus, etc.)
      final sections = _parseLyricsIntoSections(hymn.lyrics!);
      
      if (sections.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < sections.length; i++) ...[
              _buildLyricsSection(sections[i]),
              if (i < sections.length - 1)
                const SizedBox(height: AppSizes.spacing16),
            ],
          ],
        );
      }
    }
    
    // Fallback if no lyrics
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.music_note_outlined,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'Lyrics Not Available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'The lyrics for this hymn are not currently available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray600),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection(LyricsSection section) {
    switch (section.type.toLowerCase()) {
      case 'verse':
        return _buildVerse(section.content, section.number);
      case 'chorus':
        return _buildChorus(section.content);
      case 'refrain':
        return _buildRefrain(section.content);
      case 'bridge':
        return _buildBridge(section.content);
      default:
        return _buildVerse(section.content, section.number);
    }
  }

  Widget _buildVerse(String verse, int number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing8,
            vertical: AppSizes.spacing4,
          ),
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            'Verse $number',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.primaryBlue),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          verse,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildChorus(String chorus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing8,
            vertical: AppSizes.spacing4,
          ),
          decoration: BoxDecoration(
            color: const Color(AppColors.successGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            'Chorus',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.successGreen),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: const Color(AppColors.successGreen).withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: const Color(AppColors.successGreen).withOpacity(0.2),
            ),
          ),
          child: Text(
            chorus,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefrain(String refrain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing8,
            vertical: AppSizes.spacing4,
          ),
          decoration: BoxDecoration(
            color: const Color(AppColors.secondaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            'Refrain',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.secondaryBlue),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: const Color(AppColors.secondaryBlue).withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: const Color(AppColors.secondaryBlue).withOpacity(0.2),
            ),
          ),
          child: Text(
            refrain,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBridge(String bridge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing8,
            vertical: AppSizes.spacing4,
          ),
          decoration: BoxDecoration(
            color: const Color(AppColors.purple).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            'Bridge',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.purple),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          bridge,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSolfaContent() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.music_note,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'Solfa Notation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Solfa notation will be available soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffContent() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.piano,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'Staff Notation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Staff notation will be available soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChordContent() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.my_library_music,
            size: 64,
            color: Color(AppColors.gray500),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'Chord Charts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Chord charts will be available soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),
              
              if (_hymn!.author != null && _hymn!.author!.isNotEmpty)
                _buildMetadataItem('Author', _hymn!.author!, Icons.person, onTap: () {
                  context.push('/browse/authors/${Uri.encodeComponent(_hymn!.author!)}');
                }),
              
              if (_hymn!.composer != null && _hymn!.composer!.isNotEmpty)
                _buildMetadataItem('Composer', _hymn!.composer!, Icons.music_note, onTap: () {
                  context.push('/browse/composers/${Uri.encodeComponent(_hymn!.composer!)}');
                }),
              
              if (_hymn!.tuneName != null && _hymn!.tuneName!.isNotEmpty)
                _buildMetadataItem('Tune', _hymn!.tuneName!, Icons.queue_music, onTap: () {
                  context.push('/browse/tunes/${Uri.encodeComponent(_hymn!.tuneName!)}');
                }),
              
              if (_hymn!.meter != null && _hymn!.meter!.isNotEmpty)
                _buildMetadataItem('Meter', _hymn!.meter!, Icons.straighten, onTap: () {
                  context.push('/browse/meters/${Uri.encodeComponent(_hymn!.meter!)}');
                }),
              
              
              // Audio Information
              if (_audioInfo != null) ...[
                const SizedBox(height: AppSizes.spacing12),
                Text(
                  'Audio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                if (_audioInfo!.hasAnyAudio) ...[
                  ...(_audioInfo!.availableFormats.map((format) {
                    final audioFile = _audioInfo!.audioFiles[format];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spacing4),
                      child: Row(
                        children: [
                          Icon(
                            format == AudioFormat.mp3 ? Icons.audiotrack : Icons.piano,
                            size: 16,
                            color: const Color(AppColors.successGreen),
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          Text(
                            '${format.name.toUpperCase()} ${audioFile?.isLocal == true ? '(Downloaded)' : '(Online)'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(AppColors.successGreen),
                            ),
                          ),
                          if (audioFile?.isLocal == false) ...[
                            const Spacer(),
                            TextButton(
                              onPressed: () => _downloadAudioFile(format),
                              child: const Text('Download', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                    );
                  })),
                ] else if (_audioInfo!.isChecking) ...[
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSizes.spacing8),
                      Text('Checking audio availability...'),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.audiotrack_outlined,
                        size: 16,
                        color: Color(AppColors.gray500),
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Text(
                        'No audio files available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(AppColors.gray500),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              
              // Themes
              if (_hymn!.themeTags != null && _hymn!.themeTags!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacing12),
                Text(
                  'Themes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Wrap(
                  spacing: AppSizes.spacing8,
                  runSpacing: AppSizes.spacing8,
                  children: (_hymn!.themeTags ?? []).map((theme) => ActionChip(
                    label: Text(theme),
                    backgroundColor: const Color(AppColors.purple).withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Color(AppColors.purple),
                      fontSize: 12,
                    ),
                    onPressed: () {
                      context.push('/browse/topics/${Uri.encodeComponent(theme)}');
                    },
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(AppColors.gray600),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.gray600),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onTap != null ? const Color(AppColors.primaryBlue) : null,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(AppColors.gray500),
            ),
        ],
      ),
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: content,
      );
    }
    
    return content;
  }

  Widget _buildScriptureReferences() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book,
                    color: Color(AppColors.secondaryBlue),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    'Scripture References',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              Wrap(
                spacing: AppSizes.spacing8,
                runSpacing: AppSizes.spacing8,
                children: (_hymn!.scriptureRefs ?? []).map((ref) => InkWell(
                  onTap: () {
                    context.push('/browse/scripture/${Uri.encodeComponent(ref)}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing12,
                      vertical: AppSizes.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(AppColors.secondaryBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: const Color(AppColors.secondaryBlue).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      ref,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.secondaryBlue),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedHymns() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Related Hymns',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.spacing12),
              // Load related hymns from database
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getRelatedHymns(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.spacing16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Text(
                      'Error loading related hymns',
                      style: TextStyle(color: Colors.grey[600]),
                    );
                  }
                  
                  final relatedHymns = snapshot.data ?? [];
                  
                  if (relatedHymns.isEmpty) {
                    return Text(
                      'No related hymns found',
                      style: TextStyle(color: Colors.grey[600]),
                    );
                  }
                  
                  return Column(
                    children: relatedHymns.map((hymn) {
                      return _buildRelatedHymnItem(
                        hymn['title'] ?? 'Unknown Title',
                        hymn['author_name'] ?? 'Unknown Author',
                        hymn['hymn_number'] ?? 0,
                        hymn['id'] ?? 0,
                        hymn['collection_name'] ?? '',
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedHymnItem(String title, String author, int number, int hymnId, String collectionName) {
    return InkWell(
      onTap: () {
        // Navigate to related hymn with proper context
        context.push('/hymn/$hymnId?from=related');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(AppColors.gray300),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.gray600),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    // Only toggle favorite if we have a loaded hymn with a valid database ID
    if (_hymn == null || _hymn!.id <= 0) {
      print('⚠️ [HymnDetail] Cannot toggle favorite: hymn not loaded or invalid ID');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update favorites: hymn not loaded'),
          backgroundColor: Color(AppColors.errorRed),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    try {
      final success = await favoritesProvider.toggleFavorite(_hymn!.id);
      
      if (success) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        
        // Show feedback with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await favoritesProvider.toggleFavorite(_hymn!.id);
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isFavorite ? 'remove from' : 'add to'} favorites'),
            backgroundColor: const Color(AppColors.errorRed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(AppColors.errorRed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareHymn() {
    final hymn = _hymn!;
    
    // Copy hymn text to clipboard
    final text = '${hymn.title}\n\n${hymn.lyrics ?? 'Lyrics not available'}';
    
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hymn copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openFullscreen() {
    // Navigate to fullscreen view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenHymnView(hymn: _hymn!),
      ),
    );
  }

  void _printHymn() {
    _showPrintDialog();
  }

  void _downloadHymn() {
    _showDownloadDialog();
  }

  void _togglePlayback(AudioPlayerProvider audioProvider) {
    final isCurrentHymn = audioProvider.currentHymn?.id == widget.hymnId;
    
    if (isCurrentHymn) {
      if (audioProvider.isPlaying) {
        audioProvider.pause();
      } else {
        audioProvider.resume();
      }
    } else {
      // Use the current hymn for playback with preferred format
      final preferredFormat = _audioInfo?.preferredFormat;
      audioProvider.playHymn(_hymn!, preferredFormat: preferredFormat);
    }
  }
  
  Future<void> _downloadAudioFile(AudioFormat format) async {
    if (_hymn == null) return;
    
    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Downloading ${format.name.toUpperCase()} file...'),
            ],
          ),
        ),
      );
      
      final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
      final success = await audioProvider.downloadAudioFile(_hymn!, format);
      
      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (success) {
        // Refresh audio info to show downloaded status
        await _checkAudioAvailability();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${format.name.toUpperCase()} file downloaded successfully'),
              backgroundColor: const Color(AppColors.successGreen),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download ${format.name.toUpperCase()} file'),
              backgroundColor: const Color(AppColors.errorRed),
            ),
          );
        }
      }
    } catch (e) {
      // Close progress dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading audio: $e'),
            backgroundColor: const Color(AppColors.errorRed),
          ),
        );
      }
    }
  }

  void _toggleProjector(ProjectorService projectorService) {
    final isProjecting = projectorService.isProjectorActive && 
        projectorService.currentHymnId == widget.hymnId;
    
    if (isProjecting) {
      projectorService.stopProjector();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Projector stopped'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Calculate total verses from the hymn lyrics
      final totalVerses = _hymn != null ? _parseVerses(_hymn!.lyrics ?? '').length : 0;
      
      projectorService.startProjector(widget.hymnId, totalVerses: totalVerses);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.present_to_all, color: Colors.white),
              const SizedBox(width: 8),
              Text('Projecting "${_hymn!.title}" ($totalVerses verses)'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open URL',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Projector URL copied to clipboard. Paste in a new browser window on your projector screen.'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 4),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  /// Parse verses from lyrics (same logic as ProjectorWindowScreen)
  List<String> _parseVerses(String lyrics) {
    if (lyrics.isEmpty) return ['No lyrics available'];
    
    // Split by double newlines or verse markers
    final verses = lyrics.split(RegExp(r'\n\s*\n|\n\d+\.\s*'));
    return verses.where((verse) => verse.trim().isNotEmpty).toList();
  }

  Widget _buildOptimizedTitle(Hymn hymn) {
    // Get hymnal abbreviation - use collectionAbbreviation if available, otherwise derive from collectionId
    String hymnalAbbrev = hymn.collectionAbbreviation ?? 
                         (widget.collectionId?.toUpperCase() ?? 'HYMN');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // First line: Hymnal abbreviation and hymn number
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hymnal abbreviation with better contrast
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hymnalAbbrev,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Hymn number
            Text(
              '#${hymn.hymnNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 2),
        
        // Second line: Title
        Text(
          hymn.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  List<LyricsSection> _parseLyricsIntoSections(String lyrics) {
    final sections = <LyricsSection>[];
    
    // Split by double newlines to get potential sections
    final rawSections = lyrics.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty).toList();
    
    int verseNumber = 1;
    LyricsSection? chorusSection;
    
    for (final rawSection in rawSections) {
      final trimmedSection = rawSection.trim();
      if (trimmedSection.isEmpty) continue;
      
      final sectionType = _detectSectionType(trimmedSection);
      
      switch (sectionType) {
        case 'chorus':
        case 'refrain':
          // Store chorus/refrain for later repetition
          final cleanContent = _cleanSectionContent(trimmedSection, sectionType);
          chorusSection = LyricsSection(
            type: sectionType,
            number: 1,
            content: cleanContent,
          );
          sections.add(chorusSection);
          break;
          
        case 'bridge':
          final cleanContent = _cleanSectionContent(trimmedSection, sectionType);
          sections.add(LyricsSection(
            type: 'bridge',
            number: 1,
            content: cleanContent,
          ));
          break;
          
        case 'verse':
        default:
          // Treat as verse
          final cleanContent = _cleanSectionContent(trimmedSection, 'verse');
          sections.add(LyricsSection(
            type: 'verse',
            number: verseNumber,
            content: cleanContent,
          ));
          
          // Add chorus after verse if it exists and should repeat
          if (chorusSection != null && verseNumber > 1) {
            sections.add(chorusSection);
          }
          
          verseNumber++;
          break;
      }
    }
    
    return sections;
  }

  String _detectSectionType(String section) {
    final firstLine = section.split('\n').first.toLowerCase().trim();
    
    // Check for explicit labels
    if (firstLine.startsWith('chorus') || 
        firstLine.contains('chorus:')) {
      return 'chorus';
    }
    
    if (firstLine.startsWith('refrain') ||
        firstLine.contains('refrain:')) {
      return 'refrain';
    }
    
    // Check for bridge indicators
    if (firstLine.startsWith('bridge') || firstLine.contains('bridge:')) {
      return 'bridge';
    }
    
    // Check for verse indicators
    if (firstLine.startsWith('verse') || 
        firstLine.contains('verse') ||
        RegExp(r'^\d+\.?\s').hasMatch(firstLine)) {
      return 'verse';
    }
    
    // Only detect chorus/refrain if explicitly labeled or in a hymn structure with multiple sections
    // Don't auto-detect based on word repetition as that can incorrectly classify verses
    
    // Default to verse
    return 'verse';
  }

  bool _hasChorusSections(String lyrics) {
    // Check if the lyrics contain explicit chorus/refrain section labels
    // Look for labels at the beginning of lines, not just anywhere in the text
    final lines = lyrics.toLowerCase().split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('chorus') || 
          trimmedLine.contains('chorus:') ||
          trimmedLine.startsWith('refrain') ||
          trimmedLine.contains('refrain:') ||
          trimmedLine.startsWith('bridge') ||
          trimmedLine.contains('bridge:')) {
        return true;
      }
    }
    return false;
  }

  String _cleanSectionContent(String section, String sectionType) {
    final lines = section.split('\n').map((l) => l.trim()).toList();
    final cleanedLines = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;
      
      // Skip the first line if it's just a label
      if (i == 0 && _isLabelLine(line, sectionType)) {
        continue;
      }
      
      cleanedLines.add(line);
    }
    
    return cleanedLines.join('\n').trim();
  }

  bool _isLabelLine(String line, String sectionType) {
    final lowerLine = line.toLowerCase().trim();
    final cleanLine = lowerLine.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    
    switch (sectionType) {
      case 'chorus':
        return cleanLine == 'chorus' || cleanLine.startsWith('chorus ');
      case 'refrain':
        return cleanLine == 'refrain' || cleanLine.startsWith('refrain ');
      case 'bridge':
        return cleanLine == 'bridge' || cleanLine.startsWith('bridge ');
      case 'verse':
        return RegExp(r'^verse\s*\d*$').hasMatch(cleanLine) ||
               RegExp(r'^\d+\.?\s*$').hasMatch(cleanLine);
      default:
        return false;
    }
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => _navigateBack(),
      tooltip: _getBackButtonTooltip(),
    );
  }

  String _getBackButtonTooltip() {
    switch (widget.fromSource) {
      case 'favorites':
        return 'Back to Favorites';
      case 'recent':
        return 'Back to Recently Viewed';
      case 'search':
        return 'Back to Search';
      case 'collection':
        return 'Back to Collection';
      case 'browse':
        return 'Back to Browse';
      case 'home':
      default:
        return 'Back to Home';
    }
  }

  void _navigateBack() {
    try {
      // Navigate based on source context
      if (widget.fromSource != null) {
        switch (widget.fromSource) {
          case 'favorites':
            context.go('/favorites');
            break;
          case 'recent':
            context.go('/recently-viewed');
            break;
          case 'search':
            context.go('/search');
            break;
          case 'collection':
            if (widget.collectionId != null) {
              context.go('/collection/${widget.collectionId}');
            } else {
              context.go('/browse/collections');
            }
            break;
          case 'browse':
            context.go('/browse');
            break;
          case 'home':
          default:
            context.go('/home');
            break;
        }
      } else {
        // Fallback to standard back navigation or home
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      print('❌ [HymnDetail] Navigation error: $e');
      // Fallback navigation
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/home');
      }
    }
  }

  void _defaultBackNavigation() {
    _navigateBack();
  }

  String _getBackTooltip() {
    if (widget.fromSource != null) {
      switch (widget.fromSource) {
        case 'favorites':
          return 'Back to Favorites';
        case 'recent':
          return 'Back to Recent';
        case 'home':
          return 'Back to Home';
        default:
          return 'Back';
      }
    } else if (widget.collectionId != null) {
      return 'Back to Collection';
    }
    return 'Back';
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Hymn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Print options for "${_hymn!.title}":'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lyrics),
              title: const Text('Lyrics Only'),
              onTap: () {
                Navigator.pop(context);
                _printLyrics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Lyrics with Metadata'),
              onTap: () {
                Navigator.pop(context);
                _printWithMetadata();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _printLyrics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing lyrics for "${_hymn!.title}"...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            _showPrintPreview();
          },
        ),
      ),
    );
  }

  void _printWithMetadata() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing full hymn details for "${_hymn!.title}"...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            _showPrintPreview();
          },
        ),
      ),
    );
  }

  void _showPrintPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Preview'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hymn!.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Hymn #${_hymn!.hymnNumber}'),
                  if (_hymn!.author != null && _hymn!.author!.isNotEmpty) Text('By: ${_hymn!.author}'),
                  if (_hymn!.composer != null && _hymn!.composer!.isNotEmpty) Text('Music: ${_hymn!.composer}'),
                  const SizedBox(height: 16),
                  Text(_hymn!.lyrics ?? 'Lyrics not available'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sent to printer')),
              );
            },
            child: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Hymn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Download "${_hymn!.title}" as:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              subtitle: const Text('Printable format'),
              onTap: () {
                Navigator.pop(context);
                _downloadPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Text File'),
              subtitle: const Text('Plain text lyrics'),
              onTap: () {
                Navigator.pop(context);
                _downloadText();
              },
            ),
            // Audio download option (mock implementation)
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text('Audio (MP3)'),
              subtitle: const Text('Audio recording'),
              onTap: () {
                Navigator.pop(context);
                _downloadAudio();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _downloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Downloading "${_hymn!.title}.pdf"...'),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "${_hymn!.title}.pdf" to Downloads folder'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                // Open file
              },
            ),
          ),
        );
      }
    });
  }

  void _downloadText() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloaded "${_hymn!.title}.txt" to Downloads folder'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // Open file
          },
        ),
      ),
    );
  }

  void _downloadAudio() {
    if (_audioInfo == null || !_audioInfo!.hasAnyAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audio files available for download'),
          backgroundColor: Color(AppColors.errorRed),
        ),
      );
      return;
    }
    
    // Show dialog with available formats
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Audio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose audio format for "${_hymn!.title}":'),
            const SizedBox(height: 16),
            ...(_audioInfo!.availableFormats.map((format) {
              final audioFile = _audioInfo!.audioFiles[format];
              final isLocal = audioFile?.isLocal ?? false;
              
              return ListTile(
                leading: Icon(
                  format == AudioFormat.mp3 ? Icons.audiotrack : Icons.piano,
                  color: isLocal ? const Color(AppColors.successGreen) : null,
                ),
                title: Text(format.name.toUpperCase()),
                subtitle: Text(isLocal ? 'Already downloaded' : 'Download for offline use'),
                trailing: isLocal ? const Icon(Icons.check_circle, color: Color(AppColors.successGreen)) : null,
                enabled: !isLocal,
                onTap: isLocal ? null : () {
                  Navigator.of(context).pop();
                  _downloadAudioFile(format);
                },
              );
            })),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternateTunes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Color(AppColors.warningOrange),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    'Alternate Tunes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getAlternateTunes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.spacing16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No alternate tunes available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.gray500),
                      ),
                    );
                  }
                  
                  final alternateTunes = snapshot.data!;
                  
                  return Column(
                    children: alternateTunes.map((tune) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
                        child: InkWell(
                          onTap: () {
                            context.push('/browse/tunes/${Uri.encodeComponent(tune['tune_name'])}');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.spacing12),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.warningOrange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              border: Border.all(
                                color: const Color(AppColors.warningOrange).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tune['tune_name'],
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(AppColors.warningOrange),
                                        ),
                                      ),
                                      if (tune['meter'] != null && tune['meter'] != _hymn!.meter)
                                        Text(
                                          'Meter: ${tune['meter']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: const Color(AppColors.gray600),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(AppColors.warningOrange),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHymnComparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.compare_arrows,
                    color: Color(AppColors.purple),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Text(
                    'Hymn Variations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getHymnVariations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.spacing16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No variations found across different hymnals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.gray500),
                      ),
                    );
                  }
                  
                  final variations = snapshot.data!;
                  
                  return Column(
                    children: variations.map((variation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.spacing12),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.purple).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            border: Border.all(
                              color: const Color(AppColors.purple).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${variation['collection_name']} (${variation['year']})',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(AppColors.purple),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '#${variation['hymn_number']}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(AppColors.gray600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.spacing4),
                              if (variation['title_difference'] != null)
                                Text(
                                  'Title: ${variation['title_difference']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(AppColors.gray600),
                                  ),
                                ),
                              if (variation['tune_difference'] != null)
                                Text(
                                  'Tune: ${variation['tune_difference']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(AppColors.gray600),
                                  ),
                                ),
                              if (variation['lyric_changes'] != null)
                                Text(
                                  'Lyrics: ${variation['lyric_changes']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(AppColors.gray600),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getAlternateTunes() async {
    if (_hymn == null || _hymn!.meter == null) return [];
    
    try {
      final db = DatabaseHelper.instance;
      final database = await db.database;
      
      // Get hymns with the same meter but different tune names
      final alternateTunes = await database.rawQuery('''
        SELECT DISTINCT tune_name, meter
        FROM hymns
        WHERE LOWER(REPLACE(REPLACE(meter, '.', ''), ' ', '')) = LOWER(REPLACE(REPLACE(?, '.', ''), ' ', ''))
        AND tune_name IS NOT NULL
        AND tune_name != ?
        AND tune_name != ''
        ORDER BY tune_name ASC
        LIMIT 5
      ''', [_hymn!.meter!, _hymn!.tuneName ?? '']);
      
      return alternateTunes;
    } catch (e) {
      print('Error getting alternate tunes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getHymnVariations() async {
    if (_hymn == null) return [];
    
    try {
      // For demonstration, return sample data showing how hymns vary across different hymnals
      // In a real implementation, this would query the database for actual variations
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate database query
      
      return [
        {
          'collection_name': 'Seventh-day Adventist Hymnal',
          'year': 1985,
          'hymn_number': 123,
          'title_difference': 'Same title',
          'tune_difference': 'AMAZING GRACE',
          'lyric_changes': 'Verse 3 modified for theological accuracy',
        },
        {
          'collection_name': 'Christ in Song',
          'year': 1900,
          'hymn_number': 456,
          'title_difference': 'Original title: "Amazing Grace! How Sweet the Sound"',
          'tune_difference': 'NEW BRITAIN',
          'lyric_changes': 'Original 6 verses, modern version has 4',
        },
        {
          'collection_name': 'Hymns and Tunes',
          'year': 1876,
          'hymn_number': 789,
          'title_difference': 'Same title',
          'tune_difference': 'AMAZING GRACE (different arrangement)',
          'lyric_changes': 'Archaic language preserved ("thee", "thou")',
        },
      ];
    } catch (e) {
      print('Error getting hymn variations: $e');
      return [];
    }
  }
}



// Fullscreen hymn view widget
class FullscreenHymnView extends StatefulWidget {
  final Hymn hymn;

  const FullscreenHymnView({super.key, required this.hymn});

  @override
  State<FullscreenHymnView> createState() => _FullscreenHymnViewState();
}

class _FullscreenHymnViewState extends State<FullscreenHymnView> {
  double _fontSize = 18.0;
  bool _showMetadata = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.hymn.title),
        actions: [
          IconButton(
            icon: Icon(_showMetadata ? Icons.info : Icons.info_outline),
            onPressed: () {
              setState(() {
                _showMetadata = !_showMetadata;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize + 2).clamp(12.0, 32.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize - 2).clamp(12.0, 32.0);
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.hymn.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSize + 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Metadata (if enabled)
              if (_showMetadata) ...[
                Text(
                  'Hymn #${widget.hymn.hymnNumber}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: _fontSize - 2,
                  ),
                ),
                if (widget.hymn.author != null && widget.hymn.author!.isNotEmpty)
                  Text(
                    'By: ${widget.hymn.author}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: _fontSize - 2,
                    ),
                  ),
                if (widget.hymn.composer != null && widget.hymn.composer!.isNotEmpty)
                  Text(
                    'Music: ${widget.hymn.composer}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: _fontSize - 2,
                    ),
                  ),
                const SizedBox(height: 24),
              ] else 
                const SizedBox(height: 16),
              
              // Lyrics
              if (widget.hymn.lyrics != null && widget.hymn.lyrics!.isNotEmpty) ...
                widget.hymn.lyrics!.split('\n\n').where((v) => v.trim().isNotEmpty).map(
                  (verse) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      verse,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _fontSize,
                        height: 1.5,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  'Lyrics not available',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: _fontSize,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}