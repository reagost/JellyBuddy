import '../entities/user.dart';

abstract class IGameRepository {
  Future<UserProgress> getUserProgress();
  Future<void> saveUserProgress(UserProgress progress);
  Future<void> addXp(int amount);
  Future<void> updateHearts(int delta);
  Future<void> updateStreak();
  Future<void> unlockAchievement(String achievementId);
  Future<List<Achievement>> getAllAchievements();
  Future<List<Achievement>> getUnlockedAchievements();
}
