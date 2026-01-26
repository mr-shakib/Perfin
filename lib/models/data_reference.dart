/// Reference to data used in AI response
class DataReference {
  final String type;
  final String id;
  final String description;

  DataReference({
    required this.type,
    required this.id,
    required this.description,
  });

  /// Convert DataReference instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'description': description,
    };
  }

  /// Create DataReference instance from JSON map
  factory DataReference.fromJson(Map<String, dynamic> json) {
    return DataReference(
      type: json['type'] as String,
      id: json['id'] as String,
      description: json['description'] as String,
    );
  }

  @override
  String toString() {
    return 'DataReference(type: $type, id: $id, description: $description)';
  }
}
