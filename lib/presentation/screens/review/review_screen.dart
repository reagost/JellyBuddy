import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/repositories/i_learning_repository.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<_WrongQuestionItem> _wrongQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWrongQuestions();
  }

  Future<void> _loadWrongQuestions() async {
    try {
      final repo = GetIt.instance<ILearningRepository>();
      final courses = await repo.getAllCourses();
      final wrongItems = <_WrongQuestionItem>[];

      for (final course in courses) {
        if (course.lessons.isEmpty) continue;

        final completedIds = repo.getCompletedLessonIds(course.id);
        for (final lessonId in completedIds) {
          final result = await repo.getLessonResult(lessonId);
          if (result == null || result.wrongQuestionIds.isEmpty) continue;

          // Find the lesson to get questions
          final lesson = course.lessons.cast<Lesson?>().firstWhere(
                (l) => l!.id == lessonId,
                orElse: () => null,
              );
          if (lesson == null) continue;

          // Build a map of all questions in this lesson
          final questionMap = <String, Question>{};
          for (final level in lesson.levels) {
            for (final q in level.questions) {
              questionMap[q.id] = q;
            }
          }

          // Collect wrong questions
          for (final qId in result.wrongQuestionIds) {
            final question = questionMap[qId];
            if (question != null) {
              wrongItems.add(_WrongQuestionItem(
                question: question,
                lessonTitle: lesson.title,
                courseName: course.name,
              ));
            }
          }
        }
      }

      setState(() {
        _wrongQuestions = wrongItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📝 错题本'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wrongQuestions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: _wrongQuestions.length,
                  itemBuilder: (context, index) {
                    return _buildWrongQuestionCard(_wrongQuestions[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            '没有错题，继续保持！',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '完成更多关卡来检验你的学习成果',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrongQuestionCard(_WrongQuestionItem item) {
    final question = item.question;
    final correctOption = question.options?.where((o) => o.isCorrect).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.courseName} · ${item.lessonTitle}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              _buildDifficultyBadge(question.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Question content
          Text(
            question.content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          // Code snippet
          if (question.codeSnippet != null &&
              question.codeSnippet!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                question.codeSnippet!.join('\n'),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: Color(0xFFCDD6F4),
                  height: 1.6,
                ),
              ),
            ),
          ],

          // Correct answer
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '正确答案',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (correctOption != null && correctOption.isNotEmpty)
                        ...correctOption.map(
                          (o) => Text(
                            '${o.letter}. ${o.content}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      else
                        Text(
                          question.acceptedAnswers.join(' / '),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Explanation
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Related concepts
          if (question.relatedConcepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: question.relatedConcepts.map((concept) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    concept,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(Difficulty difficulty) {
    Color color;
    String label;
    switch (difficulty) {
      case Difficulty.easy:
        color = AppColors.easy;
        label = '简单';
      case Difficulty.medium:
        color = AppColors.medium;
        label = '中等';
      case Difficulty.hard:
        color = AppColors.hard;
        label = '困难';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _WrongQuestionItem {
  final Question question;
  final String lessonTitle;
  final String courseName;

  const _WrongQuestionItem({
    required this.question,
    required this.lessonTitle,
    required this.courseName,
  });
}
