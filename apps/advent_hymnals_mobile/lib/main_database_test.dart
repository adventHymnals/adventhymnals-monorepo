import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  print("🚀 Starting database test...");
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print("✅ Flutter binding initialized");
    
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      print("🔧 Testing SQLite FFI initialization...");
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print("✅ SQLite FFI initialized successfully");
    }
    
    runApp(const DatabaseTestApp());
    print("✅ Database test app started");
    
  } catch (e, stackTrace) {
    print("❌ Error in database test: $e");
    print("Stack trace: $stackTrace");
  }
}

class DatabaseTestApp extends StatelessWidget {
  const DatabaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Database Test'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storage,
                size: 100,
                color: Colors.orange,
              ),
              SizedBox(height: 20),
              Text(
                'SQLite FFI Test Passed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}