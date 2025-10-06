import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule.dart';
import '../core/env.dart';

class ScheduleService {
  ScheduleService._internal() {
    if (Env.isConfigured) {
      _loadFromSupabase();
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      _entries = [
        ScheduleEntry(
          id: const Uuid().v4(),
          roomId: 'CL1',
          start: today.add(const Duration(hours: 7, minutes: 30)),
          end: today.add(const Duration(hours: 9, minutes: 0)),
          title: 'IT 101 - Intro to CS',
          instructor: 'Ins. Mitch',
          kind: ScheduleKind.classSession,
        ),
        ScheduleEntry(
          id: const Uuid().v4(),
          roomId: 'CL1',
          start: today.add(const Duration(hours: 9, minutes: 15)),
          end: today.add(const Duration(hours: 10, minutes: 45)),
          title: 'IT 205 - Networks',
          instructor: 'Ins. Estacio',
          kind: ScheduleKind.classSession,
        ),
        ScheduleEntry(
          id: const Uuid().v4(),
          roomId: 'CL2',
          start: today.add(const Duration(hours: 11, minutes: 0)),
          end: today.add(const Duration(hours: 13, minutes: 30)),
          title: 'IT 210 - Data Structures',
          instructor: 'Ins. Celis',
          kind: ScheduleKind.classSession,
        ),
        ScheduleEntry(
          id: const Uuid().v4(),
          roomId: 'CL2',
          start: today.add(const Duration(hours: 13, minutes: 30)),
          end: today.add(const Duration(hours: 15, minutes: 0)),
          title: 'IT 330 - Databases',
          instructor: 'Ins. Estacio',
          kind: ScheduleKind.classSession,
        ),
      ];
      _emit();
    }
  }

  static final ScheduleService instance = ScheduleService._internal();

  final _controller = StreamController<List<ScheduleEntry>>.broadcast();
  late List<ScheduleEntry> _entries;

  Stream<List<ScheduleEntry>> all() => _controller.stream;
  List<ScheduleEntry> get current => List.unmodifiable(_entries);

  List<ScheduleEntry> listByRoomForToday(String roomKey) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _entries
        .where((e) => e.roomId.toLowerCase() == roomKey.toLowerCase())
        .where((e) => e.start.isAfter(dayStart) && e.start.isBefore(dayEnd))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  Future<ScheduleEntry> addEntry(ScheduleEntry entry) async {
    if (Env.isConfigured) {
      final client = Supabase.instance.client;
      await client.from('schedules').insert({
        'id': entry.id,
        'room_id': entry.roomId,
        'start': entry.start.toIso8601String(),
        'end': entry.end.toIso8601String(),
        'title': entry.title,
        'instructor': entry.instructor,
        'section': entry.section,
        'kind': entry.kind.name,
      });
      await _loadFromSupabase();
      return entry;
    } else {
      _entries.add(entry);
      _emit();
      return entry;
    }
  }

  Future<void> delete(String id) async {
    if (Env.isConfigured) {
      final client = Supabase.instance.client;
      await client.from('schedules').delete().eq('id', id);
      await _loadFromSupabase();
    } else {
      _entries.removeWhere((e) => e.id == id);
      _emit();
    }
  }

  void _emit() => _controller.add([..._entries]);
  void dispose() => _controller.close();

  Future<void> _loadFromSupabase() async {
    final client = Supabase.instance.client;
    final data = await client
        .from('schedules')
        .select('id, room_id, start, end, title, instructor, section, kind')
        .order('start');
    final list = (data as List).map((e) {
      return ScheduleEntry(
        id: e['id'] as String,
        roomId: e['room_id'] as String,
        start: DateTime.parse(e['start'] as String),
        end: DateTime.parse(e['end'] as String),
        title: e['title'] as String,
        instructor: e['instructor'] as String,
        section: e['section'] as String?,
        kind: _parseKind(e['kind'] as String?),
      );
    }).toList(growable: false);
    _entries = list;
    _emit();
  }

  ScheduleKind _parseKind(String? v) {
    switch ((v ?? '').toLowerCase()) {
      case 'event':
        return ScheduleKind.event;
      case 'maintenance':
        return ScheduleKind.maintenance;
      default:
        return ScheduleKind.classSession;
    }
  }
}
