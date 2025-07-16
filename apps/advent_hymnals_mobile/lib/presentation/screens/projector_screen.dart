import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/projector_service.dart';
import '../../domain/entities/hymn.dart';
import '../widgets/hymn_selection_widget.dart';

class ProjectorScreen extends StatefulWidget {
  final int? initialHymnId;
  final bool isSecondaryWindow;

  const ProjectorScreen({
    super.key,
    this.initialHymnId,
    this.isSecondaryWindow = false,
  });

  @override
  State<ProjectorScreen> createState() => _ProjectorScreenState();
}

class _ProjectorScreenState extends State<ProjectorScreen> {
  bool _isFullscreen = false;
  double _fontSize = 48.0;
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.white;
  List<String> _verses = [];
  String? _refrain;
  Hymn? _currentHymn;

  @override
  void initState() {
    super.initState();
    
    // Initialize projector service if hymn provided
    if (widget.initialHymnId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final projectorService = ProjectorService();
        if (!projectorService.isProjectorActive) {
          projectorService.startProjector(widget.initialHymnId!);
        }
      });
    }
    
    // Enable full screen for desktop and secondary window
    if ((Platform.isLinux || Platform.isWindows || Platform.isMacOS) || widget.isSecondaryWindow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleFullscreen();
      });
    }
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

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }


  void _showSettings(ProjectorService projectorService) {
    showDialog(
      context: context,
      builder: (context) => _ProjectorSettingsDialog(
        projectorService: projectorService,
      ),
    );
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
        
        // Show hymn selection when projector is not active and not in secondary window
        if (!projectorService.isProjectorActive && !widget.isSecondaryWindow) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Projector Mode'),
              elevation: 0,
            ),
            body: const HymnSelectionWidget(),
          );
        }
        
        return Scaffold(
          backgroundColor: _backgroundColor,
          body: Stack(
            children: [
              // Main content
              _buildMainContent(projectorService),
              
              // Advent Hymnals branding (subtle watermark)
              if (widget.isSecondaryWindow)
                _buildBrandingWatermark(),
              
              // Controls overlay (only show if not in secondary window)
              if (!widget.isSecondaryWindow)
                Positioned(
                  top: 20,
                  right: 20,
                  child: _buildControlsOverlay(projectorService),
                ),
              
              // Auto-advance countdown (if enabled)
              if (projectorService.autoAdvanceEnabled && !widget.isSecondaryWindow)
                _buildAutoAdvanceCountdown(projectorService),
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
            widget.isSecondaryWindow 
                ? 'Waiting for hymn selection from main window'
                : 'Select a hymn to begin projecting',
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

  Widget _buildControlsOverlay(ProjectorService projectorService) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(projectorService),
            tooltip: 'Projector Settings',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: projectorService.currentVerseIndex > 0 
                ? projectorService.previousSection 
                : null,
            tooltip: 'Previous Verse',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: _verses.isNotEmpty && 
                projectorService.currentVerseIndex < _verses.length - 1 
                ? projectorService.nextSection 
                : null,
            tooltip: 'Next Verse',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              projectorService.autoAdvanceEnabled 
                  ? Icons.timer 
                  : Icons.timer_off,
              color: projectorService.autoAdvanceEnabled 
                  ? Colors.green 
                  : Colors.white,
            ),
            onPressed: projectorService.toggleAutoAdvance,
            tooltip: projectorService.autoAdvanceEnabled 
                ? 'Disable Auto-Advance' 
                : 'Enable Auto-Advance',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: _toggleFullscreen,
            tooltip: _isFullscreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              projectorService.stopProjector();
              Navigator.of(context).pop();
            },
            tooltip: 'Stop Projector',
          ),
        ],
      ),
    );
  }

  Widget _buildAutoAdvanceCountdown(ProjectorService projectorService) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: StreamBuilder<int>(
        stream: projectorService.getAutoAdvanceCountdown(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data! <= 0) {
            return const SizedBox.shrink();
          }
          
          final seconds = snapshot.data!;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next in ${seconds}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
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

class _ProjectorSettingsDialog extends StatefulWidget {
  final ProjectorService projectorService;

  const _ProjectorSettingsDialog({
    required this.projectorService,
  });

  @override
  State<_ProjectorSettingsDialog> createState() => _ProjectorSettingsDialogState();
}

class _ProjectorSettingsDialogState extends State<_ProjectorSettingsDialog> {
  late ProjectorTheme _theme;
  late ProjectorTextSize _textSize;
  late bool _showVerseNumbers;
  late bool _showHymnNumber;
  late bool _showTitle;
  late bool _showMetadata;
  late bool _autoAdvanceEnabled;
  late int _autoAdvanceSeconds;

  @override
  void initState() {
    super.initState();
    final service = widget.projectorService;
    _theme = service.theme;
    _textSize = service.textSize;
    _showVerseNumbers = service.showVerseNumbers;
    _showHymnNumber = service.showHymnNumber;
    _showTitle = service.showTitle;
    _showMetadata = service.showMetadata;
    _autoAdvanceEnabled = service.autoAdvanceEnabled;
    _autoAdvanceSeconds = service.autoAdvanceSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Projector Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto-Advance Settings
            Text('Auto-Advance', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Enable auto-advance'),
              subtitle: Text('Automatically move to next verse after $_autoAdvanceSeconds seconds'),
              value: _autoAdvanceEnabled,
              onChanged: (value) => setState(() => _autoAdvanceEnabled = value!),
              dense: true,
            ),
            if (_autoAdvanceEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Interval: '),
                    Expanded(
                      child: Slider(
                        value: _autoAdvanceSeconds.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: '${_autoAdvanceSeconds}s',
                        onChanged: (value) => setState(() => _autoAdvanceSeconds = value.round()),
                      ),
                    ),
                    Text('${_autoAdvanceSeconds}s'),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(),
            
            Text('Theme', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...ProjectorTheme.values.map((theme) => RadioListTile<ProjectorTheme>(
              title: Text(_getThemeName(theme)),
              value: theme,
              groupValue: _theme,
              onChanged: (value) => setState(() => _theme = value!),
              dense: true,
            )),
            
            const SizedBox(height: 16),
            Text('Text Size', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...ProjectorTextSize.values.map((size) => RadioListTile<ProjectorTextSize>(
              title: Text(_getTextSizeName(size)),
              value: size,
              groupValue: _textSize,
              onChanged: (value) => setState(() => _textSize = value!),
              dense: true,
            )),
            
            const SizedBox(height: 16),
            Text('Display Options', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            
            CheckboxListTile(
              title: const Text('Show verse numbers'),
              value: _showVerseNumbers,
              onChanged: (value) => setState(() => _showVerseNumbers = value!),
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Show hymn number'),
              value: _showHymnNumber,
              onChanged: (value) => setState(() => _showHymnNumber = value!),
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Show title'),
              value: _showTitle,
              onChanged: (value) => setState(() => _showTitle = value!),
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Show metadata'),
              value: _showMetadata,
              onChanged: (value) => setState(() => _showMetadata = value!),
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Update projector service settings
            widget.projectorService.updateProjectorSettings(
              theme: _theme,
              textSize: _textSize,
              showVerseNumbers: _showVerseNumbers,
              showHymnNumber: _showHymnNumber,
              showTitle: _showTitle,
              showMetadata: _showMetadata,
            );
            
            // Update auto-advance settings
            if (_autoAdvanceEnabled != widget.projectorService.autoAdvanceEnabled) {
              widget.projectorService.toggleAutoAdvance();
            }
            if (_autoAdvanceSeconds != widget.projectorService.autoAdvanceSeconds) {
              widget.projectorService.setAutoAdvanceSeconds(_autoAdvanceSeconds);
            }
            
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  String _getThemeName(ProjectorTheme theme) {
    switch (theme) {
      case ProjectorTheme.dark:
        return 'Dark (Black/White)';
      case ProjectorTheme.light:
        return 'Light (White/Black)';
      case ProjectorTheme.highContrast:
        return 'High Contrast (Black/Yellow)';
      case ProjectorTheme.blue:
        return 'Blue (Dark Blue/White)';
    }
  }

  String _getTextSizeName(ProjectorTextSize size) {
    switch (size) {
      case ProjectorTextSize.small:
        return 'Small (32pt)';
      case ProjectorTextSize.medium:
        return 'Medium (40pt)';
      case ProjectorTextSize.large:
        return 'Large (48pt)';
      case ProjectorTextSize.extraLarge:
        return 'Extra Large (60pt)';
    }
  }
}

