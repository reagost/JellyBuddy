import '../../domain/repositories/i_game_repository.dart';
import '../../domain/repositories/i_learning_repository.dart';
import 'storage_service.dart';

class CourseCompletionRate {
  final String courseId;
  final String courseName;
  final String icon;
  final int completed;
  final int total;

  const CourseCompletionRate({
    required this.courseId,
    required this.courseName,
    required this.icon,
    required this.completed,
    required this.total,
  });

  double get percentage => total == 0 ? 0.0 : completed / total;
}

class RecentLessonResult {
  final String lessonId;
  final String lessonTitle;
  final int score;
  final bool isPerfect;
  final DateTime completedAt;

  const RecentLessonResult({
    required this.lessonId,
    required this.lessonTitle,
    required this.score,
    required this.isPerfect,
    required this.completedAt,
  });
}

class StatsService {
  final ILearningRepository _learningRepo;
  final IGameRepository _gameRepo;
  final StorageService _storage;

  static const String _bestStreakKey = 'stats_best_streak';

  StatsService({
    required ILearningRepository learningRepo,
    required IGameRepository gameRepo,
    required StorageService storage,
  })  : _learningRepo = learningRepo,
        _gameRepo = gameRepo,
        _storage = storage;

  /// Total number of lessons completed across all courses.
  Future<int> getTotalLessonsCompleted() async {
    final courses = await _learningRepo.getAllCourses();
    int total = 0;
    for (final course in courses) {
      total += _learningRepo.getCompletedLessonIds(course.id).length;
    }
    return total;
  }

  /// Average score across all completed lessons (0-100).
  Future<double> getOverallAccuracy() async {
    final courses = await _learningRepo.getAllCourses();
    final scores = <int>[];
    for (final course in courses) {
      final completedIds = _learningRepo.getCompletedLessonIds(course.id);
      for (final lessonId in completedIds) {
        final result = await _learningRepo.getLessonResult(lessonId);
        if (result != null) {
          scores.add(result.score);
        }
      }
    }
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// 7 booleans (Mon=index 0 through Sun=index 6) indicating whether
  /// the user completed at least one lesson on that day of the current week.
  Future<List<bool>> getWeeklyActivity() async {
    final now = DateTime.now();
    // Monday = 1 in Dart's DateTime.weekday
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    // Collect all completedAt dates for this week
    final activeDays = <int>{};
    final courses = await _learningRepo.getAllCourses();
    for (final course in courses) {
      final completedIds = _learningRepo.getCompletedLessonIds(course.id);
      for (final lessonId in completedIds) {
        final result = await _learningRepo.getLessonResult(lessonId);
        if (result != null) {
          final completedDate = result.completedAt;
          if (!completedDate.isBefore(weekStart) &&
              completedDate.isBefore(weekStart.add(const Duration(days: 7)))) {
            // weekday: 1=Mon ... 7=Sun -> index 0..6
            activeDays.add(completedDate.weekday - 1);
          }
        }
      }
    }

    return List.generate(7, (i) => activeDays.contains(i));
  }

  /// Completion rate for each course.
  Future<List<CourseCompletionRate>> getCourseCompletionRates() async {
    final courses = await _learningRepo.getAllCourses();
    final rates = <CourseCompletionRate>[];
    for (final course in courses) {
      final completedIds = _learningRepo.getCompletedLessonIds(course.id);
      final total = course.totalLessons > 0
          ? course.totalLessons
          : course.lessons.length;
      rates.add(CourseCompletionRate(
        courseId: course.id,
        courseName: course.name,
        icon: course.icon,
        completed: completedIds.length,
        total: total,
      ));
    }
    return rates;
  }

  /// Total XP earned from GameRepository.
  Future<int> getTotalXpEarned() async {
    final progress = await _gameRepo.getUserProgress();
    return progress.totalXp;
  }

  /// Current streak from GameRepository.
  Future<int> getCurrentStreak() async {
    final progress = await _gameRepo.getUserProgress();
    return progress.streak;
  }

  /// Best streak ever achieved, persisted in StorageService.
  /// Also updates the stored best streak if current streak is higher.
  Future<int> getBestStreak() async {
    final currentStreak = await getCurrentStreak();
    final storedBest = int.tryParse(_storage.getString(_bestStreakKey) ?? '') ?? 0;
    final best = currentStreak > storedBest ? currentStreak : storedBest;
    if (best > storedBest) {
      await _storage.setString(_bestStreakKey, best.toString());
    }
    return best;
  }

  /// Last N lesson results with scores, sorted by completedAt descending.
  Future<List<RecentLessonResult>> getRecentResults({int limit = 5}) async {
    final courses = await _learningRepo.getAllCourses();
    final allResults = <RecentLessonResult>[];

    // Build a lessonId -> lesson title map
    final lessonTitles = <String, String>{};
    for (final course in courses) {
      for (final lesson in course.lessons) {
        lessonTitles[lesson.id] = lesson.title;
      }
    }

    for (final course in courses) {
      final completedIds = _learningRepo.getCompletedLessonIds(course.id);
      for (final lessonId in completedIds) {
        final result = await _learningRepo.getLessonResult(lessonId);
        if (result != null) {
          allResults.add(RecentLessonResult(
            lessonId: lessonId,
            lessonTitle: lessonTitles[lessonId] ?? lessonId,
            score: result.score,
            isPerfect: result.isPerfect,
            completedAt: result.completedAt,
          ));
        }
      }
    }

    allResults.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return allResults.take(limit).toList();
  }
}
