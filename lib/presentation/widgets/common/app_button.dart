import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    double height;
    double fontSize;
    switch (size) {
      case ButtonSize.small:
        height = 36;
        fontSize = 14;
      case ButtonSize.medium:
        height = 48;
        fontSize = 16;
      case ButtonSize.large:
        height = 56;
        fontSize = 18;
    }

    Color backgroundColor;
    Color textColor;
    List<BoxShadow>? shadow;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        shadow = AppDecorations.buttonShadow;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.secondary;
        textColor = Colors.white;
        shadow = null;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        shadow = null;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        shadow = null;
    }

    if (isDisabled) {
      backgroundColor = backgroundColor.withOpacity(0.5);
    }

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
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
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );

    return AnimatedContainer(
      duration: AppDurations.fast,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDecorations.buttonRadius,
        boxShadow: shadow,
        border: variant == ButtonVariant.outline
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: AppDecorations.buttonRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
