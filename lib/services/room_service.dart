import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/room.dart';
import 'dart:collection';

class RoomService {
  RoomService._internal() {
    _rooms = UnmodifiableListView([
      Room(
        id: Uuid().v4(),
        qrCode: 'ROOM_CL1_ABC123',
        code: 'CL1',
        name: 'Computer Lab 1',
        building: 'MST',
        deptTag: 'IT',
      ),
      Room(
        id: Uuid().v4(),
        qrCode: 'ROOM_CL2_DEF456',
        code: 'CL2',
        name: 'Computer Lab 2',
        building: 'MST',
        deptTag: 'IT',
      ),
      Room(
        id: Uuid().v4(),
        qrCode: 'ROOM_RM101_GHI789',
        code: 'RM101',
        name: 'Lecture Room 101',
        building: 'Main',
        deptTag: 'GenEd',
      ),
    ]);
    _emit();
  }
  
  static final RoomService instance = RoomService._internal();

  final _controller = StreamController<UnmodifiableListView<Room>>.broadcast();
  late UnmodifiableListView<Room> _rooms;

  Stream<UnmodifiableListView<Room>> list() => _controller.stream;
  UnmodifiableListView<Room> get current => _rooms;

  Room? findByQr(String qrCode) {
    try {
      return _rooms.firstWhere((r) => r.qrCode == qrCode);
    } catch (e) {
      return null;
    }
  }

  Future<Room> create(Room room) async {
    _rooms = UnmodifiableListView([..._rooms, room]);
    _emit();
    return room;
  }
  
  Future<Room> update(Room updatedRoom) async {
    _rooms = UnmodifiableListView(_rooms.map((r) => r.id == updatedRoom.id ? updatedRoom : r));
    _emit();
    return updatedRoom;
  }

  Future<void> delete(String id) async {
    _rooms = UnmodifiableListView(_rooms.where((r) => r.id != id));
    _emit();
  }

  void _emit() => _controller.add(_rooms);
  void dispose() => _controller.close();
}
