import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/presentation/widgets/game/xp_progress_bar.dart';

void main() {
  Widget buildTestWidget({
    int currentXp = 100,
    int nextLevelXp = 300,
    int level = 3,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: XpProgressBar(
          currentXp: currentXp,
          nextLevelXp: nextLevelXp,
          level: level,
        ),
      ),
    );
  }

  group('XpProgressBar', () {
    testWidgets('renders level number', (tester) async {
      await tester.pumpWidget(buildTestWidget(level: 5));

      expect(find.text('Level 5'), findsOneWidget);
    });

    testWidgets('shows XP text with current and next values', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentXp: 200,
        nextLevelXp: 500,
      ));

      expect(find.text('200 / 500 XP'), findsOneWidget);
    });

    testWidgets('renders level 1 correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentXp: 30,
        nextLevelXp: 60,
        level: 1,
      ));

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('30 / 60 XP'), findsOneWidget);
    });

    testWidgets('shows "XP into level" text when xpIntoLevel > 0',
        (tester) async {
      // Level 3: xpToLevel[2] = 150
      // currentXp = 200, so xpIntoLevel = 200 - 150 = 50
      await tester.pumpWidget(buildTestWidget(
        currentXp: 200,
        nextLevelXp: 300,
        level: 3,
      ));

      expect(find.text('50 XP into level'), findsOneWidget);
    });

    testWidgets('does not show "XP into level" text when xpIntoLevel is 0',
        (tester) async {
      // Level 3: xpToLevel[2] = 150
      // currentXp = 150, so xpIntoLevel = 150 - 150 = 0
      await tester.pumpWidget(buildTestWidget(
        currentXp: 150,
        nextLevelXp: 300,
        level: 3,
      ));

      expect(find.textContaining('XP into level'), findsNothing);
    });

    testWidgets('handles nextLevelXp of 0 without error', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentXp: 0,
        nextLevelXp: 0,
        level: 1,
      ));

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('0 / 0 XP'), findsOneWidget);
    });
  });
}
