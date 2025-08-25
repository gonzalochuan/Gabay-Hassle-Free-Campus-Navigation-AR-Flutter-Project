import 'package:flutter/material.dart';

class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigate')),
      body: const Center(
        child: Text('Search + 2D route preview + step list (placeholder)'),
      ),
    );
  }
}
