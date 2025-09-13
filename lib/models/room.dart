import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';

@immutable
class Room {
  final String id;
  final String qrCode; // value encoded in the QR
  final String code; // e.g., CL2
  final String name; // e.g., Computer Lab 2
  final String building;
  final int? capacity;
  final String? deptTag;
  final String? qrImagePath; // Path to saved QR code image
  
  // Generate QR code widget for displaying
  Widget get qrCodeWidget => Builder(
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: qrCode,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white,
          ),
        ),
      );
      
  // Generate QR code as image data (for saving)
  Future<Uint8List> generateQrImage() async {
    try {
      final qrPainter = QrPainter(
        data: qrCode,
        version: QrVersions.auto,
        color: const Color(0xFF1E2931),
        emptyColor: Colors.white,
        gapless: true,
      );
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = 200.0;
      
      qrPainter.paint(canvas, Size(size, size));
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating QR code: $e');
      throw Exception('Failed to generate QR code');
    }
  }

  const Room({
    required this.id,
    required this.qrCode,
    required this.code,
    required this.name,
    required this.building,
    this.capacity,
    this.deptTag,
    this.qrImagePath,
  }) : assert(id != null),
       assert(qrCode != null),
       assert(code != null),
       assert(name != null),
       assert(building != null);
  
  Room copyWith({
    String? id,
    String? qrCode,
    String? code,
    String? name,
    String? building,
    String? deptTag,
    String? qrImagePath,
  }) {
    return Room(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      code: code ?? this.code,
      name: name ?? this.name,
      building: building ?? this.building,
      deptTag: deptTag ?? this.deptTag,
      qrImagePath: qrImagePath ?? this.qrImagePath,
    );
  }
}
