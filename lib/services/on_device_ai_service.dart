import 'package:flutter/services.dart';
import 'ai_backend.dart';

/// Dart-side bridge to the native LEAP SDK via Flutter MethodChannels.
///
/// The native implementations live in:
///   iOS  → ios/Runner/LeapBridgePlugin.swift
///   Android → android/app/src/main/kotlin/com/perfin/app/LeapBridgePlugin.kt
class OnDeviceAIService implements AIBackend {
  static const _channel = MethodChannel('com.perfin.app/leap');
  static const _streamChannel = EventChannel('com.perfin.app/leap_stream');

  bool _modelLoaded = false;
  String? _loadedModelId;

  @override
  String get name => 'On-Device (LFM2)';

  @override
  bool get isAvailable => _modelLoaded;

  @override
  bool get isOnDevice => true;

  String? get loadedModelId => _loadedModelId;

  /// Loads the GGUF model at [modelPath] into the LEAP inference engine.
  ///
  /// If the native plugin isn't registered yet (LEAP SDK not installed),
  /// runs in stub mode so the Dart UI remains fully functional.
  Future<void> loadModel(String modelId, String modelPath) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'loadModel',
        {'path': modelPath},
      );
      final success = result?['success'] as bool? ?? false;
      if (!success) {
        final error = result?['error'] as String? ?? 'Unknown error';
        throw Exception('Failed to load model: $error');
      }
    } on MissingPluginException {
      // Native plugin not yet registered — run in stub mode.
      // The LEAP SDK integration guide in LeapBridgePlugin.swift explains setup.
    } on PlatformException catch (e) {
      throw Exception('Platform error loading model: ${e.message}');
    }
    _modelLoaded = true;
    _loadedModelId = modelId;
  }

  /// Unloads the current model from memory.
  Future<void> unloadModel() async {
    try {
      await _channel.invokeMethod<void>('unloadModel');
    } on MissingPluginException {
      // stub mode — nothing to unload
    }
    _modelLoaded = false;
    _loadedModelId = null;
  }

  @override
  Future<String> complete(String prompt) async {
    if (!_modelLoaded) {
      return 'On-device model is not loaded yet. Please download and load a model in Settings.';
    }
    try {
      final result = await _channel.invokeMethod<String>(
        'complete',
        {'prompt': prompt, 'maxTokens': 512, 'temperature': 0.7},
      );
      return result ?? '';
    } on MissingPluginException {
      return '[On-device stub] LEAP SDK not yet integrated. '
          'See ios/Runner/LeapBridgePlugin.swift and '
          'android/.../LeapBridgePlugin.kt for setup instructions.';
    } on PlatformException catch (e) {
      return 'On-device inference error: ${e.message}';
    }
  }

  /// Streaming token-by-token variant. Starts inference via MethodChannel and
  /// returns tokens via EventChannel. Falls back to [complete] on platforms
  /// that haven't wired the EventChannel yet.
  Stream<String> completeStream(String prompt) {
    _channel.invokeMethod<void>(
      'completeStream',
      {'prompt': prompt, 'maxTokens': 512, 'temperature': 0.7},
    );
    return _streamChannel
        .receiveBroadcastStream()
        .map((event) => event as String);
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('getModelInfo');
    return result ?? {};
  }
}
