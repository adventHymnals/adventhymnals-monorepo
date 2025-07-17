import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Your actual AdMob Ad Unit ID
  static const String _bannerAdUnitId = 'ca-app-pub-2124139631235014/4093862448';
  
  // Test ad units for development
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Use test ads in debug mode, real ads in release mode
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }
    return _bannerAdUnitId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
    // Add your real interstitial ad unit ID here when you create one
    return _testInterstitialAdUnitId;
  }

  /// Initialize AdMob SDK
  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      if (kDebugMode) {
        print('AdMob not supported on this platform');
      }
      return;
    }
    
    try {
      await MobileAds.instance.initialize();
      
      if (kDebugMode) {
        print('AdMob initialized with test ads');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdMob initialization failed: $e');
      }
    }
  }

  /// Create a banner ad
  BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    required void Function(Ad ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) {
          if (kDebugMode) print('Banner ad opened');
        },
        onAdClosed: (Ad ad) {
          if (kDebugMode) print('Banner ad closed');
        },
        onAdImpression: (Ad ad) {
          if (kDebugMode) print('Banner ad impression recorded');
        },
      ),
    );
  }

  /// Create an interstitial ad
  Future<InterstitialAd?> createInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          if (kDebugMode) print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) print('Interstitial ad failed to load: $error');
        },
      ),
    );
    
    return interstitialAd;
  }

  /// Get appropriate banner size for the device
  AdSize getBannerAdSize() {
    if (Platform.isAndroid || Platform.isIOS) {
      return AdSize.banner; // 320x50
    }
    return AdSize.leaderboard; // 728x90 for tablets/desktop
  }

  /// Get adaptive banner size
  Future<AdSize> getAdaptiveBannerSize({BuildContext? context}) async {
    if (context == null) {
      return AdSize.banner;
    }
    return await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    ) ?? AdSize.banner;
  }
}

// Global navigator key for context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();