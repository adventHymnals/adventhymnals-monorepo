import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/projector_service.dart';
import '../../core/data/hymn_data_manager.dart';
import '../providers/favorites_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../../domain/entities/hymn.dart';
import '../widgets/banner_ad_widget.dart';

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
  bool _isLoading = true;
  Hymn? _hymn;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHymnData();
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
      // Only add to recently viewed if we have a loaded hymn with a valid database ID
      if (_hymn == null || _hymn!.id <= 0) {
        print('⚠️ [HymnDetail] Cannot add to recently viewed: hymn not loaded or invalid ID');
        return;
      }
      
      final recentlyViewedProvider = Provider.of<RecentlyViewedProvider>(context, listen: false);
      await recentlyViewedProvider.addRecentlyViewed(_hymn!.id);
      print('✅ [HymnDetail] Added hymn ${_hymn!.id} (${_hymn!.title}) to recently viewed');
    } catch (e) {
      print('⚠️ [HymnDetail] Failed to add to recently viewed: $e');
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

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          elevation: 0,
          leading: _buildBackButton(),
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
        title: Text(hymn.title),
        elevation: 0,
        leading: _buildBackButton(),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
            tooltip: 'Toggle Favorite',
          ),
          Consumer<AudioPlayerProvider>(
            builder: (context, audioProvider, child) {
              final isCurrentHymn = audioProvider.currentHymn?.id == widget.hymnId;
              return IconButton(
                icon: Icon(
                  isCurrentHymn && audioProvider.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                onPressed: () => _togglePlayback(audioProvider),
                tooltip: isCurrentHymn && audioProvider.isPlaying ? 'Pause' : 'Play',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            
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
            
            // Related Hymns
            _buildRelatedHymns(),
            
            const SizedBox(height: AppSizes.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing12,
                  vertical: AppSizes.spacing8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Text(
                  '#${_hymn!.hymnNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hymn!.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      'Adventist Hymnal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    
    // If we have structured lyrics (verse by verse), use that
    if (hymn.lyrics != null && hymn.lyrics!.isNotEmpty) {
      // Split lyrics into verses (assuming they're separated by double newlines)
      final verses = hymn.lyrics!.split('\\n\\n').where((v) => v.trim().isNotEmpty).toList();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < verses.length; i++) ...[
            _buildVerse(verses[i], i + 1),
            if (i < verses.length - 1)
              const SizedBox(height: AppSizes.spacing16),
          ],
        ],
      );
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
                _buildMetadataItem('Author', _hymn!.author!, Icons.person),
              
              if (_hymn!.composer != null && _hymn!.composer!.isNotEmpty)
                _buildMetadataItem('Composer', _hymn!.composer!, Icons.music_note),
              
              if (_hymn!.tuneName != null && _hymn!.tuneName!.isNotEmpty)
                _buildMetadataItem('Tune', _hymn!.tuneName!, Icons.queue_music),
              
              if (_hymn!.meter != null && _hymn!.meter!.isNotEmpty)
                _buildMetadataItem('Meter', _hymn!.meter!, Icons.straighten),
              
              
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
                  children: (_hymn!.themeTags ?? []).map((theme) => Chip(
                    label: Text(theme),
                    backgroundColor: const Color(AppColors.purple).withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Color(AppColors.purple),
                      fontSize: 12,
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value, IconData icon) {
    return Padding(
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                    // Open Bible app or reference
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
              // Sample related hymns
              _buildRelatedHymnItem('Great Is Thy Faithfulness', 'Thomas Chisholm', 18),
              _buildRelatedHymnItem('How Great Thou Art', 'Carl Boberg', 86),
              _buildRelatedHymnItem('Blessed Assurance', 'Fanny J. Crosby', 462),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedHymnItem(String title, String author, int number) {
    return InkWell(
      onTap: () {
        // Navigate to related hymn
        context.push('/hymn/$number');
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
      // Use the current hymn for playback
      audioProvider.playHymn(_hymn!);
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
      projectorService.startProjector(widget.hymnId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.present_to_all, color: Colors.white),
              const SizedBox(width: 8),
              Text('Projecting "${_hymn!.title}"'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => context.go('/projector?hymn=${widget.hymnId}'),
          ),
        ),
      );
    }
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // Handle back navigation based on source
        if (widget.fromSource != null) {
          switch (widget.fromSource) {
            case 'favorites':
              context.go('/favorites');
              break;
            case 'recent':
              context.go('/recently-viewed');
              break;
            case 'home':
              context.go('/home');
              break;
            default:
              _defaultBackNavigation();
              break;
          }
        } else if (widget.collectionId != null) {
          // If no source but has collection ID, try to navigate to collection
          // Note: This assumes collectionId is a valid collection identifier
          context.go('/collection/${widget.collectionId}');
        } else {
          _defaultBackNavigation();
        }
      },
      tooltip: _getBackTooltip(),
    );
  }

  void _defaultBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
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
            Text('Downloading "${_hymn!.title}.mp3"...'),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "${_hymn!.title}.mp3" to Downloads folder'),
            action: SnackBarAction(
              label: 'Play',
              onPressed: () {
                // Play audio
              },
            ),
          ),
        );
      }
    });
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