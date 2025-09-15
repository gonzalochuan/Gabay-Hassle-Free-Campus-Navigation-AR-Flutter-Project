import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../widgets/glass_container.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key});

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF63C1E3).withOpacity(0.9) : Colors.white.withOpacity(0.08);
    final fg = selected ? Colors.white : Colors.white.withOpacity(0.85);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _NavigateScreenState extends State<NavigateScreen> {
  // Using AR-only mock UI for now (frontend-first)
  String? _selectedDestination;

  // Mock data categories and rooms
  final Map<String, List<String>> _mockCategories = {
    'CL Rooms': List.generate(10, (i) => 'CL ${i + 1}'),
    'Admin Offices': List.generate(5, (i) => 'Admin Office ${i + 1}'),
  };

  String _activeCategory = 'CL Rooms';

  // Camera controller for real preview
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    torchEnabled: false,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _openDestinationPicker() async {
    final categories = _mockCategories.keys.toList();
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String tempCategory = _activeCategory;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return GlassContainer(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Select Destination', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      Icon(Icons.place, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // We need local state to update the list when a chip is tapped
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setSheetState) {
                        void setCategory(String c) {
                          setSheetState(() => tempCategory = c);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final c in categories)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: _CategoryChip(
                                        label: c,
                                        selected: c == tempCategory,
                                        onTap: () => setCategory(c),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: _mockCategories[tempCategory]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final room = _mockCategories[tempCategory]![index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                    leading: const Icon(Icons.room, color: Colors.white70),
                                    title: Text(room, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    subtitle: Text('Tap to navigate', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                    onTap: () => Navigator.of(context).pop(room),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _selectedDestination = selected;
        _activeCategory = _mockCategories.entries.firstWhere((e) => e.value.contains(selected)).key;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Real camera preview
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              // No onDetect needed; we only need preview for AR UI
            ),
          ),
          // AR overlay UI on top of the camera
          Positioned.fill(
            child: _ArMockOverlay(
              selectedDestination: _selectedDestination,
              categories: _mockCategories,
              activeCategory: _activeCategory,
              onCategoryChange: (c) => setState(() => _activeCategory = c),
              onSelectRoom: (room) => setState(() => _selectedDestination = room),
              onOpenPicker: _openDestinationPicker,
              onClearDestination: () => setState(() => _selectedDestination = null),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
      ],
    );
  }
}

class _ArMockOverlay extends StatelessWidget {
  const _ArMockOverlay({
    this.selectedDestination,
    required this.categories,
    required this.activeCategory,
    required this.onCategoryChange,
    required this.onSelectRoom,
    required this.onOpenPicker,
    required this.onClearDestination,
  });

  final String? selectedDestination;
  final Map<String, List<String>> categories;
  final String activeCategory;
  final ValueChanged<String> onCategoryChange;
  final ValueChanged<String> onSelectRoom;
  final VoidCallback onOpenPicker;
  final VoidCallback onClearDestination;

  @override
  Widget build(BuildContext context) {
    final rooms = categories[activeCategory] ?? const <String>[];
    return Stack(
      fit: StackFit.expand,
      children: [
        // Transparent layer over the real camera
        // Direction arrow
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_arrow_up_rounded, size: 80, color: Color(0xFF63C1E3)),
              const SizedBox(height: 6),
              Text(
                selectedDestination == null ? 'Pick a destination' : 'Head straight for 20m',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        // In-camera top controls: category chips and rooms row
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Browse and Clear
                  Row(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: InkWell(
                          onTap: onOpenPicker,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.list, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Browse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (selectedDestination != null)
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: InkWell(
                            onTap: onClearDestination,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.clear, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final c in categories.keys)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _CategoryChip(
                              label: c,
                              selected: c == activeCategory,
                              onTap: () => onCategoryChange(c),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rooms quick select for active category
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final r in rooms)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: InkWell(
                                onTap: () => onSelectRoom(r),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      selectedDestination == r ? Icons.check_circle : Icons.navigation,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(r, style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
