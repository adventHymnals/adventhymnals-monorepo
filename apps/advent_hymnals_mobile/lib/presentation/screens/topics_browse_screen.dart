import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class TopicsBrowseScreen extends StatelessWidget {
  const TopicsBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.topicsTitle),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Topics Browse Screen - Coming Soon'),
      ),
    );
  }
}