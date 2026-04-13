import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_buddy/presentation/widgets/lesson/option_tile.dart';
import 'package:jelly_buddy/core/theme/app_colors.dart';

void main() {
  Widget buildTestWidget({
    String optionLetter = 'A',
    String content = 'Test option',
    OptionState state = OptionState.normal,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OptionTile(
          optionLetter: optionLetter,
          content: content,
          state: state,
          onTap: onTap,
        ),
      ),
    );
  }

  group('OptionTile', () {
    testWidgets('renders letter and content text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        optionLetter: 'B',
        content: 'Some answer',
      ));

      expect(find.text('B'), findsOneWidget);
      expect(find.text('Some answer'), findsOneWidget);
    });

    testWidgets('normal state shows default styling (no check/cancel icon)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: OptionState.normal,
      ));

      // Normal state should NOT show check or cancel icons
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.cancel), findsNothing);

      // Verify the border color is surfaceVariant via the AnimatedContainer
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.surfaceVariant);
    });

    testWidgets('selected state shows primary border', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: OptionState.selected,
      ));

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.primary);

      // No icons in selected state
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('correct state shows green border and check icon',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: OptionState.correct,
      ));

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.success);

      // Check icon present
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, AppColors.success);

      // No cancel icon
      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('incorrect state shows red border and cancel icon',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: OptionState.incorrect,
      ));

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.error);

      // Cancel icon present
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.cancel));
      expect(icon.color, AppColors.error);

      // No check icon
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(OptionTile));
      expect(tapped, isTrue);
    });

    testWidgets('onTap is null does not crash', (tester) async {
      await tester.pumpWidget(buildTestWidget(onTap: null));

      // Tapping should not throw
      await tester.tap(find.byType(OptionTile));
      await tester.pump();
    });
  });
}
