import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../models/department_hours.dart';
import '../../services/department_hours_service.dart';
import '../../services/booking_service.dart';

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
  // Booking form state
  bool _showBooking = false;
  String _facility = 'AVR';
  DateTime? _bookingDate = DateTime.now();
  TimeOfDay? _bookingStart;
  TimeOfDay? _bookingEnd;
  final _purposeCtrl = TextEditingController();
  final _attendeesCtrl = TextEditingController();

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _attendeesCtrl.dispose();
    super.dispose();
  }

  List<DepartmentHours> get _filtered {
    final q = _query.trim().toLowerCase();
    final base = _allDepts.where((d) => d.isOffice).toList();
    if (q.isEmpty) return base;
    return base
        .where((d) => d.name.toLowerCase().contains(q) || d.location.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _showBookingDialog(BuildContext context) async {
    String facility = 'AVR';
    DateTime? date = DateTime.now();
    TimeOfDay? start;
    TimeOfDay? end;
    final purposeCtrl = TextEditingController();
    final attendeesCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E2931),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (ctx, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Book Facility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: facility,
                      dropdownColor: const Color(0xFF1E2931),
                      items: const [
                        DropdownMenuItem(value: 'AVR', child: Text('AVR', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'GYM', child: Text('GYM', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (v) => setState(() => facility = v ?? 'AVR'),
                      decoration: InputDecoration(
                        labelText: 'Facility',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pick = await showDatePicker(
                              context: ctx,
                              initialDate: date ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF63C1E3), surface: Color(0xFF1E2931), onSurface: Colors.white)),
                                child: child!,
                              ),
                            );
                            if (pick != null) setState(() => date = pick);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              date == null ? 'Pick date' : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(timePickerTheme: const TimePickerThemeData(backgroundColor: Color(0xFF1E2931)), colorScheme: const ColorScheme.dark(primary: Color(0xFF63C1E3), surface: Color(0xFF1E2931), onSurface: Colors.white)),
                                child: child!,
                              ),
                            );
                            if (t != null) setState(() => start = t);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(start == null ? 'Start time' : start!.format(ctx), style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: TimeOfDay.now(),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(timePickerTheme: const TimePickerThemeData(backgroundColor: Color(0xFF1E2931)), colorScheme: const ColorScheme.dark(primary: Color(0xFF63C1E3), surface: Color(0xFF1E2931), onSurface: Colors.white)),
                                child: child!,
                              ),
                            );
                            if (t != null) setState(() => end = t);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(end == null ? 'End time' : end!.format(ctx), style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    TextField(
                      controller: purposeCtrl,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Purpose',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: attendeesCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Attendees (optional)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (date == null || start == null || end == null || purposeCtrl.text.trim().isEmpty) return;
                            String s(String t) => t.padLeft(2, '0');
                            final st = '${s(start!.hour.toString())}:${s(start!.minute.toString())}';
                            final et = '${s(end!.hour.toString())}:${s(end!.minute.toString())}';
                            final attendees = int.tryParse(attendeesCtrl.text.trim());
                            try {
                              await BookingService.instance.create(
                                facility: facility,
                                date: date!,
                                startTime: st,
                                endTime: et,
                                purpose: purposeCtrl.text.trim(),
                                attendees: attendees,
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(ctx);
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking submitted')));
                            } catch (e) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF63C1E3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Submit'),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _showBooking = !_showBooking),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.25)),
                              ),
                              child: const Icon(Icons.event_available, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text('Book Facility (AVR / GYM)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                            Icon(_showBooking ? Icons.expand_less : Icons.expand_more, color: Colors.white70),
                          ],
                        ),
                      ),
                      if (_showBooking) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _facility,
                          dropdownColor: const Color(0xFF1E2931),
                          items: const [
                            DropdownMenuItem(value: 'AVR', child: Text('AVR', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'GYM', child: Text('GYM', style: TextStyle(color: Colors.white))),
                          ],
                          onChanged: (v) => setState(() => _facility = v ?? 'AVR'),
                          decoration: InputDecoration(
                            labelText: 'Facility',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final pick = await showDatePicker(
                                  context: context,
                                  initialDate: _bookingDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (c, child) => Theme(
                                    data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF63C1E3), surface: Color(0xFF1E2931), onSurface: Colors.white)),
                                    child: child!,
                                  ),
                                );
                                if (pick != null) setState(() => _bookingDate = pick);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  _bookingDate == null ? 'Pick date' : '${_bookingDate!.year}-${_bookingDate!.month.toString().padLeft(2, '0')}-${_bookingDate!.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (c, child) => Theme(
                                    data: Theme.of(c).copyWith(timePickerTheme: const TimePickerThemeData(backgroundColor: Color(0xFF1E2931)), colorScheme: const ColorScheme.dark(primary: Color(0xFF63C1E3), surface: Color(0xFF1E2931), onSurface: Colors.white)),
                                    child: child!,
                                  ),
                                );
                                if (t != null) setState(() => _bookingStart = t);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                child: Text(_bookingStart == null ? 'Start time' : _bookingStart!.format(context), style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder: (c, child) => Theme(
                                    data: Theme.of(c).copyWith(timePickerTheme: const TimePickerThemeData(backgroundColor: Color(0xFF1E2931)), colorScheme: const ColorScheme.dark(primary: Color(0xFF63C1E3), surface: Color(0xFF1E2931), onSurface: Colors.white)),
                                    child: child!,
                                  ),
                                );
                                if (t != null) setState(() => _bookingEnd = t);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                child: Text(_bookingEnd == null ? 'End time' : _bookingEnd!.format(context), style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _purposeCtrl,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: 'Purpose',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _attendeesCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: 'Attendees (optional)',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_bookingDate == null || _bookingStart == null || _bookingEnd == null || _purposeCtrl.text.trim().isEmpty) return;
                              String s2(int v) => v.toString().padLeft(2, '0');
                              final st = '${s2(_bookingStart!.hour)}:${s2(_bookingStart!.minute)}';
                              final et = '${s2(_bookingEnd!.hour)}:${s2(_bookingEnd!.minute)}';
                              final startMinutes = _bookingStart!.hour * 60 + _bookingStart!.minute;
                              final endMinutes = _bookingEnd!.hour * 60 + _bookingEnd!.minute;
                              if (startMinutes >= endMinutes) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start time must be before end time.')));
                                return;
                              }
                              final attendees = int.tryParse(_attendeesCtrl.text.trim());
                              try {
                                await BookingService.instance.create(
                                  facility: _facility,
                                  date: _bookingDate!,
                                  startTime: st,
                                  endTime: et,
                                  purpose: _purposeCtrl.text.trim(),
                                  attendees: attendees,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking submitted')));
                                setState(() {
                                  _showBooking = false;
                                  _facility = 'AVR';
                                  _bookingDate = DateTime.now();
                                  _bookingStart = null;
                                  _bookingEnd = null;
                                  _purposeCtrl.clear();
                                  _attendeesCtrl.clear();
                                });
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Submit Booking'),
                          ),
                        ),
                      ],
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
