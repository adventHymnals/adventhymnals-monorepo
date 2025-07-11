import 'package:flutter/material.dart';

void main() {
  print("Starting completely empty Flutter app...");
  runApp(const EmptyApp());
}

class EmptyApp extends StatelessWidget {
  const EmptyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Empty App'),
        ),
      ),
    );
  }
}