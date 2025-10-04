import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesRepository {
  ProfilesRepository._();
  static final ProfilesRepository instance = ProfilesRepository._();

  final SupabaseClient _client = Supabase.instance.client;

  static const String table = 'profiles';

  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final res = await _client.from(table).select().eq('id', uid).maybeSingle();
    return res;
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final res = await _client.from(table).select().eq('id', userId).maybeSingle();
    return res;
  }

  Future<void> upsertMyProfile({
    required String name,
    required String email,
    String? course,
    String? department,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user.');
    await _client.from(table).upsert({
      'id': uid,
      'name': name,
      'email': email,
      if (course != null) 'course': course,
      if (department != null) 'department': department,
      'active': true,
      'last_sign_in_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isCurrentUserAdmin() async {
    final p = await getMyProfile();
    if (p == null) return false;
    return (p['is_admin'] == true);
  }

  Future<void> updateLastSignInNow() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client.from(table).update({
      'last_sign_in_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }

  // Realtime stream of all profiles; requires RLS to allow select for admin (or all users if public)
  Stream<List<Map<String, dynamic>>> streamAll() {
    return _client.from(table).stream(primaryKey: ['id']).order('created_at');
  }

  // One-time fetch of all profiles
  Future<List<Map<String, dynamic>>> listAll() async {
    final res = await _client.from(table).select();
    return (res as List).cast<Map<String, dynamic>>();
  }

  // Admin: update profile fields
  Future<void> updateFields(
    String id, {
    String? name,
    String? course,
    String? department,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (course != null) data['course'] = course;
    if (department != null) data['department'] = department;
    if (data.isEmpty) return;
    await _client.from(table).update(data).eq('id', id);
  }

  // Admin: set active flag
  Future<void> setActive(String id, bool active) async {
    await _client.from(table).update({'active': active}).eq('id', id);
  }

  // Admin: delete profile row (does not delete auth user)
  Future<void> deleteProfile(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
