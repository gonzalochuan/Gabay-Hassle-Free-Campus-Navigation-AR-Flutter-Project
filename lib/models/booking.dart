import 'package:flutter/foundation.dart';

@immutable
class Booking {
  final String id;
  final String userId;
  final String facility; // 'AVR' or 'GYM'
  final DateTime date; // date part significant
  final String startTime; // HH:MM 24h
  final String endTime; // HH:MM 24h
  final String purpose;
  final int? attendees;
  final String status; // 'pending' | 'approved' | 'declined'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.facility,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    this.attendees,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  Booking copyWith({
    String? id,
    String? userId,
    String? facility,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? purpose,
    int? attendees,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      facility: facility ?? this.facility,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      attendees: attendees ?? this.attendees,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'facility': facility,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'purpose': purpose,
      'attendees': attendees,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      facility: map['facility'] as String,
      date: DateTime.parse((map['date'] as String).substring(0, 10)),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      purpose: map['purpose'] as String,
      attendees: map['attendees'] as int?,
      status: (map['status'] as String?) ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: (map['updated_at'] != null) ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }
}
