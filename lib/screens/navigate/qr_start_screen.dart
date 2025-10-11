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

    // URL format support: .../n?id=<slug>&heading=<deg>
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      try {
        final uri = Uri.parse(raw);
        final id = uri.queryParameters['id'];
        final headingStr = uri.queryParameters['heading'];
        final map = <String, dynamic>{};
        if (id != null && id.isNotEmpty) map['markerId'] = id;
        if (headingStr != null) {
          final hd = double.tryParse(headingStr);
          if (hd != null) map['yawDeg'] = hd;
        }
        if (map.isNotEmpty) return map;
      } catch (_) {}
    }

    // MARKER_ID:START_A
    if (raw.toUpperCase().contains('MARKER_ID:')) {
      final m = RegExp(r'MARKER_ID:([^;\n]+)', caseSensitive: false).firstMatch(raw);
      if (m != null) {
        final id = m.group(1)!.trim();
        final map = <String, dynamic>{'markerId': id};
        // Optional inline HEADING and POS on the same QR
        final headingM = RegExp(r'HEADING:([^;\n]+)', caseSensitive: false).firstMatch(raw);
        if (headingM != null) {
          final v = double.tryParse(headingM.group(1)!.trim());
          if (v != null) map['yawDeg'] = v;
        }
        final posM = RegExp(r'POS:([^;\n]+)', caseSensitive: false).firstMatch(raw);
        if (posM != null) {
          final parts = posM.group(1)!.split(',').map((e) => double.tryParse(e.trim())).toList();
          if (parts.length == 3 && !parts.any((e) => e == null)) {
            map['pos'] = [parts[0]!, parts[1]!, parts[2]!];
          }
        }
        final roomM = RegExp(r'ROOM:([^;\n]+)', caseSensitive: false).firstMatch(raw);
        if (roomM != null) map['room'] = roomM.group(1)!.trim();
        return map;
      }
    }

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
