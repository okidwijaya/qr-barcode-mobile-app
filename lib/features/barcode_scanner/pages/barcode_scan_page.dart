import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_app/routes/go_router_ad_extension.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  bool isFlashOn = false;
  bool scanned = false;
  MobileScannerController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Barcode',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF5F15),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.popWithAd(),
        ),
      ),
      body: _buildScannerView(context),
      backgroundColor: Colors.grey[50],
    );
  }

  Widget _buildScannerView(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5F15),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 48,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Position barcode within frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Scanner Frame
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFF5F15).withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5F15).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller ??= MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        facing: CameraFacing.back,
                      ),
                      onDetect: _handleBarcodeDetection,
                    ),
                    // Corner decorations
                    _buildCornerDecorations(),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hold steady and align the barcode',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                // Flashlight Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _toggleFlashlight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5F15),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFlashOn ? Icons.flash_off : Icons.flash_on,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isFlashOn ? 'Turn Off Flash' : 'Turn On Flash',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Back Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.popWithAd(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF5F15),
                      side: const BorderSide(
                        color: Color(0xFFFF5F15),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerDecorations() {
    return Stack(
      children: [
        // Top-left corner
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFFFF5F15), width: 4),
                left: BorderSide(color: const Color(0xFFFF5F15), width: 4),
              ),
            ),
          ),
        ),
        // Top-right corner
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFFFF5F15), width: 4),
                right: BorderSide(color: const Color(0xFFFF5F15), width: 4),
              ),
            ),
          ),
        ),
        // Bottom-left corner
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFFFF5F15), width: 4),
                left: BorderSide(color: const Color(0xFFFF5F15), width: 4),
              ),
            ),
          ),
        ),
        // Bottom-right corner
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFFFF5F15), width: 4),
                right: BorderSide(color: const Color(0xFFFF5F15), width: 4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !scanned) {
      setState(() => scanned = true);
      controller?.stop();
      
      HapticFeedback.mediumImpact();
      
      _showBarcodeDialog(barcodes.first);
    }
  }

  void _showBarcodeDialog(Barcode barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Barcode Detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barcode.type.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Value',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barcode.rawValue ?? 'No data',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5F15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => scanned = false);
              controller?.start();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5F15),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Scan Again',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.popWithAd();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5F15),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlashlight() async {
    if (controller != null) {
      await controller!.toggleTorch();
      setState(() => isFlashOn = !isFlashOn);
    }
  }
}