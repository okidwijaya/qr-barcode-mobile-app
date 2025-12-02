import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_app/routes/go_router_ad_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Barcode'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.popWithAd();
          },
        ),
      ),
      body: Padding(
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
              items: _barcodeTypes.keys.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
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
                backgroundColor: Colors.blue[700],
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: RepaintBoundary(
                      key: _barcodeKey,
                      child: BarcodeWidget(
                        barcode: _barcodeTypes[_selectedType]!,
                        data: _barcodeData!,
                        width: 280,
                        height: 120,
                        errorBuilder: (context, error) => Center(
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
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                  color: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text('No barcodes generated yet.'))
                  : ListView.separated(
                      itemCount: _history.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return ListTile(
                          title: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.barcode_reader),
                            onPressed: () {
                              setState(() {
                                _barcodeData = item;
                                _controller.text = item;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
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