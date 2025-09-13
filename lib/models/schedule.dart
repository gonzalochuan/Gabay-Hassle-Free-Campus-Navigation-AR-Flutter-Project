import 'package:flutter/foundation.dart';

enum ScheduleKind { classSession, event, maintenance }

@immutable
class ScheduleEntry {
  final String id;
  final String roomId;
  final DateTime start;
  final DateTime end;
  final String title; // subject or event title
  final String instructor; // or contact
  final String? section; // optional
  final ScheduleKind kind;

  const ScheduleEntry({
    required this.id,
    required this.roomId,
    required this.start,
    required this.end,
    required this.title,
    required this.instructor,
    this.section,
    this.kind = ScheduleKind.classSession,
  });
}
