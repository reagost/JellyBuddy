import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// A user-friendly error widget that replaces the default red error screen.
/// Shows a sad face icon, error title, message, and a retry button.
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.errorDetails,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: AppColors.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                '\u51FA\u4E86\u70B9\u95EE\u9898',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                errorDetails?.exceptionAsString() ?? '\u53D1\u751F\u4E86\u672A\u77E5\u9519\u8BEF',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('\u91CD\u8BD5'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a builder function suitable for [ErrorWidget.builder].
  static Widget Function(FlutterErrorDetails) builder() {
    return (FlutterErrorDetails details) {
      return AppErrorWidget(errorDetails: details);
    };
  }
}
