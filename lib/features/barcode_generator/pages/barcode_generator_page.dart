import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_app/routes/go_router_ad_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeGeneratorPage extends StatefulWidget {
  const BarcodeGeneratorPage({super.key});

  @override
  State<BarcodeGeneratorPage> createState() => _BarcodeGeneratorPageState();
}

class _BarcodeGeneratorPageState extends State<BarcodeGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _barcodeKey = GlobalKey();
  String? _barcodeData;
  List<String> _history = [];
  String _selectedType = 'Code 128';
  bool _isDownloading = false;

  final Map<String, Barcode> _barcodeTypes = {
    'Code 128': Barcode.code128(),
    'Code 39': Barcode.code39(),
    'Code 93': Barcode.code93(),
    'EAN-13': Barcode.ean13(),
    'EAN-8': Barcode.ean8(),
    'UPC-A': Barcode.upcA(),
    'UPC-E': Barcode.upcE(),
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('barcode_history') ?? [];
    });
  }

  Future<void> _saveToHistory(String data) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.insert(0, data);
      if (_history.length > 20) _history = _history.sublist(0, 20);
    });
    await prefs.setStringList('barcode_history', _history);
  }

  Future<void> _downloadBarcode() async {
    if (_barcodeData == null || _barcodeData!.isEmpty) return;

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
      if (_barcodeKey.currentContext == null) {
        throw Exception('Barcode not rendered yet');
      }

      // Capture the barcode as image
      RenderRepaintBoundary boundary =
          _barcodeKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Ensure the boundary has been laid out
      if (!boundary.hasSize) {
        throw Exception('Barcode not ready for capture');
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

      // Create Barcodes folder if it doesn't exist
      final barcodeFolder = Directory('${directory.path}/Barcodes');
      if (!await barcodeFolder.exists()) {
        await barcodeFolder.create(recursive: true);
      }

      // Save the file
      final fileName = 'barcode_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${barcodeFolder.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode saved to: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving barcode: $e')));
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Barcode'),
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
                  labelText: 'Enter text or number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _barcodeData = null);
                    },
                  ),
                ),
                onSubmitted: (value) => _generateBarcode(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Barcode Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _barcodeTypes.keys.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      if (_barcodeData != null) {
                        _generateBarcode();
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateBarcode,
                icon: const Icon(Icons.barcode_reader),
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
              if (_barcodeData != null && _barcodeData!.isNotEmpty)
                Column(
                  children: [
                    RepaintBoundary(
                      key: _barcodeKey,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: BarcodeWidget(
                          barcode: _barcodeTypes[_selectedType]!,
                          data: _barcodeData!,
                          width: 280,
                          height: 120,
                          errorBuilder:
                              (context, error) => Center(
                                child: Text(
                                  'Invalid data for $_selectedType',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _barcodeData!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _selectedType,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _downloadBarcode,
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
                          child: Text('No barcodes generated yet.'),
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
                                      _barcodeData = item;
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
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.orange.shade700,
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
                                                'Barcode',
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

  void _generateBarcode() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _barcodeData = text;
      });
      _saveToHistory(text);
    }
  }
}
