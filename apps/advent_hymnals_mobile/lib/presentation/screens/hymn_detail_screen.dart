import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class HymnDetailScreen extends StatelessWidget {
  final int hymnId;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hymn $hymnId'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Toggle favorite
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share hymn
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Hymn Detail Screen - Coming Soon'),
      ),
    );
  }
}