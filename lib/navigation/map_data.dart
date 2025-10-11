import 'package:vector_math/vector_math_64.dart' as vm;

class Waypoint {
  final String id;
  final vm.Vector3 pos;
  final List<String> neighbors;
  Waypoint(this.id, this.pos, this.neighbors);
}

final Map<String, Waypoint> kWaypoints = {
  'W_START': Waypoint('W_START', vm.Vector3(0, 0, 0), ['W_CL1'] ),
  'W_CL1': Waypoint('W_CL1', vm.Vector3(0, 0, -5), []),
};

final Map<String, String> kRoomToWaypoint = {
  'CL 1': 'W_CL1',
};

String getStartWaypointForCurrentArea() {
  return 'W_START';
}
