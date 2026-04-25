import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/on_device_model.dart';
import 'storage_service.dart';

/// Manages downloading, verifying, and deleting on-device AI model files.
///
/// Model files are stored in the app's support directory under `models/`.
/// Download state is persisted in Hive so it survives app restarts.
class OnDeviceModelDownloadService {
  final StorageService _storage;
  final Dio _dio = Dio();

  // Active cancel tokens keyed by modelId so pauses/cancels work per-model.
  final Map<String, CancelToken> _cancelTokens = {};

  // Stream controllers for progress updates, one per modelId.
  final Map<String, StreamController<ModelDownloadProgress>> _progressControllers = {};

  OnDeviceModelDownloadService(this._storage);

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Returns a stream of download progress for [modelId].
  /// Callers should call [startDownload] after subscribing.
  Stream<ModelDownloadProgress> progressStream(String modelId) {
    _progressControllers[modelId] ??=
        StreamController<ModelDownloadProgress>.broadcast();
    return _progressControllers[modelId]!.stream;
  }

  /// Returns the current [DownloadState] for [modelId].
  Future<DownloadState> getState(String modelId) async {
    final raw = await _storage.load<String>(_stateKey(modelId));
    if (raw == null) return DownloadState.notDownloaded;
    return _parseState(raw);
  }

  /// Returns the local file path when the model is [DownloadState.ready],
  /// null otherwise.
  Future<String?> getModelPath(String modelId) async {
    final state = await getState(modelId);
    if (state != DownloadState.ready) return null;
    final file = await _modelFile(modelId);
    return file.existsSync() ? file.path : null;
  }

  /// Starts (or resumes) downloading [model].
  Future<void> startDownload(OnDeviceModelInfo model) async {
    final currentState = await getState(model.id);

    // Idempotent: skip if already ready or actively downloading.
    if (currentState == DownloadState.ready) return;
    if (currentState == DownloadState.downloading) return;

    await _setState(model.id, DownloadState.downloading);

    final file = await _modelFile(model.id);
    final existingBytes = file.existsSync() ? file.lengthSync() : 0;

    final cancelToken = CancelToken();
    _cancelTokens[model.id] = cancelToken;

    try {
      await _dio.download(
        model.downloadUrl,
        file.path,
        cancelToken: cancelToken,
        deleteOnError: false, // keep partial file so we can resume
        options: Options(
          headers: existingBytes > 0
              ? {'Range': 'bytes=$existingBytes-'}
              : null,
          receiveTimeout: const Duration(minutes: 30),
        ),
        onReceiveProgress: (received, total) {
          final totalBytes = total > 0 ? total : model.fileSizeBytes;
          final downloaded = existingBytes + received;
          final progress = downloaded / totalBytes;
          _progressControllers[model.id]?.add(ModelDownloadProgress(
            modelId: model.id,
            progress: progress.clamp(0.0, 1.0),
            downloadedBytes: downloaded,
            totalBytes: totalBytes,
          ));
        },
      );

      // Verify integrity before marking ready.
      await _setState(model.id, DownloadState.verifying);
      final valid = await _verifySha256(file, model.sha256);
      if (valid) {
        await _setState(model.id, DownloadState.ready);
      } else {
        await file.delete();
        await _setState(model.id, DownloadState.failed);
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // User paused — keep partial file, mark paused.
        await _setState(model.id, DownloadState.paused);
      } else {
        debugPrint('Download error for ${model.id}: $e');
        await _setState(model.id, DownloadState.failed);
      }
    } catch (e) {
      debugPrint('Unexpected download error for ${model.id}: $e');
      await _setState(model.id, DownloadState.failed);
    } finally {
      _cancelTokens.remove(model.id);
    }
  }

  /// Pauses an in-progress download. The partial file is kept for resuming.
  Future<void> pauseDownload(String modelId) async {
    _cancelTokens[modelId]?.cancel('paused');
  }

  /// Resumes a paused download.
  Future<void> resumeDownload(OnDeviceModelInfo model) =>
      startDownload(model);

  /// Deletes the local model file and resets state to [DownloadState.notDownloaded].
  Future<void> deleteModel(String modelId) async {
    _cancelTokens[modelId]?.cancel('deleted');
    final file = await _modelFile(modelId);
    if (file.existsSync()) await file.delete();
    await _storage.delete(_stateKey(modelId));
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<File> _modelFile(String modelId) async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!modelsDir.existsSync()) modelsDir.createSync(recursive: true);
    return File('${modelsDir.path}/$modelId.gguf');
  }

  String _stateKey(String modelId) => 'on_device_model_state_$modelId';

  Future<void> _setState(String modelId, DownloadState state) async {
    await _storage.save(_stateKey(modelId), state.name);
  }

  DownloadState _parseState(String raw) {
    return DownloadState.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => DownloadState.notDownloaded,
    );
  }

  /// Verifies SHA-256 of [file] against [expected].
  /// Returns true if they match, or if [expected] is the placeholder string
  /// (so dev/test builds pass without real hashes).
  Future<bool> _verifySha256(File file, String expected) async {
    if (expected == 'REPLACE_WITH_REAL_SHA256') return true;
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      final actual = digest.toString();
      final match = actual == expected;
      if (!match) debugPrint('SHA256 mismatch: expected $expected got $actual');
      return match;
    } catch (e) {
      debugPrint('SHA256 verification error: $e');
      return false;
    }
  }

  void dispose() {
    for (final token in _cancelTokens.values) {
      token.cancel('disposed');
    }
    for (final controller in _progressControllers.values) {
      controller.close();
    }
  }
}
