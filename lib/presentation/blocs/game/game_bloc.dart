import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_game_repository.dart';
import '../../../core/constants/game_constants.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final IGameRepository gameRepo;

  GameBloc({required this.gameRepo})
      : super(GameState(
          progress: UserProgress(
            userId: '',
            userName: 'Learner',
            totalXp: 0,
            level: 1,
            hearts: GameConstants.maxHearts,
            diamonds: 0,
            streak: 0,
            courseProgress: const {},
            unlockedAchievements: const [],
          ),
        )) {
    on<LoadUserProgress>(_onLoadUserProgress);
    on<AddXp>(_onAddXp);
    on<UpdateHearts>(_onUpdateHearts);
    on<UpdateStreak>(_onUpdateStreak);
    on<AddDiamond>(_onAddDiamond);
    on<SpendDiamond>(_onSpendDiamond);
    on<UnlockAchievement>(_onUnlockAchievement);
    on<ClearLevelUpNotification>(_onClearLevelUpNotification);
    on<UpdateUserName>(_onUpdateUserName);
  }

  Future<void> _onLoadUserProgress(
    LoadUserProgress event,
    Emitter<GameState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final progress = await gameRepo.getUserProgress();
      final achievements = await gameRepo.getAllAchievements();
      emit(state.copyWith(
        progress: progress,
        allAchievements: achievements,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddXp(
    AddXp event,
    Emitter<GameState> emit,
  ) async {
    final oldLevel = state.progress.level;
    await gameRepo.addXp(event.amount);
    final updated = await gameRepo.getUserProgress();
    final newLevel = updated.level;
    emit(state.copyWith(
      progress: updated,
      justLeveledUp: newLevel > oldLevel,
    ));
  }

  Future<void> _onUpdateHearts(
    UpdateHearts event,
    Emitter<GameState> emit,
  ) async {
    await gameRepo.updateHearts(event.delta);
    final updated = await gameRepo.getUserProgress();
    emit(state.copyWith(progress: updated));
  }

  Future<void> _onUpdateStreak(
    UpdateStreak event,
    Emitter<GameState> emit,
  ) async {
    await gameRepo.updateStreak();
    final updated = await gameRepo.getUserProgress();
    emit(state.copyWith(progress: updated));
  }

  Future<void> _onAddDiamond(
    AddDiamond event,
    Emitter<GameState> emit,
  ) async {
    final updated = state.progress.copyWith(
      diamonds: state.progress.diamonds + event.amount,
    );
    await gameRepo.saveUserProgress(updated);
    emit(state.copyWith(progress: updated));
  }

  Future<void> _onSpendDiamond(
    SpendDiamond event,
    Emitter<GameState> emit,
  ) async {
    final newDiamonds = (state.progress.diamonds - event.amount).clamp(0, 999999);
    final updated = state.progress.copyWith(diamonds: newDiamonds);
    await gameRepo.saveUserProgress(updated);
    emit(state.copyWith(progress: updated));
  }

  Future<void> _onUnlockAchievement(
    UnlockAchievement event,
    Emitter<GameState> emit,
  ) async {
    await gameRepo.unlockAchievement(event.achievementId);
    final updated = await gameRepo.getUserProgress();
    final all = await gameRepo.getAllAchievements();
    final achievement = all.where((a) => a.id == event.achievementId).firstOrNull;
    emit(state.copyWith(
      progress: updated,
      allAchievements: all,
      newlyUnlockedAchievement: achievement,
    ));
  }

  void _onClearLevelUpNotification(
    ClearLevelUpNotification event,
    Emitter<GameState> emit,
  ) {
    emit(state.copyWith(justLeveledUp: false));
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<GameState> emit,
  ) async {
    final updated = state.progress.copyWith(userName: event.name);
    await gameRepo.saveUserProgress(updated);
    emit(state.copyWith(progress: updated));
  }
}