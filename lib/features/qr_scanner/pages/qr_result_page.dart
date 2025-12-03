import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QrResultPage extends StatefulWidget {
  const QrResultPage({super.key});

  @override
  State<QrResultPage> createState() => _QrResultPageState();
}

class _QrResultPageState extends State<QrResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Result'),
        centerTitle: true,
        backgroundColor: Color(0xFFFF5F15),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Text('QR Result Page - Under Construction'),
      ),
    );
  }
}