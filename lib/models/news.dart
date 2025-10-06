import 'package:flutter/foundation.dart';

enum PostType { announcement, event, alert, lostFound }

@immutable
class NewsPost {
  final String id;
  final PostType type;
  final String title;
  final String? body;
  final String? deptTag;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool pinned;

  const NewsPost({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.deptTag,
    required this.createdAt,
    this.scheduledAt,
    this.pinned = false,
  });

  NewsPost copyWith({
    String? id,
    PostType? type,
    String? title,
    String? body,
    String? deptTag,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? pinned,
  }) {
    return NewsPost(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      deptTag: deptTag ?? this.deptTag,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      pinned: pinned ?? this.pinned,
    );
  }

  // Serialization helpers (snake_case keys to match Supabase)
  factory NewsPost.fromMap(Map<String, dynamic> map) {
    return NewsPost(
      id: map['id'] as String,
      type: _postTypeFromString(map['type'] as String?),
      title: map['title'] as String,
      body: map['body'] as String?,
      deptTag: map['dept_tag'] as String?,
      createdAt: DateTime.parse((map['created_at'] ?? map['createdAt']) as String),
      scheduledAt: map['scheduled_at'] != null ? DateTime.parse(map['scheduled_at'] as String) : null,
      pinned: (map['pinned'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'dept_tag': deptTag,
      'created_at': createdAt.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'pinned': pinned,
    };
  }
}

PostType _postTypeFromString(String? s) {
  switch (s) {
    case 'announcement':
      return PostType.announcement;
    case 'event':
      return PostType.event;
    case 'alert':
      return PostType.alert;
    case 'lostFound':
    case 'lost_found':
      return PostType.lostFound;
    default:
      return PostType.announcement;
  }
}
