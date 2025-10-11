import 'package:vector_math/vector_math_64.dart' as vm;
import 'map_data.dart';

class _NodeRecord {
  final String id;
  final double g;
  final double f;
  final String? parent;
  const _NodeRecord(this.id, this.g, this.f, this.parent);
}

List<Waypoint> findPathAStar({
  required Map<String, Waypoint> waypoints,
  required String startId,
  required String goalId,
}) {
  if (!waypoints.containsKey(startId) || !waypoints.containsKey(goalId)) {
    return const [];
  }
  if (startId == goalId) {
    return [waypoints[startId]!];
  }

  final open = <String, _NodeRecord>{};
  final closed = <String, _NodeRecord>{};

  double h(String a, String b) {
    final pa = waypoints[a]!.pos;
    final pb = waypoints[b]!.pos;
    return (pa - pb).length;
  }

  open[startId] = _NodeRecord(startId, 0.0, h(startId, goalId), null);

  while (open.isNotEmpty) {
    String currentId = open.values.reduce((acc, e) => e.f < acc.f ? e : acc).id;
    final current = open[currentId]!;

    if (currentId == goalId) {
      final pathIds = <String>[];
      _NodeRecord? n = current;
      while (n != null) {
        pathIds.add(n.id);
        final p = n.parent;
        n = p != null ? closed[p] ?? open[p] : null;
      }
      final rev = pathIds.reversed.map((id) => waypoints[id]!).toList();
      return rev;
    }

    open.remove(currentId);
    closed[currentId] = current;

    final currentWp = waypoints[currentId]!;
    for (final neighId in currentWp.neighbors) {
      if (!waypoints.containsKey(neighId)) continue;
      if (closed.containsKey(neighId)) continue;

      final tentativeG = current.g + (currentWp.pos - waypoints[neighId]!.pos).length;
      final existing = open[neighId];
      if (existing == null || tentativeG < existing.g) {
        final f = tentativeG + h(neighId, goalId);
        open[neighId] = _NodeRecord(neighId, tentativeG, f, currentId);
      }
    }
  }

  return const [];
}

List<vm.Vector3> waypointsToPolyline(List<Waypoint> path) {
  if (path.isEmpty) return const [];
  return path.map((w) => w.pos).toList();
}
