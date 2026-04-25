import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/on_device_model.dart';
import '../providers/on_device_ai_provider.dart';
import '../providers/ai_provider.dart';
import '../theme/app_colors.dart';

/// Card showing download state, progress, and actions for a single on-device model.
class ModelDownloadCard extends StatelessWidget {
  final OnDeviceModelInfo model;

  const ModelDownloadCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final onDeviceProvider = context.watch<OnDeviceAIProvider>();
    final state = onDeviceProvider.stateOf(model.id);
    final progress = onDeviceProvider.progressOf(model.id);
    final isLoaded = onDeviceProvider.loadedModelId == model.id;
    final meetsReqs = onDeviceProvider.meetsRequirements(model);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: isLoaded
          ? AppColors.success.withValues(alpha: 0.08)
          : AppColors.creamCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(model: model, isLoaded: isLoaded),
            const SizedBox(height: 4),
            Text(
              model.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            _MetaRow(model: model),
            if (!meetsReqs) ...[
              const SizedBox(height: 8),
              _WarningBanner('Device may not meet the ${model.ramLabel}.'),
            ],
            if (state == DownloadState.downloading ||
                state == DownloadState.verifying) ...[
              const SizedBox(height: 12),
              _ProgressBar(progress: progress, state: state),
            ],
            const SizedBox(height: 12),
            _Actions(model: model, state: state, isLoaded: isLoaded),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final OnDeviceModelInfo model;
  final bool isLoaded;

  const _Header({required this.model, required this.isLoaded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            model.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        ),
        if (isLoaded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final OnDeviceModelInfo model;
  const _MetaRow({required this.model});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(model.fileSizeLabel, Icons.storage_outlined),
        const SizedBox(width: 8),
        _Chip(model.ramLabel, Icons.memory_outlined),
      ],
    );
  }
}

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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final DownloadState state;
  const _ProgressBar({required this.progress, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: state == DownloadState.verifying ? null : progress,
            minHeight: 6,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state == DownloadState.verifying
              ? 'Verifying integrity…'
              : '${(progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final OnDeviceModelInfo model;
  final DownloadState state;
  final bool isLoaded;

  const _Actions({
    required this.model,
    required this.state,
    required this.isLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final onDevice = context.read<OnDeviceAIProvider>();
    final aiProvider = context.read<AIProvider>();

    switch (state) {
      case DownloadState.notDownloaded:
      case DownloadState.failed:
        return Row(
          children: [
            if (state == DownloadState.failed)
              const Text(
                'Download failed.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => onDevice.startDownload(model),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: Text(
                  '${state == DownloadState.failed ? 'Retry' : 'Download'} (${model.fileSizeLabel})'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white),
            ),
          ],
        );

      case DownloadState.downloading:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => onDevice.pauseDownload(model.id),
              icon: const Icon(Icons.pause_rounded, size: 16),
              label: const Text('Pause'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => onDevice.deleteModel(model.id),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );

      case DownloadState.paused:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => onDevice.resumeDownload(model),
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Resume'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => onDevice.deleteModel(model.id),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );

      case DownloadState.verifying:
        return const SizedBox.shrink();

      case DownloadState.ready:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isLoaded)
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await onDevice.loadModel(model);
                    if (!context.mounted) return;
                    await aiProvider.switchBackend(
                      context.read<OnDeviceAIProvider>().onDeviceService,
                      name: 'on_device',
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load model: $e'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.bolt_rounded, size: 16),
                label: const Text('Use this model'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
              ),
            if (isLoaded)
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await onDevice.unloadModel();
                    if (!context.mounted) return;
                    await aiProvider.switchBackend(
                      context.read<AIProvider>().activeBackend,
                      name: 'cloud',
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error switching backend: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.cloud_outlined, size: 16),
                label: const Text('Switch to Cloud'),
              ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, onDevice),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
    }
  }

  void _confirmDelete(BuildContext context, OnDeviceAIProvider onDevice) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete model?'),
        content: Text(
            'This will remove the ${model.displayName} file (${model.fileSizeLabel}) from your device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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
