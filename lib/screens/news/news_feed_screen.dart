import 'dart:ui';

import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('News Feed'),
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.notifications_outlined),
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Background(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Search bar
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search announcements, events, alerts',
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Subheader
                Row(
                  children: const [
                    Text('Latest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(width: 8),
                    _Badge(label: 'Mock', color: Color(0x33475564)),
                  ],
                ),
                const SizedBox(height: 16),
                // Feed cards (mock data)
                const _AnnouncementCard(
                  title: 'Registrar: Enrollment Extension',
                  body: 'Enrollment extended until Sep 15 for late enrollees. Please proceed to online portal.',
                  dept: 'Registrar',
                  timeAgo: '2h',
                ),
                const SizedBox(height: 12),
                const _EventCard(
                  title: 'Tech Talk: Intro to Flutter',
                  date: 'SEP 12',
                  time: '2:00–3:30 PM',
                  location: 'MST Hall',
                ),
                const SizedBox(height: 12),
                const _AlertCard(
                  title: 'Power Interruption (MST Building)',
                  body: 'Maintenance from 9–11 AM. Some labs may be closed. Please plan accordingly.',
                  timeAgo: 'Just now',
                ),
                const SizedBox(height: 12),
                const _LostFoundCard(
                  title: 'Found: Black Umbrella at CL 2',
                  meta: 'Claim at Security Desk',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.value, required this.onChanged, required this.items});
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items) ...[
              _TabPill(
                label: item,
                selected: value == item,
                onTap: () => onChanged(item),
              ),
              if (item != items.last) const SizedBox(width: 6),
            ]
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF63C1E3).withOpacity(0.9) : Colors.white.withOpacity(0.08);
    final fg = selected ? Colors.white : Colors.white.withOpacity(0.85);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.title, required this.body, required this.dept, required this.timeAgo});
  final String title;
  final String body;
  final String dept;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          _Badge(label: 'Announcement', color: Color(0xFF3B82F6)),
          SizedBox(width: 8),
          _Badge(label: 'Registrar', color:  Color(0x33475564)),
        ]),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.access_time, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text(timeAgo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, color: Colors.white70)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share, color: Colors.white70)),
        ])
      ]),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.title, required this.date, required this.time, required this.location});
  final String title;
  final String date;
  final String time;
  final String location;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _DatePill(date: date),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              _Badge(label: 'Event', color: Color(0xFF10B981)),
            ]),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text('$time · $location', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF63C1E3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.event_available, size: 18),
                label: const Text('Add to Calendar'),
              ),
            )
          ]),
        ),
      ]),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.title, required this.body, required this.timeAgo});
  final String title;
  final String body;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          _Badge(label: 'Alert', color: Color(0xFFEF4444)),
        ]),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.access_time, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text(timeAgo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ])
      ]),
    );
  }
}

class _LostFoundCard extends StatelessWidget {
  const _LostFoundCard({required this.title, required this.meta});
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          _Badge(label: 'Lost & Found', color: Color(0xFFF59E0B)),
        ]),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 6),
        Text(meta, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(date.split(' ').first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 2),
          Text(date.split(' ').last, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
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
