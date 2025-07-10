import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/projector_service.dart';
import '../providers/favorites_provider.dart';
import '../providers/audio_player_provider.dart';
import '../../domain/entities/hymn.dart';

class HymnDetailScreen extends StatefulWidget {
  final int hymnId;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  String _selectedFormat = 'lyrics';
  bool _isFavorite = false;

  // Sample hymn data - in real app this would come from database/provider
  late final HymnData _hymn;

  @override
  void initState() {
    super.initState();
    _hymn = _getSampleHymnData(widget.hymnId);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFav = await favoritesProvider.isFavorite(widget.hymnId);
    setState(() {
      _isFavorite = isFav;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hymn.title),
        elevation: 0,
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
            
            // Metadata Section
            _buildMetadata(),
            
            // Scripture References
            if (_hymn.scriptureReferences.isNotEmpty) _buildScriptureReferences(),
            
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
                  '#${_hymn.number}',
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
                      _hymn.title,
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
          Icon(icon, size: 16),
          const SizedBox(width: AppSizes.spacing4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFormat = format;
          });
        }
      },
      selectedColor: Color(AppColors.primaryBlue).withOpacity(0.2),
      checkmarkColor: Color(AppColors.primaryBlue),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verses
        for (int i = 0; i < _hymn.verses.length; i++) ...[
          _buildVerse(_hymn.verses[i], i + 1),
          if (i < _hymn.verses.length - 1 || _hymn.chorus != null)
            const SizedBox(height: AppSizes.spacing16),
        ],
        
        // Chorus
        if (_hymn.chorus != null) _buildChorus(_hymn.chorus!),
      ],
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
            color: Color(AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            'Verse $number',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Color(AppColors.primaryBlue),
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
            color: Color(AppColors.successGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            'Chorus',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Color(AppColors.successGreen),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            color: Color(AppColors.successGreen).withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: Color(AppColors.successGreen).withOpacity(0.2),
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
          Icon(
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
              color: Color(AppColors.gray600),
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
          Icon(
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
              color: Color(AppColors.gray600),
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
          Icon(
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
              color: Color(AppColors.gray600),
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
              
              if (_hymn.author.isNotEmpty)
                _buildMetadataItem('Author', _hymn.author, Icons.person),
              
              if (_hymn.composer.isNotEmpty)
                _buildMetadataItem('Composer', _hymn.composer, Icons.music_note),
              
              if (_hymn.tune.isNotEmpty)
                _buildMetadataItem('Tune', _hymn.tune, Icons.queue_music),
              
              if (_hymn.meter.isNotEmpty)
                _buildMetadataItem('Meter', _hymn.meter, Icons.straighten),
              
              if (_hymn.year > 0)
                _buildMetadataItem('Year', _hymn.year.toString(), Icons.calendar_today),
              
              if (_hymn.copyright.isNotEmpty)
                _buildMetadataItem('Copyright', _hymn.copyright, Icons.copyright),
              
              // Themes
              if (_hymn.themes.isNotEmpty) ...[
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
                  children: _hymn.themes.map((theme) => Chip(
                    label: Text(theme),
                    backgroundColor: Color(AppColors.purple).withOpacity(0.1),
                    labelStyle: TextStyle(
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
            color: Color(AppColors.gray600),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Color(AppColors.gray600),
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
                  Icon(
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
                children: _hymn.scriptureReferences.map((ref) => InkWell(
                  onTap: () {
                    // Open Bible app or reference
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing12,
                      vertical: AppSizes.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: Color(AppColors.secondaryBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: Color(AppColors.secondaryBlue).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      ref,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Color(AppColors.secondaryBlue),
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
                color: Color(AppColors.gray300),
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
                      color: Color(AppColors.gray600),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
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
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    try {
      final success = await favoritesProvider.toggleFavorite(widget.hymnId);
      
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
                await favoritesProvider.toggleFavorite(widget.hymnId);
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
            backgroundColor: Color(AppColors.errorRed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Color(AppColors.errorRed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareHymn() {
    // Copy hymn text to clipboard
    final text = '${_hymn.title}\n\n${_hymn.verses.asMap().entries.map((entry) => 
      'Verse ${entry.key + 1}:\n${entry.value}'
    ).join('\n\n')}${_hymn.chorus != null ? '\n\nChorus:\n${_hymn.chorus}' : ''}';
    
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
        builder: (context) => FullscreenHymnView(hymn: _hymn),
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
      // Create hymn object for playback
      final hymnForPlayback = Hymn(
        id: widget.hymnId,
        hymnNumber: _hymn.number,
        title: _hymn.title,
        author: _hymn.author,
        composer: _hymn.composer,
        tuneName: _hymn.tune,
        meter: _hymn.meter,
        lyrics: _hymn.verses.join('\n\n'),
        firstLine: _hymn.verses.isNotEmpty ? _hymn.verses.first.split('\n').first : null,
        themeTags: _hymn.themes,
        scriptureRefs: _hymn.scriptureReferences,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: _isFavorite,
      );
      
      audioProvider.playHymn(hymnForPlayback);
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
              Text('Projecting "${_hymn.title}"'),
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

  HymnData _getSampleHymnData(int hymnId) {
    // Sample data - in real app this would come from database
    switch (hymnId) {
      case 1:
        return HymnData(
          id: 'SDAH-en-001',
          number: 1,
          title: 'Holy, Holy, Holy',
          author: 'Reginald Heber',
          composer: 'John B. Dykes',
          tune: 'Nicaea',
          meter: '11.12.12.10',
          year: 1826,
          copyright: 'Public Domain',
          verses: [
            'Holy, holy, holy! Lord God Almighty!\nEarly in the morning our song shall rise to Thee;\nHoly, holy, holy! merciful and mighty!\nGod in three Persons, blessed Trinity!',
            'Holy, holy, holy! All the saints adore Thee,\nCasting down their golden crowns around the glassy sea;\nCherubim and seraphim falling down before Thee,\nWhich wert, and art, and evermore shalt be.',
            'Holy, holy, holy! Though the darkness hide Thee,\nThough the eye of sinful man Thy glory may not see,\nOnly Thou art holy; there is none beside Thee\nPerfect in power, in love, and purity.',
          ],
          chorus: null,
          themes: ['worship', 'trinity', 'holiness', 'praise'],
          scriptureReferences: ['Revelation 4:8', 'Isaiah 6:3'],
        );
      default:
        return HymnData(
          id: 'SDAH-en-${hymnId.toString().padLeft(3, '0')}',
          number: hymnId,
          title: 'Amazing Grace',
          author: 'John Newton',
          composer: 'Traditional American Melody',
          tune: 'New Britain',
          meter: 'CM',
          year: 1779,
          copyright: 'Public Domain',
          verses: [
            'Amazing grace! how sweet the sound\nThat saved a wretch like me!\nI once was lost, but now am found,\nWas blind, but now I see.',
            '\'Twas grace that taught my heart to fear,\nAnd grace my fears relieved;\nHow precious did that grace appear\nThe hour I first believed!',
            'Through many dangers, toils and snares,\nI have already come;\n\'Tis grace hath brought me safe thus far,\nAnd grace will lead me home.',
          ],
          chorus: null,
          themes: ['grace', 'salvation', 'testimony', 'faith'],
          scriptureReferences: ['Ephesians 2:8-9', '1 Timothy 1:15'],
        );
    }
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
            Text('Print options for "${_hymn.title}":'),
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
        content: Text('Printing lyrics for "${_hymn.title}"...'),
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
        content: Text('Printing full hymn details for "${_hymn.title}"...'),
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
        content: Container(
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
                    _hymn.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Hymn #${_hymn.number}'),
                  if (_hymn.author.isNotEmpty) Text('By: ${_hymn.author}'),
                  if (_hymn.composer.isNotEmpty) Text('Music: ${_hymn.composer}'),
                  const SizedBox(height: 16),
                  ...(_hymn.verses.map((verse) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(verse),
                  ))),
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
            Text('Download "${_hymn.title}" as:'),
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
            if (_hymn.hasAudio)
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
            Text('Downloading "${_hymn.title}.pdf"...'),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "${_hymn.title}.pdf" to Downloads folder'),
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
        content: Text('Downloaded "${_hymn.title}.txt" to Downloads folder'),
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
            Text('Downloading "${_hymn.title}.mp3"...'),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "${_hymn.title}.mp3" to Downloads folder'),
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

class HymnData {
  final String id;
  final int number;
  final String title;
  final String author;
  final String composer;
  final String tune;
  final String meter;
  final int year;
  final String copyright;
  final List<String> verses;
  final String? chorus;
  final List<String> themes;
  final List<String> scriptureReferences;

  HymnData({
    required this.id,
    required this.number,
    required this.title,
    required this.author,
    required this.composer,
    required this.tune,
    required this.meter,
    required this.year,
    required this.copyright,
    required this.verses,
    this.chorus,
    required this.themes,
    required this.scriptureReferences,
  });

  bool get hasAudio => true; // Sample data - in real app would check if audio file exists
}

// Add these methods to the _HymnDetailScreenState class (move them from here)
extension HymnDetailScreenMethods on _HymnDetailScreenState {
  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Hymn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Print options for "${_hymn.title}":'),
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
    // In a real app, this would integrate with platform printing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing lyrics for "${_hymn.title}"...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Show print preview
            _showPrintPreview();
          },
        ),
      ),
    );
  }

  void _printWithMetadata() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing full hymn details for "${_hymn.title}"...'),
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
        content: Container(
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
                    _hymn.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Hymn #${_hymn.number}'),
                  if (_hymn.author.isNotEmpty) Text('By: ${_hymn.author}'),
                  if (_hymn.composer.isNotEmpty) Text('Music: ${_hymn.composer}'),
                  const SizedBox(height: 16),
                  ...(_hymn.verses.map((verse) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(verse),
                  ))),
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
            Text('Download "${_hymn.title}" as:'),
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
            if (_hymn.hasAudio)
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
    // Simulate download progress
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
            Text('Downloading "${_hymn.title}.pdf"...'),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // After 3 seconds, show completion
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "${_hymn.title}.pdf" to Downloads folder'),
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
        content: Text('Downloaded "${_hymn.title}.txt" to Downloads folder'),
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
            Text('Downloading "${_hymn.title}.mp3"...'),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded "${_hymn.title}.mp3" to Downloads folder'),
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
  final HymnData hymn;

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
                  'Hymn #${widget.hymn.number}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: _fontSize - 2,
                  ),
                ),
                if (widget.hymn.author.isNotEmpty)
                  Text(
                    'By: ${widget.hymn.author}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: _fontSize - 2,
                    ),
                  ),
                if (widget.hymn.composer.isNotEmpty)
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
              
              // Verses
              ...widget.hymn.verses.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verse ${entry.key + 1}',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: _fontSize - 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _fontSize,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Chorus (if exists)
              if (widget.hymn.chorus != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Chorus',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: _fontSize - 4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hymn.chorus!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _fontSize,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}