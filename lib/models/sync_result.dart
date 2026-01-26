/// Result of a synchronization operation
class SyncResult {
  final int successCount;
  final int failureCount;
  final List<String> failedOperationIds;
  final DateTime syncedAt;

  SyncResult({
    required this.successCount,
    required this.failureCount,
    required this.failedOperationIds,
    required this.syncedAt,
  });

  /// Convert SyncResult instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'successCount': successCount,
      'failureCount': failureCount,
      'failedOperationIds': failedOperationIds,
      'syncedAt': syncedAt.toIso8601String(),
    };
  }

  /// Create SyncResult instance from JSON map
  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      successCount: json['successCount'] as int,
      failureCount: json['failureCount'] as int,
      failedOperationIds: (json['failedOperationIds'] as List).cast<String>(),
      syncedAt: DateTime.parse(json['syncedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'SyncResult(successCount: $successCount, failureCount: $failureCount, '
        'syncedAt: $syncedAt)';
  }
}
