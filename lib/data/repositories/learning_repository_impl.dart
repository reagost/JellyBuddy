import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_learning_repository.dart';
import '../services/custom_course_service.dart';
import '../services/progress_service.dart';

class LearningRepositoryImpl implements ILearningRepository {
  final ProgressService _progressService;
  final CustomCourseService? _customCourseService;
  Course? _cachedCourse;

  LearningRepositoryImpl({
    required ProgressService progressService,
    CustomCourseService? customCourseService,
  })  : _progressService = progressService,
        _customCourseService = customCourseService;

  @override
  Future<Course> getCourse(String courseId) async {
    if (_cachedCourse != null && _cachedCourse!.id == courseId) {
      return _cachedCourse!;
    }

    // Check custom (imported) courses first
    final customCourses = _customCourseService?.getCustomCourses() ?? [];
    final custom = customCourses.where((c) => c.id == courseId).firstOrNull;
    if (custom != null) {
      _cachedCourse = custom;
      return custom;
    }

    final jsonStr = await rootBundle.loadString('assets/courses/${courseId}_l1.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _cachedCourse = _parseCourse(json);
    return _cachedCourse!;
  }

  @override
  Future<List<Course>> getAllCourses() async {
    final indexStr = await rootBundle.loadString('assets/courses/course_index.json');
    final indexJson = jsonDecode(indexStr) as Map<String, dynamic>;
    final coursesJson = indexJson['courses'] as List;

    final courses = <Course>[];
    for (final c in coursesJson) {
      try {
        final course = await getCourse(c['id'] as String);
        courses.add(course);
      } catch (_) {
        // Course data file not found, create a stub
        courses.add(Course(
          id: c['id'] as String,
          name: c['name'] as String,
          icon: c['icon'] as String,
          totalLessons: 0,
          lessons: const [],
          metadata: CourseMetadata(
            description: c['description'] as String? ?? '',
            tags: const [],
            version: 1,
          ),
        ));
      }
    }

    // Append custom (imported) courses
    final customCourses = _customCourseService?.getCustomCourses() ?? [];
    courses.addAll(customCourses);

    return courses;
  }

  @override
  Future<void> saveLessonResult(String courseId, LessonResult result) async {
    await _progressService.saveLessonResult(
      courseId: courseId,
      lessonId: result.lessonId,
      score: result.score,
      correctCount: result.correctCount,
      totalCount: result.totalCount,
      isPerfect: result.isPerfect,
      completedAt: result.completedAt,
      wrongQuestionIds: result.wrongQuestionIds,
    );
  }

  @override
  Future<LessonResult?> getLessonResult(String lessonId) async {
    final data = _progressService.getLessonResult(lessonId);
    if (data == null) return null;
    return LessonResult(
      lessonId: data['lessonId'] as String,
      score: data['score'] as int,
      correctCount: data['correctCount'] as int,
      totalCount: data['totalCount'] as int,
      timeSpent: Duration.zero,
      isPerfect: data['isPerfect'] as bool,
      completedAt: DateTime.parse(data['completedAt'] as String),
      wrongQuestionIds: _progressService.getWrongQuestionIds(lessonId),
    );
  }

  @override
  List<String> getCompletedLessonIds(String courseId) {
    return _progressService.getCompletedLessonIds(courseId);
  }

  @override
  bool isLessonCompleted(String courseId, String lessonId) {
    return _progressService.isLessonCompleted(courseId, lessonId);
  }

  // --- JSON Parsing ---

  Course _parseCourse(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List? ?? [];
    final lessons = lessonsJson.map((l) => _parseLesson(l as Map<String, dynamic>)).toList();

    final metaJson = json['metadata'] as Map<String, dynamic>? ?? {};
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      totalLessons: json['totalLessons'] as int? ?? lessons.length,
      lessons: lessons,
      metadata: CourseMetadata(
        description: metaJson['description'] as String? ?? '',
        tags: (metaJson['tags'] as List?)?.cast<String>() ?? [],
        version: metaJson['version'] as int? ?? 1,
      ),
    );
  }

  Lesson _parseLesson(Map<String, dynamic> json) {
    final levelsJson = json['levels'] as List? ?? [];
    return Lesson(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      level: json['level'] as int,
      order: json['order'] as int,
      levels: levelsJson.map((l) => _parseLessonLevel(l as Map<String, dynamic>)).toList(),
      isBoss: json['isBoss'] as bool? ?? false,
      xpReward: json['xpReward'] as int? ?? 50,
      diamondReward: json['diamondReward'] as int? ?? 1,
    );
  }

  LessonLevel _parseLessonLevel(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List? ?? [];
    final passJson = json['passCondition'] as Map<String, dynamic>? ?? {};
    return LessonLevel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      order: json['order'] as int,
      type: _parseLevelType(json['type'] as String),
      questions: questionsJson.map((q) => _parseQuestion(q as Map<String, dynamic>, json['type'] as String)).toList(),
      passCondition: PassCondition(
        requiredCorrectRate: passJson['requiredCorrectRate'] as int? ?? 70,
        timeLimitSeconds: passJson['timeLimitSeconds'] as int?,
        allowSkip: passJson['allowSkip'] as bool? ?? true,
      ),
      xpReward: json['xpReward'] as int? ?? 10,
      diamondReward: json['diamondReward'] as int? ?? 0,
    );
  }

  Question _parseQuestion(Map<String, dynamic> json, String levelType) {
    final optionsJson = json['options'] as List? ?? [];
    return Question(
      id: json['id'] as String,
      type: _parseLevelType(levelType),
      content: json['content'] as String,
      codeSnippet: (json['codeSnippet'] as List?)?.cast<String>(),
      options: optionsJson.isNotEmpty
          ? optionsJson.map((o) {
              final m = o as Map<String, dynamic>;
              return Option(
                letter: m['letter'] as String,
                content: m['content'] as String,
                isCorrect: m['isCorrect'] as bool,
              );
            }).toList()
          : null,
      acceptedAnswers: (json['acceptedAnswers'] as List).cast<String>(),
      difficulty: _parseDifficulty(json['difficulty'] as String),
      explanation: json['explanation'] as String,
      relatedConcepts: (json['relatedConcepts'] as List?)?.cast<String>() ?? [],
      estimatedSeconds: json['estimatedSeconds'] as int? ?? 20,
    );
  }

  LevelType _parseLevelType(String type) {
    switch (type) {
      case 'choice': return LevelType.choice;
      case 'fillBlank': return LevelType.fillBlank;
      case 'code': return LevelType.code;
      case 'sort': return LevelType.sort;
      case 'boss': return LevelType.boss;
      default: return LevelType.choice;
    }
  }

  Difficulty _parseDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy': return Difficulty.easy;
      case 'medium': return Difficulty.medium;
      case 'hard': return Difficulty.hard;
      default: return Difficulty.easy;
    }
  }
}
