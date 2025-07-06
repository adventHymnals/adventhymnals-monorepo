import 'package:flutter/material.dart';
import '../models/hymn.dart';

class HymnContentWidget extends StatelessWidget {
  final Hymn hymn;
  final NotationFormat format;
  final bool isProjection;

  const HymnContentWidget({
    super.key,
    required this.hymn,
    required this.format,
    this.isProjection = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (format) {
      case NotationFormat.lyrics:
        return _buildLyricsView(context);
      case NotationFormat.solfa:
      case NotationFormat.staff:
      case NotationFormat.chord:
        return _buildNotationView(context, format);
    }
  }

  Widget _buildLyricsView(BuildContext context) {
    final textStyle = isProjection
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.bodyLarge;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isProjection ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isProjection) ...[
              Text(
                'Lyrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Verses and chorus
            for (int i = 0; i < hymn.verses.length; i++) ...[
              _buildVerse(context, hymn.verses[i], textStyle),
              
              // Add chorus after each verse if it exists
              if (hymn.chorus != null && i < hymn.verses.length - 1) ...[
                const SizedBox(height: 16),
                _buildChorus(context, hymn.chorus!, textStyle),
              ],
              
              if (i < hymn.verses.length - 1)
                SizedBox(height: isProjection ? 32 : 24),
            ],
            
            // Final chorus if it exists
            if (hymn.chorus != null) ...[
              SizedBox(height: isProjection ? 32 : 24),
              _buildChorus(context, hymn.chorus!, textStyle),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerse(BuildContext context, HymnVerse verse, TextStyle? style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isProjection)
          Text(
            'Verse ${verse.number}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (!isProjection) const SizedBox(height: 8),
        Text(
          verse.text,
          style: style?.copyWith(
            height: isProjection ? 1.5 : 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildChorus(BuildContext context, HymnChorus chorus, TextStyle? style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isProjection)
          Text(
            'Chorus',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        if (!isProjection) const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(isProjection ? 16 : 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ),
          ),
          child: Text(
            chorus.text,
            style: style?.copyWith(
              height: isProjection ? 1.5 : 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotationView(BuildContext context, NotationFormat format) {
    HymnNotation? notation;
    if (hymn.notations != null) {
      try {
        notation = hymn.notations!.firstWhere((n) => n.format == format);
      } catch (e) {
        notation = hymn.notations!.isNotEmpty ? hymn.notations!.first : null;
      }
    }

    if (notation == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.music_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '${_getFormatName(format)} not available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This hymn only has lyrics available.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Switch to lyrics view
                },
                child: const Text('View Lyrics'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getFormatName(format),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (notation.quality != null)
                  Chip(
                    label: Text(_getQualityName(notation.quality!)),
                    backgroundColor: _getQualityColor(context, notation.quality!),
                  ),
              ],
            ),
            if (notation.source != null) ...[
              const SizedBox(height: 8),
              Text(
                'Source: ${notation.source}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // For now, display as text. In a real app, this would render
            // appropriate notation based on the format
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: format == NotationFormat.staff
                  ? _buildStaffNotation(context, notation)
                  : Text(
                      notation.content,
                      style: TextStyle(
                        fontFamily: format == NotationFormat.chord ? 'monospace' : null,
                        fontSize: format == NotationFormat.solfa ? 18 : 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffNotation(BuildContext context, HymnNotation notation) {
    // In a real app, this would render actual staff notation
    // For now, show a placeholder
    return Column(
      children: [
        Icon(
          Icons.music_note,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'Staff notation rendering not implemented',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Raw notation data:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          notation.content,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getFormatName(NotationFormat format) {
    switch (format) {
      case NotationFormat.lyrics:
        return 'Lyrics';
      case NotationFormat.solfa:
        return 'Solfa Notation';
      case NotationFormat.staff:
        return 'Staff Notation';
      case NotationFormat.chord:
        return 'Chord Chart';
    }
  }

  String _getQualityName(NotationQuality quality) {
    switch (quality) {
      case NotationQuality.high:
        return 'High Quality';
      case NotationQuality.medium:
        return 'Medium Quality';
      case NotationQuality.low:
        return 'Low Quality';
    }
  }

  Color _getQualityColor(BuildContext context, NotationQuality quality) {
    switch (quality) {
      case NotationQuality.high:
        return Colors.green.withOpacity(0.2);
      case NotationQuality.medium:
        return Colors.orange.withOpacity(0.2);
      case NotationQuality.low:
        return Colors.red.withOpacity(0.2);
    }
  }
}