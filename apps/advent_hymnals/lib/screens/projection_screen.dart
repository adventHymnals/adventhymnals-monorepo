import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/hymnal_provider.dart';
import '../models/hymn.dart';
import '../models/projection.dart';
import '../widgets/hymn_content_widget.dart';

class ProjectionScreen extends StatefulWidget {
  final String hymnId;

  const ProjectionScreen({
    super.key,
    required this.hymnId,
  });

  @override
  State<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends State<ProjectionScreen> {
  ProjectionSession? _session;
  int _currentSlideIndex = 0;
  bool _showControls = true;
  bool _isFullscreen = false;
  ProjectionSettings _settings = ProjectionSettings.defaultSettings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHymnAndCreateSession();
      _hideSystemUI();
    });
  }

  @override
  void dispose() {
    _showSystemUI();
    super.dispose();
  }

  Future<void> _loadHymnAndCreateSession() async {
    await context.read<HymnalProvider>().loadHymn(widget.hymnId);
    final hymn = context.read<HymnalProvider>().currentHymn;
    
    if (hymn != null) {
      _createProjectionSession(hymn);
    }
  }

  void _createProjectionSession(Hymn hymn) {
    final slides = <ProjectionSlide>[];
    
    // Title slide
    slides.add(ProjectionSlide(
      id: 'title',
      type: SlideType.title,
      content: hymn.title,
      metadata: SlideMetadata(
        title: hymn.title,
        author: hymn.author,
      ),
    ));

    // Verse and chorus slides
    for (int i = 0; i < hymn.verses.length; i++) {
      final verse = hymn.verses[i];
      
      // Add verse
      slides.add(ProjectionSlide(
        id: 'verse_${verse.number}',
        type: SlideType.verse,
        content: verse.text,
        number: verse.number,
        metadata: SlideMetadata(
          verseNumber: verse.number,
          isChorus: false,
        ),
      ));

      // Add chorus after each verse (except the last) if enabled and chorus exists
      if (_settings.showChorusAfterEachVerse && 
          hymn.chorus != null && 
          i < hymn.verses.length - 1) {
        slides.add(ProjectionSlide(
          id: 'chorus_after_${verse.number}',
          type: SlideType.chorus,
          content: hymn.chorus!.text,
          metadata: SlideMetadata(
            isChorus: true,
          ),
        ));
      }
    }

    // Final chorus if it exists
    if (hymn.chorus != null) {
      slides.add(ProjectionSlide(
        id: 'chorus_final',
        type: SlideType.chorus,
        content: hymn.chorus!.text,
        metadata: SlideMetadata(
          isChorus: true,
        ),
      ));
    }

    // Metadata slide if enabled
    if (_settings.showMetadata) {
      String metadataContent = '';
      if (hymn.author != null) metadataContent += 'Author: ${hymn.author}\n';
      if (hymn.composer != null) metadataContent += 'Composer: ${hymn.composer}\n';
      if (hymn.tune != null) metadataContent += 'Tune: ${hymn.tune}\n';
      if (hymn.meter != null) metadataContent += 'Meter: ${hymn.meter}\n';
      if (hymn.metadata?.year != null) metadataContent += 'Year: ${hymn.metadata!.year}\n';
      
      if (metadataContent.isNotEmpty) {
        slides.add(ProjectionSlide(
          id: 'metadata',
          type: SlideType.metadata,
          content: metadataContent.trim(),
        ));
      }
    }

    setState(() {
      _session = ProjectionSession(
        hymn: hymn,
        slides: slides,
        currentSlide: 0,
        settings: _settings,
      );
    });

    // Start auto-advance if enabled
    if (_settings.autoAdvance && _settings.autoAdvanceDelay != null) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    if (_settings.autoAdvanceDelay == null) return;
    
    Future.delayed(Duration(seconds: _settings.autoAdvanceDelay!), () {
      if (mounted && _settings.autoAdvance) {
        _nextSlide();
        _startAutoAdvance();
      }
    });
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() {
      _isFullscreen = true;
    });
  }

  void _showSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _isFullscreen = false;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _nextSlide() {
    if (_session != null && _currentSlideIndex < _session!.slides.length - 1) {
      setState(() {
        _currentSlideIndex++;
      });
    }
  }

  void _previousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() {
        _currentSlideIndex--;
      });
    }
  }

  void _goToSlide(int index) {
    if (_session != null && index >= 0 && index < _session!.slides.length) {
      setState(() {
        _currentSlideIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Consumer<HymnalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHymn || _session == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.hymnError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Hymn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.hymnError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Exit Projection'),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Main content
                _buildSlideContent(),
                
                // Controls overlay
                if (_showControls) _buildControlsOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlideContent() {
    if (_session == null) return const SizedBox.shrink();
    
    final slide = _session!.slides[_currentSlideIndex];
    final textStyle = _getTextStyle();

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Slide type indicator
          if (_settings.showVerseNumbers && slide.type != SlideType.title)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getSlideTypeLabel(slide),
                style: textStyle.copyWith(
                  fontSize: (textStyle.fontSize ?? 16) * 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Main content
          Expanded(
            child: Center(
              child: Text(
                slide.content,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Slide counter
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Text(
              '${_currentSlideIndex + 1} / ${_session!.slides.length}',
              style: textStyle.copyWith(
                fontSize: (textStyle.fontSize ?? 16) * 0.5,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Top controls
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _session?.hymn.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _showSettingsDialog,
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Bottom controls
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    IconButton(
                      onPressed: _currentSlideIndex > 0 ? _previousSlide : null,
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      iconSize: 36,
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Slide selector
                    GestureDetector(
                      onTap: _showSlideSelector,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentSlideIndex + 1} / ${_session?.slides.length ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 32),
                    
                    // Next button
                    IconButton(
                      onPressed: _session != null && _currentSlideIndex < _session!.slides.length - 1 
                          ? _nextSlide 
                          : null,
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      iconSize: 36,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_settings.theme) {
      case ProjectionTheme.light:
        return Colors.white;
      case ProjectionTheme.dark:
        return Colors.black;
      case ProjectionTheme.highContrast:
        return Colors.black;
    }
  }

  TextStyle _getTextStyle() {
    final baseSize = _getFontSize();
    final color = _getTextColor();
    
    return TextStyle(
      fontSize: baseSize,
      color: color,
      height: 1.4,
      fontWeight: FontWeight.w500,
    );
  }

  double _getFontSize() {
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = screenHeight * 0.06; // 6% of screen height
    
    switch (_settings.fontSize) {
      case FontSize.small:
        return baseSize * 0.8;
      case FontSize.medium:
        return baseSize;
      case FontSize.large:
        return baseSize * 1.2;
      case FontSize.extraLarge:
        return baseSize * 1.5;
    }
  }

  Color _getTextColor() {
    switch (_settings.theme) {
      case ProjectionTheme.light:
        return Colors.black;
      case ProjectionTheme.dark:
        return Colors.white;
      case ProjectionTheme.highContrast:
        return Colors.yellow;
    }
  }

  String _getSlideTypeLabel(ProjectionSlide slide) {
    switch (slide.type) {
      case SlideType.verse:
        return 'Verse ${slide.number}';
      case SlideType.chorus:
        return 'Chorus';
      case SlideType.title:
        return 'Title';
      case SlideType.metadata:
        return 'Credits';
    }
  }

  void _showSlideSelector() {
    if (_session == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Slide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _session!.slides.length,
                itemBuilder: (context, index) {
                  final slide = _session!.slides[index];
                  final isSelected = index == _currentSlideIndex;
                  
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.white.withOpacity(0.1),
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.white : Colors.grey,
                      foregroundColor: isSelected ? Colors.black : Colors.white,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      _getSlideTypeLabel(slide),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      slide.content.length > 50 
                          ? '${slide.content.substring(0, 50)}...'
                          : slide.content,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _goToSlide(index);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Projection Settings'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<FontSize>(
                value: _settings.fontSize,
                decoration: const InputDecoration(labelText: 'Font Size'),
                items: FontSize.values.map((size) =>
                  DropdownMenuItem(
                    value: size,
                    child: Text(_getFontSizeName(size)),
                  ),
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      _settings = _settings.copyWith(fontSize: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProjectionTheme>(
                value: _settings.theme,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: ProjectionTheme.values.map((theme) =>
                  DropdownMenuItem(
                    value: theme,
                    child: Text(_getProjectionThemeName(theme)),
                  ),
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      _settings = _settings.copyWith(theme: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Show Verse Numbers'),
                value: _settings.showVerseNumbers,
                onChanged: (value) {
                  setDialogState(() {
                    _settings = _settings.copyWith(showVerseNumbers: value);
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Show Metadata'),
                value: _settings.showMetadata,
                onChanged: (value) {
                  setDialogState(() {
                    _settings = _settings.copyWith(showMetadata: value);
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                // Settings already updated in dialog
              });
              Navigator.of(context).pop();
              
              // Recreate session with new settings
              final hymn = context.read<HymnalProvider>().currentHymn;
              if (hymn != null) {
                _createProjectionSession(hymn);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _getFontSizeName(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Medium';
      case FontSize.large:
        return 'Large';
      case FontSize.extraLarge:
        return 'Extra Large';
    }
  }

  String _getProjectionThemeName(ProjectionTheme theme) {
    switch (theme) {
      case ProjectionTheme.light:
        return 'Light';
      case ProjectionTheme.dark:
        return 'Dark';
      case ProjectionTheme.highContrast:
        return 'High Contrast';
    }
  }
}