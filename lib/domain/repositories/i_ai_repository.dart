enum MessageRole { user, assistant, system }
enum ModelState { uninitialized, loading, ready, error }
enum AIConnectionStatus { connected, loading, error, fallback }

class AIMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<String>? relatedConcepts;

  AIMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.relatedConcepts,
  });
}

class AIConfig {
  final int maxTokens;
  final double temperature;
  final double topP;

  const AIConfig({
    this.maxTokens = 512,
    this.temperature = 0.7,
    this.topP = 0.9,
  });
}

abstract class IAIRepository {
  Stream<String> streamResponse({
    required List<AIMessage> conversationHistory,
    required AIConfig config,
  });
  Future<String> generateResponse({
    required List<AIMessage> conversationHistory,
    required AIConfig config,
  });
  Future<void> clearConversation();
  ModelState get modelState;
}
