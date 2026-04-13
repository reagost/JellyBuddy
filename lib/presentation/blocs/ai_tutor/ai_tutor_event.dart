import 'package:equatable/equatable.dart';

abstract class AITutorEvent extends Equatable {
  const AITutorEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends AITutorEvent {
  final String message;
  final String? contextQuestionId;

  const SendMessage({required this.message, this.contextQuestionId});

  @override
  List<Object?> get props => [message, contextQuestionId];
}

class LoadConceptContext extends AITutorEvent {
  final String conceptId;

  const LoadConceptContext(this.conceptId);

  @override
  List<Object?> get props => [conceptId];
}

class ClearConversation extends AITutorEvent {}

class StartAITutor extends AITutorEvent {
  final String? questionContext;

  const StartAITutor({this.questionContext});

  @override
  List<Object?> get props => [questionContext];
}

class ToggleAITutor extends AITutorEvent {}
