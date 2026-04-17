import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum AvatarState { idle, thinking, speaking }

class AIAvatar extends StatefulWidget {
  final String name;
  final AvatarState state;

  const AIAvatar({
    super.key,
    required this.name,
    required this.state,
  });

  @override
  State<AIAvatar> createState() => _AIAvatarState();
}

class _AIAvatarState extends State<AIAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.state == AvatarState.idle) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AIAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == AvatarState.idle) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: widget.state == AvatarState.idle
                  ? Offset(0, -_floatAnimation.value)
                  : Offset.zero,
              child: child,
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (widget.state == AvatarState.thinking)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (i * 200)),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3 + (value * 0.7)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
      ],
    );
  }
}
