import 'package:perfin/services/storage_service.dart';

/// Mock implementation of StorageService for testing
class MockStorageService implements StorageService {
  final Map<String, dynamic> _storage = {};
  bool _initialized = false;

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<void> save<T>(String key, T value) async {
    if (!_initialized) {
      throw Exception('Storage not initialized');
    }
    _storage[key] = value;
  }

  @override
  Future<T?> load<T>(String key) async {
    if (!_initialized) {
      throw Exception('Storage not initialized');
    }
    return _storage[key] as T?;
  }

  @override
  Future<void> delete(String key) async {
    if (!_initialized) {
      throw Exception('Storage not initialized');
    }
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    if (!_initialized) {
      throw Exception('Storage not initialized');
    }
    _storage.clear();
  }
}
