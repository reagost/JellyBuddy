import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:jelly_llm/jelly_llm.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/model/model_bloc.dart';
import '../../blocs/model/model_event.dart';
import '../../blocs/model/model_state.dart';

class ModelSettingsScreen extends StatelessWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.modelManagementTitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<ModelBloc, ModelBlocState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Engine Status Card
              _buildStatusCard(context, state),
              const SizedBox(height: 24),

              // Available Models
              Text(
                AppLocalizations.of(context)!.modelAvailable,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (state.isDownloading)
                _buildDownloadProgressCard(context, state),

              if (state.isChecking)
                const Center(child: CircularProgressIndicator())
              else if (state.availableModels.isEmpty)
                Center(child: Text(AppLocalizations.of(context)!.modelNoModels))
              else
                ...state.availableModels.map((model) =>
                    _buildModelCard(context, model, state)),

              if (state.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.error!.length > 100
                                  ? '${state.error!.substring(0, 100)}...'
                                  : state.error!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<ModelBloc>().add(CheckModels());
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('\u91CD\u8BD5'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ModelBlocState state) {
    final l10n = AppLocalizations.of(context)!;
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (state.engineState) {
      case LlmEngineState.ready:
        statusText = l10n.modelReady;
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
      case LlmEngineState.loading:
        statusText = l10n.modelLoading;
        statusColor = AppColors.primary;
        statusIcon = Icons.hourglass_bottom;
      case LlmEngineState.downloading:
        statusText = l10n.modelDownloading;
        statusColor = AppColors.primary;
        statusIcon = Icons.download;
      case LlmEngineState.generating:
        statusText = l10n.modelGenerating;
        statusColor = AppColors.primary;
        statusIcon = Icons.auto_awesome;
      case LlmEngineState.error:
        statusText = l10n.modelError;
        statusColor = AppColors.error;
        statusIcon = Icons.error;
      case LlmEngineState.uninitialized:
        statusText = l10n.modelUninitialized;
        statusColor = AppColors.textHint;
        statusIcon = Icons.cloud_off;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.modelInferenceEngine,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgressCard(BuildContext context, ModelBlocState state) {
    final l10n = AppLocalizations.of(context)!;
    final progress = state.downloadProgress;
    final fraction = state.downloadFraction;
    final percentText = fraction != null
        ? '${(fraction * 100).toStringAsFixed(1)}%'
        : '...';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.download, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.modelDownloadProgress(percentText),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          if (progress?.currentFile != null)
            Text(
              l10n.modelCurrentFile(progress!.currentFile!),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (progress?.sourceLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.modelDownloadSource(progress!.sourceLabel!),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final modelId = state.downloadingModelId;
                if (modelId != null) {
                  context.read<ModelBloc>().add(CancelDownloadModel(modelId));
                }
              },
              icon: const Icon(Icons.close, size: 18),
              label: Text(l10n.modelCancelDownload),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, ModelInfo model, ModelBlocState state) {
    final l10n = AppLocalizations.of(context)!;
    final isLoaded = state.loadedModelId == model.id && state.engineState == LlmEngineState.ready;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLoaded ? Border.all(color: AppColors.success, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${model.sizeFormatted} · ${model.format}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoaded)
                Chip(
                  label: Text(l10n.modelLoaded, style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFFE8F5E9),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!model.isDownloaded)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isDownloading
                        ? null
                        : () => context.read<ModelBloc>().add(DownloadModel(model.id)),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(l10n.modelDownloadButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else if (!isLoaded)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => context.read<ModelBloc>().add(LoadModel(model.id)),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(l10n.modelLoadButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<ModelBloc>().add(UnloadModel()),
                    icon: const Icon(Icons.stop, size: 18),
                    label: Text(l10n.modelUnloadButton),
                  ),
                ),
              if (model.isDownloaded) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isLoaded
                      ? null
                      : () => context.read<ModelBloc>().add(DeleteModel(model.id)),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
