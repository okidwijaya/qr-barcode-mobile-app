import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import './home_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';

class HomeController extends GetxController {
  final state = HomeState().obs;

  @override
  void onInit() {
    super.onInit();
    loadScanHistory();
  }

  Future<void> loadScanHistory() async {
    try {
      state.value = state.value.copyWith(isLoading: true);

      final prefs = await SharedPreferences.getInstance();
      final qrHistory = prefs.getStringList('qr_history') ?? [];
      final barcodeHistory = prefs.getStringList('barcode_history') ?? [];
      List<ScanItem> items = [];

      for (int i = 0; i < qrHistory.length; i++) {
        if (qrHistory[i].isNotEmpty) {
          items.add(
            ScanItem(
              id: 'qr_${DateTime.now().millisecondsSinceEpoch}_$i',
              data: qrHistory[i],
              type: ScanType.qr,
              timestamp: DateTime.now().subtract(Duration(minutes: i * 5)),
            ),
          );
        }
      }

      // Add Barcode history with proper timestamps
      for (int i = 0; i < barcodeHistory.length; i++) {
        if (barcodeHistory[i].isNotEmpty) {
          items.add(
            ScanItem(
              id: 'barcode_${DateTime.now().millisecondsSinceEpoch}_$i',
              data: barcodeHistory[i],
              type: ScanType.barcode,
              timestamp: DateTime.now().subtract(
                Duration(minutes: (qrHistory.length + i) * 5),
              ),
            ),
          );
        }
      }

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state.value = state.value.copyWith(isLoading: false, scanHistory: items);
    } catch (e, stackTrace) {
      state.value = state.value.copyWith(isLoading: false, scanHistory: []);

      Get.snackbar(
        'Error',
        'Failed to load scan history: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: Duration(seconds: 5),
      );
    }
  }

  void onBottomNavTap(int index) {
    state.value = state.value.copyWith(selectedNavIndex: index);
  }

  // Navigation methods that take BuildContext for GoRouter
  void scanBarcode(BuildContext context) {
    context.pushNamed('barcode_scanner');
  }

  void scanQR(BuildContext context) {
    context.pushNamed('qr_scanner');
  }

  void generateBarcode(BuildContext context) {
    context.pushNamed('barcode_generator').then((_) {
      loadScanHistory();
    });
  }

  void generateQR(BuildContext context) {
    context.pushNamed('qr_generator').then((_) {
      loadScanHistory();
    });
  }

  Future<void> deleteScanItem(String id) async {
    try {
      final updatedHistory = List<ScanItem>.from(state.value.scanHistory)
        ..removeWhere((item) => item.id == id);

      state.value = state.value.copyWith(scanHistory: updatedHistory);

      await _syncToSharedPreferences(updatedHistory);

      Get.snackbar(
        'Deleted',
        'Item removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> _syncToSharedPreferences(List<ScanItem> items) async {
    final prefs = await SharedPreferences.getInstance();

    final qrItems =
        items
            .where((item) => item.type == ScanType.qr)
            .map((item) => item.data)
            .toList();

    final barcodeItems =
        items
            .where((item) => item.type == ScanType.barcode)
            .map((item) => item.data)
            .toList();

    await prefs.setStringList('qr_history', qrItems);
    await prefs.setStringList('barcode_history', barcodeItems);
  }

  void copyScanData(String data) {
    Clipboard.setData(ClipboardData(text: data));
    Get.snackbar(
      'Copied',
      'Data copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
    );
  }

  Future<void> downloadImage(GlobalKey key) async {
    try {
      // Request storage permission
      if (!await Permission.storage.request().isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to save images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Cannot access storage directory');
      }

      String fileName =
          '${directory.path}/QR_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(fileName);
      await file.writeAsBytes(pngBytes);

      Get.snackbar(
        'Success',
        'Image saved to gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }
}
