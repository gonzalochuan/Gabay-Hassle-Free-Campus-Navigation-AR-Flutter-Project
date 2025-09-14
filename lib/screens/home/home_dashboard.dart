import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:Gabay/models/user.dart';
import 'package:Gabay/services/user_service.dart';
import '../navigate/navigate_screen.dart';
import '../room_scanner/room_scanner_screen.dart';
import '../news/news_feed_screen.dart';
import '../emergency/emergency_screen.dart';
import '../dept_hours/dept_hours_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key, this.userName = 'Gonzalo Chuan'});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final cardHeight = screenH < 700 ? 184.0 : 200.0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur/overlay
          _Background(),
          // Foreground scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(userName: userName),
                  const SizedBox(height: 20),
                  // Grid of quick access cards (2x2)
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          title: 'Navigation',
                          description:
                              'Navigate campus with 2D maps or AR arrows.',
                          assetPath: '',
                          fallbackIcon: Icons.near_me,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NavigateScreen(),
                              ),
                            );
                          },
                          height: cardHeight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Room Scanner',
                          description:
                              'Scan room QR codes for schedules and availability.',
                          assetPath: '',
                          fallbackIcon: Icons.qr_code_scanner,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RoomScannerScreen(),
                              ),
                            );
                          },
                          height: cardHeight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          title: 'News Feed',
                          description:
                              'Stay updated with announcements, events and reminders.',
                          assetPath: '',
                          fallbackIcon: Icons.article,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NewsFeedScreen(),
                              ),
                            );
                          },
                          height: cardHeight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FeatureCard(
                          title: 'Emergency',
                          description:
                              'View evacuation routes, safe exits, and emergency contacts.',
                          assetPath: '',
                          fallbackIcon: Icons.warning_amber_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EmergencyScreen(),
                              ),
                            );
                          },
                          height: cardHeight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Full-width card for Dept Hours
                  _FeatureCard(
                    title: 'Department Hours',
                    description:
                        'Check office schedules and open or close times to plan your visits and avoid waiting.',
                    assetPath: '',
                    fallbackIcon: Icons.event_available,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeptHoursScreen(),
                        ),
                      );
                    },
                    fullWidth: true,
                    height: cardHeight,
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
        // Optional extra blur to emphasize glassmorphism
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatefulWidget {
  const _HeaderCard({required this.userName});
  final String userName;

  @override
  State<_HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<_HeaderCard> {
  bool _showDetails = false;

  static AppUser _resolveUser(String name) {
    try {
      final list = UserService.instance.current;
      // 1) Try exact name match
      final byName = list.where((u) => u.name.toLowerCase() == name.toLowerCase());
      if (byName.isNotEmpty) return byName.first;
      // 2) Fallback to first non-admin user with data
      final withData = list.where((u) => u.role == UserRole.user && ((u.course ?? u.department ?? u.block ?? u.yearId ?? u.yearSection) != null));
      if (withData.isNotEmpty) return withData.first;
      // 3) Fallback to first user if any
      if (list.isNotEmpty) return list.first;
      // Final fallback
      return AppUser(id: 'local', name: name, email: '', role: UserRole.user);
    } catch (_) {
      return AppUser(id: 'local', name: name, email: '', role: UserRole.user);
    }
  }

  static String _buildTooltip(AppUser u) {
    final isAdmin = u.role == UserRole.admin || u.email.toLowerCase() == 'admin@seait.edu';
    final course = (u.course ?? u.department ?? '').trim();
    final lines = <String>[
      'Role: ${describeEnum(u.role)}',
      'Username: ${u.name}',
      if (!isAdmin && course.isNotEmpty) 'Course: $course',
      if (u.email.isNotEmpty) 'Email: ${u.email}',
    ];
    return lines.join('\n');
  }

  static Widget _profileChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _actionChip({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser user = _resolveUser(widget.userName);
    final String tooltipMsg = _buildTooltip(user);
    final bool isAdmin = user.role == UserRole.admin || user.email.toLowerCase() == 'admin@seait.edu';
    final String courseStr = isAdmin ? '' : ((user.course ?? user.department) ?? '').trim();
    return _GlassContainer(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleBadge(assetPath: 'assets/image/homelogo.png', fallbackIcon: Icons.place),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${widget.userName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'There are quick access cards to navigate wherever you go',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: tooltipMsg,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                padding: const EdgeInsets.all(10),
                waitDuration: const Duration(milliseconds: 200),
                child: InkWell(
                  borderRadius: BorderRadius.circular(21),
                  onTap: () => setState(() => _showDetails = !_showDetails),
                  child: const _CircleBadge(fallbackIcon: Icons.person_outline),
                ),
              ),
            ],
          ),
          if (_showDetails) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _CircleBadge(fallbackIcon: Icons.person_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            if (user.email.isNotEmpty)
                              Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (courseStr.isNotEmpty) _profileChip(Icons.school_outlined, 'Course: ' + courseStr),
                      _profileChip(Icons.badge_outlined, 'Role: ${describeEnum(user.role)}'),
                      _actionChip(
                        icon: Icons.logout,
                        text: 'Logout',
                        onTap: () {
                          // Pop all routes and return to the app's root (e.g., welcome/login screen)
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                      if (!user.active) _profileChip(Icons.person_off_outlined, 'Inactive'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.fallbackIcon,
    required this.onTap,
    this.fullWidth = false,
    this.height = 200,
  });

  final String title;
  final String description;
  final String assetPath;
  final IconData fallbackIcon;
  final VoidCallback onTap;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBadge(assetPath: assetPath, fallbackIcon: fallbackIcon),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: _EnterButton(onTap: onTap),
        ),
      ],
    );

    return _GlassContainer(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: content,
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF63C1E3).withOpacity(0.9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF63C1E3).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            SizedBox(width: 8),
            Icon(Icons.arrow_right_alt, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.assetPath, required this.fallbackIcon});
  final String assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: Colors.white, size: 32),
    );
  }
}

class _CircleBadge extends StatelessWidget {
  const _CircleBadge({this.assetPath, this.fallbackIcon});
  final String? assetPath;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      alignment: Alignment.center,
      child: assetPath != null
          ? Image.asset(
              assetPath!,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Icon(fallbackIcon ?? Icons.circle, color: Colors.white),
            )
          : Icon(fallbackIcon ?? Icons.circle, color: Colors.white),
    );
  }
}
