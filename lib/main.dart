import 'dart:ui';

import 'package:flutter/material.dart';
import 'app.dart';
import 'presentation/widgets/common/error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch framework errors (widget build errors, layout errors, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
    debugPrint('[FlutterError] ${details.stack}');
  };

  // Catch async errors not caught by the framework (e.g. Future/Stream errors)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[AsyncError] $error');
    debugPrint('[AsyncError] $stack');
    return true;
  };

  // Replace the default red error screen with a user-friendly widget
  ErrorWidget.builder = AppErrorWidget.builder();

  await setupDependencies();
  runApp(const JellyBuddyApp());
}
