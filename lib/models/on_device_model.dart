/// State of a downloadable on-device model.
enum DownloadState {
  notDownloaded,
  downloading,
  paused,
  verifying,
  ready,
  failed,
}

/// Metadata for a downloadable Liquid AI LFM2 model.
class OnDeviceModelInfo {
  final String id;
  final String displayName;
  final String description;
  final String downloadUrl;
  final int fileSizeBytes;
  final String sha256;
  final int minRamMB;
  final int parametersBillions; // e.g. 1 for 1.2B, 0 for 350M

  const OnDeviceModelInfo({
    required this.id,
    required this.displayName,
    required this.description,
    required this.downloadUrl,
    required this.fileSizeBytes,
    required this.sha256,
    required this.minRamMB,
    required this.parametersBillions,
  });

  String get fileSizeLabel {
    final gb = fileSizeBytes / (1024 * 1024 * 1024);
    if (gb >= 1) return '${gb.toStringAsFixed(1)} GB';
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  String get ramLabel => '${minRamMB ~/ 1024} GB RAM required';
}

/// Download progress snapshot for a single model.
class ModelDownloadProgress {
  final String modelId;
  final double progress; // 0.0 – 1.0
  final int downloadedBytes;
  final int totalBytes;

  const ModelDownloadProgress({
    required this.modelId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
  });
}

/// Catalogue of available Liquid AI LFM2 models.
///
/// URLs point to quantised GGUF builds hosted on HuggingFace.
/// Replace sha256 values with the real hashes from the HuggingFace file cards
/// before shipping.
const List<OnDeviceModelInfo> kAvailableOnDeviceModels = [
  OnDeviceModelInfo(
    id: 'lfm2.5-1.2b-instruct',
    displayName: 'LFM2.5 1.2B Instruct',
    description: 'Recommended — best quality for finance chat.',
    downloadUrl:
        'https://huggingface.co/LiquidAI/LFM2.5-1.2B-Instruct-GGUF/resolve/main/LFM2.5-1.2B-Instruct-Q4_K_M.gguf',
    fileSizeBytes: 760_000_000, // ~760 MB for Q4_K_M quant
    sha256: 'REPLACE_WITH_REAL_SHA256',
    minRamMB: 3072,
    parametersBillions: 1,
  ),
  OnDeviceModelInfo(
    id: 'lfm2-350m',
    displayName: 'LFM2 350M Lite',
    description: 'Smallest model — works on low-end devices.',
    downloadUrl:
        'https://huggingface.co/LiquidAI/LFM2-350M-GGUF/resolve/main/LFM2-350M-Q4_K_M.gguf',
    fileSizeBytes: 230_000_000, // ~230 MB for Q4_K_M quant
    sha256: 'REPLACE_WITH_REAL_SHA256',
    minRamMB: 2048,
    parametersBillions: 0,
  ),
];
