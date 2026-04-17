import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StreakCounter extends StatelessWidget {
  final int days;
  final bool showFire;

  const StreakCounter({
    super.key,
    required this.days,
    this.showFire = true,
  });

  @override
  Widget build(BuildContext context) {
    String emoji = '';
    if (showFire && days >= 30) {
      emoji = '🌟';
    } else if (showFire && days >= 7) {
      emoji = '🔥';
    }

    return Semantics(
      label: '$days day streak',
      child: TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: days),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji.isNotEmpty) ...[
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 4),
            ],
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.streakOrange,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '天',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    ),
    );
  }
}
