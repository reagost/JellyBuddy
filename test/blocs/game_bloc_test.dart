import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jelly_buddy/core/constants/game_constants.dart';
import 'package:jelly_buddy/domain/entities/user.dart';
import 'package:jelly_buddy/presentation/blocs/game/game_bloc.dart';
import 'package:jelly_buddy/presentation/blocs/game/game_event.dart';
import 'package:jelly_buddy/presentation/blocs/game/game_state.dart';
import '../helpers/mock_game_repository.dart';

void main() {
  late MockGameRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const UserProgress(
      userId: '',
      userName: '',
      totalXp: 0,
      level: 1,
      hearts: 5,
      diamonds: 0,
      streak: 0,
      courseProgress: {},
      unlockedAchievements: [],
    ));
  });

  const initialProgress = UserProgress(
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

  const testAchievements = [
    Achievement(
      id: 'first_step',
      name: 'First Step',
      nameZh: '第一步',
      description: '完成第一个关卡',
      category: '新手',
      xpReward: 10,
      icon: '⭐',
    ),
  ];

  setUp(() {
    mockRepo = MockGameRepository();
  });

  group('GameBloc', () {
    group('LoadUserProgress', () {
      blocTest<GameBloc, GameState>(
        'emits loading then progress from repository',
        build: () {
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => initialProgress);
          when(() => mockRepo.getAllAchievements())
              .thenAnswer((_) async => testAchievements);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(LoadUserProgress()),
        expect: () => [
          // First emission: isLoading = true
          isA<GameState>().having((s) => s.isLoading, 'isLoading', true),
          // Second emission: isLoading = false, progress loaded
          isA<GameState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.progress, 'progress', initialProgress)
              .having((s) => s.allAchievements, 'allAchievements', testAchievements),
        ],
      );

      blocTest<GameBloc, GameState>(
        'emits error state when repository throws',
        build: () {
          when(() => mockRepo.getUserProgress())
              .thenThrow(Exception('Load failed'));
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(LoadUserProgress()),
        expect: () => [
          isA<GameState>().having((s) => s.isLoading, 'isLoading', true),
          isA<GameState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );
    });

    group('AddXp', () {
      blocTest<GameBloc, GameState>(
        'updates totalXp and level through repository',
        build: () {
          final updatedProgress = initialProgress.copyWith(totalXp: 50, level: 1);
          when(() => mockRepo.addXp(50)).thenAnswer((_) async {});
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => updatedProgress);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(const AddXp(50)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.totalXp, 'totalXp', 50),
        ],
      );

      blocTest<GameBloc, GameState>(
        'sets justLeveledUp when level increases',
        build: () {
          // After addXp, the repo returns a higher level
          final updatedProgress = initialProgress.copyWith(totalXp: 100, level: 2);
          when(() => mockRepo.addXp(100)).thenAnswer((_) async {});
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => updatedProgress);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(const AddXp(100)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.justLeveledUp, 'justLeveledUp', true)
              .having((s) => s.progress.level, 'level', 2),
        ],
      );

      blocTest<GameBloc, GameState>(
        'does not set justLeveledUp when level stays same',
        build: () {
          final updatedProgress = initialProgress.copyWith(totalXp: 30, level: 1);
          when(() => mockRepo.addXp(30)).thenAnswer((_) async {});
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => updatedProgress);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(const AddXp(30)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.justLeveledUp, 'justLeveledUp', false),
        ],
      );
    });

    group('UpdateHearts', () {
      blocTest<GameBloc, GameState>(
        'decrements hearts via repository',
        build: () {
          final updatedProgress = initialProgress.copyWith(hearts: 4);
          when(() => mockRepo.updateHearts(-1)).thenAnswer((_) async {});
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => updatedProgress);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(const UpdateHearts(-1)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.hearts, 'hearts', 4),
        ],
      );

      blocTest<GameBloc, GameState>(
        'increments hearts via repository',
        build: () {
          final updatedProgress = initialProgress.copyWith(hearts: GameConstants.maxHearts);
          when(() => mockRepo.updateHearts(1)).thenAnswer((_) async {});
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => updatedProgress);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(const UpdateHearts(1)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.hearts, 'hearts', GameConstants.maxHearts),
        ],
      );
    });

    group('UpdateStreak', () {
      blocTest<GameBloc, GameState>(
        'updates streak via repository',
        build: () {
          final updatedProgress = initialProgress.copyWith(streak: 1);
          when(() => mockRepo.updateStreak()).thenAnswer((_) async {});
          when(() => mockRepo.getUserProgress())
              .thenAnswer((_) async => updatedProgress);
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(UpdateStreak()),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.streak, 'streak', 1),
        ],
      );
    });

    group('AddDiamond', () {
      blocTest<GameBloc, GameState>(
        'updates diamonds by adding amount',
        build: () {
          when(() => mockRepo.saveUserProgress(any())).thenAnswer((_) async {});
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) => bloc.add(const AddDiamond(5)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.diamonds, 'diamonds', 5),
        ],
      );

      blocTest<GameBloc, GameState>(
        'accumulates diamonds across multiple events',
        build: () {
          when(() => mockRepo.saveUserProgress(any())).thenAnswer((_) async {});
          return GameBloc(gameRepo: mockRepo);
        },
        act: (bloc) {
          bloc.add(const AddDiamond(3));
          bloc.add(const AddDiamond(7));
        },
        expect: () => [
          isA<GameState>().having((s) => s.progress.diamonds, 'diamonds', 3),
          isA<GameState>().having((s) => s.progress.diamonds, 'diamonds', 10),
        ],
      );
    });

    group('SpendDiamond', () {
      blocTest<GameBloc, GameState>(
        'reduces diamonds by spending amount',
        build: () {
          when(() => mockRepo.saveUserProgress(any())).thenAnswer((_) async {});
          return GameBloc(gameRepo: mockRepo);
        },
        seed: () => GameState(
          progress: initialProgress.copyWith(diamonds: 10),
        ),
        act: (bloc) => bloc.add(const SpendDiamond(3)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.diamonds, 'diamonds', 7),
        ],
      );

      blocTest<GameBloc, GameState>(
        'clamps diamonds to 0 when spending more than available',
        build: () {
          when(() => mockRepo.saveUserProgress(any())).thenAnswer((_) async {});
          return GameBloc(gameRepo: mockRepo);
        },
        seed: () => GameState(
          progress: initialProgress.copyWith(diamonds: 2),
        ),
        act: (bloc) => bloc.add(const SpendDiamond(5)),
        expect: () => [
          isA<GameState>()
              .having((s) => s.progress.diamonds, 'diamonds', 0),
        ],
      );
    });

    group('ClearLevelUpNotification', () {
      blocTest<GameBloc, GameState>(
        'clears justLeveledUp flag',
        build: () => GameBloc(gameRepo: mockRepo),
        seed: () => const GameState(
          progress: initialProgress,
          justLeveledUp: true,
        ),
        act: (bloc) => bloc.add(ClearLevelUpNotification()),
        expect: () => [
          isA<GameState>()
              .having((s) => s.justLeveledUp, 'justLeveledUp', false),
        ],
      );
    });
  });
}
