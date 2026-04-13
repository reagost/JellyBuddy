import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models/llm_engine_state.dart';
import 'models/llm_stats.dart';
import 'models/model_info.dart';
import 'models/generation_config.dart';
import 'models/download_progress.dart';
import 'jelly_llm_method_channel.dart';

/// Platform interface for the JellyLlm plugin.
///
/// Mirrors PhoneClaw's `LLMEngine` protocol with additions for
/// model management and download.
abstract class JellyLlmPlatform extends PlatformInterface {
  JellyLlmPlatform() : super(token: _token);

  static final Object _token = Object();

  static JellyLlmPlatform _instance = JellyLlmMethodChannel();

  static JellyLlmPlatform get instance => _instance;

  static set instance(JellyLlmPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // --- Inference Lifecycle ---

  /// Load a model into memory for inference.
  Future<void> loadModel(String modelId);

  /// Optional warmup pass (may be no-op on some platforms).
  Future<void> warmup();

  /// Stream generated tokens for the given prompt.
  Stream<String> generateStream({
    required String prompt,
    GenerationConfig? config,
  });

  /// Cancel ongoing generation.
  Future<void> cancel();

  /// Unload the current model from memory.
  Future<void> unload();

  /// Get inference statistics from the last generation.
  Future<LlmStats> getStats();

  /// Current engine state.
  LlmEngineState get currentState;

  /// Stream of engine state changes.
  Stream<LlmEngineState> get stateStream;

  // --- Model Management ---

  /// List all models available for this platform.
  Future<List<ModelInfo>> getAvailableModels();

  /// Start downloading a model.
  Future<void> downloadModel(String modelId);

  /// Cancel an in-progress download.
  Future<void> cancelDownload(String modelId);

  /// Stream download progress for a model.
  Stream<DownloadProgress> downloadProgressStream(String modelId);

  /// Check if a model is fully downloaded.
  Future<bool> isModelDownloaded(String modelId);

  /// Delete downloaded model files.
  Future<void> deleteModel(String modelId);
}
