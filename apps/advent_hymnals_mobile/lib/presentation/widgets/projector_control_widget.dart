import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/projector_service.dart';
import '../../core/services/projector_window_service.dart';

/// A control widget for managing projector functionality while projection is active
class ProjectorControlWidget extends StatefulWidget {
  const ProjectorControlWidget({super.key});

  @override
  State<ProjectorControlWidget> createState() => _ProjectorControlWidgetState();
}

class _ProjectorControlWidgetState extends State<ProjectorControlWidget> {
  List<MonitorInfo> _monitors = [];
  bool _isLoadingMonitors = false;

  @override
  void initState() {
    super.initState();
    _loadMonitors();
  }

  Future<void> _loadMonitors() async {
    setState(() {
      _isLoadingMonitors = true;
    });

    try {
      final projectorWindowService = ProjectorWindowService.instance;
      final monitors = await projectorWindowService.getAvailableMonitors();
      setState(() {
        _monitors = monitors;
      });
    } catch (e) {
      print('Error loading monitors: $e');
    } finally {
      setState(() {
        _isLoadingMonitors = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectorService>(
      builder: (context, projectorService, child) {
        if (!projectorService.isProjectorActive) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.cast_connected, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Projector Active',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadMonitors,
                    tooltip: 'Refresh monitors',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current hymn info
              if (projectorService.currentHymnId != null) ...[
                _buildCurrentHymnInfo(projectorService),
                const SizedBox(height: 16),
              ],

              // Navigation controls
              _buildNavigationControls(projectorService),
              const SizedBox(height: 16),

              // Monitor selection
              _buildMonitorSelection(projectorService),
              const SizedBox(height: 16),

              // Settings controls
              _buildSettingsControls(projectorService),
              const SizedBox(height: 16),

              // Auto-advance controls
              _buildAutoAdvanceControls(projectorService),
              const SizedBox(height: 16),

              // Action buttons
              _buildActionButtons(projectorService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentHymnInfo(ProjectorService projectorService) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Hymn',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hymn #${projectorService.currentHymnId}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.library_music,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Verse ${projectorService.currentVerseIndex + 1}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(ProjectorService projectorService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navigation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: projectorService.currentVerseIndex > 0
                    ? projectorService.previousSection
                    : null,
                icon: const Icon(Icons.skip_previous),
                label: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: projectorService.nextSection,
                icon: const Icon(Icons.skip_next),
                label: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonitorSelection(ProjectorService projectorService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitor Selection',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingMonitors) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
        ] else if (_monitors.isEmpty) ...[
          Text(
            'No monitors detected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ] else ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _monitors.length,
              itemBuilder: (context, index) {
                final monitor = _monitors[index];
                return _buildMonitorCard(monitor, projectorService);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonitorCard(MonitorInfo monitor, ProjectorService projectorService) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        child: InkWell(
          onTap: () => _moveToMonitor(monitor.index, projectorService),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      monitor.isPrimary ? Icons.monitor : Icons.desktop_windows,
                      size: 20,
                      color: monitor.isPrimary ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        monitor.isPrimary ? 'Primary' : 'Monitor ${monitor.index + 1}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: monitor.isPrimary ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${monitor.width} × ${monitor.height}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Scale: ${monitor.scaleFactor.toStringAsFixed(1)}x',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _moveToMonitor(monitor.index, projectorService),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 32),
                  ),
                  child: const Text('Use'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsControls(ProjectorService projectorService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ProjectorTheme>(
                value: projectorService.theme,
                decoration: const InputDecoration(
                  labelText: 'Theme',
                  border: OutlineInputBorder(),
                ),
                items: ProjectorTheme.values.map((theme) {
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(_getThemeName(theme)),
                  );
                }).toList(),
                onChanged: (theme) {
                  if (theme != null) {
                    projectorService.updateProjectorSettings(theme: theme);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<ProjectorTextSize>(
                value: projectorService.textSize,
                decoration: const InputDecoration(
                  labelText: 'Text Size',
                  border: OutlineInputBorder(),
                ),
                items: ProjectorTextSize.values.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(_getTextSizeName(size)),
                  );
                }).toList(),
                onChanged: (size) {
                  if (size != null) {
                    projectorService.updateProjectorSettings(textSize: size);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('Verse Numbers'),
              selected: projectorService.showVerseNumbers,
              onSelected: (selected) {
                projectorService.updateProjectorSettings(showVerseNumbers: selected);
              },
            ),
            FilterChip(
              label: const Text('Hymn Number'),
              selected: projectorService.showHymnNumber,
              onSelected: (selected) {
                projectorService.updateProjectorSettings(showHymnNumber: selected);
              },
            ),
            FilterChip(
              label: const Text('Title'),
              selected: projectorService.showTitle,
              onSelected: (selected) {
                projectorService.updateProjectorSettings(showTitle: selected);
              },
            ),
            FilterChip(
              label: const Text('Metadata'),
              selected: projectorService.showMetadata,
              onSelected: (selected) {
                projectorService.updateProjectorSettings(showMetadata: selected);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAutoAdvanceControls(ProjectorService projectorService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Auto-Advance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Switch(
              value: projectorService.autoAdvanceEnabled,
              onChanged: (_) => projectorService.toggleAutoAdvance(),
            ),
          ],
        ),
        if (projectorService.autoAdvanceEnabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Interval: '),
              Expanded(
                child: Slider(
                  value: projectorService.autoAdvanceSeconds.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${projectorService.autoAdvanceSeconds}s',
                  onChanged: (value) {
                    projectorService.setAutoAdvanceSeconds(value.round());
                  },
                ),
              ),
              Text('${projectorService.autoAdvanceSeconds}s'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ProjectorService projectorService) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showProjectorScreen(context),
            icon: const Icon(Icons.fullscreen),
            label: const Text('Show Projector'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _stopProjector(projectorService),
            icon: const Icon(Icons.stop),
            label: const Text('Stop Projector'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _moveToMonitor(int monitorIndex, ProjectorService projectorService) async {
    try {
      final projectorWindowService = ProjectorWindowService.instance;
      final success = await projectorWindowService.moveToMonitor(monitorIndex);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved projector to monitor ${monitorIndex + 1}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to move projector to monitor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error moving projector: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showProjectorScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/projector');
  }

  void _stopProjector(ProjectorService projectorService) {
    projectorService.stopProjector();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Projector stopped'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getThemeName(ProjectorTheme theme) {
    switch (theme) {
      case ProjectorTheme.dark:
        return 'Dark';
      case ProjectorTheme.light:
        return 'Light';
      case ProjectorTheme.highContrast:
        return 'High Contrast';
      case ProjectorTheme.blue:
        return 'Blue';
    }
  }

  String _getTextSizeName(ProjectorTextSize size) {
    switch (size) {
      case ProjectorTextSize.small:
        return 'Small';
      case ProjectorTextSize.medium:
        return 'Medium';
      case ProjectorTextSize.large:
        return 'Large';
      case ProjectorTextSize.extraLarge:
        return 'Extra Large';
    }
  }
}