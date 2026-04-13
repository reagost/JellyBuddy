import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

class GameState extends Equatable {
  final UserProgress progress;
  final List<Achievement> allAchievements;
  final bool isLoading;
  final String? error;
  final bool justLeveledUp;
  final Achievement? newlyUnlockedAchievement;

  const GameState({
    required this.progress,
    this.allAchievements = const [],
    this.isLoading = false,
    this.error,
    this.justLeveledUp = false,
    this.newlyUnlockedAchievement,
  });

  GameState copyWith({
    UserProgress? progress,
    List<Achievement>? allAchievements,
    bool? isLoading,
    String? error,
    bool? justLeveledUp,
    Achievement? newlyUnlockedAchievement,
  }) {
    return GameState(
      progress: progress ?? this.progress,
      allAchievements: allAchievements ?? this.allAchievements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      justLeveledUp: justLeveledUp ?? this.justLeveledUp,
      newlyUnlockedAchievement: newlyUnlockedAchievement,
    );
  }

  @override
  List<Object?> get props => [progress, allAchievements, isLoading, error, justLeveledUp, newlyUnlockedAchievement];
}