/// Enum representing the status of a sync operation
enum SyncStatus {
  pending,
  inProgress,
  completed,
  failed;

  /// Convert SyncStatus to string for JSON serialization
  String toJson() => name;

  /// Create SyncStatus from string
  static SyncStatus fromJson(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw ArgumentError('Invalid sync status: $value'),
    );
  }
}

/// Operation queued for synchronization
class SyncOperation {
  final String id;
  final String operationType;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime queuedAt;
  final int retryCount;
  final SyncStatus status;

  SyncOperation({
    required this.id,
    required this.operationType,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.queuedAt,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
  });

  /// Convert SyncOperation instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operationType': operationType,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'queuedAt': queuedAt.toIso8601String(),
      'retryCount': retryCount,
      'status': status.toJson(),
    };
  }

  /// Create SyncOperation instance from JSON map
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      operationType: json['operationType'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: SyncStatus.fromJson(json['status'] as String),
    );
  }

  /// Create a copy of this SyncOperation with updated fields
  SyncOperation copyWith({
    String? id,
    String? operationType,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? queuedAt,
    int? retryCount,
    SyncStatus? status,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      queuedAt: queuedAt ?? this.queuedAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'SyncOperation(id: $id, operationType: $operationType, '
        'entityType: $entityType, entityId: $entityId, '
        'status: $status, retryCount: $retryCount)';
  }
}
