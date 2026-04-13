import 'dart:convert';
import '../../domain/entities/daily_task.dart';
import 'storage_service.dart';

class DailyTaskService {
  final StorageService _storage;

  DailyTaskService({required StorageService storage}) : _storage = storage;

  // --- Keys ---

  String get _todayKey {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'daily_tasks_$dateStr';
  }

  // --- Internal data access ---

  Map<String, dynamic> _loadTodayData() {
    final raw = _storage.getString(_todayKey);
    if (raw == null) {
      return {
        'lessonsCompleted': 0,
        'perfectLessonsCompleted': 0,
        'wrongQuestionsReviewed': 0,
        'hasEarlyBirdLesson': false,
      };
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {
        'lessonsCompleted': 0,
        'perfectLessonsCompleted': 0,
        'wrongQuestionsReviewed': 0,
        'hasEarlyBirdLesson': false,
      };
    }
  }

  Future<void> _saveTodayData(Map<String, dynamic> data) async {
    await _storage.setString(_todayKey, jsonEncode(data));
  }

  // --- Public API ---

  /// Called when a lesson finishes. Updates daily task progress.
  Future<void> markLessonCompleted(bool isPerfect) async {
    final data = _loadTodayData();

    // Increment lessons completed
    data['lessonsCompleted'] = (data['lessonsCompleted'] as int) + 1;

    // Increment perfect lessons if applicable
    if (isPerfect) {
      data['perfectLessonsCompleted'] =
          (data['perfectLessonsCompleted'] as int) + 1;
    }

    // Check early bird: 6:00 - 9:00
    final now = DateTime.now();
    if (now.hour >= 6 && now.hour < 9) {
      data['hasEarlyBirdLesson'] = true;
    }

    await _saveTodayData(data);
  }

  /// Called when wrong questions are reviewed. Stub for now.
  Future<void> markWrongQuestionsReviewed(int count) async {
    final data = _loadTodayData();
    data['wrongQuestionsReviewed'] =
        (data['wrongQuestionsReviewed'] as int) + count;
    await _saveTodayData(data);
  }

  /// Returns the list of daily tasks with current progress.
  List<DailyTask> getDailyTasks() {
    final data = _loadTodayData();

    final lessonsCompleted = data['lessonsCompleted'] as int;
    final perfectLessonsCompleted = data['perfectLessonsCompleted'] as int;
    final wrongQuestionsReviewed = data['wrongQuestionsReviewed'] as int;
    final hasEarlyBirdLesson = data['hasEarlyBirdLesson'] as bool;

    return [
      DailyTask(
        id: 'daily_lessons',
        title: '日课',
        reward: '+30 XP + 1 钻石',
        currentProgress: lessonsCompleted.clamp(0, 3),
        targetProgress: 3,
      ),
      DailyTask(
        id: 'perfect_lesson',
        title: '完美',
        reward: '+20 XP',
        currentProgress: perfectLessonsCompleted.clamp(0, 1),
        targetProgress: 1,
      ),
      DailyTask(
        id: 'review_wrong',
        title: '复习',
        reward: '+25 XP',
        currentProgress: wrongQuestionsReviewed.clamp(0, 5),
        targetProgress: 5,
      ),
      DailyTask(
        id: 'early_bird',
        title: '晨鸟',
        reward: 'XP x1.5',
        currentProgress: hasEarlyBirdLesson ? 1 : 0,
        targetProgress: 1,
      ),
    ];
  }
}
