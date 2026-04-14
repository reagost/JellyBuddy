import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../data/services/analytics_service.dart';
import '../../../domain/repositories/i_ai_repository.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

class AITutorBloc extends Bloc<AITutorEvent, AITutorState> {
  final IAIRepository aiRepo;

  AITutorBloc({required this.aiRepo}) : super(const AITutorState()) {
    on<SendMessage>(_onSendMessage);
    on<ClearConversation>(_onClearConversation);
    on<StartAITutor>(_onStartAITutor);
    on<ToggleAITutor>(_onToggleAITutor);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AITutorState> emit,
  ) async {
    GetIt.instance<AnalyticsService>().trackEvent('ai_query');

    // Add user message
    final userMessage = AIMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      content: event.message,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isGenerating: true,
      status: AIConnectionStatus.loading,
    ));

    try {
      // Create a placeholder AI message for streaming
      final aiMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
      final aiMessage = AIMessage(
        id: aiMessageId,
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, aiMessage],
      ));

      // Stream AI response token by token
      final buffer = StringBuffer();
      await for (final token in aiRepo.streamResponse(
        conversationHistory: state.messages
            .where((m) => m.id != aiMessageId)
            .toList(),
        config: const AIConfig(),
      )) {
        buffer.write(token);
        final updatedMessage = AIMessage(
          id: aiMessageId,
          role: MessageRole.assistant,
          content: buffer.toString(),
          timestamp: DateTime.now(),
        );

        final updatedMessages = state.messages.map((m) {
          return m.id == aiMessageId ? updatedMessage : m;
        }).toList();

        emit(state.copyWith(
          messages: updatedMessages,
        ));
      }

      emit(state.copyWith(
        isGenerating: false,
        status: AIConnectionStatus.connected,
      ));
    } catch (e) {
      emit(state.copyWith(
        isGenerating: false,
        status: AIConnectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearConversation(
    ClearConversation event,
    Emitter<AITutorState> emit,
  ) {
    emit(state.copyWith(
      messages: [],
      isGenerating: false,
    ));
  }

  void _onStartAITutor(
    StartAITutor event,
    Emitter<AITutorState> emit,
  ) {
    emit(state.copyWith(
      currentQuestionContext: event.questionContext,
      isPanelOpen: true,
    ));
  }

  void _onToggleAITutor(
    ToggleAITutor event,
    Emitter<AITutorState> emit,
  ) {
    emit(state.copyWith(isPanelOpen: !state.isPanelOpen));
  }
}
