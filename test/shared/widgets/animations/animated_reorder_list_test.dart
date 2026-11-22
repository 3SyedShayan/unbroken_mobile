import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_reorder_list.dart';

void main() {
  group('AnimatedReorderList', () {
    testWidgets('renders items in initial order', (tester) async {
      final items = ['A', 'B', 'C'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedReorderList<String>(
              items: items,
              itemKey: (it) => it,
              itemBuilder: (context, it, index) => Text(it, key: ValueKey(it)),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('smoothly translates reordered items without crashing', (tester) async {
      var items = ['A', 'B', 'C'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimatedReorderList<String>(
                      items: items,
                      itemKey: (it) => it,
                      itemBuilder: (context, it, index) => SizedBox(
                        key: ValueKey(it),
                        height: 50,
                        child: Text(it),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          items = ['B', 'C', 'A']; // A moved to bottom
                        });
                      },
                      child: const Text('Reorder'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      await tester.tap(find.text('Reorder'));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });
}
