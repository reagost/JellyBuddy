import 'dart:convert';
import 'storage_service.dart';

class ProgressService {
  final StorageService _storage;

  ProgressService({required StorageService storage}) : _storage = storage;

  // --- Keys ---

  String _lessonResultKey(String lessonId) => 'lesson_result_$lessonId';
  String _completedLessonsKey(String courseId) => 'completed_lessons_$courseId';
  String _wrongQuestionsKey(String lessonId) => 'wrong_questions_$lessonId';

  // --- Save / Read Lesson Results ---

  Future<void> saveLessonResult({
    required String courseId,
    required String lessonId,
    required int score,
    required int correctCount,
    required int totalCount,
    required bool isPerfect,
    required DateTime completedAt,
    required List<String> wrongQuestionIds,
  }) async {
    // Save the lesson result
    final resultJson = jsonEncode({
      'lessonId': lessonId,
      'score': score,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'isPerfect': isPerfect,
      'completedAt': completedAt.toIso8601String(),
    });
    await _storage.setString(_lessonResultKey(lessonId), resultJson);

    // Save wrong question IDs
    if (wrongQuestionIds.isNotEmpty) {
      await _storage.setString(
        _wrongQuestionsKey(lessonId),
        jsonEncode(wrongQuestionIds),
      );
    }

    // Update completed lessons set for the course
    final completedIds = getCompletedLessonIds(courseId);
    if (!completedIds.contains(lessonId)) {
      completedIds.add(lessonId);
      await _storage.setString(
        _completedLessonsKey(courseId),
        jsonEncode(completedIds),
      );
    }
  }

  Map<String, dynamic>? getLessonResult(String lessonId) {
    final data = _storage.getString(_lessonResultKey(lessonId));
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  List<String> getCompletedLessonIds(String courseId) {
    final data = _storage.getString(_completedLessonsKey(courseId));
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  bool isLessonCompleted(String courseId, String lessonId) {
    return getCompletedLessonIds(courseId).contains(lessonId);
  }

  List<String> getWrongQuestionIds(String lessonId) {
    final data = _storage.getString(_wrongQuestionsKey(lessonId));
    if (data == null) return [];
    try {
      return (jsonDecode(data) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}
