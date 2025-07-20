import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/projector_service.dart';
import '../../domain/entities/hymn.dart';

/// A dedicated widget for displaying hymn content in the projector presentation window
class ProjectorPresentationWidget extends StatefulWidget {
  const ProjectorPresentationWidget({super.key});

  @override
  State<ProjectorPresentationWidget> createState() => _ProjectorPresentationWidgetState();
}

class _ProjectorPresentationWidgetState extends State<ProjectorPresentationWidget> {
  double _fontSize = 48.0;
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.white;
  List<String> _verses = [];
  String? _refrain;
  Hymn? _currentHymn;

  @override
  void initState() {
    super.initState();
  }

  void _loadHymn(int hymnId) async {
    // For now, use sample data - in production this would load from DataManager
    final hymn = _getSampleHymn(hymnId);
    if (hymn != null) {
      setState(() {
        _currentHymn = hymn;
        _verses = _parseVerses(hymn.lyrics ?? '');
      });
    }
  }

  List<String> _parseVerses(String lyrics) {
    // Split lyrics into verses and extract refrain
    final lines = lyrics.split('\n\n');
    final verses = <String>[];
    
    for (final line in lines) {
      if (line.toLowerCase().startsWith('refrain:')) {
        _refrain = line.replaceFirst(RegExp(r'^refrain:\s*', caseSensitive: false), '');
      } else if (line.trim().isNotEmpty) {
        verses.add(line.trim());
      }
    }
    
    return verses;
  }

  void _applyTheme(ProjectorTheme theme, ProjectorTextSize textSize) {
    switch (theme) {
      case ProjectorTheme.dark:
        _backgroundColor = Colors.black;
        _textColor = Colors.white;
        break;
      case ProjectorTheme.light:
        _backgroundColor = Colors.white;
        _textColor = Colors.black;
        break;
      case ProjectorTheme.highContrast:
        _backgroundColor = Colors.black;
        _textColor = Colors.yellow;
        break;
      case ProjectorTheme.blue:
        _backgroundColor = const Color(0xFF001122);
        _textColor = Colors.white;
        break;
    }
    
    switch (textSize) {
      case ProjectorTextSize.small:
        _fontSize = 32.0;
        break;
      case ProjectorTextSize.medium:
        _fontSize = 40.0;
        break;
      case ProjectorTextSize.large:
        _fontSize = 48.0;
        break;
      case ProjectorTextSize.extraLarge:
        _fontSize = 60.0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectorService>(
      builder: (context, projectorService, child) {
        // Apply current theme settings
        _applyTheme(projectorService.theme, projectorService.textSize);
        
        // Load hymn if changed
        if (projectorService.currentHymnId != null && 
            (_currentHymn == null || _currentHymn!.id != projectorService.currentHymnId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadHymn(projectorService.currentHymnId!);
          });
        }
        
        return Container(
          color: _backgroundColor,
          child: Stack(
            children: [
              // Main content
              _buildMainContent(projectorService),
              
              // Branding watermark
              _buildBrandingWatermark(),
              
              // Connection indicator
              _buildConnectionIndicator(projectorService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(ProjectorService projectorService) {
    if (_currentHymn == null || _verses.isEmpty) {
      return _buildNoHymnState();
    }

    final currentVerseIndex = projectorService.currentVerseIndex;
    final isValidIndex = currentVerseIndex < _verses.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hymn title and number
            if (projectorService.showTitle) ...[
              if (projectorService.showHymnNumber)
                Text(
                  '#${_currentHymn!.hymnNumber}',
                  style: TextStyle(
                    color: _textColor.withOpacity(0.8),
                    fontSize: _fontSize * 0.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                _currentHymn!.title,
                style: TextStyle(
                  color: _textColor,
                  fontSize: _fontSize * 0.8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
            
            // Current verse content
            if (isValidIndex) ...[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (projectorService.showVerseNumbers)
                          Text(
                            'Verse ${currentVerseIndex + 1}',
                            style: TextStyle(
                              color: _textColor.withOpacity(0.7),
                              fontSize: _fontSize * 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          _verses[currentVerseIndex],
                          style: TextStyle(
                            color: _textColor,
                            fontSize: _fontSize,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        // Show refrain after verse if exists
                        if (_refrain != null && _refrain!.isNotEmpty) ...[
                          const SizedBox(height: 40),
                          Text(
                            'Refrain',
                            style: TextStyle(
                              color: _textColor.withOpacity(0.7),
                              fontSize: _fontSize * 0.5,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _refrain!,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: _fontSize * 0.9,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    'End of hymn',
                    style: TextStyle(
                      color: _textColor.withOpacity(0.6),
                      fontSize: _fontSize * 0.8,
                    ),
                  ),
                ),
              ),
            ],
            
            // Metadata
            if (projectorService.showMetadata) ...[
              const SizedBox(height: 40),
              Text(
                [
                  if (_currentHymn!.author != null) 'Words: ${_currentHymn!.author}',
                  if (_currentHymn!.composer != null) 'Music: ${_currentHymn!.composer}',
                  if (_currentHymn!.tuneName != null) 'Tune: ${_currentHymn!.tuneName}',
                ].join(' • '),
                style: TextStyle(
                  color: _textColor.withOpacity(0.6),
                  fontSize: _fontSize * 0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Verse indicator
            if (_verses.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_verses.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentVerseIndex
                          ? _textColor
                          : _textColor.withOpacity(0.3),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoHymnState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Advent Hymnals logo/branding
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.library_music,
                  size: _fontSize * 2,
                  color: _textColor.withOpacity(0.6),
                ),
                const SizedBox(height: 20),
                Text(
                  'Advent Hymnals',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Projector Display',
                  style: TextStyle(
                    color: _textColor.withOpacity(0.7),
                    fontSize: _fontSize * 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Waiting for hymn selection from main window',
            style: TextStyle(
              color: _textColor.withOpacity(0.6),
              fontSize: _fontSize * 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingWatermark() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Advent Hymnals',
          style: TextStyle(
            color: _textColor.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(ProjectorService projectorService) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: projectorService.isProjectorActive 
              ? Colors.green.withOpacity(0.2) 
              : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: projectorService.isProjectorActive 
                ? Colors.green 
                : Colors.red,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              projectorService.isProjectorActive 
                  ? Icons.cast_connected 
                  : Icons.cast,
              color: projectorService.isProjectorActive 
                  ? Colors.green 
                  : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              projectorService.isProjectorActive 
                  ? 'Connected' 
                  : 'Disconnected',
              style: TextStyle(
                color: projectorService.isProjectorActive 
                    ? Colors.green 
                    : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data method (replace with DataManager in production)
  Hymn? _getSampleHymn(int hymnId) {
    // This would be replaced with actual data loading
    return Hymn(
      id: hymnId,
      hymnNumber: hymnId,
      title: 'Amazing Grace',
      author: 'John Newton',
      composer: 'William Walker',
      lyrics: '''Amazing grace! how sweet the sound,
That saved a wretch; like me!
I once was lost, but now am found,
Was blind, but now I see.

'Twas grace that taught my heart to fear,
And grace my fears relieved;
How precious did that grace appear
The hour I first believed!

The Lord hath promised good to me,
His word my hope secures;
He will my shield and portion be
As long as life endures.

Refrain:
Amazing grace! how sweet the sound,
That saved a wretch like me!''',
      themeTags: ['Grace', 'Salvation', 'Testimony'],
    );
  }
}