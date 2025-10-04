import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin-only actions that require Supabase Edge Functions.
///
/// You must deploy the following Edge Functions in your Supabase project:
/// - admin_create_user
/// - admin_delete_user
/// - admin_send_reset (or similar)
///
/// These functions should use the Service Role key on the server side ONLY.
/// Never embed the service role in the mobile app.
class AdminRepository {
  AdminRepository._();
  static final AdminRepository instance = AdminRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    bool isAdmin = false,
    String? course,
    String? department,
    String createdBy = 'admin',
  }) async {
    final payload = {
      'email': email,
      'password': password,
      'name': name,
      'is_admin': isAdmin,
      if (course != null) 'course': course,
      if (department != null) 'department': department,
      'created_by': createdBy,
    };
    final res = await _client.functions.invoke('admin_create_user', body: payload);
    if (res.status >= 400) {
      throw Exception('admin_create_user failed (${res.status}): ${res.data}');
    }
  }

  Future<void> deleteUser(String userId) async {
    final res = await _client.functions.invoke('admin_delete_user', body: {
      'user_id': userId,
    });
    if (res.status >= 400) {
      throw Exception('admin_delete_user failed (${res.status}): ${res.data}');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final res = await _client.functions.invoke('admin_send_reset', body: {
      'email': email,
    });
    if (res.status >= 400) {
      throw Exception('admin_send_reset failed (${res.status}): ${res.data}');
    }
  }
}
