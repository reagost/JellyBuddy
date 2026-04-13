import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum LoadingType { circular, dots, pulse }

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final LoadingType type;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
          ),
        );
      case LoadingType.dots:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (i * 200)),
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: size / 4,
                  height: size / 4,
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.primary).withOpacity(0.3 + (value * 0.7)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        );
      case LoadingType.pulse:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.2),
          duration: const Duration(milliseconds: 800),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: (color ?? AppColors.primary).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
    }
  }
}
