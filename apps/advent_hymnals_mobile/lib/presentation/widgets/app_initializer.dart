import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/services/data_import_service.dart';
import '../screens/data_loading_screen.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({
    super.key,
    required this.child,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final DataImportService _importService = DataImportService();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _status = 'Checking data...';
  double _progress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _status = 'Checking data...';
        _progress = 0.0;
      });

      // Add timeout for initialization to prevent hanging
      await _initializeWithTimeout();
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AppInitializer] Initialization failed: $e');
      }
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _initializeWithTimeout() async {
    try {
      // Add timeout to prevent infinite hanging (especially on Windows)
      await Future.any([
        _performInitialization(),
        Future.delayed(Duration(seconds: Platform.isWindows ? 45 : 30)).then((_) {
          throw TimeoutException('Initialization timed out', Duration(seconds: Platform.isWindows ? 45 : 30));
        }),
      ]);
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⏱️ [AppInitializer] Initialization timed out, allowing app to continue');
      }
      // Allow app to continue without full data loading
      setState(() {
        _status = 'Continuing with limited data...';
        _progress = 1.0;
        _isInitialized = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _performInitialization() async {
    // Check if import is needed
    final needsImport = await _importService.isImportNeeded();
    
    if (!needsImport) {
      // Data is already available
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      return;
    }

    // Import data
    setState(() {
      _status = 'Preparing hymnal database...';
      _progress = 0.1;
    });

    final result = await _importService.importAllData(
      onProgress: (status) {
        setState(() {
          _status = status;
          // Estimate progress based on status
          if (status.contains('collections')) {
            _progress = 0.2;
          } else if (status.contains('hymns')) {
            // Parse hymn progress if possible
            final match = RegExp(r'\((\d+)/(\d+)\)').firstMatch(status);
            if (match != null) {
              final current = int.tryParse(match.group(1) ?? '0') ?? 0;
              final total = int.tryParse(match.group(2) ?? '1') ?? 1;
              _progress = 0.3 + (current / total) * 0.6; // 30% to 90%
            } else {
              _progress = 0.5;
            }
          } else if (status.contains('Finalizing')) {
            _progress = 0.95;
          } else if (status.contains('complete')) {
            _progress = 1.0;
          }
        });
      },
    );

    if (result.success) {
      setState(() {
        _status = 'Ready!';
        _progress = 1.0;
        _isInitialized = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return widget.child;
    }

    return DataLoadingScreen(
      status: _status,
      progress: _progress,
      hasError: _hasError,
      errorMessage: _errorMessage,
      onRetry: _hasError ? _initializeApp : null,
      onSkip: _hasError ? () {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _hasError = false;
        });
      } : null,
    );
  }
}