import 'package:flutter/material.dart';

class HeartsDisplay extends StatelessWidget {
  final int current;
  final int max;
  final bool showAnimation;

  const HeartsDisplay({
    super.key,
    required this.current,
    this.max = 5,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$current of $max lives',
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        final isFilled = index < current;
        if (showAnimation && !isFilled && index == current) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: _buildHeart(isFilled),
          );
        }
        return _buildHeart(isFilled);
      }),
    ),
    );
  }

  Widget _buildHeart(bool isFilled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        isFilled ? '❤️' : '🖤',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
