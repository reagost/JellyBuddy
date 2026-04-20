import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jelly_llm/jelly_llm.dart';
import 'package:path_provider/path_provider.dart';

/// Definition of a downloadable model with its remote repository
/// and required file list.
class ModelDefinition {
  final String id;
  final String displayName;
  final String repoId;
  final List<String> files;
  final String format;
  final int approximateSizeBytes;

  const ModelDefinition({
    required this.id,
    required this.displayName,
    required this.repoId,
    required this.files,
    required this.format,
    required this.approximateSizeBytes,
  });
}

/// A remote source from which models can be downloaded.
class _DownloadSource {
  final String label;
  final String Function(String repoId, String file) urlBuilder;

  const _DownloadSource({required this.label, required this.urlBuilder});
}

/// Cross-platform model download service with 3-source fallback chain,
/// resumable downloads, atomic move on completion, and progress streaming.
class ModelDownloadService {
  ModelDownloadService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 10),
              sendTimeout: const Duration(seconds: 30),
            ));

  final Dio _dio;

  /// All Gemma model definitions across platforms.
  /// Use [platformModels] to get the appropriate list for the current OS.
  static const List<ModelDefinition> _allModels = [
    // --- Apple Platforms (iOS/iPadOS/macOS): MLX safetensors ---
    ModelDefinition(
      id: 'gemma-4-e2b-it-4bit',
      displayName: 'Gemma 4 E2B (MLX 4-bit)',
      repoId: 'mlx-community/gemma-4-e2b-it-4bit',
      files: [
        'config.json',
        'model.safetensors',
        'model.safetensors.index.json',
        'tokenizer.json',
        'tokenizer_config.json',
        'generation_config.json',
        'processor_config.json',
        'chat_template.jinja',
      ],
      format: 'safetensors',
      approximateSizeBytes: 3800000000, // ~3.8 GB
    ),

    // --- Android/Windows: GGUF for llama.cpp ---
    ModelDefinition(
      id: 'gemma-4-e2b-it-gguf',
      displayName: 'Gemma 4 E2B (GGUF Q4)',
      repoId: 'unsloth/gemma-4-E2B-it-GGUF',
      files: [
        'gemma-4-E2B-it-Q4_K_M.gguf',
      ],
      format: 'gguf',
      approximateSizeBytes: 2900000000, // ~2.9 GB
    ),
  ];

  /// Returns model definitions appropriate for the current platform.
  /// - Apple (iOS/macOS): MLX safetensors format
  /// - Android/Windows: GGUF format for llama.cpp
  static List<ModelDefinition> get platformModels {
    if (Platform.isIOS || Platform.isMacOS) {
      return _allModels.where((m) => m.format == 'safetensors').toList();
    } else {
      // Android, Windows, Linux
      return _allModels.where((m) => m.format == 'gguf').toList();
    }
  }

  /// All known models (both formats).
  static List<ModelDefinition> get knownModels => _allModels;

  /// 3-source fallback chain: ModelScope -> HF Mirror -> HuggingFace.
  static final List<_DownloadSource> _sources = [
    _DownloadSource(
      label: 'ModelScope',
      urlBuilder: (repoId, file) =>
          'https://modelscope.cn/models/$repoId/resolve/master/$file',
    ),
    _DownloadSource(
      label: 'HF Mirror',
      urlBuilder: (repoId, file) =>
          'https://hf-mirror.com/$repoId/resolve/main/$file',
    ),
    _DownloadSource(
      label: 'HuggingFace',
      urlBuilder: (repoId, file) =>
          'https://huggingface.co/$repoId/resolve/main/$file',
    ),
  ];

  /// Active cancel tokens keyed by model ID for cancellation support.
  final Map<String, CancelToken> _activeCancelTokens = {};

  /// Returns the base directory for storing models.
  Future<String> get _modelsBasePath async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/models';
  }

  /// Look up a [ModelDefinition] by ID across all known models.
  ModelDefinition? getDefinition(String modelId) {
    for (final def in _allModels) {
      if (def.id == modelId) return def;
    }
    return null;
  }

  /// Returns a list of [ModelInfo] for the current platform with download status.
  Future<List<ModelInfo>> getAvailableModels() async {
    final results = <ModelInfo>[];
    for (final def in platformModels) {
      final downloaded = await isModelDownloaded(def.id);
      results.add(ModelInfo(
        id: def.id,
        displayName: def.displayName,
        sizeBytes: def.approximateSizeBytes,
        format: def.format,
        isDownloaded: downloaded,
      ));
    }
    return results;
  }

  /// Check if all files for a model are present in the final directory.
  Future<bool> isModelDownloaded(String modelId) async {
    final def = getDefinition(modelId);
    if (def == null) return false;

    final basePath = await _modelsBasePath;
    final modelDir = Directory('$basePath/$modelId');
    if (!modelDir.existsSync()) return false;

    for (final file in def.files) {
      if (!File('${modelDir.path}/$file').existsSync()) {
        return false;
      }
    }
    return true;
  }

  /// Download all files for the given model, yielding [DownloadProgress]
  /// events throughout.
  ///
  /// Tries each download source in order for every file. On HTTP errors
  /// (4xx/5xx) or timeouts, falls back to the next source. Downloads to
  /// a `.partial` temporary directory and atomically renames on success.
  ///
  /// Supports resumable downloads via HTTP Range headers.
  Stream<DownloadProgress> downloadModel(String modelId) async* {
    final def = getDefinition(modelId);
    if (def == null) {
      throw ArgumentError('Unknown model ID: $modelId');
    }

    final basePath = await _modelsBasePath;
    final finalDir = Directory('$basePath/$modelId');
    final partialDir = Directory('$basePath/$modelId.partial');

    // If already fully downloaded, emit 100% and return.
    if (await isModelDownloaded(modelId)) {
      yield DownloadProgress(
        modelId: modelId,
        bytesReceived: def.approximateSizeBytes,
        totalBytes: def.approximateSizeBytes,
        currentFile: def.files.last,
        sourceLabel: 'local',
      );
      return;
    }

    // Ensure partial directory exists.
    if (!partialDir.existsSync()) {
      partialDir.createSync(recursive: true);
    }

    final cancelToken = CancelToken();
    _activeCancelTokens[modelId] = cancelToken;

    try {
      // Track cumulative progress across all files.
      int cumulativeBytesReceived = 0;
      // We cannot know exact total until headers are received, so use
      // the approximate size as the overall total for progress display.
      final overallTotal = def.approximateSizeBytes;

      for (int fileIdx = 0; fileIdx < def.files.length; fileIdx++) {
        final fileName = def.files[fileIdx];
        final partialFilePath = '${partialDir.path}/$fileName';
        final partialFile = File(partialFilePath);

        // Determine already-downloaded bytes for resume support.
        int existingBytes = 0;
        if (partialFile.existsSync()) {
          existingBytes = partialFile.lengthSync();
        }

        // Ensure parent directory exists (for nested file paths).
        final parentDir = partialFile.parent;
        if (!parentDir.existsSync()) {
          parentDir.createSync(recursive: true);
        }

        bool fileDownloaded = false;

        for (final source in _sources) {
          if (cancelToken.isCancelled) return;

          final url = source.urlBuilder(def.repoId, fileName);

          try {
            // Build headers for resumable download.
            final headers = <String, dynamic>{};
            if (existingBytes > 0) {
              headers['Range'] = 'bytes=$existingBytes-';
            }

            final response = await _dio.get<ResponseBody>(
              url,
              options: Options(
                responseType: ResponseType.stream,
                headers: headers,
                followRedirects: true,
                maxRedirects: 5,
                validateStatus: (status) =>
                    status != null && status >= 200 && status < 300,
              ),
              cancelToken: cancelToken,
            );

            final responseBody = response.data;
            if (responseBody == null) {
              continue; // Try next source.
            }

            // Determine file total from Content-Length / Content-Range.
            int? fileTotal;
            final contentRange =
                response.headers.value('content-range');
            final contentLength =
                response.headers.value('content-length');

            if (contentRange != null) {
              // Format: bytes 1000-9999/10000
              final match =
                  RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
              if (match != null) {
                fileTotal = int.tryParse(match.group(1)!);
              }
            } else if (contentLength != null) {
              final cl = int.tryParse(contentLength);
              if (cl != null) {
                fileTotal = cl + existingBytes;
              }
            }

            // Open file for appending.
            final sink = partialFile.openWrite(
              mode: existingBytes > 0 ? FileMode.append : FileMode.write,
            );

            int fileBytesReceived = existingBytes;

            try {
              await for (final chunk in responseBody.stream) {
                if (cancelToken.isCancelled) {
                  await sink.close();
                  return;
                }
                sink.add(chunk);
                fileBytesReceived += chunk.length;
                cumulativeBytesReceived += chunk.length;

                yield DownloadProgress(
                  modelId: modelId,
                  bytesReceived: cumulativeBytesReceived,
                  totalBytes: overallTotal,
                  currentFile: fileName,
                  sourceLabel: source.label,
                );
              }
              await sink.flush();
              await sink.close();
            } catch (e) {
              await sink.close();
              // Subtract what we counted so it's accurate on retry.
              cumulativeBytesReceived -= (fileBytesReceived - existingBytes);
              // Update existingBytes for potential resume with next source.
              if (partialFile.existsSync()) {
                existingBytes = partialFile.lengthSync();
              }
              continue; // Try next source.
            }

            // Verify we got something reasonable.
            if (fileTotal != null && fileBytesReceived < fileTotal) {
              // Incomplete download; subtract partial count and try next.
              cumulativeBytesReceived -= (fileBytesReceived - existingBytes);
              existingBytes = fileBytesReceived;
              continue;
            }

            fileDownloaded = true;
            break; // File successfully downloaded from this source.
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) return;
            // HTTP error or timeout: try next source.
            continue;
          }
        }

        if (!fileDownloaded) {
          throw Exception(
            'Failed to download "$fileName" for model "$modelId" '
            'from all sources.',
          );
        }
      }

      // All files downloaded. Atomic move: rename partial -> final.
      if (finalDir.existsSync()) {
        finalDir.deleteSync(recursive: true);
      }
      partialDir.renameSync(finalDir.path);

      // Emit final 100% progress.
      yield DownloadProgress(
        modelId: modelId,
        bytesReceived: overallTotal,
        totalBytes: overallTotal,
        currentFile: def.files.last,
        sourceLabel: 'complete',
      );
    } finally {
      _activeCancelTokens.remove(modelId);
    }
  }

  /// Cancel an in-progress download.
  void cancelDownload(String modelId) {
    final token = _activeCancelTokens.remove(modelId);
    token?.cancel('Download cancelled by user');
  }

  /// Delete downloaded model files (both final and partial).
  Future<void> deleteModel(String modelId) async {
    final basePath = await _modelsBasePath;
    final finalDir = Directory('$basePath/$modelId');
    final partialDir = Directory('$basePath/$modelId.partial');

    if (finalDir.existsSync()) {
      await finalDir.delete(recursive: true);
    }
    if (partialDir.existsSync()) {
      await partialDir.delete(recursive: true);
    }
  }

  /// Returns the local path to a downloaded model's directory, or null
  /// if the model is not downloaded.
  Future<String?> getModelPath(String modelId) async {
    if (!await isModelDownloaded(modelId)) return null;
    final basePath = await _modelsBasePath;
    return '$basePath/$modelId';
  }

  /// Dispose the Dio client.
  void dispose() {
    _dio.close();
  }
}
