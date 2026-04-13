import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:jelly_buddy/data/services/storage_service.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:jelly_buddy/presentation/screens/onboarding/onboarding_screen.dart';
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
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
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

  group('OnboardingScreen', () {
    testWidgets('shows first page content', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // First page title
      expect(find.text('\u50CF\u73A9\u6E38\u620F\u4E00\u6837\u5B66\u7F16\u7A0B'),
          findsOneWidget); // 像玩游戏一样学编程

      // First page subtitle
      expect(
          find.text(
              '\u95EF\u5173\u3001\u7B54\u9898\u3001\u8D5A\u7ECF\u9A8C\u503C\uFF0C\u8BA9\u5B66\u4E60\u53D8\u5F97\u6709\u8DA3'),
          findsOneWidget); // 闯关、答题、赚经验值，让学习变得有趣

      // First page emoji
      expect(find.text('\uD83C\uDFAE'), findsOneWidget); // 🎮
    });

    testWidgets('has next button with correct text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 下一步 button
      expect(find.text('\u4E0B\u4E00\u6B65'), findsOneWidget);
    });

    testWidgets('has skip button with correct text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 跳过 button
      expect(find.text('\u8DF3\u8FC7'), findsOneWidget);
    });

    testWidgets('shows dot indicators for pages', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // There should be 3 AnimatedContainers for dot indicators
      // (plus others from the page). We verify by checking the page structure exists.
      // The first dot should be wider (24px) indicating active page.
      final animatedContainers =
          tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      // At least 3 dots exist
      expect(animatedContainers.length, greaterThanOrEqualTo(3));
    });

    testWidgets('tapping next advances to second page', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap 下一步
      await tester.tap(find.text('\u4E0B\u4E00\u6B65'));
      await tester.pumpAndSettle();

      // Second page title
      expect(find.text('Code Buddy \u968F\u65F6\u5E2E\u4F60'),
          findsOneWidget); // Code Buddy 随时帮你
    });

    testWidgets('skip button navigates away from onboarding', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap 跳过
      await tester.tap(find.text('\u8DF3\u8FC7'));
      await tester.pumpAndSettle();

      // Should navigate to home
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
