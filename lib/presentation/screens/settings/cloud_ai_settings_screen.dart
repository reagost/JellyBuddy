import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/ai_providers/cloud_ai_provider.dart';
import '../../../data/services/cloud_ai_service.dart';
import '../../../data/services/storage_service.dart';

class CloudAiSettingsScreen extends StatefulWidget {
  const CloudAiSettingsScreen({super.key});

  @override
  State<CloudAiSettingsScreen> createState() => _CloudAiSettingsScreenState();
}

class _CloudAiSettingsScreenState extends State<CloudAiSettingsScreen> {
  late final CloudAiService _service;
  String? _activeId;
  List<_ConfigRow> _configs = [];

  @override
  void initState() {
    super.initState();
    _service = GetIt.instance<CloudAiService>();
    _reload();
  }

  void _reload() {
    setState(() {
      _activeId = _service.getActiveConfigId();
      // Re-read configs by using the service internal structure through a lightweight approach
      final storage = GetIt.instance<StorageService>();
      final jsonStr = storage.getString('cloud_ai_configs') ?? '';
      if (jsonStr.isEmpty) {
        _configs = [];
        return;
      }
      try {
        final list = jsonDecode(jsonStr) as List;
        _configs = list.map((item) {
          final m = item as Map<String, dynamic>;
          return _ConfigRow(
            id: m['id'] as String,
            config: CloudAiConfig.fromJson(m['config'] as Map<String, dynamic>),
          );
        }).toList();
      } catch (_) {
        _configs = [];
      }
    });
  }

  Future<void> _setActive(String? id) async {
    await _service.setActiveConfig(id);
    _reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(id == null ? '✅ ${AppLocalizations.of(context)!.modelCloudDisabled}' : '✅ ${AppLocalizations.of(context)!.modelCloudSwitched}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _delete(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.cloudAIDeleteTitle),
        content: Text(l10n.cloudAIDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cloudAICancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cloudAIDelete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deleteConfig(id);
      _reload();
    }
  }

  Future<void> _addOrEdit({_ConfigRow? existing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddEditProviderSheet(service: _service, existing: existing),
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cloudAITitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.cloudAIAddModel),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildIntroCard(),
          const SizedBox(height: 16),
          if (_configs.isEmpty)
            _buildEmptyState()
          else ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                AppLocalizations.of(context)!.cloudAIConfigured,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            ..._configs.map(_buildConfigCard),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.cloudAITitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.cloudAIIntroDesc,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.smart_toy_outlined, size: 60, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.cloudAIEmptyTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.cloudAIEmptyHint,
            style: TextStyle(fontSize: 13, color: AppColors.textHint.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(_ConfigRow row) {
    final isActive = _activeId == row.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        Text(
                          row.config.type.displayName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.modelInUse,
                              style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.config.modelId,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'edit':
                      _addOrEdit(existing: row);
                    case 'delete':
                      _delete(row.id);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context)!.cloudAIEdit)),
                  PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.cloudAIDelete, style: const TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: isActive
                    ? OutlinedButton.icon(
                        onPressed: () => _setActive(null),
                        icon: const Icon(Icons.pause_circle_outline, size: 16),
                        label: Text(AppLocalizations.of(context)!.modelDisable),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _setActive(row.id),
                        icon: const Icon(Icons.play_circle_outline, size: 16, color: Colors.white),
                        label: Text(AppLocalizations.of(context)!.modelEnable, style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfigRow {
  final String id;
  final CloudAiConfig config;
  _ConfigRow({required this.id, required this.config});
}

// ============================================================
// Add/Edit sheet
// ============================================================

class _AddEditProviderSheet extends StatefulWidget {
  final CloudAiService service;
  final _ConfigRow? existing;

  const _AddEditProviderSheet({required this.service, this.existing});

  @override
  State<_AddEditProviderSheet> createState() => _AddEditProviderSheetState();
}

class _AddEditProviderSheetState extends State<_AddEditProviderSheet> {
  late CloudAiProviderType _type;
  late TextEditingController _modelController;
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  bool _obscureKey = true;
  bool _testing = false;
  bool _saving = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.config.type ?? CloudAiProviderType.openRouter;
    _modelController = TextEditingController(text: existing?.config.modelId ?? _type.defaultModel);
    _baseUrlController = TextEditingController(text: existing?.config.baseUrl ?? _type.defaultBaseUrl);
    _apiKeyController = TextEditingController();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    if (widget.existing != null) {
      final key = await widget.service.getApiKey(widget.existing!.id);
      if (key != null && mounted) {
        _apiKeyController.text = key;
      }
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _onTypeChanged(CloudAiProviderType newType) {
    setState(() {
      _type = newType;
      if (_modelController.text.isEmpty ||
          _modelController.text == _modelController.text /* keep */) {
        _modelController.text = newType.defaultModel;
      }
      if (_baseUrlController.text.isEmpty ||
          _baseUrlController.text == widget.existing?.config.baseUrl) {
        _baseUrlController.text = newType.defaultBaseUrl;
      }
    });
  }

  Future<void> _test() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    try {
      final id = await widget.service.saveConfig(
        config: CloudAiConfig(
          type: _type,
          modelId: _modelController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
        ),
        apiKey: _apiKeyController.text.trim(),
        existingId: tempId,
      );
      final provider = await widget.service.getProvider(id);
      final ok = await provider?.testConnection() ?? false;
      // Delete temp config
      await widget.service.deleteConfig(tempId);
      setState(() => _testResult = ok ? '✅ ${l10n.cloudAIConnectionSuccess}' : '❌ ${l10n.cloudAIConnectionFailed}');
    } catch (e) {
      await widget.service.deleteConfig(tempId);
      setState(() => _testResult = '❌ ${l10n.cloudAITestFailed(e.toString())}');
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_modelController.text.trim().isEmpty || _apiKeyController.text.trim().isEmpty) {
      setState(() => _testResult = '❌ ${l10n.cloudAIEmptyFields}');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.service.saveConfig(
        config: CloudAiConfig(
          type: _type,
          modelId: _modelController.text.trim(),
          baseUrl: _baseUrlController.text.trim(),
        ),
        apiKey: _apiKeyController.text.trim(),
        existingId: widget.existing?.id,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _testResult = '❌ ${l10n.cloudAISaveFailed(e.toString())}');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null ? AppLocalizations.of(context)!.cloudAIAddTitle : AppLocalizations.of(context)!.cloudAIEditTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Provider type
            Text(AppLocalizations.of(context)!.cloudAIProvider, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CloudAiProviderType.values.map((type) {
                final selected = _type == type;
                return GestureDetector(
                  onTap: () => _onTypeChanged(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? Colors.white : AppColors.textPrimary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Model ID
            Text(AppLocalizations.of(context)!.cloudAIModelId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(
                hintText: _type.defaultModel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            if (_type.popularModels.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _type.popularModels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final m = _type.popularModels[i];
                    return ActionChip(
                      label: Text(m, style: const TextStyle(fontSize: 11)),
                      onPressed: () => _modelController.text = m,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),

            // API Key
            const Text('API Key', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                hintText: 'sk-... / Bearer token',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Base URL (advanced)
            ExpansionTile(
              title: Text(AppLocalizations.of(context)!.cloudAIAdvancedOptions, style: const TextStyle(fontSize: 13)),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                const Text('Base URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _baseUrlController,
                  decoration: InputDecoration(
                    hintText: _type.defaultBaseUrl,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ],
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testResult!.contains('✅')
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_testResult!, style: const TextStyle(fontSize: 13)),
              ),
            ],
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testing || _saving ? null : _test,
                    icon: _testing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering, size: 16),
                    label: Text(_testing ? AppLocalizations.of(context)!.cloudAITesting : AppLocalizations.of(context)!.cloudAITestConnection),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save, size: 16, color: Colors.white),
                    label: Text(_saving ? AppLocalizations.of(context)!.cloudAISaving : AppLocalizations.of(context)!.cloudAISave, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
