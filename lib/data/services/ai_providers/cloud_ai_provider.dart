import '../../../domain/repositories/i_ai_repository.dart';

/// Identifier for a cloud AI provider type.
enum CloudAiProviderType {
  minimax,
  openRouter,
  openAi,
  anthropic,
  deepseek,
  custom,
}

extension CloudAiProviderTypeInfo on CloudAiProviderType {
  String get displayName {
    switch (this) {
      case CloudAiProviderType.minimax:
        return 'MiniMax';
      case CloudAiProviderType.openRouter:
        return 'OpenRouter';
      case CloudAiProviderType.openAi:
        return 'OpenAI';
      case CloudAiProviderType.anthropic:
        return 'Anthropic Claude';
      case CloudAiProviderType.deepseek:
        return 'DeepSeek';
      case CloudAiProviderType.custom:
        return '自定义 (OpenAI 兼容)';
    }
  }

  String get icon {
    switch (this) {
      case CloudAiProviderType.minimax:
        return '🌊';
      case CloudAiProviderType.openRouter:
        return '🔀';
      case CloudAiProviderType.openAi:
        return '🤖';
      case CloudAiProviderType.anthropic:
        return '🎭';
      case CloudAiProviderType.deepseek:
        return '🔍';
      case CloudAiProviderType.custom:
        return '⚙️';
    }
  }

  String get defaultBaseUrl {
    switch (this) {
      case CloudAiProviderType.minimax:
        return 'https://api.minimax.chat/v1';
      case CloudAiProviderType.openRouter:
        return 'https://openrouter.ai/api/v1';
      case CloudAiProviderType.openAi:
        return 'https://api.openai.com/v1';
      case CloudAiProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case CloudAiProviderType.deepseek:
        return 'https://api.deepseek.com/v1';
      case CloudAiProviderType.custom:
        return '';
    }
  }

  /// Default model ID for this provider.
  String get defaultModel {
    switch (this) {
      case CloudAiProviderType.minimax:
        return 'MiniMax-Text-01';
      case CloudAiProviderType.openRouter:
        return 'google/gemini-2.0-flash-exp:free';
      case CloudAiProviderType.openAi:
        return 'gpt-4o-mini';
      case CloudAiProviderType.anthropic:
        return 'claude-3-5-haiku-latest';
      case CloudAiProviderType.deepseek:
        return 'deepseek-chat';
      case CloudAiProviderType.custom:
        return '';
    }
  }

  /// Popular models for this provider (for dropdown selection).
  List<String> get popularModels {
    switch (this) {
      case CloudAiProviderType.minimax:
        return ['MiniMax-Text-01', 'MiniMax-M1', 'abab6.5s-chat'];
      case CloudAiProviderType.openRouter:
        return [
          'google/gemini-2.0-flash-exp:free',
          'meta-llama/llama-3.3-70b-instruct:free',
          'deepseek/deepseek-r1:free',
          'anthropic/claude-3.5-sonnet',
          'openai/gpt-4o-mini',
        ];
      case CloudAiProviderType.openAi:
        return ['gpt-4o-mini', 'gpt-4o', 'gpt-4-turbo', 'gpt-3.5-turbo'];
      case CloudAiProviderType.anthropic:
        return [
          'claude-3-5-haiku-latest',
          'claude-3-5-sonnet-latest',
          'claude-3-opus-latest',
        ];
      case CloudAiProviderType.deepseek:
        return ['deepseek-chat', 'deepseek-reasoner'];
      case CloudAiProviderType.custom:
        return [];
    }
  }
}

/// Configuration for a cloud AI provider instance.
class CloudAiConfig {
  final CloudAiProviderType type;
  final String modelId;
  final String baseUrl;
  final String? customName;

  const CloudAiConfig({
    required this.type,
    required this.modelId,
    required this.baseUrl,
    this.customName,
  });

  String get displayName => customName ?? '${type.displayName} · $modelId';

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'modelId': modelId,
        'baseUrl': baseUrl,
        'customName': customName,
      };

  factory CloudAiConfig.fromJson(Map<String, dynamic> json) {
    return CloudAiConfig(
      type: CloudAiProviderType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => CloudAiProviderType.custom,
      ),
      modelId: json['modelId'] as String,
      baseUrl: json['baseUrl'] as String,
      customName: json['customName'] as String?,
    );
  }
}

/// Unified cloud AI provider interface.
///
/// All providers must implement streaming and non-streaming text generation.
abstract class CloudAiProvider {
  CloudAiConfig get config;

  /// Stream tokens from the AI.
  Stream<String> streamResponse({
    required List<AIMessage> history,
    required AIConfig aiConfig,
    String? systemPrompt,
  });

  /// Get a complete response (awaits full stream).
  Future<String> generateResponse({
    required List<AIMessage> history,
    required AIConfig aiConfig,
    String? systemPrompt,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in streamResponse(
      history: history,
      aiConfig: aiConfig,
      systemPrompt: systemPrompt,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  /// Test the API key and connection.
  Future<bool> testConnection();
}
