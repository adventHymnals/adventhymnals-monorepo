import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _prodApiUrl = 'https://adventhymnals.org/api';
  static const String _devApiUrl = 'http://localhost:3000/api';
  static const String _stagingApiUrl = 'https://staging.adventhymnals.org/api';
  
  static String get apiBaseUrl {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    const customUrl = String.fromEnvironment('API_BASE_URL');
    
    if (customUrl.isNotEmpty) return customUrl;
    
    return switch (environment) {
      'production' => _prodApiUrl,
      'staging' => _stagingApiUrl,
      _ => _devApiUrl,
    };
  }
  
  static String getApiUrl(String path) {
    if (path.startsWith('/')) {
      return '$apiBaseUrl$path';
    }
    return '$apiBaseUrl/$path';
  }
  
  static String get mediaBaseUrl {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    const customMediaUrl = String.fromEnvironment('MEDIA_BASE_URL');
    
    if (customMediaUrl.isNotEmpty) return customMediaUrl;
    
    return switch (environment) {
      'production' => 'https://adventhymnals.org/media',
      'staging' => 'https://staging.adventhymnals.org/media',
      _ => 'http://localhost:3000/media',
    };
  }
  
  static String getMediaUrl(String path) {
    if (path.startsWith('/')) {
      return '$mediaBaseUrl$path';
    }
    return '$mediaBaseUrl/$path';
  }
  
  static bool get isProduction => apiBaseUrl.contains('adventhymnals.org');
  static bool get isDevelopment => apiBaseUrl.contains('localhost');
  static bool get isStaging => apiBaseUrl.contains('staging');
  
  static void logConfig() {
    if (kDebugMode) {
      print('API Configuration:');
      print('  Environment: ${String.fromEnvironment('ENVIRONMENT', defaultValue: 'development')}');
      print('  API Base URL: $apiBaseUrl');
      print('  Media Base URL: $mediaBaseUrl');
      print('  Is Production: $isProduction');
      print('  Is Development: $isDevelopment');
      print('  Is Staging: $isStaging');
    }
  }
}