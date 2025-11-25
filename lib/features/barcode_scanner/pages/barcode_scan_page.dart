import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
        title: const Text('Scan Barcode'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: _buildScannerView(context),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildScannerView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 320,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blueAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MobileScanner(
                controller: controller ??= MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  facing: CameraFacing.back,
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && !scanned) {
                    setState(() {
                      scanned = true;
                    });
                    controller?.stop();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Barcode Found'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${barcodes.first.type.name}'),
                            const SizedBox(height: 8),
                            Text('Value: ${barcodes.first.rawValue ?? 'No data'}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                scanned = false;
                              });
                              controller?.start();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Align the barcode within the frame to scan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: () async {
              if (controller != null) {
                await controller!.toggleTorch();
                setState(() {
                  isFlashOn = !(isFlashOn);
                });
              }
            },
            icon: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
            label: Text(isFlashOn ? 'Turn Off Flashlight' : 'Turn On Flashlight'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}