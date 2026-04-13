import 'package:jelly_llm/jelly_llm.dart';

class ModelBlocState {
  final LlmEngineState engineState;
  final List<ModelInfo> availableModels;
  final String? loadedModelId;
  final String? downloadingModelId;
  final bool isChecking;
  final String? error;

  /// Current download progress (non-null while downloading).
  final DownloadProgress? downloadProgress;

  const ModelBlocState({
    this.engineState = LlmEngineState.uninitialized,
    this.availableModels = const [],
    this.loadedModelId,
    this.downloadingModelId,
    this.isChecking = false,
    this.error,
    this.downloadProgress,
  });

  bool get isModelReady => engineState == LlmEngineState.ready;
  bool get isLoading => engineState == LlmEngineState.loading;
  bool get isDownloading => engineState == LlmEngineState.downloading;

  /// Download fraction 0.0-1.0 (null if not downloading or total unknown).
  double? get downloadFraction => downloadProgress?.fraction;

  ModelBlocState copyWith({
    LlmEngineState? engineState,
    List<ModelInfo>? availableModels,
    String? loadedModelId,
    String? downloadingModelId,
    bool? isChecking,
    String? error,
    DownloadProgress? downloadProgress,
    bool clearDownloadProgress = false,
    bool clearDownloadingModelId = false,
  }) {
    return ModelBlocState(
      engineState: engineState ?? this.engineState,
      availableModels: availableModels ?? this.availableModels,
      loadedModelId: loadedModelId ?? this.loadedModelId,
      downloadingModelId: clearDownloadingModelId
          ? null
          : (downloadingModelId ?? this.downloadingModelId),
      isChecking: isChecking ?? this.isChecking,
      error: error,
      downloadProgress: clearDownloadProgress
          ? null
          : (downloadProgress ?? this.downloadProgress),
    );
  }
}
