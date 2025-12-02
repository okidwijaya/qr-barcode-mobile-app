import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoading = false;
  static int _numInterstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  static String get adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4774376429155227/8781439340';
    } else {
      return '';
    }
  }

  static void loadAd() {
    if (_isAdLoading || _interstitialAd != null) {
      return;
    }

    _isAdLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _isAdLoading = false;

          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _numInterstitialLoadAttempts++;
          _interstitialAd = null;
          _isAdLoading = false;

          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 3), loadAd);
          }
        },
      ),
    );
  }

  static void showAd({required Function() onAdClosed}) {
    if (_interstitialAd == null) {
      onAdClosed();
      loadAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdClosed();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onAdClosed();
        loadAd();
      },
    );

    _interstitialAd!.show();
  }
}