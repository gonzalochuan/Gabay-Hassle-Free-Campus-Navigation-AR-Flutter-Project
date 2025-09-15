import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:Gabay/models/user.dart';
import 'package:Gabay/services/user_service.dart';
import '../../widgets/glass_container.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassContainer(
                    radius: 16,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Accounts',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Add User',
                          onPressed: () => _showCreateDialog(context),
                          icon: const Icon(Icons.person_add_alt, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<AppUser>>(
                      stream: UserService.instance.list(),
                      builder: (context, snap) {
                        final users = snap.data ?? const <AppUser>[];
                        if (users.isEmpty) {
                          return Center(
                            child: GlassContainer(
                              radius: 18,
                              padding: const EdgeInsets.all(16),
                              child: const Text(
                                'No users found',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) => _UserRow(user: users[i]),
                        );
                      },
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

  static Future<void> _showCreateDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final courseCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    UserRole role = UserRole.user;

    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GlassContainer(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                _UserRow._input(nameCtrl, label: 'Name'),
                const SizedBox(height: 10),
                _UserRow._input(emailCtrl, label: 'Email'),
                const SizedBox(height: 10),
                _UserRow._input(courseCtrl, label: 'Course (optional)'),
                const SizedBox(height: 10),
                _UserRow._input(deptCtrl, label: 'Department (optional)'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: DropdownButton<UserRole>(
                    value: role,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E2931),
                    iconEnabledColor: Colors.white,
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: UserRole.user, child: Text('User', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: UserRole.admin, child: Text('Admin', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (v) => role = v ?? UserRole.user,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await UserService.instance.create(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          role: role,
                          course: courseCtrl.text.trim().isEmpty ? null : courseCtrl.text.trim(),
                          department: deptCtrl.text.trim().isEmpty ? null : deptCtrl.text.trim(),
                          createdBy: 'admin@seait.edu',
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63C1E3),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Create'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_circle, color: Colors.white70, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    _statusChip(user),
                    const SizedBox(width: 6),
                    _roleChip(user),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((user.course ?? user.department)?.isNotEmpty == true)
                      _smallChip(Icons.school_outlined, (user.course ?? user.department)!),
                    if (user.createdBy != null && user.createdBy!.isNotEmpty)
                      _smallChip(Icons.person_add_alt, 'Created by: ${user.createdBy}')
                    else
                      _smallChip(Icons.person_add_alt, 'Created by: system'),
                    _smallChip(Icons.calendar_today_outlined, 'Created: ${_fmtMaybeDate(user.createdAt)}'),
                    if (user.lastSignInAt != null)
                      _smallChip(Icons.login, 'Sign in: ${_fmtMaybeDate(user.lastSignInAt)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditDialog(context, user),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                      label: const Text('Edit', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: () => _showPasswordDialog(context, user),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.lock_reset, size: 18, color: Colors.white),
                      label: const Text('Password', style: TextStyle(color: Colors.white)),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: user.active ? 'Deactivate' : 'Activate',
                      onPressed: () => UserService.instance.deactivate(user.id),
                      icon: Icon(user.active ? Icons.person_off_outlined : Icons.person_outline, color: Colors.white70),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, user.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _statusChip(AppUser u) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (u.active ? Colors.green : Colors.red).withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(u.active ? 'Active' : 'Inactive', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  static Widget _roleChip(AppUser u) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF63C1E3).withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(describeEnum(u.role), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  static Widget _smallChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  static String _fmtMaybeDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static Future<void> _confirmDelete(BuildContext context, String userId) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GlassContainer(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delete User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Are you sure you want to delete this user? This action cannot be undone.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await UserService.instance.delete(userId);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _showPasswordDialog(BuildContext context, AppUser user) async {
    final passCtrl = TextEditingController();
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GlassContainer(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Password • ${user.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 12),
              _input(passCtrl, label: 'New Password', obscure: true),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await UserService.instance.updatePassword(user.id, passCtrl.text);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated (mock)'), backgroundColor: Colors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF63C1E3),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Update'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _showEditDialog(BuildContext context, AppUser user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final courseCtrl = TextEditingController(text: user.course ?? '');
    final deptCtrl = TextEditingController(text: user.department ?? '');

    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GlassContainer(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit • ${user.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 12),
                _input(nameCtrl, label: 'Name'),
                const SizedBox(height: 10),
                _input(courseCtrl, label: 'Course (optional)'),
                const SizedBox(height: 10),
                _input(deptCtrl, label: 'Department (optional)'),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await UserService.instance.updateName(user.id, nameCtrl.text.trim());
                        await UserService.instance.updateCourse(
                          user.id,
                          course: courseCtrl.text.trim().isEmpty ? null : courseCtrl.text.trim(),
                          department: deptCtrl.text.trim().isEmpty ? null : deptCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63C1E3),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Save'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shared input builder for glass dialogs
  static Widget _input(TextEditingController ctrl, {required String label, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
