import 'dart:async';
import 'package:flutter/services.dart';
import 'jelly_llm_platform_interface.dart';
import 'models/llm_engine_state.dart';
import 'models/llm_stats.dart';
import 'models/model_info.dart';
import 'models/generation_config.dart';
import 'models/download_progress.dart';

/// Default MethodChannel/EventChannel implementation of [JellyLlmPlatform].
class JellyLlmMethodChannel extends JellyLlmPlatform {
  static const _methodChannel = MethodChannel('com.jellybuddy/jelly_llm');
  static const _generateChannel = EventChannel('com.jellybuddy/jelly_llm/generate');
  static const _stateChannel = EventChannel('com.jellybuddy/jelly_llm/state');
  static const _downloadChannel = EventChannel('com.jellybuddy/jelly_llm/download_progress');

  LlmEngineState _currentState = LlmEngineState.uninitialized;
  StreamController<LlmEngineState>? _stateController;

  @override
  LlmEngineState get currentState => _currentState;

  @override
  Stream<LlmEngineState> get stateStream {
    _stateController ??= StreamController<LlmEngineState>.broadcast();
    _listenToStateChannel();
    return _stateController!.stream;
  }

  void _listenToStateChannel() {
    _stateChannel.receiveBroadcastStream().listen((event) {
      final map = event as Map;
      final stateName = map['state'] as String;
      _currentState = LlmEngineState.values.firstWhere(
        (s) => s.name == stateName,
        orElse: () => LlmEngineState.error,
      );
      _stateController?.add(_currentState);
    });
  }

  // --- Inference Lifecycle ---

  @override
  Future<void> loadModel(String modelId) async {
    await _methodChannel.invokeMethod('loadModel', {'modelId': modelId});
  }

  @override
  Future<void> warmup() async {
    await _methodChannel.invokeMethod('warmup');
  }

  @override
  Stream<String> generateStream({
    required String prompt,
    GenerationConfig? config,
  }) {
    final args = <String, dynamic>{
      'prompt': prompt,
      if (config != null) ...config.toMap(),
    };
    return _generateChannel.receiveBroadcastStream(args).map((event) => event as String);
  }

  @override
  Future<void> cancel() async {
    await _methodChannel.invokeMethod('cancel');
  }

  @override
  Future<void> unload() async {
    await _methodChannel.invokeMethod('unload');
  }

  @override
  Future<LlmStats> getStats() async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>('getStats');
    return LlmStats.fromMap(result ?? {});
  }

  // --- Model Management ---

  @override
  Future<List<ModelInfo>> getAvailableModels() async {
    final result = await _methodChannel.invokeListMethod<Map>('getAvailableModels');
    return result
            ?.map((m) => ModelInfo.fromMap(Map<String, dynamic>.from(m)))
            .toList() ??
        [];
  }

  @override
  Future<void> downloadModel(String modelId) async {
    await _methodChannel.invokeMethod('downloadModel', {'modelId': modelId});
  }

  @override
  Future<void> cancelDownload(String modelId) async {
    await _methodChannel.invokeMethod('cancelDownload', {'modelId': modelId});
  }

  @override
  Stream<DownloadProgress> downloadProgressStream(String modelId) {
    return _downloadChannel
        .receiveBroadcastStream({'modelId': modelId})
        .where((event) => event is Map)
        .map((event) => DownloadProgress.fromMap(Map<String, dynamic>.from(event as Map)));
  }

  @override
  Future<bool> isModelDownloaded(String modelId) async {
    final result = await _methodChannel
        .invokeMethod<bool>('isModelDownloaded', {'modelId': modelId});
    return result ?? false;
  }

  @override
  Future<void> deleteModel(String modelId) async {
    await _methodChannel.invokeMethod('deleteModel', {'modelId': modelId});
  }
}
