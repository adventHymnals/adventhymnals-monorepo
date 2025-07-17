import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import '../../core/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize;
  final EdgeInsets? margin;
  
  const BannerAdWidget({
    super.key,
    this.adSize,
    this.margin,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final AdMobService _adMobService = AdMobService();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Skip ad loading on non-mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    
    try {
      final adSize = widget.adSize ?? _adMobService.getBannerAdSize();
      
      _bannerAd = _adMobService.createBannerAd(
        adSize: adSize,
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          try {
            ad.dispose();
          } catch (e) {
            print('Error disposing failed ad: $e');
          }
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      );

      _bannerAd?.load();
    } catch (e) {
      print('Error creating banner ad: $e');
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _bannerAd?.dispose();
      } catch (e) {
        // Safely handle any disposal errors
        print('Warning: Error disposing banner ad: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      // Return a placeholder or nothing while ad loads
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

class AdaptiveBannerAdWidget extends StatefulWidget {
  final EdgeInsets? margin;
  
  const AdaptiveBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final AdMobService _adMobService = AdMobService();

  @override
  void initState() {
    super.initState();
    _loadAdaptiveBannerAd();
  }

  void _loadAdaptiveBannerAd() async {
    // Skip ad loading on non-mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    
    try {
      final adSize = await _adMobService.getAdaptiveBannerSize();
      
      _bannerAd = _adMobService.createBannerAd(
        adSize: adSize,
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('Adaptive banner ad failed to load: $error');
          try {
            ad.dispose();
          } catch (e) {
            print('Error disposing failed adaptive ad: $e');
          }
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      );

      _bannerAd?.load();
    } catch (e) {
      print('Error creating adaptive banner ad: $e');
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _bannerAd?.dispose();
      } catch (e) {
        // Safely handle any disposal errors
        print('Warning: Error disposing banner ad: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      // Return a placeholder or nothing while ad loads
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,      
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}