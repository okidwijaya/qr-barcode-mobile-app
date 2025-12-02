import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ads/interstitial_ad_manager.dart';

extension GoRouterAdExtension on BuildContext {
  static int _navigationCount = 0;
  static DateTime? _lastAdShownTime;
  
  static const int showAdEveryNNavigations = 3;
  static const int minSecondsBetweenAds = 30;

  void pushWithAd(
    String location, {
    Map<String, String>? queryParameters,
    Object? extra,
    bool forceAd = false,
  }) {
    _navigationCount++;

    final shouldShowAd = forceAd || _shouldShowAd();

    if (shouldShowAd) {
      InterstitialAdManager.showAd(
        onAdClosed: () {
          if (mounted) {
            push(location, extra: extra);
          }
        },
      );
      _lastAdShownTime = DateTime.now();
    } else {
      push(location, extra: extra);
    }
  }

  void goWithAd(
    String location, {
    Map<String, String>? queryParameters,
    Object? extra,
    bool forceAd = false,
  }) {
    _navigationCount++;

    final shouldShowAd = forceAd || _shouldShowAd();

    if (shouldShowAd) {
      InterstitialAdManager.showAd(
        onAdClosed: () {
          if (mounted) {
            go(location, extra: extra);
          }
        },
      );
      _lastAdShownTime = DateTime.now();
    } else {
      go(location, extra: extra);
    }
  }

  void pushNamedWithAd(
    String name, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
    bool forceAd = false,
  }) {
    _navigationCount++;

    final shouldShowAd = forceAd || _shouldShowAd();

    if (shouldShowAd) {
      InterstitialAdManager.showAd(
        onAdClosed: () {
          if (mounted) {
            pushNamed(
              name,
              pathParameters: pathParameters ?? {},
              queryParameters: queryParameters ?? {},
              extra: extra,
            );
          }
        },
      );
      _lastAdShownTime = DateTime.now();
    } else {
      pushNamed(
        name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra,
      );
    }
  }

  void goNamedWithAd(
    String name, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
    bool forceAd = false,
  }) {
    _navigationCount++;

    final shouldShowAd = forceAd || _shouldShowAd();

    if (shouldShowAd) {
      InterstitialAdManager.showAd(
        onAdClosed: () {
          if (mounted) {
            goNamed(
              name,
              pathParameters: pathParameters ?? {},
              queryParameters: queryParameters ?? {},
              extra: extra,
            );
          }
        },
      );
      _lastAdShownTime = DateTime.now();
    } else {
      goNamed(
        name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra,
      );
    }
  }

  void popWithAd({bool forceAd = false}) {
    _navigationCount++;

    final shouldShowAd = forceAd || _shouldShowAd();

    if (shouldShowAd) {
      InterstitialAdManager.showAd(
        onAdClosed: () {
          if (mounted && canPop()) {
            pop();
          }
        },
      );
      _lastAdShownTime = DateTime.now();
    } else {
      if (canPop()) {
        pop();
      }
    }
  }

  static bool _shouldShowAd() {
    final frequencyCheck = _navigationCount % showAdEveryNNavigations == 0;
    
    bool timeCheck = true;
    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      timeCheck = timeSinceLastAd.inSeconds >= minSecondsBetweenAds;
      
      if (!timeCheck) {
        print('⏱️ Too soon: ${minSecondsBetweenAds - timeSinceLastAd.inSeconds}s remaining');
      }
    }

    return frequencyCheck && timeCheck;
  }

  static void resetAdCounter() {
    _navigationCount = 0;
    _lastAdShownTime = null;
  }

  static int getAdNavigationCount() => _navigationCount;
}