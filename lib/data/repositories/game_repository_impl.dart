import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_game_repository.dart';
import '../../core/constants/game_constants.dart';
import '../services/storage_service.dart';

class GameRepositoryImpl implements IGameRepository {
  final StorageService storage;
  UserProgress? _cached;

  GameRepositoryImpl({required this.storage});

  UserProgress _createInitialProgress() {
    return const UserProgress(
      userId: 'local_user',
      userName: 'Learner',
      totalXp: 0,
      level: 1,
      hearts: GameConstants.maxHearts,
      diamonds: 0,
      streak: 0,
      courseProgress: {},
      unlockedAchievements: [],
    );
  }

  @override
  Future<UserProgress> getUserProgress() async {
    if (_cached != null) return _cached!;

    final data = storage.getString('user_progress');
    if (data == null) {
      _cached = _createInitialProgress();
      return _cached!;
    }

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      _cached = UserProgress(
        userId: json['userId'] as String? ?? 'local_user',
        userName: json['userName'] as String? ?? 'Learner',
        totalXp: json['totalXp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        hearts: json['hearts'] as int? ?? GameConstants.maxHearts,
        diamonds: json['diamonds'] as int? ?? 0,
        streak: json['streak'] as int? ?? 0,
        lastStudyDate: json['lastStudyDate'] != null
            ? DateTime.tryParse(json['lastStudyDate'] as String)
            : null,
        lastHeartLostAt: json['lastHeartLostAt'] != null
            ? DateTime.tryParse(json['lastHeartLostAt'] as String)
            : null,
        courseProgress: const {},
        unlockedAchievements: (json['unlockedAchievements'] as List?)?.cast<String>() ?? [],
      );
      // Apply heart recovery
      _cached = _applyHeartRecovery(_cached!);
      return _cached!;
    } catch (_) {
      _cached = _createInitialProgress();
      return _cached!;
    }
  }

  @override
  Future<void> saveUserProgress(UserProgress progress) async {
    _cached = progress;
    final json = jsonEncode({
      'userId': progress.userId,
      'userName': progress.userName,
      'totalXp': progress.totalXp,
      'level': progress.level,
      'hearts': progress.hearts,
      'diamonds': progress.diamonds,
      'streak': progress.streak,
      'lastStudyDate': progress.lastStudyDate?.toIso8601String(),
      'lastHeartLostAt': progress.lastHeartLostAt?.toIso8601String(),
      'unlockedAchievements': progress.unlockedAchievements,
    });
    await storage.setString('user_progress', json);
  }

  UserProgress _applyHeartRecovery(UserProgress progress) {
    if (progress.hearts >= GameConstants.maxHearts) return progress;
    final lostAt = progress.lastHeartLostAt;
    if (lostAt == null) return progress;

    final hoursSinceLost = DateTime.now().difference(lostAt).inHours;
    final recoveredHearts = hoursSinceLost ~/ GameConstants.heartsRecoveryHours;
    if (recoveredHearts <= 0) return progress;

    final newHearts = (progress.hearts + recoveredHearts).clamp(0, GameConstants.maxHearts);
    return progress.copyWith(
      hearts: newHearts,
      lastHeartLostAt: newHearts >= GameConstants.maxHearts ? null : lostAt,
    );
  }

  @override
  Future<void> addXp(int amount) async {
    final progress = await getUserProgress();
    final newXp = progress.totalXp + amount;
    final newLevel = _calculateLevel(newXp);
    final updated = progress.copyWith(totalXp: newXp, level: newLevel);
    await saveUserProgress(updated);
  }

  @override
  Future<void> updateHearts(int delta) async {
    final progress = await getUserProgress();
    final newHearts = (progress.hearts + delta).clamp(0, GameConstants.maxHearts);
    final updated = progress.copyWith(
      hearts: newHearts,
      lastHeartLostAt: delta < 0 ? DateTime.now() : progress.lastHeartLostAt,
    );
    await saveUserProgress(updated);
  }

  @override
  Future<void> updateStreak() async {
    final progress = await getUserProgress();
    final now = DateTime.now();
    final lastStudy = progress.lastStudyDate;

    int newStreak = progress.streak;
    if (lastStudy == null) {
      newStreak = 1;
    } else {
      final hoursSinceLastStudy = now.difference(lastStudy).inHours;
      if (hoursSinceLastStudy < 24) {
        // Already studied today, no change
        return;
      } else if (hoursSinceLastStudy < GameConstants.streakGraceHours) {
        newStreak = progress.streak + 1;
      } else {
        newStreak = 1; // Reset streak
      }
    }

    final updated = progress.copyWith(
      streak: newStreak,
      lastStudyDate: now,
    );
    await saveUserProgress(updated);
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    final progress = await getUserProgress();
    if (!progress.unlockedAchievements.contains(achievementId)) {
      final updated = progress.copyWith(
        unlockedAchievements: [...progress.unlockedAchievements, achievementId],
      );
      await saveUserProgress(updated);
    }
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return const [
      Achievement(
        id: 'first_step',
        name: 'First Step',
        nameZh: '第一步',
        description: '完成第一个关卡',
        category: '新手',
        xpReward: 10,
        icon: '⭐',
      ),
      Achievement(
        id: 'streak_7',
        name: 'Streak Master',
        nameZh: '连续大师',
        description: '7天连续学习',
        category: '进阶',
        xpReward: 50,
        icon: '🔥',
      ),
      Achievement(
        id: 'perfect_10',
        name: 'Perfectionist',
        nameZh: '完美主义者',
        description: '完成10个 Perfect 关卡',
        category: '进阶',
        xpReward: 100,
        icon: '🏆',
      ),
      Achievement(
        id: 'quick_learner',
        name: 'Quick Learner',
        nameZh: '快速学习者',
        description: '连续答对5题',
        category: '新手',
        xpReward: 5,
        icon: '⚡',
      ),
    ];
  }

  @override
  Future<List<Achievement>> getUnlockedAchievements() async {
    final progress = await getUserProgress();
    final all = await getAllAchievements();
    return all.where((a) => progress.unlockedAchievements.contains(a.id)).toList();
  }

  int _calculateLevel(int xp) {
    for (int i = GameConstants.xpToLevel.length - 1; i >= 0; i--) {
      if (xp >= GameConstants.xpToLevel[i]) return i + 1;
    }
    return 1;
  }
}
