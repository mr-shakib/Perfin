import 'dart:convert';
import 'dart:math';
import '../models/sync_operation.dart';
import '../models/sync_result.dart';
import 'storage_service.dart';

/// Service responsible for offline data synchronization
/// Manages sync queue and handles retry logic with exponential backoff
class SyncService {
  final StorageService _storageService;

  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncTimeKeyPrefix = 'last_sync_time_';
  static const int _maxRetries = 3;
  static const int _baseBackoffMs = 1000; // 1 second
  static const int _staleDataThresholdHours = 24;

  SyncService(this._storageService);

  /// Queue an operation for synchronization
  /// Operations are stored locally and synced when connection is available
  Future<void> queueOperation({
    required SyncOperation operation,
  }) async {
    try {
      // Load existing queue
      final queue = await _loadSyncQueue();

      // Check if operation already exists (by entity ID and type)
      final existingIndex = queue.indexWhere((op) =>
          op.entityId == operation.entityId &&
          op.entityType == operation.entityType &&
          op.operationType == operation.operationType);

      if (existingIndex != -1) {
        // Update existing operation
        queue[existingIndex] = operation;
      } else {
        // Add new operation
        queue.add(operation);
      }

      // Save updated queue
      await _saveSyncQueue(queue);
    } catch (e) {
      throw SyncServiceException(
          'Failed to queue operation: ${e.toString()}');
    }
  }

  /// Process all pending operations in the sync queue
  /// Implements exponential backoff retry logic (max 3 attempts)
  /// Returns result with success/failure counts
  Future<SyncResult> processSyncQueue() async {
    try {
      final queue = await _loadSyncQueue();
      int successCount = 0;
      int failureCount = 0;
      final List<String> failedOperationIds = [];

      // Process each pending operation
      for (final operation in queue) {
        if (operation.status == SyncStatus.completed) {
          successCount++;
          continue;
        }

        // Check if max retries exceeded
        if (operation.retryCount >= _maxRetries) {
          failureCount++;
          failedOperationIds.add(operation.id);
          continue;
        }

        // Update operation status to in progress
        final updatedOp = operation.copyWith(status: SyncStatus.inProgress);
        await _updateOperationInQueue(updatedOp);

        // Attempt to sync
        final success = await _syncOperation(updatedOp);

        if (success) {
          // Mark as completed
          final completedOp = updatedOp.copyWith(status: SyncStatus.completed);
          await _updateOperationInQueue(completedOp);
          successCount++;
        } else {
          // Increment retry count and mark as failed
          final failedOp = updatedOp.copyWith(
            status: SyncStatus.failed,
            retryCount: updatedOp.retryCount + 1,
          );
          await _updateOperationInQueue(failedOp);

          // Apply exponential backoff delay before next retry
          final backoffMs = _calculateBackoff(failedOp.retryCount);
          await Future.delayed(Duration(milliseconds: backoffMs));

          if (failedOp.retryCount >= _maxRetries) {
            failureCount++;
            failedOperationIds.add(failedOp.id);
          }
        }
      }

      // Clean up completed operations from queue
      await _cleanupCompletedOperations();

      return SyncResult(
        successCount: successCount,
        failureCount: failureCount,
        failedOperationIds: failedOperationIds,
        syncedAt: DateTime.now(),
      );
    } catch (e) {
      throw SyncServiceException(
          'Failed to process sync queue: ${e.toString()}');
    }
  }

  /// Check if cached data is stale (older than 24 hours)
  bool isDataStale({
    required DateTime lastSyncTime,
  }) {
    final hoursSinceSync = DateTime.now().difference(lastSyncTime).inHours;
    return hoursSinceSync >= _staleDataThresholdHours;
  }

  /// Force sync all data for a user
  /// Triggers immediate synchronization of all pending operations
  Future<SyncResult> forceSyncAll({
    required String userId,
  }) async {
    try {
      // Process the sync queue
      final result = await processSyncQueue();

      // Update last sync time
      await _updateLastSyncTime(userId);

      return result;
    } catch (e) {
      throw SyncServiceException('Failed to force sync: ${e.toString()}');
    }
  }

  /// Get current sync status
  /// Returns information about pending operations and last sync time
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final queue = await _loadSyncQueue();

      final pendingCount =
          queue.where((op) => op.status == SyncStatus.pending).length;
      final inProgressCount =
          queue.where((op) => op.status == SyncStatus.inProgress).length;
      final failedCount =
          queue.where((op) => op.status == SyncStatus.failed).length;
      final completedCount =
          queue.where((op) => op.status == SyncStatus.completed).length;

      return {
        'totalOperations': queue.length,
        'pendingCount': pendingCount,
        'inProgressCount': inProgressCount,
        'failedCount': failedCount,
        'completedCount': completedCount,
        'hasFailedOperations': failedCount > 0,
      };
    } catch (e) {
      throw SyncServiceException('Failed to get sync status: ${e.toString()}');
    }
  }

  /// Attempt to sync a single operation
  /// Returns true if successful, false otherwise
  /// In a real implementation, this would make API calls to Supabase
  Future<bool> _syncOperation(SyncOperation operation) async {
    try {
      // TODO: Implement actual sync logic with Supabase
      // For now, simulate sync with a delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate 80% success rate for testing
      // In production, this would be actual API calls
      return Random().nextDouble() > 0.2;
    } catch (e) {
      return false;
    }
  }

  /// Calculate exponential backoff delay in milliseconds
  /// Formula: base_delay * 2^(retry_count - 1)
  int _calculateBackoff(int retryCount) {
    if (retryCount <= 0) return 0;
    return _baseBackoffMs * pow(2, retryCount - 1).toInt();
  }

  /// Load sync queue from storage
  Future<List<SyncOperation>> _loadSyncQueue() async {
    try {
      final queueData = await _storageService.load<String>(_syncQueueKey);

      if (queueData == null) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(queueData);
      return jsonList
          .map((json) => SyncOperation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SyncServiceException('Failed to load sync queue: ${e.toString()}');
    }
  }

  /// Save sync queue to storage
  Future<void> _saveSyncQueue(List<SyncOperation> queue) async {
    try {
      final jsonList = queue.map((op) => op.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _storageService.save(_syncQueueKey, jsonString);
    } catch (e) {
      throw SyncServiceException('Failed to save sync queue: ${e.toString()}');
    }
  }

  /// Update a specific operation in the queue
  Future<void> _updateOperationInQueue(SyncOperation operation) async {
    try {
      final queue = await _loadSyncQueue();
      final index = queue.indexWhere((op) => op.id == operation.id);

      if (index != -1) {
        queue[index] = operation;
        await _saveSyncQueue(queue);
      }
    } catch (e) {
      throw SyncServiceException(
          'Failed to update operation in queue: ${e.toString()}');
    }
  }

  /// Remove completed operations from queue
  Future<void> _cleanupCompletedOperations() async {
    try {
      final queue = await _loadSyncQueue();

      // Keep only non-completed operations
      final activeQueue =
          queue.where((op) => op.status != SyncStatus.completed).toList();

      await _saveSyncQueue(activeQueue);
    } catch (e) {
      // Don't throw on cleanup failure
      print('Failed to cleanup completed operations: ${e.toString()}');
    }
  }

  /// Update last sync time for a user
  Future<void> _updateLastSyncTime(String userId) async {
    try {
      final key = _getLastSyncTimeKey(userId);
      final timestamp = DateTime.now().toIso8601String();
      await _storageService.save(key, timestamp);
    } catch (e) {
      // Don't throw on timestamp update failure
      print('Failed to update last sync time: ${e.toString()}');
    }
  }

  /// Get last sync time for a user
  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final key = _getLastSyncTimeKey(userId);
      final timestamp = await _storageService.load<String>(key);

      if (timestamp == null) {
        return null;
      }

      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Get storage key for last sync time
  String _getLastSyncTimeKey(String userId) {
    return '$_lastSyncTimeKeyPrefix$userId';
  }
}

/// Custom exception for sync service operations
class SyncServiceException implements Exception {
  final String message;

  SyncServiceException(this.message);

  @override
  String toString() => 'SyncServiceException: $message';
}
