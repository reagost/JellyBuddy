import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'app.dart';
import 'data/services/crash_log_service.dart';
import 'data/services/analytics_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/widgets/common/error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace the default red error screen with a user-friendly widget
  ErrorWidget.builder = AppErrorWidget.builder();

  await setupDependencies();

  final crashLog = GetIt.instance<CrashLogService>();
  final analytics = GetIt.instance<AnalyticsService>();

  // Catch framework errors (widget build errors, layout errors, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
    debugPrint('[FlutterError] ${details.stack}');
    crashLog.logError(details.exceptionAsString(), details.stack);
  };

  // Catch async errors not caught by the framework (e.g. Future/Stream errors)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[AsyncError] $error');
    debugPrint('[AsyncError] $stack');
    crashLog.logError(error, stack);
    return true;
  };

  // Track app open
  analytics.trackEvent('app_open');

  // Initialize local notifications and schedule daily reminder
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminder();

  runApp(const JellyBuddyApp());
}
