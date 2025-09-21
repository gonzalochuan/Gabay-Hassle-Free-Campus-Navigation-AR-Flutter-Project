import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../models/department_hours.dart';
import '../../services/department_hours_service.dart';

class DeptHoursScreen extends StatefulWidget {
  const DeptHoursScreen({super.key});

  @override
  State<DeptHoursScreen> createState() => _DeptHoursScreenState();
}

class _DeptHoursScreenState extends State<DeptHoursScreen> {
  static const Color _accent = Color(0xFF63C1E3);
  List<DepartmentHours> _allDepts = const <DepartmentHours>[];
  String _query = '';
  int _selectedDayIndex = DateTime.now().weekday % 7; // 0=Sun..6=Sat

  List<DepartmentHours> get _filtered {
    final q = _query.trim().toLowerCase();
    final base = _allDepts.where((d) => d.isOffice).toList();
    if (q.isEmpty) return base;
    return base
        .where((d) => d.name.toLowerCase().contains(q) || d.location.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Department Hours'),
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
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search department or office',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < _days.length; i++) ...[
                          _DayChip(
                            label: _days[i],
                            selected: _selectedDayIndex == i,
                            onTap: () => setState(() => _selectedDayIndex = i),
                          ),
                          if (i != _days.length - 1) const SizedBox(width: 8),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Data section
                StreamBuilder<List<DepartmentHours>>(
                  stream: DepartmentHoursService.instance.list(),
                  builder: (context, snapshot) {
                    _allDepts = snapshot.data ?? const <DepartmentHours>[];
                    final list = _filtered;
                    if (list.isEmpty) {
                      return const Center(
                        child: Text('No departments found', style: TextStyle(color: Colors.white70)),
                      );
                    }
                    return Column(
                      children: [
                        for (final dept in list) ...[
                          _DeptCard(
                            dept: dept,
                            dayIndex: _selectedDayIndex,
                            accent: _accent,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptCard extends StatelessWidget {
  const _DeptCard({required this.dept, required this.dayIndex, required this.accent});
  final DepartmentHours dept;
  final int dayIndex; // 0=Sun..6=Sat
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final todayRanges = dept.weeklyHours[dayIndex] ?? const <TimeRange>[];
    final status = _statusFor(todayRanges, DateTime.now());
    final isOpen = status.isOpen;
    final statusText = isOpen ? 'Open now' : 'Closed';
    final statusColor = isOpen ? accent : const Color(0xFFEF4444);

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
                child: const Icon(Icons.apartment_rounded, color: Colors.white),
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
                            dept.name,
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
                              Icon(isOpen ? Icons.access_time : Icons.lock_clock, color: statusColor, size: 16),
                              const SizedBox(width: 6),
                              Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Flexible(child: Text(dept.location, style: const TextStyle(color: Colors.white70))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Today\'s Hours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (todayRanges.isEmpty)
            const Text('Closed today', style: TextStyle(color: Colors.white70))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tr in todayRanges)
                  Text(_formatRange(tr), style: const TextStyle(color: Colors.white70)),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: dept.phone == null ? null : () {},
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text('Call', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                label: const Text('Directions', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  static String _formatRange(TimeRange tr) => '${tr.start} - ${tr.end}';

  static _OpenStatus _statusFor(List<TimeRange> ranges, DateTime now) {
    if (ranges.isEmpty) return const _OpenStatus(false);
    final hm = now.hour * 60 + now.minute;
    for (final r in ranges) {
      final start = _toMinutes(r.start);
      final end = _toMinutes(r.end);
      if (hm >= start && hm < end) return const _OpenStatus(true);
    }
    return const _OpenStatus(false);
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return h * 60 + m;
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sel = selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(sel ? 0.6 : 0.25)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _OpenStatus {
  const _OpenStatus(this.isOpen);
  final bool isOpen;
}

const List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

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
