import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class RecentlyViewedScreen extends StatelessWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Recently Viewed Screen - Coming Soon'),
      ),
    );
  }
}