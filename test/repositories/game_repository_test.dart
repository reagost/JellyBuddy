import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/core/constants/game_constants.dart';
import 'package:jelly_buddy/data/repositories/game_repository_impl.dart';
import '../helpers/mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;
  late GameRepositoryImpl repository;

  setUp(() {
    mockStorage = MockStorageService();
    repository = GameRepositoryImpl(storage: mockStorage);
  });

  group('GameRepositoryImpl', () {
    group('getUserProgress', () {
      test('returns initial progress when no data stored', () async {
        final progress = await repository.getUserProgress();

        expect(progress.userId, 'local_user');
        expect(progress.userName, 'Learner');
        expect(progress.totalXp, 0);
        expect(progress.level, 1);
        expect(progress.hearts, GameConstants.maxHearts);
        expect(progress.diamonds, 0);
        expect(progress.streak, 0);
        expect(progress.courseProgress, isEmpty);
        expect(progress.unlockedAchievements, isEmpty);
      });

      test('returns cached progress on second call', () async {
        final first = await repository.getUserProgress();
        final second = await repository.getUserProgress();

        expect(identical(first, second), isTrue);
      });
    });

    group('saveUserProgress', () {
      test('persists data that can be reloaded', () async {
        final initial = await repository.getUserProgress();
        final modified = initial.copyWith(totalXp: 500, level: 3, diamonds: 10);

        await repository.saveUserProgress(modified);

        // Create a new repository with the same storage to verify persistence
        final newRepo = GameRepositoryImpl(storage: mockStorage);
        final loaded = await newRepo.getUserProgress();

        expect(loaded.totalXp, 500);
        expect(loaded.level, 3);
        expect(loaded.diamonds, 10);
      });
    });

    group('addXp', () {
      test('increases XP by the specified amount', () async {
        await repository.addXp(30);
        final progress = await repository.getUserProgress();

        expect(progress.totalXp, 30);
      });

      test('calculates level correctly for level 1', () async {
        await repository.addXp(50);
        final progress = await repository.getUserProgress();

        // 50 XP: xpToLevel[0]=0, xpToLevel[1]=60 => level 1
        expect(progress.level, 1);
      });

      test('calculates level correctly for level 2', () async {
        await repository.addXp(60);
        final progress = await repository.getUserProgress();

        // 60 XP: xpToLevel[1]=60 => level 2
        expect(progress.level, 2);
      });

      test('calculates level correctly for higher levels', () async {
        await repository.addXp(300);
        final progress = await repository.getUserProgress();

        // 300 XP: xpToLevel[3]=300 => level 4
        expect(progress.level, 4);
      });

      test('accumulates XP across multiple calls', () async {
        await repository.addXp(30);
        await repository.addXp(40);
        final progress = await repository.getUserProgress();

        expect(progress.totalXp, 70);
        // 70 XP: xpToLevel[1]=60 => level 2
        expect(progress.level, 2);
      });
    });

    group('updateHearts', () {
      test('decrements hearts by delta', () async {
        await repository.updateHearts(-1);
        final progress = await repository.getUserProgress();

        expect(progress.hearts, GameConstants.maxHearts - 1);
      });

      test('increments hearts by positive delta', () async {
        // First reduce hearts
        await repository.updateHearts(-3);
        // Then add one back
        await repository.updateHearts(1);
        final progress = await repository.getUserProgress();

        expect(progress.hearts, GameConstants.maxHearts - 2);
      });

      test('clamps hearts to 0 (does not go negative)', () async {
        // Try to remove more hearts than available
        await repository.updateHearts(-10);
        final progress = await repository.getUserProgress();

        expect(progress.hearts, 0);
      });

      test('clamps hearts to maxHearts (does not exceed max)', () async {
        // Start at max, try to add more
        await repository.updateHearts(5);
        final progress = await repository.getUserProgress();

        expect(progress.hearts, GameConstants.maxHearts);
      });

      test('sets lastHeartLostAt when delta is negative', () async {
        await repository.updateHearts(-1);
        final progress = await repository.getUserProgress();

        expect(progress.lastHeartLostAt, isNotNull);
      });

      test('preserves lastHeartLostAt when delta is positive', () async {
        // Lose a heart first
        await repository.updateHearts(-1);
        final afterLoss = await repository.getUserProgress();
        final lostAt = afterLoss.lastHeartLostAt;

        // Gain a heart
        await repository.updateHearts(1);
        final afterGain = await repository.getUserProgress();

        // lastHeartLostAt should be preserved (not cleared by positive delta)
        expect(afterGain.lastHeartLostAt, lostAt);
      });
    });

    group('updateStreak', () {
      test('sets streak to 1 when no previous study date', () async {
        await repository.updateStreak();
        final progress = await repository.getUserProgress();

        expect(progress.streak, 1);
        expect(progress.lastStudyDate, isNotNull);
      });

      test('does not change streak if studied less than 24 hours ago', () async {
        await repository.updateStreak(); // streak = 1
        await repository.updateStreak(); // same day, no change

        final progress = await repository.getUserProgress();
        expect(progress.streak, 1);
      });

      test('increments streak when studied within grace period', () async {
        // Manually set a study date ~25 hours ago to simulate next day
        final initial = await repository.getUserProgress();
        final yesterday = DateTime.now().subtract(const Duration(hours: 25));
        final modified = initial.copyWith(
          streak: 3,
          lastStudyDate: yesterday,
        );
        await repository.saveUserProgress(modified);

        // Force cache invalidation by creating new repo
        final freshRepo = GameRepositoryImpl(storage: mockStorage);
        await freshRepo.updateStreak();
        final progress = await freshRepo.getUserProgress();

        expect(progress.streak, 4);
      });

      test('resets streak when gap exceeds grace hours', () async {
        // Set a study date far in the past (> 36 hours ago)
        final initial = await repository.getUserProgress();
        final longAgo = DateTime.now().subtract(const Duration(hours: 48));
        final modified = initial.copyWith(
          streak: 5,
          lastStudyDate: longAgo,
        );
        await repository.saveUserProgress(modified);

        final freshRepo = GameRepositoryImpl(storage: mockStorage);
        await freshRepo.updateStreak();
        final progress = await freshRepo.getUserProgress();

        expect(progress.streak, 1); // Reset
      });
    });

    group('heart recovery', () {
      test('recovers hearts based on time elapsed', () async {
        // Set progress with reduced hearts and a lastHeartLostAt in the past
        final initial = await repository.getUserProgress();
        final lostAt = DateTime.now().subtract(
          const Duration(hours: GameConstants.heartsRecoveryHours * 2),
        );
        final modified = initial.copyWith(
          hearts: 2,
          lastHeartLostAt: lostAt,
        );
        await repository.saveUserProgress(modified);

        // Create fresh repo to trigger recovery on load
        final freshRepo = GameRepositoryImpl(storage: mockStorage);
        final progress = await freshRepo.getUserProgress();

        // Should recover 2 hearts (8 hours / 4 hours per recovery = 2)
        expect(progress.hearts, 4);
      });

      test('does not recover beyond maxHearts', () async {
        final initial = await repository.getUserProgress();
        final lostAt = DateTime.now().subtract(const Duration(hours: 100));
        final modified = initial.copyWith(
          hearts: 1,
          lastHeartLostAt: lostAt,
        );
        await repository.saveUserProgress(modified);

        final freshRepo = GameRepositoryImpl(storage: mockStorage);
        final progress = await freshRepo.getUserProgress();

        expect(progress.hearts, GameConstants.maxHearts);
      });

      test('clears lastHeartLostAt when fully recovered', () async {
        final initial = await repository.getUserProgress();
        final lostAt = DateTime.now().subtract(const Duration(hours: 100));
        final modified = initial.copyWith(
          hearts: 1,
          lastHeartLostAt: lostAt,
        );
        await repository.saveUserProgress(modified);

        final freshRepo = GameRepositoryImpl(storage: mockStorage);
        final progress = await freshRepo.getUserProgress();

        expect(progress.hearts, GameConstants.maxHearts);
        expect(progress.lastHeartLostAt, isNull);
      });

      test('does not recover if already at maxHearts', () async {
        final initial = await repository.getUserProgress();
        // Already at max hearts
        expect(initial.hearts, GameConstants.maxHearts);

        final freshRepo = GameRepositoryImpl(storage: mockStorage);
        final progress = await freshRepo.getUserProgress();
        expect(progress.hearts, GameConstants.maxHearts);
      });
    });

    group('unlockAchievement', () {
      test('adds achievement to unlocked list', () async {
        await repository.unlockAchievement('first_step');
        final progress = await repository.getUserProgress();

        expect(progress.unlockedAchievements, contains('first_step'));
      });

      test('does not duplicate already unlocked achievement', () async {
        await repository.unlockAchievement('first_step');
        await repository.unlockAchievement('first_step');
        final progress = await repository.getUserProgress();

        expect(
          progress.unlockedAchievements.where((a) => a == 'first_step').length,
          1,
        );
      });
    });

    group('getAllAchievements', () {
      test('returns a non-empty list of achievements', () async {
        final achievements = await repository.getAllAchievements();

        expect(achievements, isNotEmpty);
        expect(achievements.length, 4);
      });
    });

    group('getUnlockedAchievements', () {
      test('returns empty list when nothing unlocked', () async {
        final unlocked = await repository.getUnlockedAchievements();
        expect(unlocked, isEmpty);
      });

      test('returns only unlocked achievements', () async {
        await repository.unlockAchievement('first_step');
        final unlocked = await repository.getUnlockedAchievements();

        expect(unlocked.length, 1);
        expect(unlocked.first.id, 'first_step');
      });
    });
  });
}
