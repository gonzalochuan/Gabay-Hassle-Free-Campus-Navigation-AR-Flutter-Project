import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';

class RoomScannerScreen extends StatefulWidget {
  const RoomScannerScreen({super.key});

  @override
  State<RoomScannerScreen> createState() => _RoomScannerScreenState();
}

class _RoomScannerScreenState extends State<RoomScannerScreen> {
  static const Color _accent = Color(0xFF63C1E3);

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  bool _locked = false; // lock after a successful read
  Room? _room;
  List<ScheduleEntry> _today = const [];
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_locked) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;
    final value = codes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _locked = true);

    // Try cached rooms first, then fallback to an on-demand fetch
    Room? room = RoomService.instance.findByQr(value);
    if (room == null) {
      try {
        await RoomService.instance.listAll();
        room = RoomService.instance.findByQr(value);
      } catch (_) {
        // ignore and handle as not found below
      }
      if (room == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room not found for this QR'), backgroundColor: Colors.red),
          );
        }
        setState(() => _locked = false);
        return;
      }
    }

    // Fetch today's schedule using room.code (matches ScheduleService mock data)
    final entries = ScheduleService.instance.listByRoomForToday(room.code);
    if (mounted) {
      setState(() {
        _room = room;
        _today = entries;
      });
    }
  }

  void _reset() {
    setState(() {
      _locked = false;
      _room = null;
      _today = const [];
    });
  }

  String _fmt(DateTime t) => DateFormat.jm().format(t);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Room Scanner'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Background(),
          if (_room == null)
            _buildScanner()
          else
            SafeArea(child: _buildResult()),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        Positioned.fill(
          child: MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
        ),
        Positioned(
          bottom: 16 + (MediaQuery.of(context).padding.bottom),
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                'Scan a room QR code',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await _scannerController.toggleTorch();
                  setState(() {
                    _torchOn = !_torchOn;
                  });
                },
                icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
                label: const Text('Flash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  _room!.name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_room!.code}'
                  '${_room!.building != null ? ' • ${_room!.building}' : ''}'
                  '${_room!.deptTag != null ? ' • ${_room!.deptTag}' : ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
                // Capacity removed (no capacity in Room spec)
                const SizedBox(height: 12),
                const Text("Today's Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (_today.isEmpty)
                  const Text('No entries for today', style: TextStyle(color: Colors.white70))
                else
                  Column(
                    children: [
                      for (final e in _today)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withOpacity(0.16)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule, color: Colors.white70, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${_fmt(e.start)} - ${_fmt(e.end)}', style: const TextStyle(color: Colors.white70)),
                                        const SizedBox(height: 2),
                                        Text(e.title, style: const TextStyle(color: Colors.white)),
                                        const SizedBox(height: 2),
                                        Text(e.instructor, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _reset,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Scan another room'),
          )
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
            ),
          ),
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
      ],
    );
  }
}
