import 'dart:async';
import 'package:fllama/fllama.dart';
import 'ai_backend.dart';

/// On-device inference via fllama (llama.cpp wrapper).
///
/// Flow:
///   1. [loadModel] → calls fllama initContext, stores a contextId.
///   2. [complete] / [completeStream] → calls fllama completion, reads tokens
///      from onTokenStream, resolves when the completion Future finishes.
///   3. [unloadModel] → calls fllama releaseContext, clears state.
class OnDeviceAIService implements AIBackend {
  bool _modelLoaded = false;
  String? _loadedModelId;
  double? _contextId;

  @override
  String get name => 'On-Device (LFM2)';

  @override
  bool get isAvailable => _modelLoaded;

  @override
  bool get isOnDevice => true;

  String? get loadedModelId => _loadedModelId;

  Future<void> loadModel(String modelId, String modelPath) async {
    if (_contextId != null) {
      await Fllama.instance()!.releaseContext(_contextId!);
      _contextId = null;
      _modelLoaded = false;
    }

    final result = await Fllama.instance()!.initContext(
      modelPath,
      nCtx: 2048,
      nBatch: 512,
      nThreads: 4,
      nGpuLayers: 0,
      useMlock: true,
      useMmap: true,
    );

    final rawId = result?['contextId'];
    if (rawId == null) {
      throw Exception('fllama initContext returned no contextId — check model path: $modelPath');
    }

    _contextId = double.parse(rawId.toString());
    _modelLoaded = true;
    _loadedModelId = modelId;
  }

  Future<void> unloadModel() async {
    if (_contextId != null) {
      try {
        await Fllama.instance()!.stopCompletion(contextId: _contextId!);
      } catch (_) {}
      await Fllama.instance()!.releaseContext(_contextId!);
    }
    _contextId = null;
    _modelLoaded = false;
    _loadedModelId = null;
  }

  @override
  Future<String> complete(String prompt) async {
    if (!_modelLoaded || _contextId == null) {
      return 'On-device model is not loaded yet. Please download and load a model in Settings.';
    }

    final buffer = StringBuffer();
    StreamSubscription? sub;

    sub = Fllama.instance()!.onTokenStream?.listen((data) {
      if (data['function'] == 'completion') {
        final token = data['result']?['token'] as String? ?? '';
        buffer.write(token);
      }
    });

    try {
      await Fllama.instance()!.completion(
        _contextId!,
        prompt: prompt,
        nPredict: 512,
        temperature: 0.7,
        emitRealtimeCompletion: true,
        stop: ['<eos>', 'User:'],
      );
    } finally {
      await sub?.cancel();
    }

    return buffer.toString();
  }

  Stream<String> completeStream(String prompt) {
    if (!_modelLoaded || _contextId == null) {
      return Stream.value(
          'On-device model is not loaded yet. Please download and load a model in Settings.');
    }

    final controller = StreamController<String>();
    StreamSubscription? sub;

    sub = Fllama.instance()!.onTokenStream?.listen((data) {
      if (data['function'] == 'completion') {
        final token = data['result']?['token'] as String? ?? '';
        if (token.isNotEmpty && !controller.isClosed) controller.add(token);
      }
    });

    Fllama.instance()!
        .completion(
          _contextId!,
          prompt: prompt,
          nPredict: 512,
          temperature: 0.7,
          emitRealtimeCompletion: true,
          stop: ['<eos>', 'User:'],
        )
        .then((_) {
          sub?.cancel();
          if (!controller.isClosed) controller.close();
        })
        .catchError((e) {
          sub?.cancel();
          if (!controller.isClosed) {
            controller.addError(e);
            controller.close();
          }
        });

    return controller.stream;
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    return {
      'loaded': _modelLoaded,
      if (_loadedModelId != null) 'name': _loadedModelId,
    };
  }
}
