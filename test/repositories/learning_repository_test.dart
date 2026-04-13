import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/data/repositories/learning_repository_impl.dart';
import 'package:jelly_buddy/data/services/progress_service.dart';
import 'package:jelly_buddy/domain/entities/user.dart';
import '../helpers/mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;
  late ProgressService progressService;
  late LearningRepositoryImpl repository;

  setUp(() {
    mockStorage = MockStorageService();
    progressService = ProgressService(storage: mockStorage);
    repository = LearningRepositoryImpl(progressService: progressService);
  });

  group('LearningRepositoryImpl', () {
    group('saveLessonResult', () {
      test('delegates to ProgressService and stores data', () async {
        final result = LessonResult(
          lessonId: 'lesson_1',
          score: 90,
          correctCount: 9,
          totalCount: 10,
          timeSpent: const Duration(minutes: 5),
          isPerfect: false,
          completedAt: DateTime(2024, 1, 15, 10, 30),
          wrongQuestionIds: const ['q3'],
        );

        await repository.saveLessonResult('course_1', result);

        // Verify via ProgressService that data was stored
        final stored = progressService.getLessonResult('lesson_1');
        expect(stored, isNotNull);
        expect(stored!['score'], 90);
        expect(stored['correctCount'], 9);
      });
    });

    group('getLessonResult', () {
      test('returns null when no result stored', () async {
        final result = await repository.getLessonResult('nonexistent');
        expect(result, isNull);
      });

      test('returns parsed LessonResult from stored data', () async {
        // First store a result
        final originalResult = LessonResult(
          lessonId: 'lesson_42',
          score: 85,
          correctCount: 17,
          totalCount: 20,
          timeSpent: const Duration(minutes: 10),
          isPerfect: false,
          completedAt: DateTime(2024, 3, 10, 14, 0),
          wrongQuestionIds: const ['q4', 'q11', 'q15'],
        );
        await repository.saveLessonResult('course_1', originalResult);

        // Retrieve it
        final fetched = await repository.getLessonResult('lesson_42');

        expect(fetched, isNotNull);
        expect(fetched!.lessonId, 'lesson_42');
        expect(fetched.score, 85);
        expect(fetched.correctCount, 17);
        expect(fetched.totalCount, 20);
        expect(fetched.isPerfect, false);
        expect(fetched.completedAt, DateTime(2024, 3, 10, 14, 0));
        expect(fetched.wrongQuestionIds, ['q4', 'q11', 'q15']);
      });

      test('returns LessonResult with timeSpent as Duration.zero', () async {
        final originalResult = LessonResult(
          lessonId: 'lesson_1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          timeSpent: const Duration(minutes: 3),
          isPerfect: true,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: const [],
        );
        await repository.saveLessonResult('course_1', originalResult);

        final fetched = await repository.getLessonResult('lesson_1');

        // The stored data doesn't include timeSpent, so it should be Duration.zero
        expect(fetched!.timeSpent, Duration.zero);
      });
    });

    group('getCompletedLessonIds', () {
      test('returns empty list when no lessons completed', () {
        final ids = repository.getCompletedLessonIds('course_1');
        expect(ids, isEmpty);
      });

      test('returns completed lesson IDs after saving results', () async {
        await repository.saveLessonResult(
          'course_1',
          LessonResult(
            lessonId: 'lesson_1',
            score: 100,
            correctCount: 10,
            totalCount: 10,
            timeSpent: Duration.zero,
            isPerfect: true,
            completedAt: DateTime(2024, 1, 15),
            wrongQuestionIds: const [],
          ),
        );
        await repository.saveLessonResult(
          'course_1',
          LessonResult(
            lessonId: 'lesson_2',
            score: 80,
            correctCount: 8,
            totalCount: 10,
            timeSpent: Duration.zero,
            isPerfect: false,
            completedAt: DateTime(2024, 1, 16),
            wrongQuestionIds: const ['q3', 'q7'],
          ),
        );

        final ids = repository.getCompletedLessonIds('course_1');
        expect(ids, containsAll(['lesson_1', 'lesson_2']));
      });
    });

    group('isLessonCompleted', () {
      test('returns false when lesson not completed', () {
        expect(repository.isLessonCompleted('course_1', 'lesson_1'), isFalse);
      });

      test('returns true when lesson completed', () async {
        await repository.saveLessonResult(
          'course_1',
          LessonResult(
            lessonId: 'lesson_1',
            score: 100,
            correctCount: 10,
            totalCount: 10,
            timeSpent: Duration.zero,
            isPerfect: true,
            completedAt: DateTime(2024, 1, 15),
            wrongQuestionIds: const [],
          ),
        );

        expect(repository.isLessonCompleted('course_1', 'lesson_1'), isTrue);
      });
    });

    // Note: getCourse and getAllCourses require rootBundle (Flutter asset loading),
    // which needs a full Flutter test environment with TestWidgetsFlutterBinding
    // and mock asset bundles. We test the JSON parsing logic indirectly
    // through integration with ProgressService above.
  });
}
