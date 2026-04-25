import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/on_device_model.dart';
import '../services/on_device_ai_service.dart';
import '../services/on_device_model_download_service.dart';
import '../services/storage_service.dart';

/// Manages the lifecycle of on-device AI models:
/// download state, progress, device capability checks, and model loading.
class OnDeviceAIProvider extends ChangeNotifier {
  final OnDeviceModelDownloadService _downloadService;
  final OnDeviceAIService _aiService;
  final StorageService _storage;

  // Per-model download state (populated lazily).
  final Map<String, DownloadState> _states = {};
  final Map<String, double> _progress = {};

  // Active stream subscriptions for in-progress downloads.
  final Map<String, StreamSubscription<ModelDownloadProgress>> _subs = {};

  // Device RAM in MB — loaded once on first use.
  int? _deviceRamMB;

  OnDeviceAIProvider(this._downloadService, this._aiService, this._storage) {
    _init();
  }

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isModelLoaded => _aiService.isAvailable;
  String? get loadedModelId => _aiService.loadedModelId;

  /// Exposes the underlying service so callers can pass it as an [AIBackend].
  OnDeviceAIService get onDeviceService => _aiService;

  DownloadState stateOf(String modelId) =>
      _states[modelId] ?? DownloadState.notDownloaded;

  double progressOf(String modelId) => _progress[modelId] ?? 0.0;

  int? get deviceRamMB => _deviceRamMB;

  /// Whether the device meets the RAM requirement for [model].
  bool meetsRequirements(OnDeviceModelInfo model) {
    if (_deviceRamMB == null) return true; // unknown → allow
    return _deviceRamMB! >= model.minRamMB;
  }

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    await _loadDeviceRam();
    for (final model in kAvailableOnDeviceModels) {
      _states[model.id] = await _downloadService.getState(model.id);
    }
    notifyListeners();
  }

  Future<void> _loadDeviceRam() async {
    try {
      // Neither iOS nor Android exposes physical RAM to Flutter apps via
      // device_info_plus, so we keep _deviceRamMB null and allow all downloads.
      // Replace this body when a platform-specific RAM API becomes available.
      _deviceRamMB = null;
    } catch (_) {
      _deviceRamMB = null;
    }
  }

  // ─── Download lifecycle ────────────────────────────────────────────────────

  Future<void> startDownload(OnDeviceModelInfo model) async {
    if (_states[model.id] == DownloadState.downloading) return;

    _states[model.id] = DownloadState.downloading;
    _progress[model.id] = 0.0;
    notifyListeners();

    // Subscribe to progress stream before starting.
    _subs[model.id]?.cancel();
    _subs[model.id] = _downloadService
        .progressStream(model.id)
        .listen((p) {
      _progress[model.id] = p.progress;
      notifyListeners();
    });

    await _downloadService.startDownload(model);

    // After download completes, refresh state from storage.
    _subs[model.id]?.cancel();
    _subs.remove(model.id);
    _states[model.id] = await _downloadService.getState(model.id);
    notifyListeners();
  }

  Future<void> pauseDownload(String modelId) async {
    await _downloadService.pauseDownload(modelId);
    _states[modelId] = DownloadState.paused;
    notifyListeners();
  }

  Future<void> resumeDownload(OnDeviceModelInfo model) =>
      startDownload(model);

  Future<void> retryDownload(OnDeviceModelInfo model) async {
    _states[model.id] = DownloadState.notDownloaded;
    notifyListeners();
    await startDownload(model);
  }

  // ─── Model loading ─────────────────────────────────────────────────────────

  /// Loads the [model] into the LEAP inference engine.
  /// The model must be in [DownloadState.ready] first.
  Future<void> loadModel(OnDeviceModelInfo model) async {
    if (_states[model.id] != DownloadState.ready) return;
    final path = await _downloadService.getModelPath(model.id);
    if (path == null) return;
    await _aiService.loadModel(model.id, path);
    // Persist last-loaded model so we can auto-load on next launch.
    await _storage.save('on_device_last_loaded_model', model.id);
    notifyListeners();
  }

  Future<void> unloadModel() async {
    await _aiService.unloadModel();
    await _storage.delete('on_device_last_loaded_model');
    notifyListeners();
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteModel(String modelId) async {
    if (_aiService.loadedModelId == modelId) await _aiService.unloadModel();
    await _downloadService.deleteModel(modelId);
    _states[modelId] = DownloadState.notDownloaded;
    _progress.remove(modelId);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subs.values) {
      sub.cancel();
    }
    _downloadService.dispose();
    super.dispose();
  }
}
