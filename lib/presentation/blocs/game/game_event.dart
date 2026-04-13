import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProgress extends GameEvent {}

class UpdateHearts extends GameEvent {
  final int delta;
  const UpdateHearts(this.delta);

  @override
  List<Object?> get props => [delta];
}

class AddXp extends GameEvent {
  final int amount;
  const AddXp(this.amount);

  @override
  List<Object?> get props => [amount];
}

class UpdateStreak extends GameEvent {}

class UnlockAchievement extends GameEvent {
  final String achievementId;
  const UnlockAchievement(this.achievementId);

  @override
  List<Object?> get props => [achievementId];
}

class AddDiamond extends GameEvent {
  final int amount;
  const AddDiamond(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SpendDiamond extends GameEvent {
  final int amount;
  const SpendDiamond(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ClearLevelUpNotification extends GameEvent {}

class UpdateUserName extends GameEvent {
  final String name;
  const UpdateUserName(this.name);

  @override
  List<Object?> get props => [name];
}