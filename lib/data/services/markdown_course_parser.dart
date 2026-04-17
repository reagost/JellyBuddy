import '../../domain/entities/course.dart';
import '../../domain/entities/question.dart';

/// Parses a Markdown course file into a Course entity.
///
/// Template format: see docs/question_bank_template.md
class MarkdownCourseParser {
  /// Parse Markdown content into a Course.
  /// Throws [FormatException] if the content is invalid.
  static Course parse(String markdown) {
    final lines = markdown.split('\n');

    // 1. Parse frontmatter
    final frontmatter = _parseFrontmatter(lines);
    final courseId = frontmatter['id'];
    if (courseId == null || courseId.isEmpty) {
      throw const FormatException('Missing required field: id');
    }

    // 2. Parse lessons
    final body = _removeFrontmatter(lines);
    final lessons = _parseLessons(body, courseId);

    return Course(
      id: courseId,
      name: frontmatter['name'] ?? courseId,
      icon: frontmatter['icon'] ?? '📚',
      totalLessons: lessons.length,
      lessons: lessons,
      metadata: CourseMetadata(
        description: frontmatter['description'] ?? '',
        tags: [frontmatter['difficulty'] ?? 'beginner'],
        version: int.tryParse(frontmatter['version'] ?? '1') ?? 1,
      ),
    );
  }

  // --- Frontmatter ---

  static Map<String, String> _parseFrontmatter(List<String> lines) {
    final result = <String, String>{};
    if (lines.isEmpty || lines[0].trim() != '---') return result;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line == '---') break;
      if (line.isEmpty || line.startsWith('#')) continue;
      final colonIdx = line.indexOf(':');
      if (colonIdx < 0) continue;
      final key = line.substring(0, colonIdx).trim();
      final value = line.substring(colonIdx + 1).trim();
      result[key] = value;
    }
    return result;
  }

  static List<String> _removeFrontmatter(List<String> lines) {
    if (lines.isEmpty || lines[0].trim() != '---') return lines;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim() == '---') {
        return lines.sublist(i + 1);
      }
    }
    return lines;
  }

  // --- Lessons ---

  static List<Lesson> _parseLessons(List<String> lines, String courseId) {
    final lessons = <Lesson>[];
    int? currentLessonStart;
    int order = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Match ## Lesson or ## 🎯 or other top-level lesson headers (not ###)
      if (line.startsWith('## ') && !line.startsWith('### ')) {
        // Skip "## 📖 模版格式说明" type documentation sections
        if (line.contains('模版格式') || line.contains('Template Format')) break;

        if (currentLessonStart != null) {
          final lesson = _parseLesson(
            lines.sublist(currentLessonStart, i),
            courseId,
            ++order,
          );
          if (lesson != null) lessons.add(lesson);
        }
        currentLessonStart = i;
      }
    }
    // Last lesson
    if (currentLessonStart != null) {
      final lesson = _parseLesson(
        lines.sublist(currentLessonStart),
        courseId,
        ++order,
      );
      if (lesson != null) lessons.add(lesson);
    }

    return lessons;
  }

  static Lesson? _parseLesson(List<String> lines, String courseId, int fallbackOrder) {
    if (lines.isEmpty) return null;

    // Extract title from "## Lesson N: Title" or "## 🎯 Title"
    final titleLine = lines[0];
    String title = titleLine.replaceFirst(RegExp(r'^##\s+'), '').trim();
    final colonIdx = title.indexOf(':');
    if (colonIdx > 0 && title.toLowerCase().startsWith('lesson')) {
      title = title.substring(colonIdx + 1).trim();
    }

    // Parse lesson-meta comment
    final meta = _parseLessonMeta(lines);
    final order = int.tryParse(meta['order'] ?? '') ?? fallbackOrder;
    final xpReward = int.tryParse(meta['xpReward'] ?? '') ?? 50;
    final diamondReward = int.tryParse(meta['diamondReward'] ?? '') ?? 1;
    final isBoss = meta['isBoss']?.toLowerCase() == 'true';

    // Parse questions (### Question blocks)
    final questions = _parseQuestions(lines);
    if (questions.isEmpty) return null;

    // Wrap each question in its own LessonLevel
    final levels = <LessonLevel>[];
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final lessonId = '${courseId}_lesson$order';
      levels.add(LessonLevel(
        id: '${lessonId}_level${i + 1}',
        lessonId: lessonId,
        order: i + 1,
        type: q.type,
        questions: [q],
        passCondition: const PassCondition(requiredCorrectRate: 70, allowSkip: true),
        xpReward: 10,
        diamondReward: 0,
      ));
    }

    return Lesson(
      id: '${courseId}_lesson$order',
      courseId: courseId,
      title: title,
      level: 1,
      order: order,
      levels: levels,
      isBoss: isBoss,
      xpReward: xpReward,
      diamondReward: diamondReward,
    );
  }

  static Map<String, String> _parseLessonMeta(List<String> lines) {
    final result = <String, String>{};
    final buffer = lines.join('\n');
    final match = RegExp(r'<!--\s*lesson-meta\s*([\s\S]*?)\s*-->').firstMatch(buffer);
    if (match == null) return result;
    final content = match.group(1) ?? '';
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final colonIdx = trimmed.indexOf(':');
      if (colonIdx < 0) continue;
      result[trimmed.substring(0, colonIdx).trim()] =
          trimmed.substring(colonIdx + 1).trim();
    }
    return result;
  }

  // --- Questions ---

  static List<Question> _parseQuestions(List<String> lines) {
    final questions = <Question>[];
    int? start;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('### ')) {
        if (start != null) {
          final q = _parseQuestion(lines.sublist(start, i));
          if (q != null) questions.add(q);
        }
        start = i;
      }
    }
    if (start != null) {
      final q = _parseQuestion(lines.sublist(start));
      if (q != null) questions.add(q);
    }
    return questions;
  }

  static Question? _parseQuestion(List<String> lines) {
    if (lines.isEmpty) return null;

    // Parse header: ### Question X.Y (type, difficulty)
    final headerMatch = RegExp(
      r'###\s+Question\s+[\d.]+\s*\((\w+)(?:,\s*(\w+))?\)',
      caseSensitive: false,
    ).firstMatch(lines[0]);
    if (headerMatch == null) return null;

    final type = _parseType(headerMatch.group(1) ?? 'choice');
    final difficulty = _parseDifficulty(headerMatch.group(2) ?? 'easy');

    final body = lines.skip(1).join('\n');

    // Extract code snippet (first ```...``` block after question content)
    List<String>? codeSnippet;
    final codeMatch = RegExp(r'```[\w]*\n([\s\S]*?)```').firstMatch(body);
    if (codeMatch != null) {
      codeSnippet = codeMatch.group(1)?.trim().split('\n');
    }

    // Extract question content (everything before first - [ ], - A., **答案**, **答案**:, or code block)
    String content = body;
    final boundaries = [
      body.indexOf('- ['),
      body.indexOf('- A.'),
      body.indexOf('- A '),
      body.indexOf('**答案**'),
      body.indexOf('**Answer**'),
      body.indexOf('**顺序**'),
      body.indexOf('**Order**'),
      body.indexOf('```'),
    ].where((x) => x >= 0).toList();
    if (boundaries.isNotEmpty) {
      content = body.substring(0, boundaries.reduce((a, b) => a < b ? a : b));
    }
    content = content.trim();

    // Extract explanation
    final explanationMatch = RegExp(
      r'\*\*(?:解析|Explanation)\*\*[:：]?\s*([\s\S]*?)(?=\n\s*\*\*|\n---|$)',
    ).firstMatch(body);
    final explanation = explanationMatch?.group(1)?.trim() ?? '';

    // Extract related concepts
    final conceptsMatch = RegExp(
      r'\*\*(?:相关概念|Related Concepts)\*\*[:：]?\s*(.+)',
    ).firstMatch(body);
    final relatedConcepts = conceptsMatch?.group(1)?.trim().split(RegExp(r',\s*')) ?? [];

    // Parse answers based on type
    final id = 'q_${DateTime.now().microsecondsSinceEpoch}_${content.hashCode.abs()}';

    switch (type) {
      case LevelType.choice:
        return _buildChoiceQuestion(id, content, codeSnippet, body, difficulty, explanation, relatedConcepts);
      case LevelType.fillBlank:
      case LevelType.code:
        return _buildFillOrCodeQuestion(id, type, content, codeSnippet, body, difficulty, explanation, relatedConcepts);
      case LevelType.sort:
        return _buildSortQuestion(id, content, codeSnippet, body, difficulty, explanation, relatedConcepts);
      default:
        return null;
    }
  }

  static Question _buildChoiceQuestion(
    String id, String content, List<String>? codeSnippet, String body,
    Difficulty difficulty, String explanation, List<String> concepts) {
    final options = <Option>[];
    final acceptedAnswers = <String>[];
    // Match - [ ] or - [x] options
    final optionRegex = RegExp(r'-\s+\[([ xX])\]\s+(.+)');
    int letterIdx = 0;
    for (final match in optionRegex.allMatches(body)) {
      final isCorrect = match.group(1)?.trim().toLowerCase() == 'x';
      final text = match.group(2)?.trim() ?? '';
      final letter = String.fromCharCode('A'.codeUnitAt(0) + letterIdx);
      options.add(Option(letter: letter, content: text, isCorrect: isCorrect));
      if (isCorrect) acceptedAnswers.add(letter);
      letterIdx++;
    }

    return Question(
      id: id,
      type: LevelType.choice,
      content: content,
      codeSnippet: codeSnippet,
      options: options,
      acceptedAnswers: acceptedAnswers,
      difficulty: difficulty,
      explanation: explanation,
      relatedConcepts: concepts,
      estimatedSeconds: 20,
    );
  }

  static Question _buildFillOrCodeQuestion(
    String id, LevelType type, String content, List<String>? codeSnippet, String body,
    Difficulty difficulty, String explanation, List<String> concepts) {
    final answerMatch = RegExp(
      r'\*\*(?:答案|Answer)\*\*[:：]?\s*(.+)',
    ).firstMatch(body);
    final answerText = answerMatch?.group(1)?.trim() ?? '';
    // Split by | and strip backticks
    final answers = answerText
        .split('|')
        .map((a) => a.trim().replaceAll('`', ''))
        .where((a) => a.isNotEmpty)
        .toList();

    return Question(
      id: id,
      type: type,
      content: content,
      codeSnippet: codeSnippet,
      acceptedAnswers: answers,
      difficulty: difficulty,
      explanation: explanation,
      relatedConcepts: concepts,
      estimatedSeconds: type == LevelType.code ? 90 : 30,
    );
  }

  static Question _buildSortQuestion(
    String id, String content, List<String>? codeSnippet, String body,
    Difficulty difficulty, String explanation, List<String> concepts) {
    // Parse - A. xxx / - B. xxx options
    final options = <Option>[];
    final sortOptionRegex = RegExp(r'-\s+([A-Z])\.\s+(.+)');
    for (final match in sortOptionRegex.allMatches(body)) {
      final letter = match.group(1) ?? '';
      final text = match.group(2)?.trim() ?? '';
      options.add(Option(letter: letter, content: text, isCorrect: false));
    }

    // Parse order: **顺序**: A, C, B
    final orderMatch = RegExp(
      r'\*\*(?:顺序|Order)\*\*[:：]?\s*(.+)',
    ).firstMatch(body);
    final orderText = orderMatch?.group(1)?.trim() ?? '';
    final correctOrder = orderText.replaceAll(RegExp(r'[,\s]'), '');

    return Question(
      id: id,
      type: LevelType.sort,
      content: content,
      codeSnippet: codeSnippet,
      options: options,
      acceptedAnswers: [correctOrder],
      difficulty: difficulty,
      explanation: explanation,
      relatedConcepts: concepts,
      estimatedSeconds: 60,
    );
  }

  static LevelType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'choice':
        return LevelType.choice;
      case 'fillblank':
      case 'fill_blank':
      case 'fill':
        return LevelType.fillBlank;
      case 'sort':
        return LevelType.sort;
      case 'code':
        return LevelType.code;
      case 'boss':
        return LevelType.boss;
      default:
        return LevelType.choice;
    }
  }

  static Difficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
  }
}
