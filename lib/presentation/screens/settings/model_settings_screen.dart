import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:jelly_llm/jelly_llm.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/ai_providers/cloud_ai_provider.dart';
import '../../../data/services/cloud_ai_service.dart';
import '../../../data/services/storage_service.dart';
import '../../blocs/model/model_bloc.dart';
import '../../blocs/model/model_event.dart';
import '../../blocs/model/model_state.dart';

class ModelSettingsScreen extends StatefulWidget {
  const ModelSettingsScreen({super.key});

  @override
  State<ModelSettingsScreen> createState() => _ModelSettingsScreenState();
}

class _ModelSettingsScreenState extends State<ModelSettingsScreen> {
  late final CloudAiService _cloudService;
  late final StorageService _storage;
  String? _activeCloudId;
  List<_CloudConfigRow> _cloudConfigs = [];

  @override
  void initState() {
    super.initState();
    _cloudService = GetIt.instance<CloudAiService>();
    _storage = GetIt.instance<StorageService>();
    _reloadCloud();
  }

  void _reloadCloud() {
    setState(() {
      _activeCloudId = _cloudService.getActiveConfigId();
      final jsonStr = _storage.getString('cloud_ai_configs') ?? '';
      if (jsonStr.isEmpty) {
        _cloudConfigs = [];
        return;
      }
      try {
        final list = jsonDecode(jsonStr) as List;
        _cloudConfigs = list.map((item) {
          final m = item as Map<String, dynamic>;
          return _CloudConfigRow(
            id: m['id'] as String,
            config: CloudAiConfig.fromJson(m['config'] as Map<String, dynamic>),
          );
        }).toList();
      } catch (_) {
        _cloudConfigs = [];
      }
    });
  }

  Future<void> _setActiveCloud(String? id) async {
    await _cloudService.setActiveConfig(id);
    _reloadCloud();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(id == null ? '已禁用云端 AI' : '已切换到云端 AI'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.modelManagementTitle),
        backgroundColor: AppColors.backgroundOf(context),
        foregroundColor: AppColors.textPrimaryOf(context),
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

              // Active Provider Banner
              _buildActiveProviderBanner(state),
              if (_activeCloudId != null || state.loadedModelId != null)
                const SizedBox(height: 24),

              // ===== Local Models Section =====
              _buildSectionHeader(
                icon: Icons.phone_android,
                title: '本地 AI 模型',
                subtitle: '离线推理 · 隐私优先',
              ),
              const SizedBox(height: 12),

              if (state.isDownloading) _buildDownloadProgressCard(context, state),
              if (state.isChecking)
                const Center(child: CircularProgressIndicator())
              else if (state.availableModels.isEmpty)
                Center(child: Text(AppLocalizations.of(context)!.modelNoModels))
              else
                ...state.availableModels.map((model) =>
                    _buildLocalModelCard(context, model, state)),

              if (state.error != null) _buildErrorCard(state),

              const SizedBox(height: 28),

              // ===== Cloud Models Section =====
              _buildSectionHeader(
                icon: Icons.cloud,
                title: '云端 AI 模型',
                subtitle: 'MiniMax · OpenRouter · OpenAI · Claude · DeepSeek',
                action: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push('/cloud-ai-settings');
                    _reloadCloud();
                  },
                  icon: const Icon(Icons.settings, size: 14),
                  label: const Text('管理', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (_cloudConfigs.isEmpty)
                _buildCloudEmptyState()
              else
                ..._cloudConfigs.map(_buildCloudModelCard),
            ],
          );
        },
      ),
    );
  }

  // ----- Banner / Status -----

  Widget _buildActiveProviderBanner(ModelBlocState state) {
    final hasCloud = _activeCloudId != null;
    final hasLocal = state.loadedModelId != null && state.engineState == LlmEngineState.ready;

    if (!hasCloud && !hasLocal) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI 助手当前使用预设答案，加载本地模型或配置云端 AI 获得智能回答',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    String title;
    String subtitle;
    IconData icon;

    if (hasCloud) {
      final active = _cloudConfigs.firstWhere(
        (c) => c.id == _activeCloudId,
        orElse: () => _cloudConfigs.first,
      );
      title = '使用中: ${active.config.type.displayName}';
      subtitle = active.config.modelId;
      icon = Icons.cloud_done;
    } else {
      title = '使用中: 本地模型';
      subtitle = state.loadedModelId ?? '';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.success, Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryOf(context))),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondaryOf(context))),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  // ----- Cloud model card -----

  Widget _buildCloudEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_outlined, size: 40, color: AppColors.textHint),
          const SizedBox(height: 10),
          const Text('还没有配置云端模型', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '添加你自己的 API Key，使用 MiniMax / OpenRouter 等在线模型',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/cloud-ai-settings');
              _reloadCloud();
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('添加云端模型'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudModelCard(_CloudConfigRow row) {
    final isActive = _activeCloudId == row.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.success : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(row.config.type.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(row.config.type.displayName,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryOf(context))),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('使用中',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(row.config.modelId,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryOf(context)),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: isActive
                ? OutlinedButton.icon(
                    onPressed: () => _setActiveCloud(null),
                    icon: const Icon(Icons.pause_circle_outline, size: 16),
                    label: const Text('停用'),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _setActiveCloud(row.id),
                    icon: const Icon(Icons.play_circle_outline,
                        size: 16, color: Colors.white),
                    label: const Text('设为 AI 助手使用',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                  ),
          ),
        ],
      ),
    );
  }

  // ----- Status Card -----

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
        color: AppColors.cardOf(context),
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
                Text(l10n.modelInferenceEngine,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryOf(context))),
                const SizedBox(height: 4),
                Text(statusText,
                    style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- Local model card -----

  Widget _buildLocalModelCard(
      BuildContext context, ModelInfo model, ModelBlocState state) {
    final l10n = AppLocalizations.of(context)!;
    final isLoaded = state.loadedModelId == model.id &&
        state.engineState == LlmEngineState.ready;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
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
                    Text(model.displayName,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryOf(context))),
                    Text('${model.sizeFormatted} · ${model.format}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryOf(context))),
                  ],
                ),
              ),
              if (isLoaded)
                Chip(
                  label: Text(l10n.modelLoaded,
                      style: const TextStyle(fontSize: 12)),
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
                        : () =>
                            context.read<ModelBloc>().add(DownloadModel(model.id)),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(l10n.modelDownloadButton),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white),
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
                        foregroundColor: Colors.white),
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
                      : () =>
                          context.read<ModelBloc>().add(DeleteModel(model.id)),
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

  // ----- Download progress / error -----

  Widget _buildDownloadProgressCard(
      BuildContext context, ModelBlocState state) {
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
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.download, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(l10n.modelDownloadProgress(percentText),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryOf(context))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          if (progress?.currentFile != null)
            Text(l10n.modelCurrentFile(progress!.currentFile!),
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          if (progress?.sourceLabel != null) ...[
            const SizedBox(height: 4),
            Text(l10n.modelDownloadSource(progress!.sourceLabel!),
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(context))),
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

  Widget _buildErrorCard(ModelBlocState state) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.error!.length > 100
                      ? '${state.error!.substring(0, 100)}...'
                      : state.error!,
                  style: const TextStyle(fontSize: 14, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.read<ModelBloc>().add(CheckModels()),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudConfigRow {
  final String id;
  final CloudAiConfig config;
  _CloudConfigRow({required this.id, required this.config});
}
