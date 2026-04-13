import 'package:jelly_llm/jelly_llm.dart';
import '../../domain/repositories/i_ai_repository.dart';
import '../services/model_download_service.dart';
import '../services/prompt_template_service.dart';

/// AI repository that uses JellyLlm for local inference
/// with fallback to pre-cached answers when model is not available.
class AIRepositoryImpl implements IAIRepository {
  final JellyLlm _llm;
  final ModelDownloadService? _downloadService;
  String? _currentExplanation;
  String? _currentCourseName;
  String? _currentLessonName;
  String? _currentQuestionContent;

  AIRepositoryImpl({JellyLlm? llm, ModelDownloadService? downloadService})
      : _llm = llm ?? JellyLlm(),
        _downloadService = downloadService;

  /// Check if any model is downloaded and available for inference.
  Future<bool> isAnyModelAvailable() async {
    final service = _downloadService;
    if (service == null) return false;
    final models = await service.getAvailableModels();
    return models.any((m) => m.isDownloaded);
  }

  /// Set the current question context for AI responses.
  void setQuestionContext({
    String? explanation,
    String? courseName,
    String? lessonName,
    String? questionContent,
  }) {
    _currentExplanation = explanation;
    _currentCourseName = courseName;
    _currentLessonName = lessonName;
    _currentQuestionContent = questionContent;
  }

  @override
  Future<String> generateResponse({
    required List<AIMessage> conversationHistory,
    required AIConfig config,
  }) async {
    // Try real LLM first
    if (_llm.currentState == LlmEngineState.ready) {
      try {
        final prompt = _buildPrompt(conversationHistory);
        final buffer = StringBuffer();
        await for (final token in _llm.generateStream(
          prompt: prompt,
          config: GenerationConfig(
            maxTokens: config.maxTokens,
            temperature: config.temperature,
            topP: config.topP,
          ),
        )) {
          buffer.write(token);
        }
        return buffer.toString();
      } catch (_) {
        // Fall through to pre-cached answer
      }
    }

    // Fallback: pre-cached answer from question data
    return _getFallbackResponse(conversationHistory);
  }

  @override
  Stream<String> streamResponse({
    required List<AIMessage> conversationHistory,
    required AIConfig config,
  }) async* {
    // Try real LLM first
    if (_llm.currentState == LlmEngineState.ready) {
      try {
        final prompt = _buildPrompt(conversationHistory);
        yield* _llm.generateStream(
          prompt: prompt,
          config: GenerationConfig(
            maxTokens: config.maxTokens,
            temperature: config.temperature,
            topP: config.topP,
          ),
        );
        return;
      } catch (_) {
        // Fall through to pre-cached answer
      }
    }

    // Fallback: simulate streaming with pre-cached answer (yield individual characters)
    final response = _getFallbackResponse(conversationHistory);
    for (var i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      yield response[i];
    }
  }

  @override
  Future<void> clearConversation() async {
    _currentExplanation = null;
    _currentCourseName = null;
    _currentLessonName = null;
    _currentQuestionContent = null;
  }

  @override
  ModelState get modelState {
    switch (_llm.currentState) {
      case LlmEngineState.ready:
      case LlmEngineState.generating:
        return ModelState.ready;
      case LlmEngineState.loading:
        return ModelState.loading;
      case LlmEngineState.error:
        return ModelState.error;
      default:
        return ModelState.uninitialized;
    }
  }

  String _buildPrompt(List<AIMessage> history) {
    final systemPrompt = PromptTemplateService.buildSystemPrompt(
      courseName: _currentCourseName,
      lessonName: _currentLessonName,
      questionContent: _currentQuestionContent,
    );

    final historyRecords = history.map((m) => (
          role: m.role == MessageRole.user ? 'user' : 'assistant',
          content: m.content,
        )).toList();

    final lastUserMessage = history.isNotEmpty ? history.last.content : '';

    return PromptTemplateService.buildConversationPrompt(
      systemPrompt: systemPrompt,
      history: historyRecords.length > 1
          ? historyRecords.sublist(0, historyRecords.length - 1)
          : [],
      userMessage: lastUserMessage,
    );
  }

  String _getFallbackResponse(List<AIMessage> conversationHistory) {
    if (conversationHistory.isEmpty) {
      return '你好！我是 Code Buddy，你的编程学习助手。有什么问题想问我吗？';
    }

    if (_currentExplanation != null) {
      return '让我来帮你分析这道题：\n\n$_currentExplanation';
    }

    return '好的，让我来帮你分析。你可以告诉我具体哪道题不太理解，我来为你解释。';
  }
}
