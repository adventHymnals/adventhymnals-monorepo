import 'package:flutter/material.dart';

void main() {
  print("🚀 Starting minimal Windows test...");
  
  try {
    runApp(const MinimalTestApp());
    print("✅ App started successfully");
  } catch (e, stackTrace) {
    print("❌ Error in main: $e");
    print("Stack trace: $stackTrace");
  }
}

class MinimalTestApp extends StatelessWidget {
  const MinimalTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("🎨 Building MinimalTestApp...");
    
    return MaterialApp(
      title: 'Windows Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Windows Flutter Test'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                'Flutter Windows App Working!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Basic window functionality confirmed',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}