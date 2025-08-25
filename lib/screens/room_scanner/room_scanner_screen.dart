import 'package:flutter/material.dart';

class RoomScannerScreen extends StatelessWidget {
  const RoomScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Scanner')),
      body: const Center(
        child: Text('QR scan view + result sheet (placeholder)'),
      ),
    );
  }
}
