import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AuthorsBrowseScreen extends StatelessWidget {
  const AuthorsBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.authorsTitle),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Authors Browse Screen - Coming Soon'),
      ),
    );
  }
}