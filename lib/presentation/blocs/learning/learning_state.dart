import 'package:equatable/equatable.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';

enum QuestionState { unanswered, answered, correct, incorrect }

abstract class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

class LearningInitial extends LearningState {}

class LearningLoading extends LearningState {}

class CourseLoaded extends LearningState {
  final Course course;
  const CourseLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class LessonInProgress extends LearningState {
  final Lesson lesson;
  final int currentQuestionIndex;
  final QuestionState questionState;
  final int hearts;
  final int currentXp;
  final String? selectedAnswer;

  const LessonInProgress({
    required this.lesson,
    required this.currentQuestionIndex,
    required this.questionState,
    required this.hearts,
    required this.currentXp,
    this.selectedAnswer,
  });

  LessonInProgress copyWith({
    Lesson? lesson,
    int? currentQuestionIndex,
    QuestionState? questionState,
    int? hearts,
    int? currentXp,
    String? selectedAnswer,
  }) {
    return LessonInProgress(
      lesson: lesson ?? this.lesson,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questionState: questionState ?? this.questionState,
      hearts: hearts ?? this.hearts,
      currentXp: currentXp ?? this.currentXp,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }

  @override
  List<Object?> get props => [lesson, currentQuestionIndex, questionState, hearts, currentXp, selectedAnswer];
}

class LessonCompleted extends LearningState {
  final LessonResult result;
  const LessonCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

class LearningError extends LearningState {
  final String message;
  const LearningError(this.message);

  @override
  List<Object?> get props => [message];
}