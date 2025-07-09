import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Downloads Screen - Coming Soon'),
      ),
    );
  }
}