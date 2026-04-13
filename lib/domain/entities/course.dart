import 'package:equatable/equatable.dart';
import 'question.dart';

class Course extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int totalLessons;
  final List<Lesson> lessons;
  final CourseMetadata metadata;

  const Course({
    required this.id,
    required this.name,
    required this.icon,
    required this.totalLessons,
    required this.lessons,
    required this.metadata,
  });

  @override
  List<Object?> get props => [id, name, icon, totalLessons, lessons, metadata];
}

class CourseMetadata extends Equatable {
  final String description;
  final List<String> tags;
  final int version;

  const CourseMetadata({
    required this.description,
    required this.tags,
    required this.version,
  });

  @override
  List<Object?> get props => [description, tags, version];
}

class Lesson extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final int level;
  final int order;
  final List<LessonLevel> levels;
  final bool isBoss;
  final int xpReward;
  final int diamondReward;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.level,
    required this.order,
    required this.levels,
    required this.isBoss,
    required this.xpReward,
    required this.diamondReward,
  });

  @override
  List<Object?> get props => [id, courseId, title, level, order, levels, isBoss, xpReward, diamondReward];
}

class LessonLevel extends Equatable {
  final String id;
  final String lessonId;
  final int order;
  final LevelType type;
  final List<Question> questions;
  final PassCondition passCondition;
  final int xpReward;
  final int diamondReward;

  const LessonLevel({
    required this.id,
    required this.lessonId,
    required this.order,
    required this.type,
    required this.questions,
    required this.passCondition,
    required this.xpReward,
    required this.diamondReward,
  });

  @override
  List<Object?> get props => [id, lessonId, order, type, questions, passCondition, xpReward, diamondReward];
}

enum LevelType { choice, fillBlank, code, sort, boss }

enum Difficulty { easy, medium, hard }

class PassCondition extends Equatable {
  final int requiredCorrectRate;
  final int? timeLimitSeconds;
  final bool allowSkip;

  const PassCondition({
    required this.requiredCorrectRate,
    this.timeLimitSeconds,
    required this.allowSkip,
  });

  @override
  List<Object?> get props => [requiredCorrectRate, timeLimitSeconds, allowSkip];
}
