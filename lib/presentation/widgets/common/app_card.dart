import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool showShadow;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: AppDecorations.cardRadius,
        boxShadow: showShadow ? AppDecorations.cardShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: AppDurations.fast,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: content,
        ),
      );
    }

    return content;
  }
}
