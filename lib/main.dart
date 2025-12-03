import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_app/ads/interstitial_ad_manager.dart';
import 'package:qr_app/features/splash/splash_screen.dart';
import 'ads/app_open_ad_manager.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  AppOpenAdManager.loadAd();
  InterstitialAdManager.loadAd();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _lastAdShownTime;
  bool _hasShownInitialAd = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _startSplashTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitAndShowInitialAd();
    });
  }

  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  void _waitAndShowInitialAd() async {
    if (_hasShownInitialAd) return;

    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (AppOpenAdManager.isAdAvailable) {
        _hasShownInitialAd = true;
        _tryShowAd();
        return;
      }
    }

    _hasShownInitialAd = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryShowAd();
    }
  }

  void _tryShowAd() {
    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      if (timeSinceLastAd.inSeconds < 30) {
        return;
      }
    }

    _lastAdShownTime = DateTime.now();
    AppOpenAdManager.showAdIfAvailable();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Go Scan - QR',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:qr_app/ads/interstitial_ad_manager.dart';
// import 'ads/app_open_ad_manager.dart';
// import 'routes/app_router.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await MobileAds.instance.initialize();

//   AppOpenAdManager.loadAd();
//   InterstitialAdManager.loadAd();

//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   DateTime? _lastAdShownTime;
//   bool _hasShownInitialAd = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _waitAndShowInitialAd();
//     });
//   }

//   void _waitAndShowInitialAd() async {
//     if (_hasShownInitialAd) return;

//     for (int i = 0; i < 20; i++) {
//       await Future.delayed(const Duration(milliseconds: 500));

//       if (!mounted) return;

//       if (AppOpenAdManager.isAdAvailable) {
//         _hasShownInitialAd = true;
//         _tryShowAd();
//         return;
//       }
//     }

//     _hasShownInitialAd = true;
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _tryShowAd();
//     }
//   }

//   void _tryShowAd() {
//     if (_lastAdShownTime != null) {
//       final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
//       if (timeSinceLastAd.inSeconds < 30) {
//         return;
//       }
//     }

//     _lastAdShownTime = DateTime.now();
//     AppOpenAdManager.showAdIfAvailable();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Go Scan - QR',
//       routerConfig: AppRouter.router,
//     );
//   }
// }
