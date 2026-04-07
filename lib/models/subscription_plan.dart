/// Subscription plan options for monetization.
enum SubscriptionPlan {
  free,
  pro,
  family;

  String toJson() => name;

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.family:
        return 'Family';
    }
  }

  static SubscriptionPlan fromJson(String value) {
    return SubscriptionPlan.values.firstWhere(
      (plan) => plan.name == value,
      orElse: () => SubscriptionPlan.free,
    );
  }
}

/// Subscription lifecycle status.
enum SubscriptionStatus {
  active,
  trialing,
  canceled,
  pastDue,
  expired;

  String toJson() => name;

  static SubscriptionStatus fromJson(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SubscriptionStatus.active,
    );
  }
}

/// User subscription state.
class SubscriptionInfo {
  final String? id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime updatedAt;

  SubscriptionInfo({
    this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    required this.updatedAt,
  });

  factory SubscriptionInfo.free({required String userId}) {
    final now = DateTime.now();
    final periodStart = DateTime(now.year, now.month, 1);
    final periodEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return SubscriptionInfo(
      userId: userId,
      plan: SubscriptionPlan.free,
      status: SubscriptionStatus.active,
      periodStart: periodStart,
      periodEnd: periodEnd,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.toJson(),
      'status': status.toJson(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      plan: SubscriptionPlan.fromJson(json['plan'] as String),
      status: SubscriptionStatus.fromJson(json['status'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  SubscriptionInfo copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? updatedAt,
  }) {
    return SubscriptionInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
