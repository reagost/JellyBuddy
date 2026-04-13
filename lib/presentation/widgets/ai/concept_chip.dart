import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ConceptChip extends StatelessWidget {
  final String conceptName;
  final VoidCallback? onTap;

  const ConceptChip({
    super.key,
    required this.conceptName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            conceptName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
