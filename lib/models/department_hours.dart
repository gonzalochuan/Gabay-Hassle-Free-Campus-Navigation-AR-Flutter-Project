import 'package:flutter/foundation.dart';

@immutable
class TimeRange {
  final String start; // HH:MM 24h
  final String end;   // HH:MM 24h
  const TimeRange(this.start, this.end);

  Map<String, dynamic> toMap() => {'start': start, 'end': end};
  factory TimeRange.fromMap(Map<String, dynamic> map) => TimeRange(
        map['start'] as String,
        map['end'] as String,
      );
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'location': location,
        'phone': phone,
        'is_office': isOffice,
        // store as {"0":[{start,end}],"1":[...],...}
        'weekly_hours': weeklyHours.map((k, v) => MapEntry(k.toString(), v.map((e) => e.toMap()).toList())),
      };

  factory DepartmentHours.fromMap(Map<String, dynamic> map) {
    final raw = (map['weekly_hours'] as Map).map((k, v) => MapEntry(k.toString(), v));
    final parsed = <int, List<TimeRange>>{};
    for (final entry in raw.entries) {
      final dayIdx = int.tryParse(entry.key) ?? 0;
      final list = (entry.value as List)
          .map((e) => TimeRange.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      parsed[dayIdx] = list;
    }
    return DepartmentHours(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      phone: map['phone'] as String?,
      isOffice: (map['is_office'] as bool?) ?? true,
      weeklyHours: parsed,
    );
  }
}
