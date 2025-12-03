import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:qr_app/routes/go_router_ad_extension.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String? _qrData;
  List<String> _history = [];
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('qr_history') ?? [];
    });
  }

  Future<void> _saveToHistory(String data) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.insert(0, data);
      if (_history.length > 20) _history = _history.sublist(0, 20);
    });
    await prefs.setStringList('qr_history', _history);
  }

  Future<void> _downloadQRCode() async {
    if (_qrData == null || _qrData!.isEmpty) return;

    setState(() => _isDownloading = true);

    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage permission denied')),
              );
            }
            setState(() => _isDownloading = false);
            return;
          }
        }
      }

      // Wait for the frame to be rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if the context and render object are available
      if (_qrKey.currentContext == null) {
        throw Exception('QR code not rendered yet');
      }

      // Capture the QR code as image
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Ensure the boundary has been laid out
      if (!boundary.hasSize) {
        throw Exception('QR code not ready for capture');
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List imageBytes = byteData!.buffer.asUint8List();

      // Get the directory to save the file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to access storage')),
          );
        }
        setState(() => _isDownloading = false);
        return;
      }

      // Create QRCodes folder if it doesn't exist
      final qrFolder = Directory('${directory.path}/QRCodes');
      if (!await qrFolder.exists()) {
        await qrFolder.create(recursive: true);
      }

      // Save the file
      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${qrFolder.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code saved to: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving QR code: $e')));
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        centerTitle: true,
        backgroundColor: Color(0xFFFF5F15),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.popWithAd();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter text or link',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _qrData = null);
                    },
                  ),
                ),
                onSubmitted: (value) => _generateQR(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateQR,
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF5F15),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_qrData != null && _qrData!.isNotEmpty)
                Column(
                  children: [
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _qrData!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _downloadQRCode,
                      icon:
                          _isDownloading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.download),
                      label: Text(
                        _isDownloading ? 'Downloading...' : 'Download',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5F15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child:
                    _history.isEmpty
                        ? const Center(
                          child: Text('No QR codes generated yet.'),
                        )
                        : ListView.separated(
                          itemCount: _history.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      _qrData = item;
                                      _controller.text = item;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Icon container with background
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.qr_code_2,
                                            color: Colors.blue.shade700,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'QR Code',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Arrow icon
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateQR() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _qrData = text;
      });
      _saveToHistory(text);
    }
  }
}
