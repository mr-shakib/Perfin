/// Response from AI bill/receipt analysis
class BillAnalysisResponse {
  final String message;
  final List<Map<String, dynamic>> transactions;
  final double confidence;

  BillAnalysisResponse({
    required this.message,
    required this.transactions,
    required this.confidence,
  });

  factory BillAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return BillAnalysisResponse(
      message: json['message'] as String,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => t as Map<String, dynamic>)
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'transactions': transactions,
      'confidence': confidence,
    };
  }
}
