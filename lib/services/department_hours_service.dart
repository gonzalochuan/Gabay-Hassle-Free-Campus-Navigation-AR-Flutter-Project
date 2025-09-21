import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/department_hours.dart';

class DepartmentHoursService {
  DepartmentHoursService._internal() {
    // Seed with sample OFFICE-only data
    _items = [
      DepartmentHours(
        id: const Uuid().v4(),
        name: "Registrar's Office",
        location: 'Admin Building, Room 101',
        phone: '555-1234',
        weeklyHours: {
          1: [const TimeRange('08:00', '12:00'), const TimeRange('13:00', '17:00')],
          2: [const TimeRange('08:00', '12:00'), const TimeRange('13:00', '17:00')],
          3: [const TimeRange('08:00', '12:00'), const TimeRange('13:00', '17:00')],
          4: [const TimeRange('08:00', '12:00'), const TimeRange('13:00', '17:00')],
          5: [const TimeRange('08:00', '12:00'), const TimeRange('13:00', '16:00')],
        },
        isOffice: true,
      ),
      DepartmentHours(
        id: const Uuid().v4(),
        name: 'CICT Office',
        location: 'Office Services Center, 3rd Floor',
        phone: '555-5678',
        weeklyHours: {
          1: [const TimeRange('09:00', '12:00'), const TimeRange('13:00', '16:00')],
          2: [const TimeRange('09:00', '12:00'), const TimeRange('13:00', '16:00')],
          3: [const TimeRange('09:00', '12:00'), const TimeRange('13:00', '16:00')],
          4: [const TimeRange('09:00', '12:00'), const TimeRange('13:00', '16:00')],
          5: [const TimeRange('09:00', '15:00')],
        },
        isOffice: true,
      ),
      DepartmentHours(
        id: const Uuid().v4(),
        name: 'Library',
        location: 'Main Library, 4th Floor',
        phone: '555-2468',
        weeklyHours: {
          0: [const TimeRange('10:00', '16:00')],
          1: [const TimeRange('08:00', '20:00')],
          2: [const TimeRange('08:00', '20:00')],
          3: [const TimeRange('08:00', '20:00')],
          4: [const TimeRange('08:00', '20:00')],
          5: [const TimeRange('08:00', '18:00')],
          6: [const TimeRange('10:00', '16:00')],
        },
        isOffice: true,
      ),
      DepartmentHours(
        id: const Uuid().v4(),
        name: 'Accounting/Cashier',
        location: 'Finance Office, Room 203',
        weeklyHours: {
          1: [const TimeRange('08:30', '12:00'), const TimeRange('13:00', '16:30')],
          2: [const TimeRange('08:30', '12:00'), const TimeRange('13:00', '16:30')],
          3: [const TimeRange('08:30', '12:00'), const TimeRange('13:00', '16:30')],
          4: [const TimeRange('08:30', '12:00'), const TimeRange('13:00', '16:30')],
          5: [const TimeRange('08:30', '15:00')],
        },
        isOffice: true,
      ),
      DepartmentHours(
        id: const Uuid().v4(),
        name: 'Clinic',
        location: 'Health Services, Ground Floor',
        phone: '555-1357',
        weeklyHours: {
          1: [const TimeRange('08:00', '17:00')],
          2: [const TimeRange('08:00', '17:00')],
          3: [const TimeRange('08:00', '17:00')],
          4: [const TimeRange('08:00', '17:00')],
          5: [const TimeRange('08:00', '17:00')],
        },
        isOffice: true,
      ),
      DepartmentHours(
        id: const Uuid().v4(),
        name: 'IT Helpdesk',
        location: 'Tech Hub, Room 310',
        phone: '555-9999',
        weeklyHours: {
          1: [const TimeRange('08:00', '18:00')],
          2: [const TimeRange('08:00', '18:00')],
          3: [const TimeRange('08:00', '18:00')],
          4: [const TimeRange('08:00', '18:00')],
          5: [const TimeRange('08:00', '18:00')],
        },
        isOffice: true,
      ),
    ];
    _emit();
  }

  static final DepartmentHoursService instance = DepartmentHoursService._internal();

  final _controller = StreamController<List<DepartmentHours>>.broadcast();
  late List<DepartmentHours> _items;

  Stream<List<DepartmentHours>> list() => _controller.stream;
  List<DepartmentHours> get current => List.unmodifiable(_items);

  Future<DepartmentHours> create(DepartmentHours item) async {
    _items.add(item);
    _emit();
    return item;
  }

  Future<DepartmentHours> upsert(DepartmentHours item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    _emit();
    return item;
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }

  void _emit() => _controller.add([..._items]);
  void dispose() => _controller.close();
}
