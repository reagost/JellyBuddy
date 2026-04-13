import 'package:equatable/equatable.dart';
import '../../../domain/repositories/i_ai_repository.dart';

class AITutorState extends Equatable {
  final List<AIMessage> messages;
  final bool isGenerating;
  final AIConnectionStatus status;
  final String? errorMessage;
  final String? currentQuestionContext;
  final bool isPanelOpen;

  const AITutorState({
    this.messages = const [],
    this.isGenerating = false,
    this.status = AIConnectionStatus.connected,
    this.errorMessage,
    this.currentQuestionContext,
    this.isPanelOpen = false,
  });

  AITutorState copyWith({
    List<AIMessage>? messages,
    bool? isGenerating,
    AIConnectionStatus? status,
    String? errorMessage,
    String? currentQuestionContext,
    bool? isPanelOpen,
  }) {
    return AITutorState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentQuestionContext: currentQuestionContext ?? this.currentQuestionContext,
      isPanelOpen: isPanelOpen ?? this.isPanelOpen,
    );
  }

  @override
  List<Object?> get props => [messages, isGenerating, status, errorMessage, currentQuestionContext, isPanelOpen];
}
