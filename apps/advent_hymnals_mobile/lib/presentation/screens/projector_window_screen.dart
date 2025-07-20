import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/projector_service.dart';
import '../../domain/entities/hymn.dart';
import '../providers/hymn_provider.dart';
import '../../core/constants/app_constants.dart';

class ProjectorWindowScreen extends StatefulWidget {
  final int? hymnId;
  
  const ProjectorWindowScreen({
    super.key,
    this.hymnId,
  });

  @override
  State<ProjectorWindowScreen> createState() => _ProjectorWindowScreenState();
}

class _ProjectorWindowScreenState extends State<ProjectorWindowScreen> {
  Hymn? _hymn;
  List<String> _verses = [];
  
  @override
  void initState() {
    super.initState();
    
    // Wait for the next frame to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHymnData();
    });
  }

  Future<void> _loadHymnData() async {
    print('🎥 [ProjectorWindow] _loadHymnData called with hymnId: ${widget.hymnId}');
    
    if (widget.hymnId == null) {
      print('🎥 [ProjectorWindow] No hymnId provided, skipping load');
      return;
    }
    
    try {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      final allHymns = hymnProvider.hymns;
      print('🎥 [ProjectorWindow] Total hymns available: ${allHymns.length}');
      
      // Debug: show some hymn numbers for reference
      if (allHymns.isNotEmpty) {
        final hymnNumbers = allHymns.take(10).map((h) => 'Hymn ${h.hymnNumber}: ${h.title}').join(', ');
        print('🎥 [ProjectorWindow] Sample hymns: $hymnNumbers');
      }
      
      final hymn = hymnProvider.hymns.firstWhere(
        (h) => h.hymnNumber == widget.hymnId,
        orElse: () => throw Exception('Hymn not found'),
      );
      
      print('🎥 [ProjectorWindow] Found hymn: ${hymn.hymnNumber} - ${hymn.title}');
      print('🎥 [ProjectorWindow] Hymn collection: ${hymn.collectionAbbreviation}');
      
      final verses = _parseVerses(hymn.lyrics ?? '');
      print('🎥 [ProjectorWindow] Parsed ${verses.length} verses from lyrics');
      
      setState(() {
        _hymn = hymn;
        _verses = verses;
      });
    } catch (e) {
      print('❌ [ProjectorWindow] Error loading hymn data: $e');
      print('❌ [ProjectorWindow] Requested hymnId: ${widget.hymnId}');
    }
  }

  Future<void> _loadHymnDataByNumber(int hymnNumber) async {
    print('🎥 [ProjectorWindow] _loadHymnDataByNumber called with hymnNumber: $hymnNumber');
    
    try {
      final hymnProvider = Provider.of<HymnProvider>(context, listen: false);
      final allHymns = hymnProvider.hymns;
      print('🎥 [ProjectorWindow] Total hymns available: ${allHymns.length}');
      
      final hymn = hymnProvider.hymns.firstWhere(
        (h) => h.hymnNumber == hymnNumber,
        orElse: () => throw Exception('Hymn $hymnNumber not found'),
      );
      
      print('🎥 [ProjectorWindow] Found hymn: ${hymn.hymnNumber} - ${hymn.title}');
      print('🎥 [ProjectorWindow] Hymn collection: ${hymn.collectionAbbreviation}');
      
      final verses = _parseVerses(hymn.lyrics ?? '');
      print('🎥 [ProjectorWindow] Parsed ${verses.length} verses from lyrics');
      
      setState(() {
        _hymn = hymn;
        _verses = verses;
      });
    } catch (e) {
      print('❌ [ProjectorWindow] Error loading hymn by number: $e');
      print('❌ [ProjectorWindow] Requested hymnNumber: $hymnNumber');
    }
  }

  List<String> _parseVerses(String lyrics) {
    if (lyrics.isEmpty) return ['No lyrics available'];
    
    // Split by double newlines or verse markers
    final verses = lyrics.split(RegExp(r'\n\s*\n|\n\d+\.\s*'));
    return verses.where((verse) => verse.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ProjectorService>(
        builder: (context, projectorService, child) {
          print('🎥 [ProjectorWindow] Build called - projector active: ${projectorService.isProjectorActive}, hymn loaded: ${_hymn != null}');
          print('🎥 [ProjectorWindow] ProjectorService current hymn: ${projectorService.currentHymnId}, verse: ${projectorService.currentVerseIndex + 1}');
          
          // If projector is active but we don't have the right hymn loaded, try to load it
          if (projectorService.isProjectorActive && projectorService.currentHymnId != null) {
            if (_hymn == null || _hymn!.hymnNumber != projectorService.currentHymnId) {
              print('🎥 [ProjectorWindow] Hymn mismatch detected, reloading hymn ${projectorService.currentHymnId}');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadHymnDataByNumber(projectorService.currentHymnId!);
              });
            }
          }
          
          if (!projectorService.isProjectorActive || _hymn == null) {
            return _buildWaitingScreen();
          }

          return _buildProjectorContent(projectorService);
        },
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.present_to_all,
            color: Colors.white,
            size: 120,
          ),
          SizedBox(height: 32),
          Text(
            'Projector Ready',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Waiting for content to project...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectorContent(ProjectorService projectorService) {
    final currentVerse = projectorService.currentVerseIndex < _verses.length
        ? _verses[projectorService.currentVerseIndex]
        : _verses.isNotEmpty ? _verses.last : 'No content';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _getBackgroundDecoration(projectorService.theme),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hymn number and title (if enabled)
              if (projectorService.showHymnNumber || projectorService.showTitle)
                _buildHeader(projectorService),
              
              const SizedBox(height: 48),
              
              // Main verse content
              Expanded(
                child: Center(
                  child: _buildVerseContent(currentVerse, projectorService),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Footer with metadata (if enabled)
              if (projectorService.showMetadata)
                _buildFooter(projectorService),
              
              // Verse navigation indicators
              _buildVerseIndicators(projectorService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProjectorService projectorService) {
    return Column(
      children: [
        if (projectorService.showHymnNumber)
          Text(
            'Hymn ${_hymn!.hymnNumber}',
            style: TextStyle(
              color: _getTextColor(projectorService.theme),
              fontSize: _getHeaderFontSize(projectorService.textSize),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        if (projectorService.showTitle)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _hymn!.title,
              style: TextStyle(
                color: _getTextColor(projectorService.theme),
                fontSize: _getTitleFontSize(projectorService.textSize),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildVerseContent(String verse, ProjectorService projectorService) {
    return Text(
      verse.trim(),
      style: TextStyle(
        color: _getTextColor(projectorService.theme),
        fontSize: _getVerseFontSize(projectorService.textSize),
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFooter(ProjectorService projectorService) {
    return Column(
      children: [
        if (_hymn!.author != null)
          Text(
            'Words: ${_hymn!.author}',
            style: TextStyle(
              color: _getTextColor(projectorService.theme).withOpacity(0.8),
              fontSize: _getMetadataFontSize(projectorService.textSize),
            ),
            textAlign: TextAlign.center,
          ),
        if (_hymn!.composer != null)
          Text(
            'Music: ${_hymn!.composer}',
            style: TextStyle(
              color: _getTextColor(projectorService.theme).withOpacity(0.8),
              fontSize: _getMetadataFontSize(projectorService.textSize),
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildVerseIndicators(ProjectorService projectorService) {
    if (_verses.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_verses.length, (index) {
          final isActive = index == projectorService.currentVerseIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive 
                  ? _getTextColor(projectorService.theme)
                  : _getTextColor(projectorService.theme).withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration(ProjectorTheme theme) {
    switch (theme) {
      case ProjectorTheme.light:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
          ),
        );
      case ProjectorTheme.dark:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          ),
        );
      case ProjectorTheme.highContrast:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
          ),
        );
      case ProjectorTheme.blue:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(AppColors.primaryBlue), Color(AppColors.secondaryBlue)],
          ),
        );
    }
  }

  Color _getTextColor(ProjectorTheme theme) {
    switch (theme) {
      case ProjectorTheme.light:
        return Colors.black;
      case ProjectorTheme.dark:
      case ProjectorTheme.highContrast:
      case ProjectorTheme.blue:
        return Colors.white;
    }
  }

  double _getHeaderFontSize(ProjectorTextSize textSize) {
    switch (textSize) {
      case ProjectorTextSize.small:
        return 36;
      case ProjectorTextSize.medium:
        return 48;
      case ProjectorTextSize.large:
        return 60;
      case ProjectorTextSize.extraLarge:
        return 72;
    }
  }

  double _getTitleFontSize(ProjectorTextSize textSize) {
    switch (textSize) {
      case ProjectorTextSize.small:
        return 28;
      case ProjectorTextSize.medium:
        return 36;
      case ProjectorTextSize.large:
        return 44;
      case ProjectorTextSize.extraLarge:
        return 52;
    }
  }

  double _getVerseFontSize(ProjectorTextSize textSize) {
    switch (textSize) {
      case ProjectorTextSize.small:
        return 24;
      case ProjectorTextSize.medium:
        return 32;
      case ProjectorTextSize.large:
        return 40;
      case ProjectorTextSize.extraLarge:
        return 48;
    }
  }

  double _getMetadataFontSize(ProjectorTextSize textSize) {
    switch (textSize) {
      case ProjectorTextSize.small:
        return 16;
      case ProjectorTextSize.medium:
        return 20;
      case ProjectorTextSize.large:
        return 24;
      case ProjectorTextSize.extraLarge:
        return 28;
    }
  }
}