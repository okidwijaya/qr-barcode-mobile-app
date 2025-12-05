import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controller/home_controller.dart';
import '../widget/home_widget.dart';
import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isAdSupported = false;

  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    
    controller.loadScanHistory();

    _checkAdSupport();
    if (_isAdSupported) {
      _loadBannerAd();
    }
  }

  void _checkAdSupport() {
    if (!kIsWeb) {
      try {
        _isAdSupported = Platform.isAndroid || Platform.isIOS;
      } catch (e) {
        _isAdSupported = false;
      }
    }
  }

  void _loadBannerAd() {
    if (!_isAdSupported) {
      return;
    }

    String adUnitId;
    if (Platform.isAndroid) {
      adUnitId = 'ca-app-pub-4774376429155227/2701362131';
    } else {
      return;
    }
    // } else if (Platform.isIOS) {
    //   adUnitId = 'ca-app-pub-3940256099942544/2934735716';

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
        // onAdOpened: (ad) => print('Banner ad opened'),
        // onAdClosed: (ad) => print('Banner ad closed'),
        // onAdImpression: (ad) => print('Banner ad impression'),
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF5F15)!, Color(0xFF121212)!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
            ),
            SizedBox(width: 12),
            Text(
              'ScanMaster',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // actions: [
        //   Padding(
        //     padding: EdgeInsets.only(right: 12),
        //     child: GestureDetector(
        //       onTap: () {
        //         Get.snackbar(
        //           'Account',
        //           'Profile page coming soon',
        //           snackPosition: SnackPosition.TOP,
        //         );
        //       },
        //       child: CircleAvatar(
        //         backgroundColor: Colors.blue[100],
        //         child: Icon(Icons.person, color: Color(0xFFFF5F15)),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final currentState = controller.state.value;

              if (currentState.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF5F15)),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: HeaderSection(
                      itemCount: currentState.scanHistory.length,
                    ),
                  ),
                  Expanded(
                    child:
                        currentState.scanHistory.isEmpty
                            ? EmptyStateWidget()
                            : ScanHistoryList(
                              items: currentState.scanHistory,
                              controller: controller,
                            ),
                  ),
                ],
              );
            }),
          ),

          if (_isAdSupported)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                height: 50,
                child:
                    _isBannerAdLoaded && _bannerAd != null
                        ? AdWidget(ad: _bannerAd!)
                        : Center(
                          child: Text(
                            'Loading ad...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              selectedIndex: controller.state.value.selectedNavIndex,
              onTap: controller.onBottomNavTap,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                ignoring: false,
                child: SpeedDialFAB(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
