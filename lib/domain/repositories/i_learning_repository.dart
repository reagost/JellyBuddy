import '../entities/course.dart';
import '../entities/user.dart';

abstract class ILearningRepository {
  Future<Course> getCourse(String courseId);
  Future<List<Course>> getAllCourses();
  Future<void> saveLessonResult(String courseId, LessonResult result);
  Future<LessonResult?> getLessonResult(String lessonId);
  List<String> getCompletedLessonIds(String courseId);
  bool isLessonCompleted(String courseId, String lessonId);
}
