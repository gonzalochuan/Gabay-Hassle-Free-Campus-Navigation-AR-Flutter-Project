import 'package:flutter/material.dart';

class DeptHoursScreen extends StatelessWidget {
  const DeptHoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Department Hours')),
      body: const Center(
        child: Text('List + detail with today\'s status (placeholder)'),
      ),
    );
  }
}
