import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// App Button Widget - 应用按钮
enum AppButtonVariant { primary, secondary, outline, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    double height;
    double fontSize;
    EdgeInsets padding;

    switch (size) {
      case AppButtonSize.small:
        height = 36;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16);
      case AppButtonSize.medium:
        height = 48;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 24);
      case AppButtonSize.large:
        height = 56;
        fontSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 32);
    }

    Color backgroundColor;
    Color textColor;
    List<BoxShadow>? shadow;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary;
        textColor = Colors.white;
        shadow = isDisabled ? null : AppDecorations.buttonShadow;
      case AppButtonVariant.secondary:
        backgroundColor = isDisabled ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.secondary;
        textColor = Colors.white;
        shadow = null;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary;
        shadow = null;
        border = Border.all(
          color: isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
          width: 2,
        );
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = isDisabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary;
        shadow = null;
    }

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(textColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppDecorations.buttonRadius,
          boxShadow: shadow,
          border: border,
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// App Card Widget - 应用卡片
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
    Widget card = Container(
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
        child: card,
      );
    }

    return card;
  }
}

/// Loading Indicator Widget - 加载指示器
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
                    color: (color ?? AppColors.primary).withValues(alpha: 0.3 + (value * 0.7)),
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
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: (color ?? AppColors.primary).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
    }
  }
}

/// Empty State Widget - 空状态
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
