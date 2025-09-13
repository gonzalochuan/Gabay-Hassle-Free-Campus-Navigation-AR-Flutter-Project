import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/news.dart';

class NewsService {
  NewsService._internal() {
    // Seed with a few posts so the feed isn't empty
    final now = DateTime.now();
    _posts = [
      NewsPost(
        id: Uuid().v4(),
        type: PostType.announcement,
        title: 'Registrar: Enrollment Extension',
        body: 'Enrollment extended until Sep 15 for late enrollees. Please proceed to online portal.',
        deptTag: 'Registrar',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NewsPost(
        id: Uuid().v4(),
        type: PostType.alert,
        title: 'Power Interruption (MST Building)',
        body: 'Maintenance from 9–11 AM. Some labs may be closed. Please plan accordingly.',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      NewsPost(
        id: Uuid().v4(),
        type: PostType.lostFound,
        title: 'Found: Black Umbrella at CL 2',
        body: 'Claim at Security Desk',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
    _emit();
  }

  static final NewsService instance = NewsService._internal();

  final _controller = StreamController<List<NewsPost>>.broadcast();
  late List<NewsPost> _posts;

  Stream<List<NewsPost>> feed() => _controller.stream;

  List<NewsPost> get current => List.unmodifiable(_posts);

  void _emit() {
    // Order: pinned first, then newest first
    final ordered = [..._posts]
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    _controller.add(ordered);
  }

  Future<NewsPost> publish({
    required PostType type,
    required String title,
    String? body,
    String? deptTag,
    DateTime? scheduledAt,
    bool pinned = false,
  }) async {
    final post = NewsPost(
      id: Uuid().v4(),
      type: type,
      title: title.trim(),
      body: body?.trim(),
      deptTag: deptTag?.trim(),
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
      pinned: pinned,
    );
    _posts.add(post);
    _emit();
    return post;
  }

  Future<void> delete(String id) async {
    _posts.removeWhere((p) => p.id == id);
    _emit();
  }

  Future<void> togglePin(String id) async {
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = _posts[idx];
    _posts[idx] = p.copyWith(pinned: !p.pinned);
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}
