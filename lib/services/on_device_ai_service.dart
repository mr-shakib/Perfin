import 'dart:async';
import 'ai_backend.dart';

/// Stub — on-device AI is disabled. Kept so provider wiring compiles.
class OnDeviceAIService implements AIBackend {
  bool _modelLoaded = false;
  String? _loadedModelId;

  @override
  String get name => 'On-Device';

  @override
  bool get isAvailable => _modelLoaded;

  @override
  bool get isOnDevice => true;

  String? get loadedModelId => _loadedModelId;

  Future<void> loadModel(String modelId, String modelPath) async {
    throw UnsupportedError('On-device AI is not available in this build.');
  }

  Future<void> unloadModel() async {
    _modelLoaded = false;
    _loadedModelId = null;
  }

  @override
  Future<String> complete(String prompt) async {
    return 'On-device AI is not available. Please use cloud AI.';
  }

  Stream<String> completeStream(String prompt) {
    return Stream.value('On-device AI is not available. Please use cloud AI.');
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    return {'loaded': false};
  }
}
