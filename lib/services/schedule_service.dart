import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/schedule.dart';

class ScheduleService {
  ScheduleService._internal() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _entries = [
      // CL1
      ScheduleEntry(
        id: const Uuid().v4(),
        roomId: 'CL1', // will map by room.qrCode for simplicity
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
      // CL2
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
    _entries.add(entry);
    _emit();
    return entry;
  }

  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
    _emit();
  }

  void _emit() => _controller.add([..._entries]);
  void dispose() => _controller.close();
}
