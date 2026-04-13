import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/constants/game_constants.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int nextLevelXp;
  final int level;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.nextLevelXp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nextLevelXp > 0 ? (currentXp / nextLevelXp).clamp(0.0, 1.0) : 0.0;
    final xpForCurrentLevel = level > 0 && level <= GameConstants.xpToLevel.length
        ? GameConstants.xpToLevel[level - 1]
        : 0;
    final xpIntoLevel = currentXp - xpForCurrentLevel;
    final xpNeeded = nextLevelXp - xpForCurrentLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$currentXp / $nextLevelXp XP',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.xpGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        if (xpIntoLevel > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$xpIntoLevel XP into level',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.xpGold,
            ),
          ),
        ],
      ],
    );
  }
}
