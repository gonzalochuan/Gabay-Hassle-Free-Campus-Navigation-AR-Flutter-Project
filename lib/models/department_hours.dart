import 'package:flutter/foundation.dart';

@immutable
class TimeRange {
  final String start; // HH:MM 24h
  final String end;   // HH:MM 24h
  const TimeRange(this.start, this.end);
}

@immutable
class DepartmentHours {
  final String id;
  final String name;
  final String location;
  final String? phone;
  final bool isOffice; // true for offices (Registrar, Library, etc.)
  // key: 0=Sun..6=Sat
  final Map<int, List<TimeRange>> weeklyHours;

  const DepartmentHours({
    required this.id,
    required this.name,
    required this.location,
    required this.weeklyHours,
    this.phone,
    this.isOffice = true,
  });

  DepartmentHours copyWith({
    String? id,
    String? name,
    String? location,
    String? phone,
    bool? isOffice,
    Map<int, List<TimeRange>>? weeklyHours,
  }) => DepartmentHours(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        phone: phone ?? this.phone,
        isOffice: isOffice ?? this.isOffice,
        weeklyHours: weeklyHours ?? this.weeklyHours,
      );
}
