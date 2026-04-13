import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/shell_screen.dart';
import '../../presentation/screens/lesson_screen.dart';
import '../../presentation/screens/settings/model_settings_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/ai_tutor/ai_tutor_screen.dart';
import '../../presentation/screens/review/review_screen.dart';
import '../../presentation/screens/stats/stats_screen.dart';
import '../../presentation/screens/leaderboard/leaderboard_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String lesson = '/lesson/:courseId/:lessonId';
  static const String aiTutor = '/ai-tutor';
  static const String achievements = '/achievements';
  static const String review = '/review';
  static const String stats = '/stats';
  static const String settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const ShellScreen(),
    ),
    GoRoute(
      path: '/model-settings',
      builder: (context, state) => const ModelSettingsScreen(),
    ),
    GoRoute(
      path: '/lesson/:courseId/:lessonId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId'] ?? '';
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return LessonScreen(courseId: courseId, lessonId: lessonId);
      },
    ),
    GoRoute(
      path: '/ai-tutor',
      builder: (context, state) {
        final initialContext = state.extra as String?;
        return AITutorScreen(initialContext: initialContext);
      },
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
  ],
);
