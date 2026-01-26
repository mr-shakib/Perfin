import 'data_reference.dart';

/// AI-generated response to a user query
class AIResponse {
  final String responseText;
  final int confidenceScore;
  final List<DataReference> dataReferences;
  final List<String> calculations;
  final bool requiresClarification;
  final List<String>? clarifyingQuestions;
  final DateTime generatedAt;

  AIResponse({
    required this.responseText,
    required this.confidenceScore,
    required this.dataReferences,
    required this.calculations,
    this.requiresClarification = false,
    this.clarifyingQuestions,
    required this.generatedAt,
  });

  /// Convert AIResponse instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'responseText': responseText,
      'confidenceScore': confidenceScore,
      'dataReferences': dataReferences.map((r) => r.toJson()).toList(),
      'calculations': calculations,
      'requiresClarification': requiresClarification,
      'clarifyingQuestions': clarifyingQuestions,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// Create AIResponse instance from JSON map
  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      responseText: json['responseText'] as String,
      confidenceScore: json['confidenceScore'] as int,
      dataReferences: (json['dataReferences'] as List)
          .map((r) => DataReference.fromJson(r as Map<String, dynamic>))
          .toList(),
      calculations: (json['calculations'] as List).cast<String>(),
      requiresClarification: json['requiresClarification'] as bool? ?? false,
      clarifyingQuestions: (json['clarifyingQuestions'] as List?)?.cast<String>(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'AIResponse(responseText: ${responseText.substring(0, responseText.length > 50 ? 50 : responseText.length)}..., '
        'confidenceScore: $confidenceScore, requiresClarification: $requiresClarification)';
  }
}
