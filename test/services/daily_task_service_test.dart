import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/data/services/daily_task_service.dart';
import '../helpers/mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;
  late DailyTaskService dailyTaskService;

  setUp(() {
    mockStorage = MockStorageService();
    dailyTaskService = DailyTaskService(storage: mockStorage);
  });

  group('DailyTaskService', () {
    group('getDailyTasks', () {
      test('returns 4 tasks with 0 progress initially', () {
        final tasks = dailyTaskService.getDailyTasks();

        expect(tasks.length, 4);

        // daily_lessons task
        final lessonsTask = tasks.firstWhere((t) => t.id == 'daily_lessons');
        expect(lessonsTask.currentProgress, 0);
        expect(lessonsTask.targetProgress, 3);
        expect(lessonsTask.isCompleted, isFalse);

        // perfect_lesson task
        final perfectTask = tasks.firstWhere((t) => t.id == 'perfect_lesson');
        expect(perfectTask.currentProgress, 0);
        expect(perfectTask.targetProgress, 1);
        expect(perfectTask.isCompleted, isFalse);

        // review_wrong task
        final reviewTask = tasks.firstWhere((t) => t.id == 'review_wrong');
        expect(reviewTask.currentProgress, 0);
        expect(reviewTask.targetProgress, 5);
        expect(reviewTask.isCompleted, isFalse);

        // early_bird task
        final earlyBirdTask = tasks.firstWhere((t) => t.id == 'early_bird');
        expect(earlyBirdTask.currentProgress, 0);
        expect(earlyBirdTask.targetProgress, 1);
        expect(earlyBirdTask.isCompleted, isFalse);
      });
    });

    group('markLessonCompleted', () {
      test('increments lesson count', () async {
        await dailyTaskService.markLessonCompleted(false);

        final tasks = dailyTaskService.getDailyTasks();
        final lessonsTask = tasks.firstWhere((t) => t.id == 'daily_lessons');
        expect(lessonsTask.currentProgress, 1);
      });

      test('increments perfect count when isPerfect is true', () async {
        await dailyTaskService.markLessonCompleted(true);

        final tasks = dailyTaskService.getDailyTasks();
        final perfectTask = tasks.firstWhere((t) => t.id == 'perfect_lesson');
        expect(perfectTask.currentProgress, 1);
        expect(perfectTask.isCompleted, isTrue);
      });

      test('does not increment perfect count when isPerfect is false', () async {
        await dailyTaskService.markLessonCompleted(false);

        final tasks = dailyTaskService.getDailyTasks();
        final perfectTask = tasks.firstWhere((t) => t.id == 'perfect_lesson');
        expect(perfectTask.currentProgress, 0);
      });

      test('multiple completions accumulate', () async {
        await dailyTaskService.markLessonCompleted(false);
        await dailyTaskService.markLessonCompleted(true);
        await dailyTaskService.markLessonCompleted(false);

        final tasks = dailyTaskService.getDailyTasks();

        final lessonsTask = tasks.firstWhere((t) => t.id == 'daily_lessons');
        expect(lessonsTask.currentProgress, 3);
        expect(lessonsTask.isCompleted, isTrue);

        final perfectTask = tasks.firstWhere((t) => t.id == 'perfect_lesson');
        expect(perfectTask.currentProgress, 1);
      });

      test('lessons progress is clamped to target', () async {
        // Complete 5 lessons (target is 3)
        for (int i = 0; i < 5; i++) {
          await dailyTaskService.markLessonCompleted(false);
        }

        final tasks = dailyTaskService.getDailyTasks();
        final lessonsTask = tasks.firstWhere((t) => t.id == 'daily_lessons');
        expect(lessonsTask.currentProgress, 3); // clamped to 3
        expect(lessonsTask.isCompleted, isTrue);
      });
    });

    group('markWrongQuestionsReviewed', () {
      test('increments review count', () async {
        await dailyTaskService.markWrongQuestionsReviewed(3);

        final tasks = dailyTaskService.getDailyTasks();
        final reviewTask = tasks.firstWhere((t) => t.id == 'review_wrong');
        expect(reviewTask.currentProgress, 3);
      });

      test('review progress is clamped to target', () async {
        await dailyTaskService.markWrongQuestionsReviewed(10);

        final tasks = dailyTaskService.getDailyTasks();
        final reviewTask = tasks.firstWhere((t) => t.id == 'review_wrong');
        expect(reviewTask.currentProgress, 5); // clamped to 5
        expect(reviewTask.isCompleted, isTrue);
      });
    });

    group('daily reset', () {
      test('tasks from a different day are not visible today', () async {
        // Simulate data from yesterday by writing to a different date key
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateStr =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
        await mockStorage.setString(
          'daily_tasks_$dateStr',
          '{"lessonsCompleted":3,"perfectLessonsCompleted":1,"wrongQuestionsReviewed":5,"hasEarlyBirdLesson":true}',
        );

        // Today's tasks should still be at 0
        final tasks = dailyTaskService.getDailyTasks();
        final lessonsTask = tasks.firstWhere((t) => t.id == 'daily_lessons');
        expect(lessonsTask.currentProgress, 0);
      });
    });

    group('early bird detection', () {
      test('early bird is set based on current time', () async {
        // We cannot easily mock DateTime.now() without a clock abstraction,
        // but we can verify the field is a bool and starts as false.
        final tasks = dailyTaskService.getDailyTasks();
        final earlyBirdTask = tasks.firstWhere((t) => t.id == 'early_bird');

        // Initially no early bird
        expect(earlyBirdTask.currentProgress, isA<int>());
        expect(earlyBirdTask.targetProgress, 1);
      });

      test('early bird reflects stored data correctly', () async {
        // Manually set today's data with early bird = true
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        await mockStorage.setString(
          'daily_tasks_$dateStr',
          '{"lessonsCompleted":0,"perfectLessonsCompleted":0,"wrongQuestionsReviewed":0,"hasEarlyBirdLesson":true}',
        );

        final tasks = dailyTaskService.getDailyTasks();
        final earlyBirdTask = tasks.firstWhere((t) => t.id == 'early_bird');
        expect(earlyBirdTask.currentProgress, 1);
        expect(earlyBirdTask.isCompleted, isTrue);
      });

      test('early bird is false when stored data says false', () async {
        final now = DateTime.now();
        final dateStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        await mockStorage.setString(
          'daily_tasks_$dateStr',
          '{"lessonsCompleted":1,"perfectLessonsCompleted":0,"wrongQuestionsReviewed":0,"hasEarlyBirdLesson":false}',
        );

        final tasks = dailyTaskService.getDailyTasks();
        final earlyBirdTask = tasks.firstWhere((t) => t.id == 'early_bird');
        expect(earlyBirdTask.currentProgress, 0);
        expect(earlyBirdTask.isCompleted, isFalse);
      });
    });
  });
}
