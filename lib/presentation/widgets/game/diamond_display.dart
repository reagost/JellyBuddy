import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DiamondDisplay extends StatelessWidget {
  final int count;

  const DiamondDisplay({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('💎', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: count),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.diamondBlue,
              ),
            );
          },
        ),
      ],
    );
  }
}
