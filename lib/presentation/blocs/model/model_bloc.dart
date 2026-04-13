import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jelly_llm/jelly_llm.dart';
import '../../../data/services/model_download_service.dart';
import 'model_event.dart';
import 'model_state.dart';

/// BLoC for managing LLM model lifecycle (download, load, unload).
///
/// Downloads are handled by [ModelDownloadService] (cross-platform,
/// 3-source fallback) instead of delegating to the native layer.
class ModelBloc extends Bloc<ModelEvent, ModelBlocState> {
  final JellyLlm _llm;
  final ModelDownloadService _downloadService;
  StreamSubscription? _stateSubscription;
  StreamSubscription<DownloadProgress>? _downloadSubscription;

  ModelBloc({
    required JellyLlm llm,
    required ModelDownloadService downloadService,
  })  : _llm = llm,
        _downloadService = downloadService,
        super(const ModelBlocState()) {
    on<CheckModels>(_onCheckModels);
    on<DownloadModel>(_onDownloadModel);
    on<CancelDownloadModel>(_onCancelDownloadModel);
    on<DownloadProgressUpdated>(_onDownloadProgressUpdated);
    on<DownloadCompleted>(_onDownloadCompleted);
    on<DownloadFailed>(_onDownloadFailed);
    on<LoadModel>(_onLoadModel);
    on<UnloadModel>(_onUnloadModel);
    on<DeleteModel>(_onDeleteModel);
    on<EngineStateChanged>(_onEngineStateChanged);

    _stateSubscription = _llm.stateStream.listen((engineState) {
      add(EngineStateChanged(engineState));
    });
  }

  Future<void> _onCheckModels(
    CheckModels event,
    Emitter<ModelBlocState> emit,
  ) async {
    emit(state.copyWith(isChecking: true));
    try {
      final models = await _downloadService.getAvailableModels();
      emit(state.copyWith(
        availableModels: models,
        isChecking: false,
      ));
    } catch (e) {
      emit(state.copyWith(isChecking: false, error: e.toString()));
    }
  }

  Future<void> _onDownloadModel(
    DownloadModel event,
    Emitter<ModelBlocState> emit,
  ) async {
    // Cancel any existing download subscription.
    await _downloadSubscription?.cancel();

    emit(state.copyWith(
      engineState: LlmEngineState.downloading,
      downloadingModelId: event.modelId,
      clearDownloadProgress: true,
    ));

    // Start download via the cross-platform service and listen for
    // progress events, forwarding them as BLoC events.
    _downloadSubscription = _downloadService
        .downloadModel(event.modelId)
        .listen(
      (progress) {
        add(DownloadProgressUpdated(progress));
      },
      onDone: () {
        add(DownloadCompleted(event.modelId));
      },
      onError: (Object error) {
        add(DownloadFailed(event.modelId, error.toString()));
      },
      cancelOnError: true,
    );
  }

  Future<void> _onCancelDownloadModel(
    CancelDownloadModel event,
    Emitter<ModelBlocState> emit,
  ) async {
    _downloadService.cancelDownload(event.modelId);
    await _downloadSubscription?.cancel();
    _downloadSubscription = null;

    emit(state.copyWith(
      engineState: LlmEngineState.uninitialized,
      clearDownloadingModelId: true,
      clearDownloadProgress: true,
    ));
  }

  void _onDownloadProgressUpdated(
    DownloadProgressUpdated event,
    Emitter<ModelBlocState> emit,
  ) {
    emit(state.copyWith(downloadProgress: event.progress));
  }

  Future<void> _onDownloadCompleted(
    DownloadCompleted event,
    Emitter<ModelBlocState> emit,
  ) async {
    _downloadSubscription = null;

    emit(state.copyWith(
      engineState: LlmEngineState.uninitialized,
      clearDownloadingModelId: true,
      clearDownloadProgress: true,
    ));

    // Refresh model list to reflect newly downloaded model.
    add(CheckModels());
  }

  void _onDownloadFailed(
    DownloadFailed event,
    Emitter<ModelBlocState> emit,
  ) {
    _downloadSubscription = null;

    emit(state.copyWith(
      engineState: LlmEngineState.error,
      error: event.error,
      clearDownloadingModelId: true,
      clearDownloadProgress: true,
    ));
  }

  Future<void> _onLoadModel(
    LoadModel event,
    Emitter<ModelBlocState> emit,
  ) async {
    emit(state.copyWith(
      engineState: LlmEngineState.loading,
      loadedModelId: event.modelId,
    ));
    try {
      await _llm.loadModel(event.modelId);
      emit(state.copyWith(engineState: LlmEngineState.ready));
    } catch (e) {
      emit(state.copyWith(
        engineState: LlmEngineState.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUnloadModel(
    UnloadModel event,
    Emitter<ModelBlocState> emit,
  ) async {
    await _llm.unload();
    emit(state.copyWith(
      engineState: LlmEngineState.uninitialized,
      loadedModelId: null,
    ));
  }

  Future<void> _onDeleteModel(
    DeleteModel event,
    Emitter<ModelBlocState> emit,
  ) async {
    await _downloadService.deleteModel(event.modelId);
    add(CheckModels());
  }

  void _onEngineStateChanged(
    EngineStateChanged event,
    Emitter<ModelBlocState> emit,
  ) {
    // Only forward engine state changes when not in a download-managed state.
    if (!state.isDownloading) {
      emit(state.copyWith(engineState: event.state));
    }
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    _downloadSubscription?.cancel();
    return super.close();
  }
}
