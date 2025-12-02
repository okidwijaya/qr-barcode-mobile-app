import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import './home_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final state = HomeState().obs;

  @override
  void onInit() {
    super.onInit();
    loadScanHistory();
  }

  Future<void> loadScanHistory() async {
    state.value = state.value.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final qrHistory = prefs.getStringList('qr_history') ?? [];
      final barcodeHistory = prefs.getStringList('barcode_history') ?? [];

      List<ScanItem> items = [];

      for (int i = 0; i < qrHistory.length; i++) {
        items.add(
          ScanItem(
            id: 'qr_${DateTime.now().millisecondsSinceEpoch}_$i',
            data: qrHistory[i],
            type: ScanType.qr,
            timestamp: DateTime.now().subtract(Duration(minutes: i * 30)),
          ),
        );
      }

      for (int i = 0; i < barcodeHistory.length; i++) {
        items.add(
          ScanItem(
            id: 'barcode_${DateTime.now().millisecondsSinceEpoch}_$i',
            data: barcodeHistory[i],
            type: ScanType.barcode,
            timestamp: DateTime.now().subtract(
              Duration(minutes: (i + qrHistory.length) * 30),
            ),
          ),
        );
      }

      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      state.value = state.value.copyWith(isLoading: false, scanHistory: items);
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false);
      Get.snackbar(
        'Error',
        'Failed to load scan history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void onBottomNavTap(int index) {
    state.value = state.value.copyWith(selectedNavIndex: index);
    if (index == 0) {
      scanBarcode();
    } else if (index == 1) {
      scanQR();
    }
  }

  void scanBarcode() {
    Get.snackbar(
      'Scan Barcode',
      'Opening Barcode Scanner...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void scanQR() {
    Get.snackbar(
      'Scan QR',
      'Opening QR Scanner...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void generateBarcode() {
    Get.snackbar(
      'Generate Barcode',
      'Opening Barcode Generator...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void generateQR() {
    Get.snackbar(
      'Generate QR',
      'Opening QR Generator...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
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
}
