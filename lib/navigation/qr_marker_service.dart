import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class QrMarker {
  final String slug;
  final vm.Vector3? position;
  final double? yawDeg;
  final String? roomCode;
  final double? latitude;
  final double? longitude;

  const QrMarker({
    required this.slug,
    this.position,
    this.yawDeg,
    this.roomCode,
    this.latitude,
    this.longitude,
  });

  factory QrMarker.fromJson(Map<String, dynamic> json) {
    vm.Vector3? pos;
    final posJson = json['pos'] ?? json['anchor_pose']?['pos'];
    if (posJson is List && posJson.length == 3) {
      final values = posJson.map((e) => (e as num).toDouble()).toList();
      pos = vm.Vector3(values[0], values[1], values[2]);
    } else if (json['pos_x'] != null && json['pos_y'] != null && json['pos_z'] != null) {
      pos = vm.Vector3(
        (json['pos_x'] as num).toDouble(),
        (json['pos_y'] as num).toDouble(),
        (json['pos_z'] as num).toDouble(),
      );
    }

    double? yaw;
    final yawJson = json['yaw_deg'] ?? json['anchor_pose']?['yawDeg'];
    if (yawJson != null) yaw = (yawJson as num).toDouble();

    return QrMarker(
      slug: json['slug'] as String,
      position: pos,
      yawDeg: yaw,
      roomCode: json['room_code'] as String?,
      latitude: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      longitude: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
    );
  }
}

class QrMarkerService {
  QrMarkerService({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? dotenv.env['QR_MARKER_API'] ?? '' {
    final anon = dotenv.env['SUPABASE_ANON_KEY'];
    if (anon != null && anon.isNotEmpty) {
      _dio.options.headers['apikey'] = anon;
      _dio.options.headers['Authorization'] = 'Bearer $anon';
    }
  }

  final Dio _dio;
  final String _baseUrl;

  String get _trimmedBaseUrl => _baseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  bool get _hasBaseUrl => _trimmedBaseUrl.isNotEmpty;

  Future<List<QrMarker>> fetchNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 50,
  }) async {
    if (!_hasBaseUrl) return const [];
    try {
      final response = await _dio.get(
        '$_trimmedBaseUrl/qr-markers',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusMeters,
        },
      );
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(QrMarker.fromJson)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<QrMarker?> fetchBySlug(String slug) async {
    if (!_hasBaseUrl) return null;
    try {
      final response = await _dio.get('$_trimmedBaseUrl/qr-markers/$slug');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return QrMarker.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}
