import '../../domain/entities/course.dart';
import '../../domain/repositories/i_learning_repository.dart';

enum SearchMatchType {
  courseName,
  courseDescription,
  lessonTitle,
  questionContent,
}

class SearchResult {
  final Course course;
  final String matchContext;
  final SearchMatchType matchType;

  const SearchResult({
    required this.course,
    required this.matchContext,
    required this.matchType,
  });
}

class SearchService {
  final ILearningRepository _learningRepo;

  SearchService({required ILearningRepository learningRepo})
      : _learningRepo = learningRepo;

  /// Search across all courses, lessons, and questions.
  /// Returns matching courses with relevance info, sorted by match type priority.
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final courses = await _learningRepo.getAllCourses();
    final results = <SearchResult>[];
    final matchedCourseIds = <String>{};

    // Pass 1: course name matches (highest priority)
    for (final course in courses) {
      if (course.name.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          course: course,
          matchContext: course.name,
          matchType: SearchMatchType.courseName,
        ));
        matchedCourseIds.add(course.id);
      }
    }

    // Pass 2: course description matches
    for (final course in courses) {
      if (matchedCourseIds.contains(course.id)) continue;
      if (course.metadata.description.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          course: course,
          matchContext: course.metadata.description,
          matchType: SearchMatchType.courseDescription,
        ));
        matchedCourseIds.add(course.id);
      }
    }

    // Pass 3: lesson title matches
    for (final course in courses) {
      if (matchedCourseIds.contains(course.id)) continue;
      for (final lesson in course.lessons) {
        if (lesson.title.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResult(
            course: course,
            matchContext: lesson.title,
            matchType: SearchMatchType.lessonTitle,
          ));
          matchedCourseIds.add(course.id);
          break; // one match per course is enough
        }
      }
    }

    // Pass 4: question content matches
    for (final course in courses) {
      if (matchedCourseIds.contains(course.id)) continue;
      outer:
      for (final lesson in course.lessons) {
        for (final level in lesson.levels) {
          for (final question in level.questions) {
            if (question.content.toLowerCase().contains(lowerQuery)) {
              results.add(SearchResult(
                course: course,
                matchContext: '${lesson.title} \u2014 ${question.content}',
                matchType: SearchMatchType.questionContent,
              ));
              matchedCourseIds.add(course.id);
              break outer;
            }
          }
        }
      }
    }

    return results;
  }
}
