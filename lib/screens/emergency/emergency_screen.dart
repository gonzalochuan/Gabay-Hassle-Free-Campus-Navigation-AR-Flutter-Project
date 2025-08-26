import 'dart:ui';

import 'package:flutter/material.dart';
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
          const _Background(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Alert banner
                GlassContainer(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _incident == 'Fire'
                              ? Icons.local_fire_department
                              : _incident == 'Earthquake'
                                  ? Icons.vibration
                                  : Icons.emergency_share,
                          color: _appAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _incident == 'Idle' ? 'No active incident' : '$_incident Alert',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _Badge(label: _incident == 'Idle' ? 'Idle' : 'Guidance Ready', color: _incidentColor()),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _incident == 'Idle'
                                  ? 'Select an incident type to get tailored routes and tips.'
                                  : 'Routes adapt based on your location. Avoid elevators and follow staff instructions.',
                              style: TextStyle(color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Incident chips
                Row(
                  children: [
                    _IncidentChip(
                      label: 'Fire',
                      selected: _incident == 'Fire',
                      color: const Color(0xFFEF4444),
                      onTap: () => setState(() {
                        _incident = 'Fire';
                        _guiding = false;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _IncidentChip(
                      label: 'Earthquake',
                      selected: _incident == 'Earthquake',
                      color: const Color(0xFFF59E0B),
                      onTap: () => setState(() {
                        _incident = 'Earthquake';
                        _guiding = false;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _IncidentChip(
                      label: 'Other',
                      selected: _incident == 'Other',
                      color: const Color(0xFF63C1E3),
                      onTap: () => setState(() {
                        _incident = 'Other';
                        _guiding = false;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Map placeholder + CTA
                GlassContainer(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: 220,
                    child: Stack(
                      children: [
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
                            child: const Text(
                              'EMERGENCY MAP HERE',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                        Positioned.fill(child: CustomPaint(painter: _EmergencyRoutePainter())),
                        // YOU dot
                        Positioned(
                          left: 40,
                          bottom: 40,
                          child: _YouDot(),
                        ),
                        // Exit pins
                        const Positioned(right: 24, top: 36, child: _ExitPin(label: 'Exit A')),
                        const Positioned(right: 20, bottom: 28, child: _ExitPin(label: 'Exit B')),
                        // CTA
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _appAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _incident == 'Idle'
                                ? null
                                : () => setState(() {
                                      _guiding = true;
                                    }),
                            child: Text(_guiding ? 'Guidance Active' : 'Start Guidance'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_guiding) ...[
                  // Step-by-step panel
                  GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.navigation_rounded, color: _appAccent),
                            const SizedBox(width: 8),
                            const Text('Step-by-step Guidance',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            TextButton(
                              onPressed: () => setState(() => _guiding = false),
                              child: const Text('End', style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _steps.length; i++) ...[
                          Row(
                            children: [
                              Icon(_steps[i].icon, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _steps[i].text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              if (i == 0) _Badge(label: 'Now', color: _appAccent),
                            ],
                          ),
                          if (i != _steps.length - 1) const Divider(color: Colors.white24, height: 16),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: const Text('Reroute'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: const Text('Pause'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ] else ...[
                  // Nearest exits list
                  const Text('Nearest Exits',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  for (final e in _exits) ...[
                    GlassContainer(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: e.status == 'Blocked'
                                  ? const Color(0xFFEF4444).withOpacity(0.15)
                                  : _appAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              e.status == 'Blocked' ? Icons.block : Icons.exit_to_app,
                              color: e.status == 'Blocked' ? const Color(0xFFEF4444) : _appAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name,
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('${e.floor} • ${e.distanceM}m • ${e.etaMin} min',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          _Badge(
                            label: e.status,
                            color: e.status == 'Blocked' ? const Color(0xFFEF4444) : _appAccent,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
                const SizedBox(height: 12),
                // Safety Tips
                const Text('Safety Tips',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                for (final t in _tips) ...[
                  GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white70),
                        const SizedBox(width: 10),
                        Expanded(child: Text(t, style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                // Contacts
                const Text('Emergency Contacts',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    _ContactButton(label: 'Security', icon: Icons.local_police_outlined),
                    SizedBox(width: 8),
                    _ContactButton(label: 'Clinic', icon: Icons.health_and_safety_outlined),
                    SizedBox(width: 8),
                    _ContactButton(label: '911', icon: Icons.call_outlined),
                  ],
                )
              ],
            ),
          )
        ],
      ),
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
