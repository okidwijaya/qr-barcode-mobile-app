import 'package:go_router/go_router.dart';
import 'package:qr_app/features/home/pages/home_page.dart';
import 'package:qr_app/features/qr_generator/pages/qr_generator_page.dart';
import 'package:qr_app/features/barcode_generator/pages/barcode_generator_page.dart' 
    as barcode_gen;
import 'package:qr_app/features/qr_scanner/pages/qr_scan_page.dart';
import 'package:qr_app/features/barcode_scanner/pages/barcode_scan_page.dart' 
    as barcode_scan;

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/qr_generator',
      name: 'qr_generator',
      builder: (context, state) => const QrGeneratorPage(),
    ),
    GoRoute(
      path: '/qr_scanner',
      name: 'qr_scanner',
      builder: (context, state) => const QrScanPage(),
    ),
    GoRoute(
      path: '/barcode_scanner',
      name: 'barcode_scanner',
      builder: (context, state) => const barcode_scan.BarcodeScanPage(),
    ),
    GoRoute(
      path: '/barcode_generator',
      name: 'barcode_generator',
      builder: (context, state) => const barcode_gen.BarcodeGeneratorPage(),
    ),
  ],
);
// import 'package:qr_app/routes/app_routes.dart';
// import '../features/auth/pages/login_page.dart';
// import '../features/auth/pages/profile_page.dart';
// import '../features/auth/pages/register_page.dart';
// import 'package:go_router/go_router.dart';
// import '../features/barcode_generator/pages/barcode_generator_page.dart';
// import '../features/barcode_scanner/pages/barcode_scan_page.dart';
// import '../features/barcode_scanner/pages/barcode_result_page.dart';
// import '../features/home/pages/home_page.dart';
// import '../features/qr_generator/pages/qr_generator_page.dart';
// import '../features/qr_scanner/pages/qr_result_page.dart';
// import '../features/qr_scanner/pages/qr_scan_page.dart';

// class AppRouter{
//   static final router = GoRouter(
//     initialLocation: "/",
//     routes: [
//       GoRoute(
//         path: "/",
//         name: "home",
//         builder: (context, state) => const HomePage(),
//       ),
//       GoRoute(
//         path: "/qr_scanner",
//         name: "scan-qr",
//         builder: (context, state) => const QrScanPage(),
//       ),
//       GoRoute(
//         path: "/qr_generator",
//         name: "generate-qr",
//         builder: (context, state) => const QrGeneratorPage(),
//       ),
//       GoRoute(
//         path: "/qr_result",
//         name: "result-qr",
//         builder: (context, state) => const QrResultPage(),
//       ),
//       GoRoute(
//         path: "/barcode_scanner",
//         name: "barcode-qr",
//         builder: (context, state) => const BarcodeScanPage(),
//       ),
//       GoRoute(
//         path: "/barcode_generator",
//         name: "barcode-generator",
//         builder: (context, state) => const BarcodeGeneratorPage(),
//       ),
//       GoRoute(
//         path: "/barcode_result",
//         name: "barcode-result",
//         builder: (context, state) => const BarcodeResultPage(),
//       ),
//     ],
//   );
// }