import 'package:flutter/foundation.dart';

enum UserRole { admin, user }

@immutable
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? yearSection;
  final String? course; // e.g., BSIT
  final String? block;  // e.g., Block 4
  final String? yearId; // e.g., 2022-1230
  final bool active;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final String? createdBy; // email or name of creator

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.yearSection,
    this.course,
    this.block,
    this.yearId,
    this.active = true,
    DateTime? createdAt,
    this.lastSignInAt,
    this.createdBy,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? department,
    String? yearSection,
    String? course,
    String? block,
    String? yearId,
    bool? active,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    String? createdBy,
  }) => AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        department: department ?? this.department,
        yearSection: yearSection ?? this.yearSection,
        course: course ?? this.course,
        block: block ?? this.block,
        yearId: yearId ?? this.yearId,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
        lastSignInAt: lastSignInAt ?? this.lastSignInAt,
        createdBy: createdBy ?? this.createdBy,
      );
}
