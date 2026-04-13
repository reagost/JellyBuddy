import 'package:equatable/equatable.dart';

abstract class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourse extends LearningEvent {
  final String courseId;
  const LoadCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class StartLesson extends LearningEvent {
  final String lessonId;
  const StartLesson(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class AnswerQuestion extends LearningEvent {
  final String questionId;
  final String answer;

  const AnswerQuestion({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

class NextQuestion extends LearningEvent {}

class CompleteLesson extends LearningEvent {}

class RequestAIHelp extends LearningEvent {
  final String questionId;
  const RequestAIHelp(this.questionId);

  @override
  List<Object?> get props => [questionId];
}