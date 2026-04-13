import '../../domain/entities/user.dart';
import '../../domain/repositories/i_game_repository.dart';
import 'progress_service.dart';
import 'storage_service.dart';

/// Evaluates achievement conditions and unlocks newly earned achievements.
class AchievementService {
  final IGameRepository _gameRepo;
  final ProgressService _progressService;
  final StorageService _storage;

  static const _consecutiveCorrectKey = 'consecutive_correct_answers';

  AchievementService({
    required IGameRepository gameRepo,
    required ProgressService progressService,
    required StorageService storage,
  })  : _gameRepo = gameRepo,
        _progressService = progressService,
        _storage = storage;

  // --- Consecutive correct answer tracking (for quick_learner) ---

  int getConsecutiveCorrect() {
    final raw = _storage.getString(_consecutiveCorrectKey);
    if (raw == null) return 0;
    return int.tryParse(raw) ?? 0;
  }

  Future<void> recordCorrectAnswer() async {
    final current = getConsecutiveCorrect();
    await _storage.setString(_consecutiveCorrectKey, '${current + 1}');
  }

  Future<void> resetConsecutiveCorrect() async {
    await _storage.setString(_consecutiveCorrectKey, '0');
  }

  // --- Main check method ---

  /// Evaluates all achievement conditions and unlocks any that are newly met.
  /// Returns the list of [Achievement] objects that were just unlocked.
  Future<List<Achievement>> checkAndUnlockAchievements({
    required String courseId,
  }) async {
    final progress = await _gameRepo.getUserProgress();
    final allAchievements = await _gameRepo.getAllAchievements();
    final alreadyUnlocked = progress.unlockedAchievements;
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (alreadyUnlocked.contains(achievement.id)) continue;

      final met = _isConditionMet(
        achievementId: achievement.id,
        progress: progress,
        courseId: courseId,
      );

      if (met) {
        await _gameRepo.unlockAchievement(achievement.id);
        await _gameRepo.addXp(achievement.xpReward);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  bool _isConditionMet({
    required String achievementId,
    required UserProgress progress,
    required String courseId,
  }) {
    switch (achievementId) {
      case 'first_step':
        return _checkFirstStep(courseId);
      case 'streak_7':
        return _checkStreak7(progress);
      case 'perfect_10':
        return _checkPerfect10(courseId);
      case 'quick_learner':
        return _checkQuickLearner();
      default:
        return false;
    }
  }

  /// first_step: any lesson completed (completedLessonIds not empty)
  bool _checkFirstStep(String courseId) {
    final completed = _progressService.getCompletedLessonIds(courseId);
    return completed.isNotEmpty;
  }

  /// streak_7: streak >= 7
  bool _checkStreak7(UserProgress progress) {
    return progress.streak >= 7;
  }

  /// perfect_10: count lessons with isPerfect == true >= 10
  bool _checkPerfect10(String courseId) {
    final completedIds = _progressService.getCompletedLessonIds(courseId);
    int perfectCount = 0;
    for (final lessonId in completedIds) {
      final result = _progressService.getLessonResult(lessonId);
      if (result != null && result['isPerfect'] == true) {
        perfectCount++;
      }
    }
    return perfectCount >= 10;
  }

  /// quick_learner: consecutive correct answers >= 5
  bool _checkQuickLearner() {
    return getConsecutiveCorrect() >= 5;
  }

  // --- Progress helpers for UI display ---

  /// Returns a map of achievement id -> (current, target) for progress display.
  Future<Map<String, (int, int)>> getAchievementProgress({
    required String courseId,
    required UserProgress progress,
  }) async {
    final result = <String, (int, int)>{};

    // first_step: 0 or 1 / 1
    final completedIds = _progressService.getCompletedLessonIds(courseId);
    result['first_step'] = (completedIds.isEmpty ? 0 : 1, 1);

    // streak_7
    result['streak_7'] = (progress.streak.clamp(0, 7), 7);

    // perfect_10
    int perfectCount = 0;
    for (final lessonId in completedIds) {
      final lr = _progressService.getLessonResult(lessonId);
      if (lr != null && lr['isPerfect'] == true) {
        perfectCount++;
      }
    }
    result['perfect_10'] = (perfectCount.clamp(0, 10), 10);

    // quick_learner
    result['quick_learner'] = (getConsecutiveCorrect().clamp(0, 5), 5);

    return result;
  }
}
