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
  final bool active;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.yearSection,
    this.active = true,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? department,
    String? yearSection,
    bool? active,
  }) => AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        department: department ?? this.department,
        yearSection: yearSection ?? this.yearSection,
        active: active ?? this.active,
      );
}
