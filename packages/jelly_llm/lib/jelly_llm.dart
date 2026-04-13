/// JellyLlm — Cross-platform local LLM inference for JellyBuddy.
///
/// Provides on-device text generation using platform-native engines:
/// - Apple (iOS/iPadOS/macOS): MLX with Metal GPU acceleration
/// - Android: llama.cpp with Vulkan/CPU
/// - Windows: llama.cpp with CUDA/CPU
library jelly_llm;

import 'src/jelly_llm_platform_interface.dart';
import 'src/models/generation_config.dart';
import 'src/models/llm_engine_state.dart';
import 'src/models/llm_stats.dart';
import 'src/models/model_info.dart';
import 'src/models/download_progress.dart';

export 'src/models/llm_engine_state.dart';
export 'src/models/llm_stats.dart';
export 'src/models/model_info.dart';
export 'src/models/generation_config.dart';
export 'src/models/download_progress.dart';

/// Main entry point for local LLM inference.
///
/// Usage:
/// ```dart
/// final llm = JellyLlm();
/// await llm.loadModel('gemma-4-e2b-it-4bit');
/// await for (final token in llm.generateStream(prompt: 'Hello!')) {
///   print(token);
/// }
/// ```
class JellyLlm {
  JellyLlmPlatform get _platform => JellyLlmPlatform.instance;

  /// Load a model into memory for inference.
  Future<void> loadModel(String modelId) => _platform.loadModel(modelId);

  /// Optional warmup pass.
  Future<void> warmup() => _platform.warmup();

  /// Stream generated tokens for the given prompt.
  Stream<String> generateStream({
    required String prompt,
    GenerationConfig? config,
  }) =>
      _platform.generateStream(prompt: prompt, config: config);

  /// Cancel ongoing generation.
  Future<void> cancel() => _platform.cancel();

  /// Unload the current model from memory.
  Future<void> unload() => _platform.unload();

  /// Get inference statistics from the last generation.
  Future<LlmStats> getStats() => _platform.getStats();

  /// Current engine state.
  LlmEngineState get currentState => _platform.currentState;

  /// Stream of engine state changes.
  Stream<LlmEngineState> get stateStream => _platform.stateStream;

  /// List available models for this platform.
  Future<List<ModelInfo>> getAvailableModels() => _platform.getAvailableModels();

  /// Start downloading a model.
  Future<void> downloadModel(String modelId) => _platform.downloadModel(modelId);

  /// Cancel an in-progress download.
  Future<void> cancelDownload(String modelId) => _platform.cancelDownload(modelId);

  /// Stream download progress.
  Stream<DownloadProgress> downloadProgressStream(String modelId) =>
      _platform.downloadProgressStream(modelId);

  /// Check if a model is fully downloaded.
  Future<bool> isModelDownloaded(String modelId) => _platform.isModelDownloaded(modelId);

  /// Delete downloaded model files.
  Future<void> deleteModel(String modelId) => _platform.deleteModel(modelId);
}
