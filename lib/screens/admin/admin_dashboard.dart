import 'dart:ui';
import 'package:Gabay/models/room.dart';

import 'package:flutter/material.dart';
import 'room_management_screen_new.dart';
import 'department_hours_management_screen.dart';
import 'package:flutter/foundation.dart';
import '../../services/news_service.dart';
import '../../models/news.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import 'user_management_screen.dart';
import 'booking_management_screen.dart';
import '../room_scanner/room_scanner_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF63C1E3).withOpacity(0.9) : Colors.white.withOpacity(0.10);
    final fg = selected ? Colors.white : Colors.white.withOpacity(0.85);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  // Announcement options
  String _scope = 'all'; // 'all' or 'building'
  String? _deptTag; // when scope == 'building'
  bool _scheduleEnabled = false;
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    await NewsService.instance.publish(
      type: PostType.announcement,
      title: title,
      body: body.isEmpty ? null : body,
      deptTag: _scope == 'building' ? (_deptTag?.trim().isEmpty == true ? null : _deptTag?.trim()) : null,
      scheduledAt: _scheduleEnabled ? _scheduledAt : null,
    );
    _titleCtrl.clear();
    _bodyCtrl.clear();
    setState(() {
      _scope = 'all';
      _deptTag = null;
      _scheduleEnabled = false;
      _scheduledAt = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.meeting_room), text: 'Room Management'),
              Tab(icon: Icon(Icons.apartment_rounded), text: 'Department Hours'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: const Color(0xFF63C1E3),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _Background(),
            TabBarView(
              children: [
                // Dashboard Tab
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAdminContent(),
                  ),
                ),
                // Room Management Tab
                const RoomManagementScreen(),
                // Department Hours Tab
                const DepartmentHoursManagementScreen(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GlassPanel(
          title: 'Announcements',
          subtitle: 'Broadcast important updates to all users',
          child: Column(
            children: [
              _NewsComposerCard(
                titleCtrl: _titleCtrl,
                bodyCtrl: _bodyCtrl,
                scope: _scope,
                deptTag: _deptTag,
                scheduleEnabled: _scheduleEnabled,
                scheduledAt: _scheduledAt,
                onScopeChanged: (v) => setState(() => _scope = v),
                onDeptTagChanged: (v) => setState(() => _deptTag = v),
                onScheduleEnabledChanged: (v) => setState(() => _scheduleEnabled = v),
                onScheduledAtChanged: (v) => setState(() => _scheduledAt = v),
                onPublish: _handlePublish,
              ),
              const SizedBox(height: 16),
              const _PostsList(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _GlassPanel(
          title: 'Quick Actions',
          subtitle: 'Frequently used admin tasks',
          child: Column(
            children: [
              _ActionButton(
                icon: Icons.people,
                label: 'User Management',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserManagementScreen(),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white24, height: 32),
              _ActionButton(
                icon: Icons.event_available,
                label: 'Booking Management',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BookingManagementScreen(),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white24, height: 32),
              _ActionButton(
                icon: Icons.qr_code,
                label: 'Scan Room QR',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RoomScannerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.title, required this.subtitle, required this.child, this.height});
  final String title;
  final String subtitle;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF63C1E3).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dashboard, color: Color(0xFF63C1E3), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _NewsComposerCard extends StatelessWidget {
  const _NewsComposerCard({
    required this.titleCtrl,
    required this.bodyCtrl,
    required this.onPublish,
    required this.scope,
    required this.deptTag,
    required this.scheduleEnabled,
    required this.scheduledAt,
    required this.onScopeChanged,
    required this.onDeptTagChanged,
    required this.onScheduleEnabledChanged,
    required this.onScheduledAtChanged,
  });
  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;
  final VoidCallback onPublish;
  final String scope;
  final String? deptTag;
  final bool scheduleEnabled;
  final DateTime? scheduledAt;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<String?> onDeptTagChanged;
  final ValueChanged<bool> onScheduleEnabledChanged;
  final ValueChanged<DateTime?> onScheduledAtChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleCtrl,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Title (e.g., Room changes, Events, Closures) ',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: bodyCtrl,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Message body…',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 10),
        // Scope & schedule controls
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SelectableChip(
              label: 'All Campus',
              selected: scope == 'all',
              onTap: () => onScopeChanged('all'),
            ),
            _SelectableChip(
              label: 'By Building',
              selected: scope == 'building',
              onTap: () => onScopeChanged('building'),
            ),
            _SelectableChip(
              label: 'Schedule',
              selected: scheduleEnabled,
              onTap: () => onScheduleEnabledChanged(!scheduleEnabled),
            ),
          ],
        ),
        if (scope == 'building') ...[
          const SizedBox(height: 10),
          TextField(
            controller: TextEditingController(text: deptTag ?? ''),
            onChanged: onDeptTagChanged,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Building/Department tag (e.g., MST, Registrar)',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
        if (scheduleEnabled) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Text(
                scheduledAt == null
                    ? 'No schedule set'
                    : 'Scheduled: '
                      '${scheduledAt!.toLocal().toString().substring(0, 16)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now.subtract(const Duration(days: 0)),
                  lastDate: now.add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF63C1E3),
                        surface: Color(0xFF1E2931),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (date == null) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      timePickerTheme: const TimePickerThemeData(
                        backgroundColor: Color(0xFF1E2931),
                      ),
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF63C1E3),
                        surface: Color(0xFF1E2931),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (time == null) return;
                final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                onScheduledAtChanged(dt.toUtc());
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Pick time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF63C1E3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onPublish,
            icon: const Icon(Icons.send),
            label: const Text('Publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63C1E3),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          ),
        )
      ],
    );
  }
}

class _PostsList extends StatelessWidget {
  const _PostsList();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NewsPost>>(
      stream: NewsService.instance.feed(),
      builder: (context, snapshot) {
        final posts = snapshot.data ?? const <NewsPost>[];
        if (posts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Text(
              'No posts yet. Publish an announcement to see it here.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return Column(
          children: [
            for (final p in posts)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined, color: Colors.white70, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            if (p.pinned)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.push_pin, size: 16, color: Colors.white70),
                              ),
                            Expanded(
                              child: Text(
                                p.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 2),
                          Text(
                            describeEnum(p.type).toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => NewsService.instance.togglePin(p.id),
                      icon: Icon(p.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.white70, size: 18),
                      tooltip: p.pinned ? 'Unpin' : 'Pin',
                    ),
                    IconButton(
                      onPressed: () => NewsService.instance.delete(p.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 18),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PostsListPlaceholder extends StatelessWidget {
  const _PostsListPlaceholder();
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Computer Lab Close Sunday', 'Scheduled • Posted 10:05 AM'),
      ('Computer Lab Close Sunday', 'Scheduled • Today 5:00 PM'),
      ('Intramurals 2025', 'Scheduled • Yesterday 8:00 AM'),
    ];
    return Column(
      children: [
        for (final item in items)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.article_outlined, color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.$2, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 18),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BroadcastPlaceholder extends StatelessWidget {
  const _BroadcastPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _ChipButton(label: 'All Users'),
            _ChipButton(label: 'By Department'),
            _ChipButton(label: 'By Year Level'),
            _ChipButton(label: 'By Building'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Test device ID or email for preview…',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.14),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text('Send Test'),
            )
          ],
        )
      ],
    );
  }
}

class _AnalyticsPlaceholder extends StatelessWidget {
  const _AnalyticsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _MetricCard(title: 'Views', value: '12.4k')),
        SizedBox(width: 8),
        Expanded(child: _MetricCard(title: 'Clicks', value: '3.1k')),
        SizedBox(width: 8),
        Expanded(child: _MetricCard(title: 'Delivery', value: '98%')),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}

class _UsersPanel extends StatelessWidget {
  const _UsersPanel();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Add User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.14),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AppUser>>(
          stream: UserService.instance.list(),
          builder: (context, snap) {
            final users = snap.data ?? const <AppUser>[];
            if (users.isEmpty) {
              return const Text('No users yet', style: TextStyle(color: Colors.white70));
            }
            return Column(
              children: [
                for (final u in users)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.account_circle, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            Text('${u.email} • ${describeEnum(u.role)}${u.active ? '' : ' (inactive)'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Toggle Role',
                        onPressed: () => UserService.instance.toggleRole(u.id),
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.white70),
                      ),
                      IconButton(
                        tooltip: 'Deactivate',
                        onPressed: u.active ? () => UserService.instance.deactivate(u.id) : null,
                        icon: const Icon(Icons.person_off_outlined, color: Colors.white70),
                      ),
                    ]),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  static void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    UserRole role = UserRole.user;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2931),
        title: const Text('Add User', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), style: const TextStyle(color: Colors.white)),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            DropdownButton<UserRole>(
              value: role,
              dropdownColor: const Color(0xFF1E2931),
              items: const [
                DropdownMenuItem(value: UserRole.user, child: Text('User', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: UserRole.admin, child: Text('Admin', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) { role = v ?? UserRole.user; },
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await UserService.instance.create(name: nameCtrl.text, email: emailCtrl.text, role: role);
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _RoomsSchedulesPanel extends StatelessWidget {
  const _RoomsSchedulesPanel();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
          stream: RoomService.instance.list(),
          builder: (context, snap) {
            final rooms = (snap.data ?? const <Room>[]) as List<Room>;
            if (rooms.isEmpty) {
              return const Text('No rooms configured yet', style: TextStyle(color: Colors.white70));
            }
            return Column(
              children: [
                for (final r in rooms)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, color: Colors.white70),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r.name} • ${r.code} • ${r.building}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              Text('QR: ${r.qrCode}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showTodaySchedule(context, r.code),
                          child: const Text('Today'),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  static void _showTodaySchedule(BuildContext context, String roomKey) {
    final entries = ScheduleService.instance.listByRoomForToday(roomKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2931),
        title: Text('Today\'s Schedule • $roomKey', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 420,
          child: entries.isEmpty
              ? const Text('No entries for today', style: TextStyle(color: Colors.white70))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('${_fmt(e.start)} - ${_fmt(e.end)}  •  ${e.title}  •  ${e.instructor}', style: const TextStyle(color: Colors.white70)),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
