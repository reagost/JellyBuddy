import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:jelly_llm/jelly_llm.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme_data.dart';
import 'data/services/storage_service.dart';
import 'data/services/crash_log_service.dart';
import 'data/services/analytics_service.dart';
import 'data/services/progress_service.dart';
import 'data/services/daily_task_service.dart';
import 'data/services/achievement_service.dart';
import 'data/services/model_download_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/search_service.dart';
import 'data/services/stats_service.dart';
import 'data/services/leaderboard_service.dart';
import 'data/services/custom_course_service.dart';
import 'data/repositories/game_repository_impl.dart';
import 'data/repositories/learning_repository_impl.dart';
import 'data/repositories/ai_repository_impl.dart';
import 'domain/repositories/i_game_repository.dart';
import 'domain/repositories/i_learning_repository.dart';
import 'domain/repositories/i_ai_repository.dart';
import 'presentation/blocs/game/game_bloc.dart';
import 'presentation/blocs/game/game_event.dart';
import 'presentation/blocs/model/model_bloc.dart';
import 'presentation/blocs/model/model_event.dart';
import 'presentation/blocs/ai_tutor/ai_tutor_bloc.dart';

final getIt = GetIt.instance;

/// Global ValueNotifier that drives locale changes across the app.
/// Read from StorageService on startup; written when the user switches
/// language in the Settings screen.
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

/// Global ValueNotifier that drives dark/light theme changes.
/// Read from StorageService on startup; written when the user toggles
/// dark mode in the Settings screen.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> setupDependencies() async {
  // Storage
  final storage = StorageService();
  await storage.init();
  getIt.registerSingleton<StorageService>(storage);

  // Crash Log Service
  final crashLogService = CrashLogService(storage: storage);
  getIt.registerSingleton<CrashLogService>(crashLogService);

  // Analytics Service
  final analyticsService = AnalyticsService(storage: storage);
  getIt.registerSingleton<AnalyticsService>(analyticsService);

  // Progress Service
  final progressService = ProgressService(storage: storage);
  getIt.registerSingleton<ProgressService>(progressService);

  // Daily Task Service
  final dailyTaskService = DailyTaskService(storage: storage);
  getIt.registerSingleton<DailyTaskService>(dailyTaskService);

  // JellyLlm (cross-platform local LLM)
  final jellyLlm = JellyLlm();
  getIt.registerSingleton<JellyLlm>(jellyLlm);

  // Model Download Service (cross-platform, 3-source fallback)
  final modelDownloadService = ModelDownloadService();
  getIt.registerSingleton<ModelDownloadService>(modelDownloadService);

  // Custom Course Service (for MD-imported courses)
  getIt.registerSingleton<CustomCourseService>(
    CustomCourseService(storage: storage),
  );

  // Repositories
  getIt.registerLazySingleton<IGameRepository>(
    () => GameRepositoryImpl(storage: getIt<StorageService>()),
  );
  getIt.registerLazySingleton<ILearningRepository>(
    () => LearningRepositoryImpl(
      progressService: getIt<ProgressService>(),
      customCourseService: getIt<CustomCourseService>(),
    ),
  );
  getIt.registerLazySingleton<IAIRepository>(
    () => AIRepositoryImpl(
      llm: getIt<JellyLlm>(),
      downloadService: getIt<ModelDownloadService>(),
    ),
  );

  // Search Service
  getIt.registerLazySingleton<SearchService>(
    () => SearchService(learningRepo: getIt<ILearningRepository>()),
  );

  // Achievement Service
  getIt.registerLazySingleton<AchievementService>(
    () => AchievementService(
      gameRepo: getIt<IGameRepository>(),
      progressService: getIt<ProgressService>(),
      storage: getIt<StorageService>(),
    ),
  );

  // Notification Service
  getIt.registerSingleton<NotificationService>(NotificationService());

  // Stats Service
  getIt.registerLazySingleton<StatsService>(
    () => StatsService(
      learningRepo: getIt<ILearningRepository>(),
      gameRepo: getIt<IGameRepository>(),
      storage: getIt<StorageService>(),
    ),
  );

  // Leaderboard Service
  getIt.registerLazySingleton<LeaderboardService>(
    () => LeaderboardService(
      storage: getIt<StorageService>(),
      statsService: getIt<StatsService>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<GameBloc>(
    () => GameBloc(gameRepo: getIt<IGameRepository>())..add(LoadUserProgress()),
  );
  getIt.registerFactory<ModelBloc>(
    () => ModelBloc(
      llm: getIt<JellyLlm>(),
      downloadService: getIt<ModelDownloadService>(),
    )..add(CheckModels()),
  );
  getIt.registerFactory<AITutorBloc>(
    () => AITutorBloc(aiRepo: getIt<IAIRepository>()),
  );
}

class JellyBuddyApp extends StatefulWidget {
  const JellyBuddyApp({super.key});

  @override
  State<JellyBuddyApp> createState() => _JellyBuddyAppState();
}

class _JellyBuddyAppState extends State<JellyBuddyApp> {
  @override
  void initState() {
    super.initState();
    final storage = getIt<StorageService>();

    // Seed locale notifier from persisted preference.
    final storedLocale = storage.getString('app_locale');
    if (storedLocale != null) {
      localeNotifier.value = Locale(storedLocale);
    }

    // Seed theme mode notifier from persisted preference.
    final storedDark = storage.getString('dark_mode');
    if (storedDark == 'true') {
      themeModeNotifier.value = ThemeMode.dark;
    }

    localeNotifier.addListener(_rebuild);
    themeModeNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_rebuild);
    themeModeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    setState(() {}); // rebuild MaterialApp with new locale / theme
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<GameBloc>()),
        BlocProvider(create: (_) => getIt<ModelBloc>()),
        BlocProvider(create: (_) => getIt<AITutorBloc>()),
      ],
      child: MaterialApp.router(
        title: 'JellyBuddy',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: localeNotifier.value,
        theme: AppThemeData.light(),
        darkTheme: AppThemeData.dark(),
        themeMode: themeModeNotifier.value,
        routerConfig: appRouter,
      ),
    );
  }
}
