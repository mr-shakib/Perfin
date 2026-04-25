import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/on_device_model.dart';
import '../../providers/ai_provider.dart';
import '../../providers/on_device_ai_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/model_download_card.dart';

/// Settings screen for managing on-device AI models and backend selection.
class OnDeviceAISettingsScreen extends StatelessWidget {
  const OnDeviceAISettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('On-Device AI'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _BackendToggleSection(),
          SizedBox(height: 20),
          _ModelLibrarySection(),
          SizedBox(height: 20),
          _InfoSection(),
        ],
      ),
    );
  }
}

// ── Backend toggle ────────────────────────────────────────────────────────────

class _BackendToggleSection extends StatelessWidget {
  const _BackendToggleSection();

  @override
  Widget build(BuildContext context) {
    final ai = context.watch<AIProvider>();
    final onDevice = context.watch<OnDeviceAIProvider>();
    final isOnDevice = ai.isUsingOnDevice;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.creamCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Backend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
            const SizedBox(height: 4),
            Text(
              'Choose where Perfin runs AI inference.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.primaryLight),
            ),
            const SizedBox(height: 16),
            _BackendOption(
              title: 'Cloud (Groq)',
              subtitle: 'Fastest, requires internet. Uses Llama 3.3 70B.',
              icon: Icons.cloud_outlined,
              selected: !isOnDevice,
              onTap: () async {
                if (onDevice.isModelLoaded) await onDevice.unloadModel();
                if (context.mounted) {
                  await context.read<AIProvider>().switchBackend(
                        context.read<AIProvider>().activeBackend,
                        name: 'cloud',
                      );
                }
              },
            ),
            const Divider(height: 1),
            _BackendOption(
              title: 'On-Device (LFM2)',
              subtitle: onDevice.isModelLoaded
                  ? 'Active — ${onDevice.loadedModelId}. Works offline.'
                  : 'Download a model below to enable.',
              icon: Icons.phone_android_outlined,
              selected: isOnDevice,
              enabled: onDevice.isModelLoaded,
              onTap: onDevice.isModelLoaded
                  ? () async {
                      if (context.mounted) {
                        await context.read<AIProvider>().switchBackend(
                              context
                                  .read<OnDeviceAIProvider>()
                                  .onDeviceService,
                              name: 'on_device',
                            );
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _BackendOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: selected ? AppColors.secondary : AppColors.primaryLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.primary : AppColors.primaryLight,
        ),
      ),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryLight)),
      trailing: selected
          ? const Icon(Icons.radio_button_checked, color: AppColors.secondary)
          : const Icon(Icons.radio_button_off, color: AppColors.primaryLight),
      onTap: enabled ? onTap : null,
    );
  }
}

// ── Model library ─────────────────────────────────────────────────────────────

class _ModelLibrarySection extends StatelessWidget {
  const _ModelLibrarySection();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnDeviceAIProvider>(
      builder: (context, onDevice, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Model Library',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
            ),
            ...kAvailableOnDeviceModels.map(
              (model) => ModelDownloadCard(model: model),
            ),
          ],
        );
      },
    );
  }
}

// ── Info section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Text(
                  'About On-Device AI',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _InfoRow(
              icon: Icons.lock_outline,
              text: 'Your financial data never leaves your device.',
            ),
            const _InfoRow(
              icon: Icons.wifi_off_outlined,
              text: 'Works completely offline once the model is downloaded.',
            ),
            const _InfoRow(
              icon: Icons.speed_outlined,
              text: 'Response speed depends on your device hardware.',
            ),
            const _InfoRow(
              icon: Icons.storage_outlined,
              text: 'Models are stored in app support storage and can be deleted any time.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
