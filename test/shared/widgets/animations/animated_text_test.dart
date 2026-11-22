import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_text.dart';

void main() {
  group('AppAnimatedText', () {
    testWidgets('renders initial text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAnimatedText(text: 'Initial text'),
          ),
        ),
      );

      expect(find.text('Initial text'), findsOneWidget);
    });

    testWidgets('animates text change smoothly to new text', (tester) async {
      var currentText = 'First state';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AppAnimatedText(
                      text: currentText,
                      direction: AnimatedTextDirection.up,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentText = 'Second state';
                        });
                      },
                      child: const Text('Change'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('First state'), findsOneWidget);
      expect(find.text('Second state'), findsNothing);

      // Trigger text change
      await tester.tap(find.text('Change'));
      await tester.pump(); // Start transition

      // Halfway through transition
      await tester.pump(const Duration(milliseconds: 150));
      // Both old and new text exist during transition
      expect(find.text('First state'), findsOneWidget);
      expect(find.text('Second state'), findsOneWidget);

      // Complete transition
      await tester.pumpAndSettle();
      expect(find.text('First state'), findsNothing);
      expect(find.text('Second state'), findsOneWidget);
    });

    testWidgets('supports downward direction and fadeOnly without error',
        (tester) async {
      var mode = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AppAnimatedText(
                      text: 'Mode $mode',
                      direction: mode == 1
                          ? AnimatedTextDirection.down
                          : AnimatedTextDirection.fadeOnly,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mode = (mode + 1) % 2;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Mode 0'), findsOneWidget);
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Mode 1'), findsOneWidget);
    });
  });
}
