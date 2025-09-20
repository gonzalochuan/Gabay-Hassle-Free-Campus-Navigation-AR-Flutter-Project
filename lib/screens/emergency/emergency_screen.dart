import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widgets/glass_container.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const Color _appAccent = Color(0xFF63C1E3);
  String _incident = 'Idle'; // Idle | Fire | Earthquake | Other
  bool _guiding = false;

  // Camera controller for AR-only preview
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    torchEnabled: false,
    facing: CameraFacing.back,
  );

  // Currently selected exit to guide to (by name)
  String? _targetExitName;

  // Mock data
  final List<_ExitItem> _exits = const [
    _ExitItem(name: 'Exit A - North Stairwell', floor: '1F', distanceM: 45, etaMin: 1, status: 'Open'),
    _ExitItem(name: 'Exit B - East Gate', floor: 'G', distanceM: 80, etaMin: 2, status: 'Open'),
    _ExitItem(name: 'Exit C - West Ramp', floor: 'G', distanceM: 120, etaMin: 3, status: 'Blocked'),
  ];

  final List<_StepItem> _steps = const [
    _StepItem(text: 'Go straight for 20m', icon: Icons.straighten),
    _StepItem(text: 'Turn left at corridor', icon: Icons.turn_left),
    _StepItem(text: 'Take the stairs down', icon: Icons.stairs),
    _StepItem(text: 'Exit through North Stairwell', icon: Icons.outbond),
  ];

  List<String> get _tips {
    switch (_incident) {
      case 'Fire':
        return const [
          'Stay low and cover your nose/mouth.',
          'Do not use elevators.',
          'Check doors for heat before opening.',
        ];
      case 'Earthquake':
        return const [
          'Drop, Cover, and Hold On.',
          'Stay away from windows.',
          'After shaking stops, proceed calmly to nearest exit.',
        ];
      default:
        return const [
          'Remain calm and follow the marked route.',
          'Assist others if safe to do so.',
        ];
    }
  }

  Color _incidentColor() {
    switch (_incident) {
      case 'Fire':
        return const Color(0xFFEF4444);
      case 'Earthquake':
        return const Color(0xFFF59E0B);
      default:
        return _appAccent;
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Emergency'),
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.shield_outlined),
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // AR-only: live camera preview
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
            ),
          ),
          // AR overlay
          Positioned.fill(
            child: _EmergencyArOverlay(
              incident: _incident,
              exits: _exits,
              steps: _steps,
              tips: _tips,
              accent: _appAccent,
              onIncidentChange: (i) => setState(() => _incident = i),
              selectedExitName: _targetExitName,
              onSelectExit: (name) => setState(() => _targetExitName = name),
              onClearTarget: () => setState(() => _targetExitName = null),
              onShowTips: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) {
                  final items = _tips.take(3).toList();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Wrap(
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Safety Tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 8),
                              for (final t in items) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(t, style: const TextStyle(color: Colors.white))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple AR route painter: draws a smooth path from bottom center upward to suggest direction
class _ArRoutePainter extends CustomPainter {
  _ArRoutePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final start = Offset(size.width * 0.5, size.height * 0.85);
    final mid1 = Offset(size.width * 0.5, size.height * 0.6);
    final mid2 = Offset(size.width * 0.6, size.height * 0.35);
    final end = Offset(size.width * 0.65, size.height * 0.18);

    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      start.dx, start.dy - 80,
      mid1.dx + 40, mid1.dy - 60,
      mid1.dx + 20, mid1.dy - 40,
    );
    path.quadraticBezierTo(mid2.dx - 10, mid2.dy, end.dx, end.dy);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    // Draw arrow head at end
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const arrowSize = 10.0;
    final arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(end.dx - arrowSize, end.dy + arrowSize * 1.6);
    arrowPath.lineTo(end.dx + arrowSize, end.dy + arrowSize * 1.6);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Subtle dashed halo
    final dash = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, dash);
  }

  @override
  bool shouldRepaint(covariant _ArRoutePainter oldDelegate) => oldDelegate.color != color;
}

class _EmergencyArOverlay extends StatelessWidget {
  const _EmergencyArOverlay({
    required this.incident,
    required this.exits,
    required this.steps,
    required this.tips,
    required this.accent,
    required this.onIncidentChange,
    required this.selectedExitName,
    required this.onSelectExit,
    required this.onClearTarget,
    required this.onShowTips,
  });

  final String incident;
  final List<_ExitItem> exits;
  final List<_StepItem> steps;
  final List<String> tips;
  final Color accent;
  final ValueChanged<String> onIncidentChange;
  final String? selectedExitName;
  final ValueChanged<String> onSelectExit;
  final VoidCallback onClearTarget;
  final VoidCallback onShowTips;

  @override
  Widget build(BuildContext context) {
    final Color incidentColor = incident == 'Fire'
        ? const Color(0xFFEF4444)
        : (incident == 'Earthquake' ? const Color(0xFFF59E0B) : accent);
    // Determine nearest open exit
    final List<_ExitItem> openExits = exits.where((e) => e.status.toLowerCase() != 'blocked').toList();
    _ExitItem? nearest;
    if (openExits.isNotEmpty) {
      nearest = openExits.reduce((a, b) => a.distanceM <= b.distanceM ? a : b);
    }
    final bool isNear = nearest != null && nearest.distanceM <= 20;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Center guidance arrow and text
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_arrow_up_rounded, size: 96, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                incident == 'Idle'
                    ? 'Select an incident'
                    : (selectedExitName == null
                        ? 'Pick an exit to guide'
                        : 'Guiding to $selectedExitName...'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              if (selectedExitName != null) ...[
                const SizedBox(height: 6),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.assistant_navigation, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      const Text('Head straight for 20m', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onClearTarget,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Text('Clear', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
        // Top controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incident chips (switch within AR)
                  Row(
                    children: [
                      _IncidentChip(
                        label: 'Fire',
                        selected: incident == 'Fire',
                        color: const Color(0xFFEF4444),
                        onTap: () => onIncidentChange('Fire'),
                      ),
                      const SizedBox(width: 8),
                      _IncidentChip(
                        label: 'Earthquake',
                        selected: incident == 'Earthquake',
                        color: const Color(0xFFF59E0B),
                        onTap: () => onIncidentChange('Earthquake'),
                      ),
                      const SizedBox(width: 8),
                      _IncidentChip(
                        label: 'Other',
                        selected: incident == 'Other',
                        color: const Color(0xFF63C1E3),
                        onTap: () => onIncidentChange('Other'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Header controls row (status, Tips, Nearest Exit)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: incidentColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              incident == 'Idle' ? 'No Incident' : '$incident Mode',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onShowTips,
                        borderRadius: BorderRadius.circular(12),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.tips_and_updates, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (nearest != null)
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_walk,
                                color: isNear ? const Color(0xFF10B981) : Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => onSelectExit(nearest!.name.split(' - ').first),
                                child: Text(
                                  '${nearest!.name.split(' - ').first} • ${nearest.distanceM}m • ${nearest.etaMin} min',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isNear ? const Color(0xFF10B981) : Colors.white24).withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Text(
                                  isNear ? 'Near' : 'Far',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 8),
                  // Quick exits row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final e in exits)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    e.status == 'Blocked' ? Icons.block : Icons.exit_to_app,
                                    color: e.status == 'Blocked'
                                        ? const Color(0xFFEF4444)
                                        : (selectedExitName == e.name.split(' - ').first
                                            ? const Color(0xFF10B981)
                                            : Colors.white),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: e.status == 'Blocked' ? null : () => onSelectExit(e.name.split(' - ').first),
                                    child: Text(
                                      e.name.split(' - ').first,
                                      style: TextStyle(
                                        color: selectedExitName == e.name.split(' - ').first
                                            ? const Color(0xFF10B981)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // (Nearest exit indicator moved into header row above)
                ],
              ),
            ),
          ),
        ),
        // Bottom step card
        Positioned(
          left: 12,
          right: 12,
          bottom: 16,
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(steps.first.icon, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    steps.first.text,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: incidentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Text('Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IncidentChip extends StatelessWidget {
  const _IncidentChip({required this.label, required this.selected, required this.color, required this.onTap});
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = selected ? color : Colors.white.withOpacity(0.2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tint.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: selected ? color : Colors.white54, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _ExitItem {
  final String name;
  final String floor;
  final int distanceM;
  final int etaMin;
  final String status;
  const _ExitItem({required this.name, required this.floor, required this.distanceM, required this.etaMin, required this.status});
}

class _StepItem {
  final String text;
  final IconData icon;
  const _StepItem({required this.text, required this.icon});
}

class _ExitPin extends StatelessWidget {
  const _ExitPin({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(height: 6),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
        )
      ],
    );
  }
}

class _YouDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF63C1E3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
          ),
        ),
        const SizedBox(height: 4),
        const Text('YOU', style: TextStyle(color: Colors.white70, fontSize: 12))
      ],
    );
  }
}

class _EmergencyRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF63C1E3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(40, size.height - 40);
    path.lineTo(size.width * 0.35, size.height * 0.55);
    path.quadraticBezierTo(size.width * 0.55, size.height * 0.35, size.width - 30, 40);
    canvas.drawPath(path, paint);

    final dashPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dashPath = Path();
    dashPath.addPath(path, Offset.zero);
    // Simple dashed overlay effect by stroking path multiple times with alpha
    canvas.drawPath(dashPath, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
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
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
      ],
    );
  }
}
