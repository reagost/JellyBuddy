import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';
import 'ai_providers/cloud_ai_provider.dart';
import 'ai_providers/openai_compatible_provider.dart';
import 'ai_providers/anthropic_provider.dart';

/// Manages cloud AI configurations and API keys.
///
/// - API keys are stored in [FlutterSecureStorage] (Keychain/EncryptedSharedPrefs)
/// - Configs (provider type, model, baseUrl) are stored in regular Hive storage
/// - Active provider ID is tracked in Hive
class CloudAiService {
  final StorageService _storage;
  final FlutterSecureStorage _secureStorage;

  CloudAiService({
    required StorageService storage,
    FlutterSecureStorage? secureStorage,
  })  : _storage = storage,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _configsKey = 'cloud_ai_configs';
  static const _activeIdKey = 'cloud_ai_active_id';
  static const _apiKeyPrefix = 'cloud_ai_key_';

  // --- Config Management ---

  /// Get all saved configurations.
  List<_StoredConfig> getConfigs() {
    final jsonStr = _storage.getString(_configsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((item) => _StoredConfig.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save or update a configuration with its API key.
  /// Returns the config ID.
  Future<String> saveConfig({
    required CloudAiConfig config,
    required String apiKey,
    String? existingId,
  }) async {
    final id = existingId ?? 'cfg_${DateTime.now().microsecondsSinceEpoch}';

    // Save API key to secure storage
    await _secureStorage.write(key: '$_apiKeyPrefix$id', value: apiKey);

    // Save config
    final configs = getConfigs();
    final updated = [
      ...configs.where((c) => c.id != id),
      _StoredConfig(id: id, config: config),
    ];
    await _persistConfigs(updated);

    return id;
  }

  /// Delete a configuration and its API key.
  Future<void> deleteConfig(String id) async {
    await _secureStorage.delete(key: '$_apiKeyPrefix$id');
    final configs = getConfigs();
    await _persistConfigs(configs.where((c) => c.id != id).toList());

    // Clear active if deleted
    if (getActiveConfigId() == id) {
      await _storage.remove(_activeIdKey);
    }
  }

  Future<void> _persistConfigs(List<_StoredConfig> configs) async {
    final jsonList = configs.map((c) => c.toJson()).toList();
    await _storage.setString(_configsKey, jsonEncode(jsonList));
  }

  // --- Active Provider ---

  String? getActiveConfigId() => _storage.getString(_activeIdKey);

  Future<void> setActiveConfig(String? id) async {
    if (id == null) {
      await _storage.remove(_activeIdKey);
    } else {
      await _storage.setString(_activeIdKey, id);
    }
  }

  /// Get the currently active provider (if any and key is valid).
  Future<CloudAiProvider?> getActiveProvider() async {
    final id = getActiveConfigId();
    if (id == null) return null;

    final stored = getConfigs().where((c) => c.id == id).firstOrNull;
    if (stored == null) return null;

    final apiKey = await _secureStorage.read(key: '$_apiKeyPrefix$id');
    if (apiKey == null || apiKey.isEmpty) return null;

    return _buildProvider(stored.config, apiKey);
  }

  /// Get provider for a specific config (used for testing).
  Future<CloudAiProvider?> getProvider(String id) async {
    final stored = getConfigs().where((c) => c.id == id).firstOrNull;
    if (stored == null) return null;

    final apiKey = await _secureStorage.read(key: '$_apiKeyPrefix$id');
    if (apiKey == null || apiKey.isEmpty) return null;

    return _buildProvider(stored.config, apiKey);
  }

  /// Get the API key for a config (for editing UI).
  Future<String?> getApiKey(String id) async {
    return _secureStorage.read(key: '$_apiKeyPrefix$id');
  }

  CloudAiProvider _buildProvider(CloudAiConfig config, String apiKey) {
    if (config.type == CloudAiProviderType.anthropic) {
      return AnthropicProvider(config: config, apiKey: apiKey);
    }
    // All other providers use OpenAI-compatible API
    return OpenAiCompatibleProvider(config: config, apiKey: apiKey);
  }
}

class _StoredConfig {
  final String id;
  final CloudAiConfig config;

  _StoredConfig({required this.id, required this.config});

  Map<String, dynamic> toJson() => {
        'id': id,
        'config': config.toJson(),
      };

  factory _StoredConfig.fromJson(Map<String, dynamic> json) {
    return _StoredConfig(
      id: json['id'] as String,
      config: CloudAiConfig.fromJson(json['config'] as Map<String, dynamic>),
    );
  }
}
