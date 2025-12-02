import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
  static DateTime? _adLoadTime;
  static bool _isAdLoading = false;

  static String get adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4774376429155227/2842291920';
    } else {
      return '';
    }
  }

  static bool get isAdAvailable {
    if (_appOpenAd == null) return false;
    if (_adLoadTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_adLoadTime!);
    return difference.inHours < 4;
  }

  static void loadAd() {
    if (_appOpenAd != null) {
      return;
    }

    if (_isAdLoading) {
      return;
    }

    _isAdLoading = true;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _adLoadTime = DateTime.now();
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _adLoadTime = null;
          _isAdLoading = false;

          Future.delayed(const Duration(seconds: 5), () {
            if (_appOpenAd == null) {
              loadAd();
            }
          });
        },
      ),
    );
  }

  static void showAdIfAvailable() {
    if (!isAdAvailable) {
      if (!_isAdLoading) {
        loadAd();
      }
      return;
    }

    if (_isShowingAd) {
      return;
    }

    _isShowingAd = true;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        _cleanup(ad);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _cleanup(ad);
      },
    );

    _appOpenAd!.show();
  }

  static void _cleanup(AppOpenAd ad) {
    _isShowingAd = false;
    ad.dispose();
    _appOpenAd = null;
    _adLoadTime = null;

    loadAd();
  }
}
