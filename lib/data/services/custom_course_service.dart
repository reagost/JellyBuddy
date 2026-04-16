import 'dart:convert';
import '../../domain/entities/course.dart';
import '../../domain/entities/question.dart';
import 'storage_service.dart';
import 'markdown_course_parser.dart';

/// Service for importing and persisting user-created custom courses.
class CustomCourseService {
  final StorageService _storage;

  CustomCourseService({required StorageService storage}) : _storage = storage;

  static const _storageKey = 'custom_courses';

  /// Import a course from Markdown content.
  /// Returns the parsed Course on success.
  Future<Course> importFromMarkdown(String markdown) async {
    final course = MarkdownCourseParser.parse(markdown);

    final existing = getCustomCourses();
    // Replace if same ID exists
    final updated = [
      ...existing.where((c) => c.id != course.id),
      course,
    ];
    await _saveCourses(updated);
    return course;
  }

  /// Get all custom courses stored locally.
  List<Course> getCustomCourses() {
    final jsonStr = _storage.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((item) => _courseFromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get a specific custom course by ID.
  Course? getCustomCourse(String id) {
    return getCustomCourses().firstWhere(
      (c) => c.id == id,
      orElse: () => throw StateError('Course not found'),
    );
  }

  /// Delete a custom course.
  Future<void> deleteCustomCourse(String id) async {
    final existing = getCustomCourses();
    final filtered = existing.where((c) => c.id != id).toList();
    await _saveCourses(filtered);
  }

  Future<void> _saveCourses(List<Course> courses) async {
    final jsonList = courses.map(_courseToJson).toList();
    await _storage.setString(_storageKey, jsonEncode(jsonList));
  }

  // --- JSON (de)serialization ---

  Map<String, dynamic> _courseToJson(Course c) => {
        'id': c.id,
        'name': c.name,
        'icon': c.icon,
        'totalLessons': c.totalLessons,
        'metadata': {
          'description': c.metadata.description,
          'tags': c.metadata.tags,
          'version': c.metadata.version,
        },
        'lessons': c.lessons.map(_lessonToJson).toList(),
      };

  Course _courseFromJson(Map<String, dynamic> j) {
    final meta = j['metadata'] as Map<String, dynamic>? ?? {};
    return Course(
      id: j['id'] as String,
      name: j['name'] as String,
      icon: j['icon'] as String? ?? '📚',
      totalLessons: j['totalLessons'] as int? ?? 0,
      lessons: (j['lessons'] as List? ?? []).map((l) => _lessonFromJson(l as Map<String, dynamic>)).toList(),
      metadata: CourseMetadata(
        description: meta['description'] as String? ?? '',
        tags: (meta['tags'] as List?)?.cast<String>() ?? [],
        version: meta['version'] as int? ?? 1,
      ),
    );
  }

  Map<String, dynamic> _lessonToJson(Lesson l) => {
        'id': l.id,
        'courseId': l.courseId,
        'title': l.title,
        'level': l.level,
        'order': l.order,
        'isBoss': l.isBoss,
        'xpReward': l.xpReward,
        'diamondReward': l.diamondReward,
        'levels': l.levels.map(_levelToJson).toList(),
      };

  Lesson _lessonFromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        courseId: j['courseId'] as String,
        title: j['title'] as String,
        level: j['level'] as int? ?? 1,
        order: j['order'] as int? ?? 1,
        isBoss: j['isBoss'] as bool? ?? false,
        xpReward: j['xpReward'] as int? ?? 50,
        diamondReward: j['diamondReward'] as int? ?? 1,
        levels: (j['levels'] as List? ?? []).map((ll) => _levelFromJson(ll as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> _levelToJson(LessonLevel l) => {
        'id': l.id,
        'lessonId': l.lessonId,
        'order': l.order,
        'type': l.type.name,
        'xpReward': l.xpReward,
        'diamondReward': l.diamondReward,
        'questions': l.questions.map(_questionToJson).toList(),
        'passCondition': {
          'requiredCorrectRate': l.passCondition.requiredCorrectRate,
          'allowSkip': l.passCondition.allowSkip,
        },
      };

  LessonLevel _levelFromJson(Map<String, dynamic> j) {
    final pc = j['passCondition'] as Map<String, dynamic>? ?? {};
    return LessonLevel(
      id: j['id'] as String,
      lessonId: j['lessonId'] as String,
      order: j['order'] as int? ?? 1,
      type: LevelType.values.firstWhere(
        (t) => t.name == j['type'],
        orElse: () => LevelType.choice,
      ),
      xpReward: j['xpReward'] as int? ?? 10,
      diamondReward: j['diamondReward'] as int? ?? 0,
      questions: (j['questions'] as List? ?? []).map((q) => _questionFromJson(q as Map<String, dynamic>)).toList(),
      passCondition: PassCondition(
        requiredCorrectRate: pc['requiredCorrectRate'] as int? ?? 70,
        allowSkip: pc['allowSkip'] as bool? ?? true,
      ),
    );
  }

  Map<String, dynamic> _questionToJson(Question q) => {
        'id': q.id,
        'type': q.type.name,
        'content': q.content,
        'codeSnippet': q.codeSnippet,
        'options': q.options?.map((o) => {
              'letter': o.letter,
              'content': o.content,
              'isCorrect': o.isCorrect,
            }).toList(),
        'acceptedAnswers': q.acceptedAnswers,
        'difficulty': q.difficulty.name,
        'explanation': q.explanation,
        'relatedConcepts': q.relatedConcepts,
        'estimatedSeconds': q.estimatedSeconds,
      };

  Question _questionFromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as String,
        type: LevelType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => LevelType.choice,
        ),
        content: j['content'] as String,
        codeSnippet: (j['codeSnippet'] as List?)?.cast<String>(),
        options: (j['options'] as List?)?.map((o) => Option(
              letter: (o as Map)['letter'] as String,
              content: o['content'] as String,
              isCorrect: o['isCorrect'] as bool,
            )).toList(),
        acceptedAnswers: (j['acceptedAnswers'] as List? ?? []).cast<String>(),
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == j['difficulty'],
          orElse: () => Difficulty.easy,
        ),
        explanation: j['explanation'] as String? ?? '',
        relatedConcepts: (j['relatedConcepts'] as List?)?.cast<String>() ?? [],
        estimatedSeconds: j['estimatedSeconds'] as int? ?? 20,
      );
}
