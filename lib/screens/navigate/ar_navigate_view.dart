import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import '../../navigation/map_data.dart';
import '../../navigation/a_star.dart';

class ARNavigateView extends StatefulWidget {
  final String destinationCode;
  final vm.Vector3? initialOrigin;
  final double? initialYawRad;
  const ARNavigateView({super.key, required this.destinationCode, this.initialOrigin, this.initialYawRad});
  @override
  State<ARNavigateView> createState() => _ARNavigateViewState();
}

class _ARNavigateViewState extends State<ARNavigateView> {
  ARSessionManager? sessionManager;
  ARObjectManager? objectManager;
  ARAnchorManager? anchorManager;
  ARLocationManager? locationManager;

  bool ready = false;
  bool originSet = false;
  vm.Vector3 origin = vm.Vector3.zero();
  double currentDistance = 0.0;
  final List<ARNode> _breadcrumbs = [];
  ARNode? _destNode;
  vm.Vector3? _destWorld;

  // Demo destination: 5m forward from origin
  vm.Vector3 get demoDestination => vm.Vector3(0, 0, -5);

  void onARViewCreated(ARSessionManager s, ARObjectManager o, ARAnchorManager a, ARLocationManager l) {
    sessionManager = s;
    objectManager = o;
    anchorManager = a;
    locationManager = l;
    () async {
      sessionManager!.onInitialize(
        showAnimatedGuide: false,
        showFeaturePoints: false,
        showPlanes: false,
        showWorldOrigin: false,
        handleTaps: false,
      );
      objectManager!.onInitialize();
      sessionManager!.onPlaneOrPointTap = _onPlaneTap;
      if (mounted) setState(() => ready = true);
      await Future.delayed(const Duration(milliseconds: 900));
      await _autoStart();
    }();
  }

  Future<void> _autoStart() async {
    // Always fetch current camera pose to anchor AR world
    vm.Matrix4? camPose;
    for (int i = 0; i < 20; i++) {
      camPose = await sessionManager?.getCameraPose();
      if (camPose != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (camPose == null) return;
    final camPos = camPose.getTranslation();

    // If QR provided an initial origin (camera position in building space), pass it through
    if (widget.initialOrigin != null) {
      await _setOrigin(
        vm.Vector3(camPos.x, camPos.y, camPos.z),
        auto: true,
        camPose: camPose,
        camPositionBuilding: widget.initialOrigin,
        overrideYaw: widget.initialYawRad,
      );
      return;
    }

    // Fallback: use camera pose as both AR world anchor and building origin
    await _setOrigin(vm.Vector3(camPos.x, camPos.y, camPos.z), auto: true, camPose: camPose);
  }

  Future<void> _onPlaneTap(List<ARHitTestResult> hits) async {
    if (hits.isEmpty) return;
    final h = hits.firstWhere((e) => e.type == ARHitTestResultType.plane, orElse: () => hits.first);
    final m = h.worldTransform;
    final pos = vm.Vector3(m.getColumn(3).x, m.getColumn(3).y, m.getColumn(3).z);
    await _setOrigin(pos);
  }

  Future<void> _setOrigin(vm.Vector3 pos, {bool auto = false, vm.Matrix4? camPose, double? overrideYaw, vm.Vector3? camPositionBuilding}) async {
    // Clear previous nodes
    for (final n in _breadcrumbs) {
      try { await objectManager?.removeNode(n); } catch (_) {}
    }
    _breadcrumbs.clear();
    if (_destNode != null) {
      try { await objectManager?.removeNode(_destNode!); } catch (_) {}
      _destNode = null;
    }

    origin = pos;
    originSet = true;

    // Determine forward from provided cam pose or latest
    vm.Vector3 forward = vm.Vector3(0, 0, -1);
    vm.Matrix4? pose = camPose;
    if (pose == null) {
      try { pose = await sessionManager!.getCameraPose(); } catch (_) {}
    }
    if (pose != null) {
      final zCol = pose.getColumn(2); // camera forward is -Z
      forward = vm.Vector3(-zCol.x, -zCol.y, -zCol.z).normalized();
    }

    // If we have a graph path for the destination, render based on it; else fallback to straight line
    final destId = kRoomToWaypoint[widget.destinationCode] ?? 'W_CL1';
    String startId = getStartWaypointForCurrentArea();
    final start = kWaypoints[startId]?.pos ?? vm.Vector3.zero();
    final goal = kWaypoints[destId]?.pos ?? vm.Vector3(0, 0, -5);
    final path = findPathAStar(waypoints: kWaypoints, startId: startId, goalId: destId);
    final polyline = path.isEmpty ? <vm.Vector3>[start, goal] : waypointsToPolyline(path);

    // Align building frame to camera: rotate so +Z of building aligns to camera forward in AR
    final yaw = overrideYaw ?? math.atan2(forward.x, -forward.z);
    vm.Matrix3 rotY = vm.Matrix3.rotationY(yaw);

    // We treat camPositionBuilding as the camera position in building coordinates (from QR)
    // and 'origin' as the camera position in AR world coordinates (from camPose).
    // World position for any building point p:
    //   world = camWorld + R * (p - camBuilding)
    // If QR provides building-space camera position, use it; otherwise snap the building-space camera
    // to the chosen start waypoint so the path begins at the user's current AR origin.
    final vm.Vector3 camBuilding = camPositionBuilding ?? (kWaypoints[startId]?.pos ?? vm.Vector3.zero());
    // If we know the camera position in building coordinates (from QR), choose nearest graph node as start
    if (camPositionBuilding != null) {
      startId = findNearestWaypointId(camBuilding, kWaypoints);
    }
    final vm.Vector3 camWorld = origin;
    vm.Vector3 tf(vm.Vector3 p) {
      final delta = p - camBuilding;
      final r = rotY.transformed(delta);
      return vm.Vector3(camWorld.x + r.x, camWorld.y + r.y, camWorld.z + r.z);
    }

    // Transform polyline to AR world and drop breadcrumbs approximately every 1m
    final worldPts = <vm.Vector3>[];
    for (final p in polyline) {
      worldPts.add(tf(p));
    }
    for (int s = 0; s < worldPts.length - 1; s++) {
      final p0 = worldPts[s];
      final p1 = worldPts[s + 1];
      final seg = p1 - p0;
      final segLen = seg.length;
      if (segLen <= 0.1) continue;
      final norm = seg / segLen;
      final steps = segLen.floor();
      for (int i = 1; i <= steps; i++) {
        final center = p0 + norm * i.toDouble() + vm.Vector3(0, 0.01, 0);
        final yawSeg = math.atan2(norm.x, -norm.z);
        final shaft = ARNode(
          type: NodeType.webGLB,
          uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb',
          scale: vm.Vector3(0.45, 0.03, 0.09),
          position: center,
          eulerAngles: vm.Vector3(0, yawSeg, 0),
        );
        await objectManager?.addNode(shaft);
        _breadcrumbs.add(shaft);

        final headOffset = vm.Vector3(norm.x * 0.28, 0, norm.z * 0.28);
        final head = ARNode(
          type: NodeType.webGLB,
          uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb',
          scale: vm.Vector3(0.12, 0.04, 0.12),
          position: center + headOffset,
          eulerAngles: vm.Vector3(0, yawSeg, 0),
        );
        await objectManager?.addNode(head);
        _breadcrumbs.add(head);
      }
    }

    // Visible marker at origin
    final originMarker = ARNode(
      type: NodeType.webGLB,
      uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb',
      scale: vm.Vector3(0.18, 0.02, 0.18),
      position: origin + vm.Vector3(0, 0.01, 0),
    );
    await objectManager?.addNode(originMarker);
    _breadcrumbs.add(originMarker);

    // Destination pin (placeholder duck) at final world polyline point
    final vm.Vector3 destWorld = worldPts.isNotEmpty ? worldPts.last : tf(goal);
    final pin = ARNode(
      type: NodeType.webGLB,
      uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
      scale: vm.Vector3(0.08, 0.08, 0.08),
      position: destWorld + vm.Vector3(0, 0.05, 0),
    );
    await objectManager?.addNode(pin);
    _destNode = pin;
    _destWorld = destWorld;

    _updateDistance();
    if (mounted) setState(() {});
  }

  void _updateDistance() {
    if (!originSet || sessionManager == null) return;
    // Compute distance between camera and destination
    () async {
      final camPose = await sessionManager!.getCameraPose();
      if (camPose == null) return;
      final camPos = camPose.getTranslation();
      final vm.Vector3? destPos = _destWorld;
      if (destPos == null) return;
      currentDistance = vm.Vector3(camPos.x, camPos.y, camPos.z).distanceTo(destPos);
      if (mounted) setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR Navigate: ${widget.destinationCode}')),
      body: Stack(children: [
        ARView(
          onARViewCreated: onARViewCreated,
          planeDetectionConfig: PlaneDetectionConfig.horizontal,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(originSet ? 'Tap again to reset origin' : 'Tap floor to set origin'),
                      if (originSet) Text('${currentDistance.toStringAsFixed(1)} m') else const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
