import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_checkmark.dart';

void main() {
  group('AppAnimatedCheckmark', () {
    testWidgets('renders AppAnimatedCheckmark without icon when unchecked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAnimatedCheckmark(checked: false),
          ),
        ),
      );

      expect(find.byType(AppAnimatedCheckmark), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('mounts icon when alwaysMountIcon is true even if unchecked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAnimatedCheckmark(checked: false, alwaysMountIcon: true),
          ),
        ),
      );

      expect(find.byType(AppAnimatedCheckmark), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('animates and displays checkmark when checked transitions to true', (tester) async {
      var isChecked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AppAnimatedCheckmark(checked: isChecked),
                    ElevatedButton(
                      onPressed: () => setState(() => isChecked = true),
                      child: const Text('Check'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.text('Check'));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      final checkmarkFinder = find.descendant(
        of: find.byType(AppAnimatedCheckmark),
        matching: find.byType(CustomPaint),
      );
      expect(checkmarkFinder, findsOneWidget);
    });
  });
}
