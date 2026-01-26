/// User preferences for notifications
class NotificationPreferences {
  final String userId;
  final bool budgetAlerts;
  final bool recurringExpenseReminders;
  final bool goalDeadlineAlerts;
  final bool unusualSpendingAlerts;
  final DateTime updatedAt;

  NotificationPreferences({
    required this.userId,
    this.budgetAlerts = true,
    this.recurringExpenseReminders = true,
    this.goalDeadlineAlerts = true,
    this.unusualSpendingAlerts = true,
    required this.updatedAt,
  });

  /// Convert NotificationPreferences instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'budgetAlerts': budgetAlerts,
      'recurringExpenseReminders': recurringExpenseReminders,
      'goalDeadlineAlerts': goalDeadlineAlerts,
      'unusualSpendingAlerts': unusualSpendingAlerts,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create NotificationPreferences instance from JSON map
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      userId: json['userId'] as String,
      budgetAlerts: json['budgetAlerts'] as bool? ?? true,
      recurringExpenseReminders: json['recurringExpenseReminders'] as bool? ?? true,
      goalDeadlineAlerts: json['goalDeadlineAlerts'] as bool? ?? true,
      unusualSpendingAlerts: json['unusualSpendingAlerts'] as bool? ?? true,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy of this NotificationPreferences with updated fields
  NotificationPreferences copyWith({
    String? userId,
    bool? budgetAlerts,
    bool? recurringExpenseReminders,
    bool? goalDeadlineAlerts,
    bool? unusualSpendingAlerts,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      recurringExpenseReminders: recurringExpenseReminders ?? this.recurringExpenseReminders,
      goalDeadlineAlerts: goalDeadlineAlerts ?? this.goalDeadlineAlerts,
      unusualSpendingAlerts: unusualSpendingAlerts ?? this.unusualSpendingAlerts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences(userId: $userId, budgetAlerts: $budgetAlerts, '
        'recurringExpenseReminders: $recurringExpenseReminders, '
        'goalDeadlineAlerts: $goalDeadlineAlerts, unusualSpendingAlerts: $unusualSpendingAlerts)';
  }
}
