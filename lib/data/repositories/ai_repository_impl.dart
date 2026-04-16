import 'package:jelly_llm/jelly_llm.dart';
import '../../domain/repositories/i_ai_repository.dart';
import '../services/cloud_ai_service.dart';
import '../services/model_download_service.dart';
import '../services/prompt_template_service.dart';

/// AI repository with 3-tier priority:
/// 1. Cloud AI (if configured and active) — MiniMax/OpenRouter/OpenAI/Anthropic/DeepSeek
/// 2. Local LLM (JellyLlm — Gemma 4 on iOS MLX / Android llama.cpp)
/// 3. Pre-cached answers from question.explanation
class AIRepositoryImpl implements IAIRepository {
  final JellyLlm _llm;
  final ModelDownloadService? _downloadService;
  final CloudAiService? _cloudAiService;
  String? _currentExplanation;
  String? _currentCourseName;
  String? _currentLessonName;
  String? _currentQuestionContent;

  AIRepositoryImpl({
    JellyLlm? llm,
    ModelDownloadService? downloadService,
    CloudAiService? cloudAiService,
  })  : _llm = llm ?? JellyLlm(),
        _downloadService = downloadService,
        _cloudAiService = cloudAiService;

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
    // 1. Try cloud AI first (if configured)
    final cloudProvider = await _cloudAiService?.getActiveProvider();
    if (cloudProvider != null) {
      try {
        return await cloudProvider.generateResponse(
          history: conversationHistory,
          aiConfig: config,
          systemPrompt: _buildSystemPrompt(),
        );
      } catch (_) {
        // Fall through to local LLM
      }
    }

    // 2. Try local LLM
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
        // Fall through to pre-cached
      }
    }

    // 3. Fallback: pre-cached answer
    return _getFallbackResponse(conversationHistory);
  }

  @override
  Stream<String> streamResponse({
    required List<AIMessage> conversationHistory,
    required AIConfig config,
  }) async* {
    // 1. Try cloud AI first (if configured)
    final cloudProvider = await _cloudAiService?.getActiveProvider();
    if (cloudProvider != null) {
      try {
        yield* cloudProvider.streamResponse(
          history: conversationHistory,
          aiConfig: config,
          systemPrompt: _buildSystemPrompt(),
        );
        return;
      } catch (e) {
        // Yield error message and fall through
        yield '\n⚠️ 云端 AI 出错，降级到本地模型...\n';
      }
    }

    // 2. Try local LLM
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
        // Fall through to pre-cached
      }
    }

    // 3. Fallback: simulate streaming with pre-cached answer
    final response = _getFallbackResponse(conversationHistory);
    for (var i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      yield response[i];
    }
  }

  /// Build the system prompt used by cloud providers.
  String _buildSystemPrompt() {
    return PromptTemplateService.buildSystemPrompt(
      courseName: _currentCourseName,
      lessonName: _currentLessonName,
      questionContent: _currentQuestionContent,
    );
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

  static const _fallbackNote = '\u{1F4DA} 预设解析（本地 AI 模型未加载）\n\n';

  String _getFallbackResponse(List<AIMessage> conversationHistory) {
    if (conversationHistory.isEmpty) {
      return '$_fallbackNote你好！我是 JellyBuddy，你的编程学习助手。有什么问题想问我吗？\n\n提示：前往「我的 → AI 模型管理」下载模型，获得更智能的解答。';
    }

    if (_currentExplanation != null) {
      return '$_fallbackNote让我来帮你分析这道题：\n\n$_currentExplanation';
    }

    return '$_fallbackNote好的，让我来帮你分析。你可以告诉我具体哪道题不太理解，我来为你解释。';
  }
}
