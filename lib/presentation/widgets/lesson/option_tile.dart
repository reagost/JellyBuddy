import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

enum OptionState { normal, selected, correct, incorrect }

class OptionTile extends StatelessWidget {
  final String optionLetter;
  final String content;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.optionLetter,
    required this.content,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;

    switch (state) {
      case OptionState.normal:
        borderColor = AppColors.surfaceVariant;
        backgroundColor = Colors.white;
      case OptionState.selected:
        borderColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.05);
      case OptionState.correct:
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
      case OptionState.incorrect:
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppDecorations.cardRadius,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (state == OptionState.correct)
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            if (state == OptionState.incorrect)
              const Icon(Icons.cancel, color: AppColors.error, size: 24),
          ],
        ),
      ),
    );
  }
}
