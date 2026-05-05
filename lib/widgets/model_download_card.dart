import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/on_device_model.dart';
import '../providers/on_device_ai_provider.dart';
import '../theme/app_colors.dart';

/// Card showing download state, progress and actions for one on-device model.
/// Uses only Column + Wrap layouts — no Row with unbounded width expansion.
class ModelDownloadCard extends StatelessWidget {
  final OnDeviceModelInfo model;
  const ModelDownloadCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final onDevice = context.watch<OnDeviceAIProvider>();
    final state = onDevice.stateOf(model.id);
    final progress = onDevice.progressOf(model.id);
    final isLoaded = onDevice.loadedModelId == model.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLoaded
            ? AppColors.success.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLoaded
              ? AppColors.success.withValues(alpha: 0.4)
              : const Color(0xFFE7E4DA),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ──
          Row(
            children: [
              Expanded(
                child: Text(
                  model.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (isLoaded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Active',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // ── Description ──
          Text(
            model.description,
            style: const TextStyle(fontSize: 13, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 8),

          // ── Meta chips ──
          Wrap(
            spacing: 8,
            children: [
              _Chip(model.fileSizeLabel, Icons.storage_outlined),
              _Chip(model.ramLabel, Icons.memory_outlined),
            ],
          ),

          // ── Progress bar ──
          if (state == DownloadState.downloading ||
              state == DownloadState.verifying) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state == DownloadState.verifying ? null : progress,
                minHeight: 6,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state == DownloadState.verifying
                  ? 'Verifying…'
                  : '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.primaryLight),
            ),
          ],

          const SizedBox(height: 12),

          // ── Action buttons ──
          _ActionButtons(model: model, state: state, isLoaded: isLoaded),
        ],
      ),
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryLight),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.primaryLight)),
        ],
      ),
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final OnDeviceModelInfo model;
  final DownloadState state;
  final bool isLoaded;

  const _ActionButtons({
    required this.model,
    required this.state,
    required this.isLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final onDevice = context.read<OnDeviceAIProvider>();

    switch (state) {
      // ── Not downloaded / failed ───────────────────────────────────────────
      case DownloadState.notDownloaded:
      case DownloadState.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state == DownloadState.failed)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Download failed. Tap Retry to try again.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            FilledButton.icon(
              onPressed: () => onDevice.startDownload(model),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text(
                '${state == DownloadState.failed ? 'Retry' : 'Download'} (${model.fileSizeLabel})',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );

      // ── Downloading ───────────────────────────────────────────────────────
      case DownloadState.downloading:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => onDevice.pauseDownload(model.id),
              icon: const Icon(Icons.pause_rounded, size: 16),
              label: const Text('Pause'),
            ),
            OutlinedButton.icon(
              onPressed: () => onDevice.deleteModel(model.id),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );

      // ── Paused ────────────────────────────────────────────────────────────
      case DownloadState.paused:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => onDevice.resumeDownload(model),
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Resume'),
            ),
            OutlinedButton.icon(
              onPressed: () => onDevice.deleteModel(model.id),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );

      // ── Verifying ─────────────────────────────────────────────────────────
      case DownloadState.verifying:
        return const SizedBox.shrink();

      // ── Ready ─────────────────────────────────────────────────────────────
      case DownloadState.ready:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isLoaded)
              FilledButton.icon(
                onPressed: () async {
                  try {
                    // Backend switch is handled inside loadModel via callback
                    // (before notifyListeners) to avoid the unmounted-context bug.
                    await onDevice.loadModel(model);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to load model: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red.shade700,
                    ));
                  }
                },
                icon: const Icon(Icons.bolt_rounded, size: 16),
                label: const Text('Use this model'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            if (isLoaded)
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    // unloadModel callback resets backend to cloud automatically.
                    await onDevice.unloadModel();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error unloading model: $e'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                icon: const Icon(Icons.cloud_outlined, size: 16),
                label: const Text('Switch to Cloud'),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, onDevice),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete model'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
    }
  }

  void _confirmDelete(
      BuildContext context, OnDeviceAIProvider onDevice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete model?'),
        content: Text(
          'This will remove ${model.displayName} (${model.fileSizeLabel}) from your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDevice.deleteModel(model.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
