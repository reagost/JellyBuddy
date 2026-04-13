import 'package:equatable/equatable.dart';

const _sentinel = Object();

class UserProgress extends Equatable {
  final String userId;
  final String userName;
  final int totalXp;
  final int level;
  final int hearts;
  final int diamonds;
  final int streak;
  final DateTime? lastStudyDate;
  final DateTime? lastHeartLostAt;
  final Map<String, CourseProgress> courseProgress;
  final List<String> unlockedAchievements;

  const UserProgress({
    required this.userId,
    required this.userName,
    required this.totalXp,
    required this.level,
    required this.hearts,
    required this.diamonds,
    required this.streak,
    this.lastStudyDate,
    this.lastHeartLostAt,
    required this.courseProgress,
    required this.unlockedAchievements,
  });

  UserProgress copyWith({
    String? userId,
    String? userName,
    int? totalXp,
    int? level,
    int? hearts,
    int? diamonds,
    int? streak,
    DateTime? lastStudyDate,
    Object? lastHeartLostAt = _sentinel,
    Map<String, CourseProgress>? courseProgress,
    List<String>? unlockedAchievements,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      hearts: hearts ?? this.hearts,
      diamonds: diamonds ?? this.diamonds,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      lastHeartLostAt: identical(lastHeartLostAt, _sentinel) ? this.lastHeartLostAt : lastHeartLostAt as DateTime?,
      courseProgress: courseProgress ?? this.courseProgress,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [userId, userName, totalXp, level, hearts, diamonds, streak, lastStudyDate, lastHeartLostAt, courseProgress, unlockedAchievements];
}

class CourseProgress extends Equatable {
  final String courseId;
  final String courseName;
  final int currentLessonIndex;
  final List<String> completedLessons;
  final double masteryLevel;

  const CourseProgress({
    required this.courseId,
    required this.courseName,
    required this.currentLessonIndex,
    required this.completedLessons,
    required this.masteryLevel,
  });

  @override
  List<Object?> get props => [courseId, courseName, currentLessonIndex, completedLessons, masteryLevel];
}

class LessonResult extends Equatable {
  final String lessonId;
  final int score;
  final int correctCount;
  final int totalCount;
  final Duration timeSpent;
  final bool isPerfect;
  final DateTime completedAt;
  final List<String> wrongQuestionIds;

  const LessonResult({
    required this.lessonId,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSpent,
    required this.isPerfect,
    required this.completedAt,
    required this.wrongQuestionIds,
  });

  @override
  List<Object?> get props => [lessonId, score, correctCount, totalCount, timeSpent, isPerfect, completedAt, wrongQuestionIds];
}

class Achievement extends Equatable {
  final String id;
  final String name;
  final String nameZh;
  final String description;
  final String category;
  final int xpReward;
  final int? diamondReward;
  final String icon;

  const Achievement({
    required this.id,
    required this.name,
    required this.nameZh,
    required this.description,
    required this.category,
    required this.xpReward,
    this.diamondReward,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, name, nameZh, description, category, xpReward, diamondReward, icon];
}
