import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:jelly_llm/jelly_llm.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'data/services/storage_service.dart';
import 'data/services/progress_service.dart';
import 'data/services/daily_task_service.dart';
import 'data/services/achievement_service.dart';
import 'data/services/model_download_service.dart';
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

Future<void> setupDependencies() async {
  // Storage
  final storage = StorageService();
  await storage.init();
  getIt.registerSingleton<StorageService>(storage);

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

  // Repositories
  getIt.registerLazySingleton<IGameRepository>(
    () => GameRepositoryImpl(storage: getIt<StorageService>()),
  );
  getIt.registerLazySingleton<ILearningRepository>(
    () => LearningRepositoryImpl(progressService: getIt<ProgressService>()),
  );
  getIt.registerLazySingleton<IAIRepository>(
    () => AIRepositoryImpl(
      llm: getIt<JellyLlm>(),
      downloadService: getIt<ModelDownloadService>(),
    ),
  );

  // Achievement Service
  getIt.registerLazySingleton<AchievementService>(
    () => AchievementService(
      gameRepo: getIt<IGameRepository>(),
      progressService: getIt<ProgressService>(),
      storage: getIt<StorageService>(),
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

class JellyBuddyApp extends StatelessWidget {
  const JellyBuddyApp({super.key});

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
