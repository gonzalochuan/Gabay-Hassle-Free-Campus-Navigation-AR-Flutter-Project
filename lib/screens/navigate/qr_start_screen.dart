import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRStartScreen extends StatefulWidget {
  const QRStartScreen({super.key});

  @override
  State<QRStartScreen> createState() => _QRStartScreenState();
}

class _QRStartScreenState extends State<QRStartScreen> {
  bool _handled = false;

  Map<String, dynamic>? _parsePayload(String raw) {
    raw = raw.trim();
    if (raw.isEmpty) return null;

    // ROOM:CL 1
    if (raw.toUpperCase().startsWith('ROOM:')) {
      final room = raw.substring(5).trim();
      if (room.isEmpty) return null;
      return {'room': room};
    }

    // ANCHOR:ID;POS:x,y,z;HEADING:deg
    if (raw.toUpperCase().startsWith('ANCHOR:')) {
      final parts = raw.split(';');
      String? id;
      List<double>? pos;
      double? headingDeg;
      for (final p in parts) {
        final kv = p.split(':');
        if (kv.length < 2) continue;
        final key = kv[0].toUpperCase().trim();
        final val = p.substring(p.indexOf(':') + 1).trim();
        if (key == 'ANCHOR') {
          id = val;
        } else if (key == 'POS') {
          final nums = val.split(',').map((e) => double.tryParse(e.trim())).toList();
          if (nums.length == 3 && !nums.any((e) => e == null)) {
            pos = [nums[0]!, nums[1]!, nums[2]!];
          }
        } else if (key == 'HEADING') {
          headingDeg = double.tryParse(val);
        }
      }
      return {
        if (id != null) 'anchorId': id,
        if (pos != null) 'pos': pos,
        if (headingDeg != null) 'yawDeg': headingDeg,
      };
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        ),
        onDetect: (capture) {
          if (_handled) return;
          final codes = capture.barcodes;
          if (codes.isEmpty) return;
          final raw = codes.first.rawValue;
          if (raw == null) return;
          final data = _parsePayload(raw);
          if (data != null) {
            _handled = true;
            Navigator.of(context).pop(data);
          }
        },
      ),
    );
  }
}
