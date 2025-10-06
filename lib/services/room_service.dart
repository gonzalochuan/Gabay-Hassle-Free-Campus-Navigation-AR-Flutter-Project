import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';

class RoomService {
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  static RoomService get instance => _instance;
  
  RoomService._internal();

  static const String _tableName = 'rooms';
  static const String _storageKey = 'rooms_data';
  final _supabase = Supabase.instance.client;
  final List<Room> _rooms = [];
  final _controller = StreamController<List<Room>>.broadcast();
  bool _isInitialized = false;
  bool _isInitializing = false;
  SharedPreferences? _prefs;

  // Stream of all rooms with realtime updates straight from Supabase.
  // This ensures a fresh stream when the UI resubscribes after navigation.
  Stream<List<Room>> streamAll() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('name')
        .map((data) {
          _rooms.clear();
          _rooms.addAll(data.map((r) => Room.fromJson(r)).toList());
          return List<Room>.from(_rooms);
        });
  }

  // One-time fetch of all rooms
  Future<List<Room>> listAll() async {
    if (!_isInitialized) {
      await initialize();
    }
    return List<Room>.from(_rooms);
  }

  // Create a new room
  Future<Room> create(Room room) async {
    try {
      final data = room.toJson();
      final response = await _supabase
          .from(_tableName)
          .insert({
            'id': data['id'] ?? room.id,
            'qr_code': data['qrCode'],
            'code': data['code'],
            'name': data['name'],
            'building': data['building'],
            'dept_tag': data['deptTag'],
          })
          .select()
          .single();
      
      final newRoom = Room.fromJson(response);
      _rooms.add(newRoom);
      _emit();
      await _saveToLocal(_rooms);
      return newRoom;
    } catch (e) {
      print('Error creating room: $e');
      rethrow;
    }
  }

  // Update an existing room
  Future<Room> update(Room room) async {
    try {
      final data = room.toJson();
      final response = await _supabase
          .from(_tableName)
          .update({
            'qr_code': data['qrCode'],
            'code': data['code'],
            'name': data['name'],
            'building': data['building'],
            'dept_tag': data['deptTag'],
          })
          .eq('id', room.id)
          .select()
          .single();
      
      final index = _rooms.indexWhere((r) => r.id == room.id);
      if (index != -1) {
        _rooms[index] = Room.fromJson(response);
        _emit();
        await _saveToLocal(_rooms);
      }
      return Room.fromJson(response);
    } catch (e) {
      print('Error updating room: $e');
      rethrow;
    }
  }

  // Delete a room
  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
      _rooms.removeWhere((room) => room.id == id);
      _emit();
      await _saveToLocal(_rooms);
    } catch (e) {
      print('Error deleting room: $e');
      rethrow;
    }
  }

  // Find room by QR code (synchronous to keep backward compatibility)
  Room? findByQr(String qrCode) {
    try {
      // Assumes initialize() has been called in main.dart before usage
      return _rooms.firstWhere((room) => room.qrCode == qrCode);
    } catch (_) {
      return null;
    }
  }

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Try to load from Supabase first
      try {
        final response = await _supabase
            .from(_tableName)
            .select()
            .order('name');
            
        _rooms.clear();
        _rooms.addAll((response as List).map((r) => Room.fromJson(r)).toList());
        await _saveToLocal(_rooms);
      } catch (e) {
        print('Error loading from Supabase: $e');
        // Fall back to local storage if Supabase fails
        await _loadFromLocal();
      }
      
      _isInitialized = true;
      _emit();
      
      // Set up realtime subscription
      _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .listen((data) async {
            _rooms.clear();
            _rooms.addAll(data.map((r) => Room.fromJson(r)).toList());
            await _saveToLocal(_rooms);
            _emit();
          });
          
    } catch (e) {
      print('Error initializing RoomService: $e');
      await _loadFromLocal();
    } finally {
      _isInitializing = false;
    }
  }
  
  // Load rooms from local storage
  Future<void> _loadFromLocal() async {
    try {
      final jsonString = _prefs?.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _rooms.clear();
        _rooms.addAll(jsonList.map((r) => Room.fromJson(r)).toList());
        _emit();
      }
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }
  
  // Save rooms to local storage
  Future<void> _saveToLocal(List<Room> rooms) async {
    try {
      final jsonList = rooms.map((r) => r.toJson()).toList();
      await _prefs?.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }
  
  // Emit the current rooms to the stream
  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(List<Room>.from(_rooms));
  }
  
  // Clean up resources
  void dispose() {
    _controller.close();
  }

  // For backward compatibility
  Stream<List<Room>> list() => streamAll();
  
  // Get the first room or null if empty
  Room? get current => _rooms.isNotEmpty ? _rooms.first : null;
  
  // Get all rooms
  List<Room> get rooms => List<Room>.from(_rooms);
}
