import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/department_hours.dart';
import '../../services/department_hours_service.dart';
import '../../widgets/glass_container.dart';

class DepartmentHoursManagementScreen extends StatefulWidget {
  const DepartmentHoursManagementScreen({super.key});

  @override
  State<DepartmentHoursManagementScreen> createState() => _DepartmentHoursManagementScreenState();
}

class _DepartmentHoursManagementScreenState extends State<DepartmentHoursManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient consistent with AdminDashboard
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Department Hours',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _showEditDialog(context),
                        tooltip: 'Add Department/Office',
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: StreamBuilder<List<DepartmentHours>>(
                    stream: DepartmentHoursService.instance.list(),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? const <DepartmentHours>[];
                      if (items.isEmpty) {
                        return Center(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              'No departments yet. Tap + to add.',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: items.length,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemBuilder: (context, index) {
                          final d = items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF63C1E3).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      d.isOffice ? Icons.apartment_rounded : Icons.meeting_room_outlined,
                                      color: const Color(0xFF63C1E3),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d.name,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${d.location}${d.phone != null ? ' • ${d.phone}' : ''}${d.isOffice ? ' • Office' : ''}',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                                    color: Colors.white.withOpacity(0.08),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(color: Colors.white.withOpacity(0.16)),
                                    ),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showEditDialog(context, existing: d);
                                          break;
                                        case 'delete':
                                          _confirmDelete(context, d.id);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(children: [
                                          Icon(Icons.edit, size: 18, color: Colors.white70),
                                          SizedBox(width: 8),
                                          Text('Edit', style: TextStyle(color: Colors.white)),
                                        ]),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(children: [
                                          Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.white)),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: GlassContainer(
          radius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delete Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Are you sure you want to delete this item?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await DepartmentHoursService.instance.delete(id);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(ctx);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    child: const Text('Delete'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showHoursPreview(BuildContext context, DepartmentHours d) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: GlassContainer(
          radius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${d.name} • Today', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 8),
              ...(_todayRanges(d).isEmpty
                  ? const [Text('Closed today', style: TextStyle(color: Colors.white70))]
                  : _todayRanges(d)
                      .map((r) => Text('${r.start} - ${r.end}', style: const TextStyle(color: Colors.white70)))
                      .toList()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<TimeRange> _todayRanges(DepartmentHours d) {
    final idx = DateTime.now().weekday % 7;
    return d.weeklyHours[idx] ?? const <TimeRange>[];
  }

  void _showEditDialog(BuildContext context, {DepartmentHours? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    bool isOffice = existing?.isOffice ?? true;

    // One field per day, comma-separated time ranges as HH:MM-HH:MM
    final dayCtrls = List.generate(7, (i) => TextEditingController());
    if (existing != null) {
      for (var day = 0; day < 7; day++) {
        final ranges = existing.weeklyHours[day] ?? const <TimeRange>[];
        dayCtrls[day].text = ranges.map((r) => '${r.start}-${r.end}').join(',');
      }
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: GlassContainer(
            radius: 16,
            child: StatefulBuilder(
              builder: (ctx2, setModalState) {
                return SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          existing == null ? 'Add Department/Office' : 'Edit Department/Office',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: locationCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Phone (optional)',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: isOffice,
                          onChanged: (v) => setModalState(() => isOffice = v),
                          title: const Text('Is Office (exclude CL rooms)', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Keep on to show in Department Hours list', style: TextStyle(color: Colors.white70)),
                          activeColor: const Color(0xFF63C1E3),
                        ),
                        const SizedBox(height: 12),
                        _HoursEditor(dayCtrls: dayCtrls),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final weekly = <int, List<TimeRange>>{};
                                for (var day = 0; day < 7; day++) {
                                  final text = dayCtrls[day].text.trim();
                                  final ranges = _parseRanges(text);
                                  if (ranges.isNotEmpty) weekly[day] = ranges;
                                }
                                final item = DepartmentHours(
                                  id: existing?.id ?? const Uuid().v4(),
                                  name: nameCtrl.text.trim(),
                                  location: locationCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                                  isOffice: isOffice,
                                  weeklyHours: weekly,
                                );
                                if (existing == null) {
                                  await DepartmentHoursService.instance.create(item);
                                } else {
                                  await DepartmentHoursService.instance.upsert(item);
                                }
                                if (context.mounted) Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF63C1E3),
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: Text(existing == null ? 'Add' : 'Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<TimeRange> _parseRanges(String txt) {
    if (txt.isEmpty) return const <TimeRange>[];
    final parts = txt.split(',');
    final ranges = <TimeRange>[];
    for (final p in parts) {
      final s = p.trim();
      if (s.isEmpty) continue;
      final dash = s.indexOf('-');
      if (dash <= 0 || dash >= s.length - 1) continue;
      final start = s.substring(0, dash).trim();
      final end = s.substring(dash + 1).trim();
      if (_isValidHHMM(start) && _isValidHHMM(end)) {
        ranges.add(TimeRange(start, end));
      }
    }
    return ranges;
  }

  bool _isValidHHMM(String v) {
    final m = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    return m.hasMatch(v);
  }
}

class _HoursEditor extends StatelessWidget {
  const _HoursEditor({required this.dayCtrls});
  final List<TextEditingController> dayCtrls;

  static const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Hours (HH:MM-HH:MM, comma separated)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        for (var i = 0; i < 7; i++) ...[
          TextField(
            controller: dayCtrls[i],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: days[i],
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'e.g. 08:00-12:00,13:00-17:00',
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
