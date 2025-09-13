import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class UserService {
  UserService._internal() {
    _users = [
      AppUser(
        id: const Uuid().v4(),
        name: 'Admin',
        email: 'admin@seait.edu',
        role: UserRole.admin,
        course: 'Admin',
        block: 'N/A',
        yearId: 'N/A',
      ),
      AppUser(
        id: const Uuid().v4(),
        name: 'Juan Dela Cruz',
        email: 'juan@example.com',
        role: UserRole.user,
        department: 'IT',
        course: 'BSIT',
        block: 'Block 4',
        yearId: '2022-1230',
      ),
      AppUser(
        id: const Uuid().v4(),
        name: 'Maria Santos',
        email: 'maria@example.com',
        role: UserRole.user,
        department: 'CS',
        course: 'BSCS',
        block: 'Block 2',
        yearId: '2021-0456',
      ),
    ];
    _emit();
  }
  static final UserService instance = UserService._internal();

  final _controller = StreamController<List<AppUser>>.broadcast();
  late List<AppUser> _users;

  Stream<List<AppUser>> list() => _controller.stream;
  List<AppUser> get current => List.unmodifiable(_users);

  void _emit() => _controller.add([..._users]);

  Future<AppUser> create({required String name, required String email, UserRole role = UserRole.user, String? department, String? yearSection}) async {
    final user = AppUser(id: Uuid().v4(), name: name, email: email, role: role, department: department, yearSection: yearSection);
    _users.add(user);
    _emit();
    return user;
  }

  Future<void> deactivate(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx == -1) return;
    _users[idx] = _users[idx].copyWith(active: false);
    _emit();
  }

  Future<void> toggleRole(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx == -1) return;
    final u = _users[idx];
    _users[idx] = u.copyWith(role: u.role == UserRole.admin ? UserRole.user : UserRole.admin);
    _emit();
  }

  void dispose() => _controller.close();
}
