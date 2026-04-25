import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Contract for all AI inference backends (cloud or on-device).
abstract class AIBackend {
  /// Human-readable name shown in the UI.
  String get name;

  /// Whether this backend is ready to accept requests.
  bool get isAvailable;

  /// Send [prompt] and return the model's text response.
  Future<String> complete(String prompt);
}

/// Groq cloud backend — OpenAI-compatible API.
class GroqBackend implements AIBackend {
  final String _apiKey;
  final String _baseUrl = 'https://api.groq.com/openai/v1';
  final String _model = 'llama-3.3-70b-versatile';

  GroqBackend(this._apiKey);

  @override
  String get name => 'Cloud (Groq)';

  @override
  bool get isAvailable => _apiKey.isNotEmpty;

  @override
  Future<String> complete(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content == null) {
          debugPrint('Groq returned null content: ${response.body}');
          return 'I received an empty response. Please try again.';
        }
        return content as String;
      } else {
        debugPrint('Groq error: ${response.statusCode} - ${response.body}');
        return 'I encountered an error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      debugPrint('Groq call error: $e');
      return 'I\'m having trouble connecting. Please check your internet connection and try again.';
    }
  }
}
