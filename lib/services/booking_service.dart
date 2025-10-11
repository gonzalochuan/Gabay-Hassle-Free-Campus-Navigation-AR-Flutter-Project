import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';

class BookingService {
  BookingService._internal();
  static final BookingService instance = BookingService._internal();

  static const String _table = 'bookings';
  final _supabase = Supabase.instance.client;

  Stream<List<Booking>> streamAll() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.map((r) => Booking.fromMap(Map<String, dynamic>.from(r))).toList());
  }

  Stream<List<Booking>> streamMine() {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      return Stream.value(const <Booking>[]);
    }
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at')
        .map((rows) => rows.map((r) => Booking.fromMap(Map<String, dynamic>.from(r))).toList());
  }

  Future<Booking> create({
    required String facility,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String purpose,
    int? attendees,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();
    final payload = {
      'id': id,
      'user_id': uid,
      'facility': facility,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'purpose': purpose,
      'attendees': attendees,
      'status': 'pending',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    final res = await _supabase.from(_table).insert(payload).select().single();
    return Booking.fromMap(Map<String, dynamic>.from(res as Map));
  }

  Future<void> updateStatus(String id, String status) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _supabase.from(_table).update({'status': status, 'updated_at': now}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
