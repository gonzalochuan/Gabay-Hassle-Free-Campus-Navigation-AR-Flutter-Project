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
    if (widget.initialOrigin != null) {
      await _setOrigin(widget.initialOrigin!, auto: true, overrideYaw: widget.initialYawRad);
      return;
    }
    vm.Matrix4? camPose;
    for (int i = 0; i < 20; i++) {
      camPose = await sessionManager?.getCameraPose();
      if (camPose != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (camPose == null) return;
    final camPos = camPose.getTranslation();
    await _setOrigin(vm.Vector3(camPos.x, camPos.y, camPos.z), auto: true, camPose: camPose);
  }

  Future<void> _onPlaneTap(List<ARHitTestResult> hits) async {
    if (hits.isEmpty) return;
    final h = hits.firstWhere((e) => e.type == ARHitTestResultType.plane, orElse: () => hits.first);
    final m = h.worldTransform;
    final pos = vm.Vector3(m.getColumn(3).x, m.getColumn(3).y, m.getColumn(3).z);
    await _setOrigin(pos);
  }

  Future<void> _setOrigin(vm.Vector3 pos, {bool auto = false, vm.Matrix4? camPose, double? overrideYaw}) async {
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

    // If we have a graph path for the destination, render based on it; else fallback to 5m ahead
    final destId = kRoomToWaypoint[widget.destinationCode] ?? 'W_CL1';
    final startId = getStartWaypointForCurrentArea();
    final start = kWaypoints[startId]?.pos ?? vm.Vector3.zero();
    final goal = kWaypoints[destId]?.pos ?? vm.Vector3(0, 0, -5);

    // Align building frame to camera: rotate so +Z of building aligns to camera forward in AR
    final yaw = overrideYaw ?? math.atan2(forward.x, -forward.z);
    vm.Matrix3 rotY = vm.Matrix3.rotationY(yaw);

    // Transform waypoints into AR world (origin at camera position)
    vm.Vector3 tf(vm.Vector3 p) {
      final r = rotY.transformed(p);
      return vm.Vector3(origin.x + r.x, origin.y + r.y, origin.z + r.z);
    }

    final startW = tf(start);
    final destPos = tf(goal);

    // Breadcrumbs (placeholder boxes) every 1m along path from start to dest
    final base = startW;
    final dir = destPos - base;
    final length = dir.length;
    if (length > 0.1) {
      final steps = length.floor();
      final norm = dir / length;
      for (int i = 1; i <= steps; i++) {
        final p = base + norm * i.toDouble() + vm.Vector3(0, 0.05, 0);
        final yawSeg = math.atan2(norm.x, -norm.z); // face forward
        final node = ARNode(
          type: NodeType.webGLB,
          uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb',
          scale: vm.Vector3(0.3, 0.06, 0.3),
          position: p,
          eulerAngles: vm.Vector3(0, yawSeg, 0),
        );
        await objectManager?.addNode(node);
        _breadcrumbs.add(node);
      }
    }

    // Visible marker at origin
    final originMarker = ARNode(
      type: NodeType.webGLB,
      uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb',
      scale: vm.Vector3(0.2, 0.02, 0.2),
      position: origin + vm.Vector3(0, 0.03, 0),
    );
    await objectManager?.addNode(originMarker);
    _breadcrumbs.add(originMarker);

    // Destination pin (placeholder duck)
    final pin = ARNode(
      type: NodeType.webGLB,
      uri: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
      scale: vm.Vector3(0.08, 0.08, 0.08),
      position: destPos + vm.Vector3(0, 0.05, 0),
    );
    await objectManager?.addNode(pin);
    _destNode = pin;

    _updateDistance();
    if (mounted) setState(() {});
  }

  void _updateDistance() {
    if (!originSet || sessionManager == null) return;
    // Compute distance between camera and demo destination
    () async {
      final camPose = await sessionManager!.getCameraPose();
      if (camPose == null) return;
      final camPos = camPose.getTranslation();
      final destPos = vm.Vector3(origin.x + demoDestination.x, origin.y + demoDestination.y, origin.z + demoDestination.z);
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
