import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/glass_container.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  String _mode = '2D'; // '2D' | 'AR'

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final h = media.size.height;
    final mapHeight = h * 0.42;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Background(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white70),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search Rooms, Building, Offices',
                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 2D / AR Segmented Toggle
                  Align(
                    alignment: Alignment.centerRight,
                    child: _SegmentedToggle(
                      value: _mode,
                      onChanged: (v) {
                        if (v == 'AR') {
                          // For now keep AR disabled. In future, show permission sheet.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AR prototype coming later. Using 2D for now.')),
                          );
                          return;
                        }
                        setState(() => _mode = v);
                      },
                      arEnabled: false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Recent Destinations
                  const Text('Recent Destinations', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _ChipPill(label: 'MST 220'),
                      _ChipPill(label: 'MST 220'),
                      _ChipPill(label: 'CL 2'),
                      _ChipPill(label: 'CCL 3'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Suggestion', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _ChipPill(label: 'MST 220'),
                      _ChipPill(label: 'CL 9'),
                      _ChipPill(label: 'MST 210'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Google Map (prototype) centered on SEAIT
                  GlassContainer(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      height: mapHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Builder(
                          builder: (context) {
                            // SEAIT approximate coordinates from user's embed
                            const seait = LatLng(6.34654726199553, 124.93617452002388);
                            final you = Marker(
                              markerId: const MarkerId('you'),
                              position: const LatLng(6.34648, 124.93610),
                              infoWindow: const InfoWindow(title: 'You'),
                            );
                            final dest = Marker(
                              markerId: const MarkerId('dest'),
                              position: const LatLng(6.34662, 124.93628),
                              infoWindow: const InfoWindow(title: 'Destination'),
                            );
                            final route = Polyline(
                              polylineId: const PolylineId('route'),
                              color: const Color(0xFF63C1E3),
                              width: 4,
                              points: const [
                                LatLng(6.34648, 124.93610),
                                LatLng(6.34653, 124.93615),
                                LatLng(6.34657, 124.93620),
                                LatLng(6.34660, 124.93625),
                                LatLng(6.34662, 124.93628),
                              ],
                            );
                            return GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: seait,
                                zoom: 19,
                              ),
                              markers: {you, dest},
                              polylines: {route},
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              buildingsEnabled: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bottom Info Sheet (static)
                  GlassContainer(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('To Room MST 20', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text('12 mins · 20m · Destinations distance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.turn_left, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Turn Left  40 mins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({required this.value, required this.onChanged, this.arEnabled = false});
  final String value;
  final ValueChanged<String> onChanged;
  final bool arEnabled;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: '2D',
            selected: value == '2D',
            onTap: () => onChanged('2D'),
          ),
          const SizedBox(width: 4),
          _Segment(
            label: 'AR',
            selected: value == 'AR',
            onTap: arEnabled ? () => onChanged('AR') : null,
            disabled: !arEnabled,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, this.onTap, this.disabled = false});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? const Color(0xFF63C1E3).withOpacity(0.9)
        : Colors.white.withOpacity(disabled ? 0.06 : 0.08);
    final fg = selected
        ? Colors.white
        : Colors.white.withOpacity(disabled ? 0.4 : 0.8);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/image/home_bg.jpg',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
                ),
              ),
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final route = Path();
    // Simple polyline path from bottom-left to top-right with a couple of turns
    route.moveTo(size.width * 0.1, size.height * 0.75);
    route.lineTo(size.width * 0.35, size.height * 0.75);
    route.lineTo(size.width * 0.45, size.height * 0.55);
    route.lineTo(size.width * 0.75, size.height * 0.35);
    route.lineTo(size.width * 0.9, size.height * 0.25);

    final paintRoute = Paint()
      ..color = const Color(0xFF63C1E3).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(route, paintRoute);

    // Start dot (You)
    final start = Offset(size.width * 0.1, size.height * 0.75);
    final startPaint = Paint()..color = Colors.white;
    canvas.drawCircle(start, 8, Paint()..color = const Color(0xFF2B7BE4));
    canvas.drawCircle(start, 4, startPaint);

    // Destination pin (simple)
    final end = Offset(size.width * 0.9, size.height * 0.25);
    final pinPaint = Paint()..color = Colors.black.withOpacity(0.85);
    canvas.drawCircle(end, 6, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
