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
}
