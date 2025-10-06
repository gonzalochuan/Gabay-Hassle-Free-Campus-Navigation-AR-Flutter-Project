import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/department_hours.dart';

class DepartmentHoursService {
  DepartmentHoursService._internal();

  static final DepartmentHoursService instance = DepartmentHoursService._internal();

  static const String _table = 'department_hours';
  final _supabase = Supabase.instance.client;

  // Realtime list stream
  Stream<List<DepartmentHours>> list() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('name')
        .map((rows) => rows.map((r) => DepartmentHours.fromMap(Map<String, dynamic>.from(r))).toList());
  }

  // Create
  Future<DepartmentHours> create(DepartmentHours item) async {
    final payload = item.copyWith(id: item.id.isEmpty ? const Uuid().v4() : item.id).toMap();
    final res = await _supabase.from(_table).insert(payload).select().single();
    return DepartmentHours.fromMap(Map<String, dynamic>.from(res as Map));
  }

  // Upsert by id
  Future<DepartmentHours> upsert(DepartmentHours item) async {
    final payload = item.toMap();
    final res = await _supabase.from(_table).upsert(payload, onConflict: 'id').select().single();
    return DepartmentHours.fromMap(Map<String, dynamic>.from(res as Map));
  }

  // Delete by id
  Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
