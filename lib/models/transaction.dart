/// Enum representing the type of transaction
enum TransactionType {
  income,
  expense;

  /// Convert TransactionType to string for JSON serialization
  String toJson() => name;

  /// Create TransactionType from string
  static TransactionType fromJson(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw ArgumentError('Invalid transaction type: $value'),
    );
  }
}

/// Transaction model representing a financial record
class Transaction {
  final String id;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? notes;
  final String userId;
  final bool isSynced;
  final String? linkedGoalId;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.notes,
    required this.userId,
    this.isSynced = true,
    this.linkedGoalId,
  });

  /// Validate the transaction
  /// Returns true if all validation rules pass
  bool isValid() {
    // Amount must be positive
    if (amount <= 0) {
      return false;
    }

    // Category must not be empty
    if (category.trim().isEmpty) {
      return false;
    }

    // Date cannot be in the future
    if (date.isAfter(DateTime.now())) {
      return false;
    }

    return true;
  }

  /// Convert Transaction instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': type.toJson(),
      'date': date.toIso8601String(),
      'notes': notes,
      'userId': userId,
      'isSynced': isSynced,
      'linkedGoalId': linkedGoalId,
    };
  }

  /// Convert Transaction to Supabase-compatible JSON (excludes local-only fields)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': type.toJson(),
      'date': date.toIso8601String(),
      'notes': notes,
      'user_id': userId, // Note: Supabase uses snake_case
    };
  }

  /// Create Transaction instance from JSON map
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      type: TransactionType.fromJson(json['type'] as String),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
      isSynced: json['isSynced'] as bool? ?? true,
      linkedGoalId: json['linkedGoalId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.type == type &&
        other.date == date &&
        other.notes == notes &&
        other.userId == userId &&
        other.isSynced == isSynced &&
        other.linkedGoalId == linkedGoalId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        type.hashCode ^
        date.hashCode ^
        notes.hashCode ^
        userId.hashCode ^
        isSynced.hashCode ^
        linkedGoalId.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, category: $category, '
        'type: $type, date: $date, notes: $notes, userId: $userId, '
        'isSynced: $isSynced, linkedGoalId: $linkedGoalId)';
  }
}
