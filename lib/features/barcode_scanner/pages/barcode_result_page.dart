import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BarcodeResultPage extends StatefulWidget {
  const BarcodeResultPage({super.key});

  @override
  State<BarcodeResultPage> createState() => _BarcodeResultPageState();
}

class _BarcodeResultPageState extends State<BarcodeResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Result'),
        centerTitle: true,
        backgroundColor: Color(0xFFFF5F15),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Text('Barcode Result Page - Under Construction'),
      ),
    );
  }
}