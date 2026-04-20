import 'package:flutter/material.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDecorations.cardRadius,
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.codeSnippet != null && question.codeSnippet!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.codeSnippet!.join('\n'),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.content,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDifficultyBadge(),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    // Note: label will be set in the build method using context
    // Since this is a StatelessWidget, we get context from the build method
    return _DifficultyBadgeWidget(difficulty: question.difficulty);
  }
}

class _DifficultyBadgeWidget extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyBadgeWidget({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;

    switch (difficulty) {
      case Difficulty.easy:
        color = AppColors.easy;
        label = l10n.lessonDifficultyEasy;
      case Difficulty.medium:
        color = AppColors.medium;
        label = l10n.lessonDifficultyMedium;
      case Difficulty.hard:
        color = AppColors.hard;
        label = l10n.lessonDifficultyHard;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
