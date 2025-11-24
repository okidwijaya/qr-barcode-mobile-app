import 'package:get/get.dart';
import '../controller/home_state.dart';

class HomeController extends GetxController {
  final state = HomeState().obs;

  @override
  void onInit() {
    super.onInit();
    loadScanHistory();
  }

  void loadScanHistory() {
    // Simulate loading data
    state.value = state.value.copyWith(
      isLoading: false,
      scanHistory: [
        ScanItem(
          id: '1',
          type: ScanType.barcode,
          data: '123456789012',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ),
        ScanItem(
          id: '2',
          type: ScanType.qr,
          data: 'https://example.com',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
        ),
        ScanItem(
          id: '3',
          type: ScanType.barcode,
          data: '987654321098',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
        ),
        ScanItem(
          id: '4',
          type: ScanType.qr,
          data: 'Contact: John Doe +1234567890',
          timestamp: DateTime.now().subtract(Duration(days: 3)),
        ),
      ],
    );
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

  void deleteScanItem(String id) {
    final updatedHistory = List<ScanItem>.from(state.value.scanHistory)
      ..removeWhere((item) => item.id == id);
    
    state.value = state.value.copyWith(scanHistory: updatedHistory);
    
    Get.snackbar(
      'Deleted',
      'Item removed successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void copyScanData(String data) {
    // Copy to clipboard logic here
    Get.snackbar(
      'Copied',
      'Data copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}