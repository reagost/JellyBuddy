import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:jelly_buddy/data/services/storage_service.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:jelly_buddy/presentation/screens/splash_screen.dart';
import '../helpers/mock_storage_service.dart';

void main() {
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();
    GetIt.instance.registerSingleton<StorageService>(mockStorage);
  });

  tearDown(() => GetIt.instance.reset());

  Widget buildTestWidget() {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('zh'),
    );
  }

  group('SplashScreen', () {
    testWidgets('shows JellyBuddy text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Allow the fade animation to start but not the 2s navigation timer
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('JellyBuddy'), findsOneWidget);

      // Drain the 2-second navigation timer so no pending timer remains
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Subtitle is 'AI 驱动游戏化学习'
      expect(find.text('AI \u9A71\u52A8\u6E38\u620F\u5316\u5B66\u4E60'),
          findsOneWidget);

      // Drain the 2-second navigation timer so no pending timer remains
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
