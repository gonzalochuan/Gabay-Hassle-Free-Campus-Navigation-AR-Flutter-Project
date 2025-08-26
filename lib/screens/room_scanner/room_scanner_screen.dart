import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class RoomScannerScreen extends StatefulWidget {
  const RoomScannerScreen({super.key});

  @override
  State<RoomScannerScreen> createState() => _RoomScannerScreenState();
}

class _RoomScannerScreenState extends State<RoomScannerScreen> {
  static const Color _accent = Color(0xFF63C1E3);

  _RoomInfo? _result; // populated after mock scan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Room Scanner'),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Background(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Text(
                  'Scan a room\'s QR code to view live schedule and availability.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        // Mock camera/scan viewport placeholder
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.06),
                                  Colors.black.withOpacity(0.06),
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text('QR CAMERA VIEW HERE', style: TextStyle(color: Colors.white54)),
                          ),
                        ),
                        // Decorative scan frame
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ScanFramePainter(color: _accent),
                          ),
                        ),
                        // Scan button overlay
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _onScan,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan QR'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_result != null) _ResultCard(info: _result!, accent: _accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onScan() {
    // Simulate a scan decode and load mock data
    setState(() {
      _result = _mockRoomInfo;
    });
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.info, required this.accent});
  final _RoomInfo info;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = _computeStatus(info, now);
    final statusColor = status.isAvailable ? accent : const Color(0xFFEF4444);

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.meeting_room_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${info.roomName} • ${info.roomCode}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(status.isAvailable ? Icons.check_circle : Icons.event_busy, color: statusColor, size: 16),
                              const SizedBox(width: 6),
                              Text(status.isAvailable ? 'Available' : 'Occupied', style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text('Capacity: ${info.capacity}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Current Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (status.current != null)
            _ScheduleTile(item: status.current!, accent: accent, highlight: true)
          else
            const Text('No class or event right now', style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 12),
          const Text('Upcoming', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (info.upcoming.isEmpty)
            const Text('No upcoming classes', style: TextStyle(color: Colors.white70))
          else
            Column(
              children: [
                for (final it in info.upcoming.take(3)) _ScheduleTile(item: it, accent: accent),
              ],
            ),

          const SizedBox(height: 12),
          const Text('Instructor / Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(status.current?.instructor ?? info.defaultInstructor, style: const TextStyle(color: Colors.white70))),
            ],
          ),

          const SizedBox(height: 12),
          const Text('Ongoing Events', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (info.ongoingEvents.isEmpty)
            const Text('None', style: TextStyle(color: Colors.white70))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in info.ongoingEvents)
                  Row(
                    children: [
                      const Icon(Icons.event_note, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e, style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static _ScanStatus _computeStatus(_RoomInfo info, DateTime now) {
    final hm = now.hour * 60 + now.minute;
    _ScheduleItem? current;
    for (final s in info.today) {
      final start = _toMinutes(s.start);
      final end = _toMinutes(s.end);
      if (hm >= start && hm < end) {
        current = s;
        break;
      }
    }
    final isAvailable = current == null;
    return _ScanStatus(isAvailable: isAvailable, current: current);
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return h * 60 + m;
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.item, required this.accent, this.highlight = false});
  final _ScheduleItem item;
  final Color accent;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? accent : Colors.white70;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.start} - ${item.end}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.title, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 2),
                Text(item.instructor, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const radius = 5.0;
    const len = 10.0;

    // corners
    // top-left
    canvas.drawLine(Offset(0, radius), Offset(0, len), paint);
    canvas.drawLine(Offset(radius, 0), Offset(len, 0), paint);
    // top-right
    canvas.drawLine(Offset(size.width, radius), Offset(size.width, len), paint);
    canvas.drawLine(Offset(size.width - radius, 0), Offset(size.width - len, 0), paint);
    // bottom-left
    canvas.drawLine(Offset(0, size.height - radius), Offset(0, size.height - len), paint);
    canvas.drawLine(Offset(radius, size.height), Offset(len, size.height), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width, size.height - radius), Offset(size.width, size.height - len), paint);
    canvas.drawLine(Offset(size.width - radius, size.height), Offset(size.width - len, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanStatus {
  const _ScanStatus({required this.isAvailable, required this.current});
  final bool isAvailable;
  final _ScheduleItem? current;
}

class _RoomInfo {
  const _RoomInfo({
    required this.roomCode,
    required this.roomName,
    required this.capacity,
    required this.today,
    required this.upcoming,
    required this.defaultInstructor,
    required this.ongoingEvents,
  });
  final String roomCode;
  final String roomName;
  final int capacity;
  final List<_ScheduleItem> today;
  final List<_ScheduleItem> upcoming;
  final String defaultInstructor;
  final List<String> ongoingEvents;
}

class _ScheduleItem {
  const _ScheduleItem({required this.start, required this.end, required this.title, required this.instructor});
  final String start;
  final String end;
  final String title;
  final String instructor;
}

// Mock data that a QR might decode to
const _RoomInfo _mockRoomInfo = _RoomInfo(
  roomCode: 'B-204',
  roomName: 'Computer Lab',
  capacity: 32,
  today: [
    _ScheduleItem(start: '07:30', end: '09:00', title: 'CS 101 - Intro to CS', instructor: 'Prof. Santos'),
    _ScheduleItem(start: '09:15', end: '10:45', title: 'IT 205 - Networks', instructor: 'Engr. Cruz'),
    _ScheduleItem(start: '11:00', end: '12:30', title: 'CS 210 - Data Structures', instructor: 'Prof. Dela Cruz'),
    _ScheduleItem(start: '13:30', end: '15:00', title: 'CS 330 - Databases', instructor: 'Prof. Reyes'),
  ],
  upcoming: [
    _ScheduleItem(start: '15:15', end: '16:45', title: 'IT 340 - Security', instructor: 'Engr. Flores'),
    _ScheduleItem(start: '17:00', end: '18:30', title: 'CS 415 - Mobile Dev', instructor: 'Prof. Navarro'),
  ],
  defaultInstructor: 'Department Scheduler',
  ongoingEvents: ['Maintenance check at 6 PM'],
);

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
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
      ],
    );
  }
}
