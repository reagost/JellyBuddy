import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_learning_repository.dart';
import '../../../domain/repositories/i_game_repository.dart';
import '../../../core/constants/game_constants.dart';
import 'learning_event.dart';
import 'learning_state.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  final ILearningRepository learningRepo;
  final IGameRepository gameRepo;

  LearningBloc({
    required this.learningRepo,
    required this.gameRepo,
  }) : super(LearningInitial()) {
    on<LoadCourse>(_onLoadCourse);
    on<StartLesson>(_onStartLesson);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<CompleteLesson>(_onCompleteLesson);
  }

  Future<void> _onLoadCourse(
    LoadCourse event,
    Emitter<LearningState> emit,
  ) async {
    emit(LearningLoading());
    try {
      final course = await learningRepo.getCourse(event.courseId);
      emit(CourseLoaded(course));
    } catch (e) {
      emit(LearningError(e.toString()));
    }
  }

  Future<void> _onStartLesson(
    StartLesson event,
    Emitter<LearningState> emit,
  ) async {
    final progress = await gameRepo.getUserProgress();
    emit(LessonInProgress(
      lesson: Lesson(
        id: event.lessonId,
        courseId: '',
        title: '',
        level: 1,
        order: 0,
        levels: [],
        isBoss: false,
        xpReward: 50,
        diamondReward: 1,
      ),
      currentQuestionIndex: 0,
      questionState: QuestionState.unanswered,
      hearts: progress.hearts,
      currentXp: progress.totalXp,
    ));
  }

  void _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<LearningState> emit,
  ) {
    if (state is! LessonInProgress) return;
    final current = state as LessonInProgress;

    final correct = event.answer == 'B'; // Simplified for demo
    final newXp = current.currentXp + (correct ? GameConstants.xpPerCorrect : 0);
    final newHearts = correct ? current.hearts : current.hearts - GameConstants.heartsPerWrong;

    emit(current.copyWith(
      questionState: correct ? QuestionState.correct : QuestionState.incorrect,
      selectedAnswer: event.answer,
      hearts: newHearts.clamp(0, GameConstants.maxHearts),
      currentXp: newXp,
    ));
  }

  void _onNextQuestion(
    NextQuestion event,
    Emitter<LearningState> emit,
  ) {
    if (state is! LessonInProgress) return;
    final current = state as LessonInProgress;

    emit(current.copyWith(
      currentQuestionIndex: current.currentQuestionIndex + 1,
      questionState: QuestionState.unanswered,
      selectedAnswer: null,
    ));
  }

  void _onCompleteLesson(
    CompleteLesson event,
    Emitter<LearningState> emit,
  ) {
    if (state is! LessonInProgress) return;
    final current = state as LessonInProgress;

    emit(LessonCompleted(
      LessonResult(
        lessonId: current.lesson.id,
        score: 80,
        correctCount: 4,
        totalCount: 5,
        timeSpent: Duration.zero,
        isPerfect: current.questionState == QuestionState.correct,
        completedAt: DateTime.now(),
        wrongQuestionIds: [],
      ),
    ));
  }
}