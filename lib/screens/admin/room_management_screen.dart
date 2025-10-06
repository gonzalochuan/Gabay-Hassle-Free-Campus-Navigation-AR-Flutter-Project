import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;
  final AsyncCallback? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (suspendingCallBack != null) {
          await suspendingCallBack!();
        }
        break;
    }
  }
}

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _buildingController = TextEditingController();
  final _deptController = TextEditingController();
  
  Room? _editingRoom;
  bool _isGeneratingQR = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  StreamSubscription<List<Room>>? _roomsSubscription;
  List<Room> _rooms = [];
  
  @override
  void initState() {
    super.initState();
    print('Initializing RoomManagementScreen');
    _setupRoomsSubscription();
    _setupAppLifecycleListener();
  }
  
  void _setupRoomsSubscription() {
    print('Setting up room subscription');
    
    // Cancel existing subscription if any
    _roomsSubscription?.cancel();
    
    _roomsSubscription = RoomService().streamAll().listen(
      (rooms) {
        print('Received ${rooms.length} rooms in subscription');
        if (mounted) {
          setState(() {
            _rooms = rooms;
            _isLoading = false;
            _errorMessage = null;
            print('Updated UI with ${_rooms.length} rooms');
          });
        }
      },
      onError: (error) {
        print('Error in room subscription: $error');
        if (mounted) {
          setState(() {
            _errorMessage = 'Error loading rooms: $error';
            _isLoading = false;
          });
        }
      },
      onDone: () => print('Room subscription closed'),
      cancelOnError: false,
    );
    
    // Force initial load
    _refreshRooms();
  }
  
  // Removed broken _initializeRoomService (malformed braces). Initialization is handled by RoomService().streamAll() and _refreshRooms().

  void _setupAppLifecycleListener() {
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          print('App resumed - refreshing rooms');
          await _refreshRooms();
        },
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _buildingController.dispose();
    _deptController.dispose();
    _roomsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        title: const Text('Room Management'),
        backgroundColor: const Color(0xFF1E2931),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRooms,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshRooms,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _rooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.meeting_room_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No rooms added yet',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _showAddRoomDialog,
                            child: const Text('Add Your First Room'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshRooms,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) => _buildRoomCard(_rooms[index]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: const Color(0xFF63C1E3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _startEditing(Room room) {
    setState(() {
      _editingRoom = room;
      _codeController.text = room.code;
      _nameController.text = room.name;
      _buildingController.text = room.building;
      _deptController.text = room.deptTag ?? '';
    });
    _showEditDialog();
  }

  void _showEditDialog() {
    final isEditing = _editingRoom != null;
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2931),
        title: Text(
          isEditing ? 'Edit Room' : 'Add New Room',
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Room Code',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _buildingController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Building',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a building name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deptController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Department (optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveRoom,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63C1E3),
              foregroundColor: Colors.white,
            ),
            child: Text(_editingRoom != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _editingRoom = null;
    _codeController.clear();
    _nameController.clear();
    _buildingController.clear();
    _deptController.clear();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final room = Room(
        id: const Uuid().v4(),
        qrCode: 'ROOM_${_codeController.text.toUpperCase()}_${const Uuid().v4().substring(0, 6)}',
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        building: _buildingController.text.trim().isNotEmpty ? _buildingController.text.trim() : null,
        deptTag: _deptController.text.trim().isNotEmpty ? _deptController.text.trim() : null,
      );

      await RoomService().create(room);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room saved successfully')),
        );
      }
    } catch (e) {
      print('Error saving room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving room: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveQRCode(Room room) async {
    setState(() => _isGeneratingQR = true);
    
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required to save QR code')),
          );
        }
        return;
      }

      // Generate QR code image
      final qrData = await room.generateQrImage();
      
      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(qrData),
        quality: 100,
        name: 'qr_${room.code.toLowerCase()}.png',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: result['isSuccess'] == true
                ? const Text('QR code saved to gallery')
                : const Text('Failed to save QR code'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error generating QR code')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingQR = false);
      }
    }
  }

  Widget _buildRoomCard(Room room) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF63C1E3).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.meeting_room, color: Color(0xFF63C1E3)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${room.code} - ${room.name}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${room.building ?? ''}${room.deptTag != null ? ' • ${room.deptTag}' : ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _startEditing(room);
                          break;
                        case 'delete':
                          _confirmDelete(room.id);
                          break;
                        case 'qr':
                          _showQRCodeDialog(room);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit Room'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'qr',
                        child: Row(
                          children: [
                            Icon(Icons.qr_code, size: 20, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Show QR Code'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Room'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQRCodeDialog(Room room) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E2931),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${room.code} QR Code',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: room.qrCodeWidget,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan this code to view room details',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: _isGeneratingQR ? null : () => _saveQRCode(room),
            icon: _isGeneratingQR
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isGeneratingQR ? 'Saving...' : 'Save QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63C1E3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String roomId) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2931),
        title: Text(
          'Delete Room',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this room? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              RoomService.instance.delete(roomId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Room deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  // Removed duplicate _saveQRCode definition
  
  Future<void> _refreshRooms() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      print('Refreshing rooms...');
      // Force a fresh fetch from the database
      final rooms = await RoomService().listAll();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error refreshing rooms: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load rooms. Please try again.';
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh rooms: $e')),
      );
    }
  }

  void _showAddRoomDialog() {
    _editingRoom = null;
    _codeController.clear();
    _nameController.clear();
    _buildingController.clear();
    _deptController.clear();  
    _showEditDialog();
  }
}
