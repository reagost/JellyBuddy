import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/presentation/widgets/game/hearts_display.dart';

void main() {
  Widget buildTestWidget({
    required int current,
    int max = 5,
    bool showAnimation = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HeartsDisplay(
          current: current,
          max: max,
          showAnimation: showAnimation,
        ),
      ),
    );
  }

  group('HeartsDisplay', () {
    testWidgets('shows correct number of filled and empty hearts',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 3, max: 5));
      await tester.pumpAndSettle();

      final filledHearts =
          find.text('\u2764\uFE0F'); // red heart emoji
      final emptyHearts = find.text('\uD83D\uDDA4'); // black heart emoji

      expect(filledHearts, findsNWidgets(3));
      expect(emptyHearts, findsNWidgets(2));
    });

    testWidgets('5 hearts with current=3 shows 3 filled + 2 empty',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 3, max: 5));
      await tester.pumpAndSettle();

      // Total hearts: 5
      // Filled hearts rendered with red heart text
      final allTexts = tester.widgetList<Text>(find.byType(Text));
      final heartTexts = allTexts
          .where((t) =>
              t.data == '\u2764\uFE0F' || t.data == '\uD83D\uDDA4')
          .toList();
      expect(heartTexts.length, 5);

      final filled =
          heartTexts.where((t) => t.data == '\u2764\uFE0F').length;
      final empty =
          heartTexts.where((t) => t.data == '\uD83D\uDDA4').length;
      expect(filled, 3);
      expect(empty, 2);
    });

    testWidgets('0 hearts shows all empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 0, max: 5));
      await tester.pumpAndSettle();

      final filledHearts = find.text('\u2764\uFE0F');
      final emptyHearts = find.text('\uD83D\uDDA4');

      expect(filledHearts, findsNothing);
      expect(emptyHearts, findsNWidgets(5));
    });

    testWidgets('all hearts filled when current equals max', (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 5, max: 5));
      await tester.pumpAndSettle();

      final filledHearts = find.text('\u2764\uFE0F');
      final emptyHearts = find.text('\uD83D\uDDA4');

      expect(filledHearts, findsNWidgets(5));
      expect(emptyHearts, findsNothing);
    });

    testWidgets('custom max hearts count', (tester) async {
      await tester.pumpWidget(buildTestWidget(current: 2, max: 3));
      await tester.pumpAndSettle();

      final allTexts = tester.widgetList<Text>(find.byType(Text));
      final heartTexts = allTexts
          .where((t) =>
              t.data == '\u2764\uFE0F' || t.data == '\uD83D\uDDA4')
          .toList();
      expect(heartTexts.length, 3);
    });
  });
}
