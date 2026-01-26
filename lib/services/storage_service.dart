/// Abstract interface for storage operations
/// Provides a generic interface for persisting and retrieving data
abstract class StorageService {
  /// Initialize the storage service
  /// Must be called before any other operations
  Future<void> init();

  /// Save a value with the given key
  /// [key] - The unique identifier for the value
  /// [value] - The value to store (must be JSON-serializable)
  Future<void> save<T>(String key, T value);

  /// Load a value by key
  /// [key] - The unique identifier for the value
  /// Returns the stored value or null if not found
  Future<T?> load<T>(String key);

  /// Delete a value by key
  /// [key] - The unique identifier for the value to delete
  Future<void> delete(String key);

  /// Clear all stored data
  Future<void> clear();
}
