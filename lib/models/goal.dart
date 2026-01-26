/// Goal model representing a financial objective with target amount and deadline
class Goal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final String? linkedCategoryId;
  final bool isManualTracking;

  Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.linkedCategoryId,
    this.isManualTracking = false,
  });

  /// Calculate progress percentage: (current_amount / target_amount) * 100
  double get progressPercentage => (currentAmount / targetAmount) * 100;

  /// Calculate required monthly savings to reach goal
  double get requiredMonthlySavings {
    final now = DateTime.now();
    final monthsRemaining = (targetDate.year - now.year) * 12 +
        (targetDate.month - now.month);
    if (monthsRemaining <= 0) return 0;
    return (targetAmount - currentAmount) / monthsRemaining;
  }

  /// Calculate days remaining until target date
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  /// Convert Goal instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'linkedCategoryId': linkedCategoryId,
      'isManualTracking': isManualTracking,
    };
  }

  /// Create Goal instance from JSON map
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      linkedCategoryId: json['linkedCategoryId'] as String?,
      isManualTracking: json['isManualTracking'] as bool? ?? false,
    );
  }

  /// Create a copy of this Goal with updated fields
  Goal copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    String? linkedCategoryId,
    bool? isManualTracking,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedCategoryId: linkedCategoryId ?? this.linkedCategoryId,
      isManualTracking: isManualTracking ?? this.isManualTracking,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isCompleted == isCompleted &&
        other.linkedCategoryId == linkedCategoryId &&
        other.isManualTracking == isManualTracking;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        targetDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isCompleted.hashCode ^
        linkedCategoryId.hashCode ^
        isManualTracking.hashCode;
  }

  @override
  String toString() {
    return 'Goal(id: $id, userId: $userId, name: $name, '
        'targetAmount: $targetAmount, currentAmount: $currentAmount, '
        'targetDate: $targetDate, isCompleted: $isCompleted, '
        'linkedCategoryId: $linkedCategoryId, isManualTracking: $isManualTracking)';
  }
}
