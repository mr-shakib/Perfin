/// Enum representing the role of a chat message sender
enum MessageRole {
  user,
  assistant;

  /// Convert MessageRole to string for JSON serialization
  String toJson() => name;

  /// Create MessageRole from string
  static MessageRole fromJson(String value) {
    return MessageRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => throw ArgumentError('Invalid message role: $value'),
    );
  }
}

/// Chat message in the Copilot conversation
class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata,
  });

  /// Convert ChatMessage instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'role': role.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create ChatMessage instance from JSON map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, userId: $userId, role: $role, '
        'content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., '
        'timestamp: $timestamp)';
  }
}
