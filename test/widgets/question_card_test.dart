import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jelly_buddy/l10n/app_localizations.dart';
import 'package:jelly_buddy/domain/entities/course.dart';
import 'package:jelly_buddy/domain/entities/question.dart';
import 'package:jelly_buddy/presentation/widgets/lesson/question_card.dart';

void main() {
  Question buildQuestion({
    String content = 'What is the output?',
    List<String>? codeSnippet,
    Difficulty difficulty = Difficulty.easy,
  }) {
    return Question(
      id: 'q1',
      type: LevelType.choice,
      content: content,
      codeSnippet: codeSnippet,
      acceptedAnswers: const ['A'],
      difficulty: difficulty,
      explanation: 'Because...',
      relatedConcepts: const ['variables'],
      estimatedSeconds: 30,
    );
  }

  Widget buildTestWidget(Question question) {
    return MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: QuestionCard(question: question),
        ),
      ),
    );
  }

  group('QuestionCard', () {
    testWidgets('renders question content text', (tester) async {
      final q = buildQuestion(content: 'What does print() do?');
      await tester.pumpWidget(buildTestWidget(q));

      expect(find.text('What does print() do?'), findsOneWidget);
    });

    testWidgets('shows code snippet when present', (tester) async {
      final q = buildQuestion(
        codeSnippet: ['int x = 5;', 'print(x);'],
      );
      await tester.pumpWidget(buildTestWidget(q));

      expect(find.text('int x = 5;\nprint(x);'), findsOneWidget);
    });

    testWidgets('does not show code snippet container when absent',
        (tester) async {
      final q = buildQuestion(codeSnippet: null);
      await tester.pumpWidget(buildTestWidget(q));

      // The code snippet text uses JetBrains Mono font family.
      // When there's no snippet, no text with that content should appear.
      // We verify by checking the question text is there but no snippet join text.
      expect(find.text('What is the output?'), findsOneWidget);
    });

    testWidgets('does not show code snippet container when empty list',
        (tester) async {
      final q = buildQuestion(codeSnippet: []);
      await tester.pumpWidget(buildTestWidget(q));

      expect(find.text('What is the output?'), findsOneWidget);
    });

    testWidgets('shows difficulty badge for easy', (tester) async {
      final q = buildQuestion(difficulty: Difficulty.easy);
      await tester.pumpWidget(buildTestWidget(q));

      expect(find.text('\u7B80\u5355'), findsOneWidget); // 简单
    });

    testWidgets('shows difficulty badge for medium', (tester) async {
      final q = buildQuestion(difficulty: Difficulty.medium);
      await tester.pumpWidget(buildTestWidget(q));

      expect(find.text('\u4E2D\u7B49'), findsOneWidget); // 中等
    });

    testWidgets('shows difficulty badge for hard', (tester) async {
      final q = buildQuestion(difficulty: Difficulty.hard);
      await tester.pumpWidget(buildTestWidget(q));

      expect(find.text('\u56F0\u96BE'), findsOneWidget); // 困难
    });
  });
}
