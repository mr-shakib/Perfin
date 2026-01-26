import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'storage_service.dart';

/// Hive implementation of StorageService
/// Provides local storage using Hive database
class HiveStorageService implements StorageService {
  late Box _box;
  static const String _boxName = 'perfin_storage';
  bool _initialized = false;

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      _initialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize storage: ${e.toString()}');
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StorageException('Storage not initialized. Call init() first.');
    }
  }

  @override
  Future<void> save<T>(String key, T value) async {
    _ensureInitialized();
    
    try {
      // Convert value to JSON-compatible format
      final jsonValue = _toJson(value);
      await _box.put(key, jsonValue);
    } catch (e) {
      throw StorageException('Failed to save data for key "$key": ${e.toString()}');
    }
  }

  @override
  Future<T?> load<T>(String key) async {
    _ensureInitialized();
    
    try {
      final value = _box.get(key);
      if (value == null) {
        return null;
      }
      return _fromJson<T>(value);
    } catch (e) {
      throw StorageException('Failed to load data for key "$key": ${e.toString()}');
    }
  }

  @override
  Future<void> delete(String key) async {
    _ensureInitialized();
    
    try {
      await _box.delete(key);
    } catch (e) {
      throw StorageException('Failed to delete data for key "$key": ${e.toString()}');
    }
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    
    try {
      await _box.clear();
    } catch (e) {
      throw StorageException('Failed to clear storage: ${e.toString()}');
    }
  }

  /// Convert value to JSON-compatible format
  dynamic _toJson(dynamic value) {
    if (value == null) {
      return null;
    }
    
    // Handle primitive types
    if (value is String || value is num || value is bool) {
      return value;
    }
    
    // Handle lists
    if (value is List) {
      return value.map((item) => _toJson(item)).toList();
    }
    
    // Handle maps
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _toJson(val)));
    }
    
    // For objects with toJson method, convert to JSON string
    try {
      if (value is Map<String, dynamic>) {
        return value;
      }
      // Assume object has toJson method
      return jsonEncode(value);
    } catch (e) {
      throw StorageException('Cannot serialize value of type ${value.runtimeType}');
    }
  }

  /// Convert stored value back to original type
  T? _fromJson<T>(dynamic value) {
    if (value == null) {
      return null;
    }
    
    // Handle primitive types
    if (value is T) {
      return value;
    }
    
    // Handle string-encoded JSON
    if (value is String && T != String) {
      try {
        return jsonDecode(value) as T;
      } catch (e) {
        // If decode fails, return as-is if type matches
        return value is T ? value as T : null;
      }
    }
    
    return value as T?;
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}
