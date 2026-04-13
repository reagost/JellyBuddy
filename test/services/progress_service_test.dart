import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/data/services/progress_service.dart';
import '../helpers/mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;
  late ProgressService progressService;

  setUp(() {
    mockStorage = MockStorageService();
    progressService = ProgressService(storage: mockStorage);
  });

  group('ProgressService', () {
    group('saveLessonResult', () {
      test('stores lesson result data correctly', () async {
        final completedAt = DateTime(2024, 1, 15, 10, 30);

        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 90,
          correctCount: 9,
          totalCount: 10,
          isPerfect: false,
          completedAt: completedAt,
          wrongQuestionIds: ['q3'],
        );

        // Verify the lesson result can be retrieved
        final result = progressService.getLessonResult('lesson_1');
        expect(result, isNotNull);
        expect(result!['lessonId'], 'lesson_1');
        expect(result['score'], 90);
        expect(result['correctCount'], 9);
        expect(result['totalCount'], 10);
        expect(result['isPerfect'], false);
        expect(result['completedAt'], completedAt.toIso8601String());
      });

      test('stores wrong question IDs', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 70,
          correctCount: 7,
          totalCount: 10,
          isPerfect: false,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: ['q2', 'q5', 'q8'],
        );

        final wrongIds = progressService.getWrongQuestionIds('lesson_1');
        expect(wrongIds, ['q2', 'q5', 'q8']);
      });

      test('adds lesson to completed lessons for the course', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          isPerfect: true,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: [],
        );

        final completed = progressService.getCompletedLessonIds('course_1');
        expect(completed, contains('lesson_1'));
      });

      test('does not duplicate lesson in completed list', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 80,
          correctCount: 8,
          totalCount: 10,
          isPerfect: false,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: ['q1', 'q2'],
        );

        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          isPerfect: true,
          completedAt: DateTime(2024, 1, 16),
          wrongQuestionIds: [],
        );

        final completed = progressService.getCompletedLessonIds('course_1');
        expect(completed.where((id) => id == 'lesson_1').length, 1);
      });
    });

    group('getLessonResult', () {
      test('returns null for non-existent lesson', () {
        final result = progressService.getLessonResult('nonexistent');
        expect(result, isNull);
      });

      test('returns stored data for existing lesson', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_42',
          score: 85,
          correctCount: 17,
          totalCount: 20,
          isPerfect: false,
          completedAt: DateTime(2024, 3, 10),
          wrongQuestionIds: ['q4', 'q11', 'q15'],
        );

        final result = progressService.getLessonResult('lesson_42');
        expect(result, isNotNull);
        expect(result!['score'], 85);
        expect(result['correctCount'], 17);
        expect(result['totalCount'], 20);
      });
    });

    group('getCompletedLessonIds', () {
      test('returns empty list when no lessons completed', () {
        final completed = progressService.getCompletedLessonIds('course_1');
        expect(completed, isEmpty);
      });

      test('returns correct list of completed lesson IDs', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          isPerfect: true,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: [],
        );
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_2',
          score: 80,
          correctCount: 8,
          totalCount: 10,
          isPerfect: false,
          completedAt: DateTime(2024, 1, 16),
          wrongQuestionIds: ['q3', 'q7'],
        );

        final completed = progressService.getCompletedLessonIds('course_1');
        expect(completed, containsAll(['lesson_1', 'lesson_2']));
        expect(completed.length, 2);
      });

      test('separates completed lessons by course', () async {
        await progressService.saveLessonResult(
          courseId: 'course_A',
          lessonId: 'lesson_A1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          isPerfect: true,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: [],
        );
        await progressService.saveLessonResult(
          courseId: 'course_B',
          lessonId: 'lesson_B1',
          score: 90,
          correctCount: 9,
          totalCount: 10,
          isPerfect: false,
          completedAt: DateTime(2024, 1, 16),
          wrongQuestionIds: ['q2'],
        );

        expect(progressService.getCompletedLessonIds('course_A'), ['lesson_A1']);
        expect(progressService.getCompletedLessonIds('course_B'), ['lesson_B1']);
      });
    });

    group('isLessonCompleted', () {
      test('returns false for non-completed lesson', () {
        expect(progressService.isLessonCompleted('course_1', 'lesson_1'), isFalse);
      });

      test('returns true for completed lesson', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          isPerfect: true,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: [],
        );

        expect(progressService.isLessonCompleted('course_1', 'lesson_1'), isTrue);
      });
    });

    group('getWrongQuestionIds', () {
      test('returns empty list for lesson with no wrong questions', () {
        final wrongIds = progressService.getWrongQuestionIds('nonexistent');
        expect(wrongIds, isEmpty);
      });

      test('returns stored wrong question IDs', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 60,
          correctCount: 6,
          totalCount: 10,
          isPerfect: false,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: ['q1', 'q3', 'q7', 'q9'],
        );

        final wrongIds = progressService.getWrongQuestionIds('lesson_1');
        expect(wrongIds, ['q1', 'q3', 'q7', 'q9']);
      });

      test('does not store wrong IDs when list is empty', () async {
        await progressService.saveLessonResult(
          courseId: 'course_1',
          lessonId: 'lesson_1',
          score: 100,
          correctCount: 10,
          totalCount: 10,
          isPerfect: true,
          completedAt: DateTime(2024, 1, 15),
          wrongQuestionIds: [],
        );

        final wrongIds = progressService.getWrongQuestionIds('lesson_1');
        expect(wrongIds, isEmpty);
      });
    });
  });
}
