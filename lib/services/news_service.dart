import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news.dart';

class NewsService {
  NewsService._internal();
  static final NewsService instance = NewsService._internal();

  static const String _table = 'news';
  final _supabase = Supabase.instance.client;

  // Live feed: realtime stream from Supabase ordered by creation time, with pinned first.
  Stream<List<NewsPost>> feed() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) {
          final posts = rows.map((r) => NewsPost.fromMap(r)).toList();
          posts.sort((a, b) {
            if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
            return b.createdAt.compareTo(a.createdAt);
          });
          return posts;
        });
  }

  // Publish a post to the database.
  Future<NewsPost> publish({
    required PostType type,
    required String title,
    String? body,
    String? deptTag,
    DateTime? scheduledAt,
    bool pinned = false,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final payload = {
      'id': id,
      'type': type.name,
      'title': title.trim(),
      'body': body?.trim(),
      'dept_tag': deptTag?.trim(),
      'created_at': now.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'pinned': pinned,
    };
    final inserted = await _supabase.from(_table).insert(payload).select().single();
    return NewsPost.fromMap(inserted as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  Future<void> togglePin(String id) async {
    // Flip the pinned state atomically by reading and writing a single row
    final row = await _supabase.from(_table).select('pinned').eq('id', id).maybeSingle();
    if (row == null) return;
    final current = (row['pinned'] as bool?) ?? false;
    await _supabase.from(_table).update({'pinned': !current}).eq('id', id);
  }
}
