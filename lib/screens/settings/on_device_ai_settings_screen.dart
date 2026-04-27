import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/on_device_model.dart';
import '../../providers/ai_provider.dart';
import '../../providers/on_device_ai_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/model_download_card.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BackendToggleSection(),
              const SizedBox(height: 20),
              const _ModelLibrarySection(),
              const SizedBox(height: 20),
              const _InfoSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E4DA)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Backend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose where Perfin runs AI inference.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.primaryLight),
          ),
          const SizedBox(height: 16),
          _BackendTile(
            title: 'Cloud (Groq)',
            subtitle: 'Fastest, requires internet. Uses Llama 3.3 70B.',
            icon: Icons.cloud_outlined,
            selected: !isOnDevice,
            onTap: () async {
              // unloadModel callback resets backend to cloud automatically.
              if (onDevice.isModelLoaded) await onDevice.unloadModel();
            },
          ),
          const Divider(height: 24),
          _BackendTile(
            title: 'On-Device (LFM2)',
            subtitle: onDevice.isModelLoaded
                ? 'Active — ${onDevice.loadedModelId}. Works offline.'
                : 'Download a model below to enable.',
            icon: Icons.phone_android_outlined,
            selected: isOnDevice,
            enabled: onDevice.isModelLoaded,
            onTap: onDevice.isModelLoaded
                ? () async {
                    await context.read<AIProvider>().switchBackend(
                          context.read<OnDeviceAIProvider>().onDeviceService,
                        );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _BackendTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _BackendTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.secondary : AppColors.primaryLight,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: enabled ? AppColors.primary : AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color:
                  selected ? AppColors.secondary : AppColors.primaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Model library ─────────────────────────────────────────────────────────────

class _ModelLibrarySection extends StatelessWidget {
  const _ModelLibrarySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Library',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        ...kAvailableOnDeviceModels
            .map((model) => ModelDownloadCard(model: model)),
      ],
    );
  }
}

// ── Info ──────────────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.primaryLight),
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
          const SizedBox(height: 10),
          _row(Icons.lock_outline,
              'Your financial data never leaves your device.'),
          _row(Icons.wifi_off_outlined,
              'Works completely offline once downloaded.'),
          _row(Icons.speed_outlined,
              'Response speed depends on your device hardware.'),
          _row(Icons.storage_outlined,
              'Models can be deleted any time from this screen.'),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.primaryLight)),
            ),
          ],
        ),
      );
}
