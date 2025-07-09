import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CollectionsBrowseScreen extends StatelessWidget {
  const CollectionsBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.collectionsTitle),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Collections Browse Screen - Coming Soon'),
      ),
    );
  }
}