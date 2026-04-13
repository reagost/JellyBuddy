import 'package:jelly_llm/jelly_llm.dart';

abstract class ModelEvent {
  const ModelEvent();
}

class CheckModels extends ModelEvent {}

class DownloadModel extends ModelEvent {
  final String modelId;
  const DownloadModel(this.modelId);
}

class CancelDownloadModel extends ModelEvent {
  final String modelId;
  const CancelDownloadModel(this.modelId);
}

class LoadModel extends ModelEvent {
  final String modelId;
  const LoadModel(this.modelId);
}

class UnloadModel extends ModelEvent {}

class DeleteModel extends ModelEvent {
  final String modelId;
  const DeleteModel(this.modelId);
}

class EngineStateChanged extends ModelEvent {
  final LlmEngineState state;
  const EngineStateChanged(this.state);
}

/// Internal event fired by the download progress stream subscription.
class DownloadProgressUpdated extends ModelEvent {
  final DownloadProgress progress;
  const DownloadProgressUpdated(this.progress);
}

/// Internal event fired when a download completes successfully.
class DownloadCompleted extends ModelEvent {
  final String modelId;
  const DownloadCompleted(this.modelId);
}

/// Internal event fired when a download fails.
class DownloadFailed extends ModelEvent {
  final String modelId;
  final String error;
  const DownloadFailed(this.modelId, this.error);
}
