import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/habit_row_card.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/mini_grid.dart';

void main() {
  const habitColor = Color(0xFFE2603A);

  BoxDecoration? cellDecoration(WidgetTester tester, int index) {
    final cellFinder = find
        .descendant(
          of: find.byType(MiniGrid),
          matching: find.byType(AnimatedContainer),
        )
        .at(index);
    final container = tester.widget<Container>(
      find.descendant(
        of: cellFinder,
        matching: find.byType(Container),
      ),
    );
    return container.decoration as BoxDecoration?;
  }

  group('MiniGrid History-style square streak', () {
    testWidgets('renders 10 square 12x12 cells with 2.5px radius and correct colors',
        (tester) async {
      final done = [
        true,
        false,
        true,
        true,
        false,
        false,
        true,
        false,
        true,
        false,
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MiniGrid(
                color: habitColor,
                done: done,
              ),
            ),
          ),
        ),
      );

      final cells = find.descendant(
        of: find.byType(MiniGrid),
        matching: find.byType(AnimatedContainer),
      );
      expect(cells, findsNWidgets(10));

      for (var i = 0; i < 10; i++) {
        final size = tester.getSize(cells.at(i));
        expect(size, const Size(12, 12));

        final decoration = cellDecoration(tester, i)!;
        expect(decoration.borderRadius, BorderRadius.circular(2.5));
        expect(decoration.color, done[i] ? habitColor : AppColors.emptyCell);

        if (i == 9) {
          expect(
            decoration.border,
            Border.all(
              color: habitColor.withValues(alpha: 0.6),
              width: 1.2,
            ),
          );
        } else {
          expect(decoration.border, isNull);
        }
      }
    });

    testWidgets(
        'highlights today cell when undone and transitions cleanly to filled when done',
        (tester) async {
      var todayDone = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MiniGrid(
                        color: habitColor,
                        done: [
                          false,
                          false,
                          false,
                          false,
                          false,
                          false,
                          false,
                          false,
                          true,
                          todayDone,
                        ],
                      ),
                      TextButton(
                        onPressed: () => setState(() => todayDone = true),
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      final before = cellDecoration(tester, 9)!;
      expect(before.color, AppColors.emptyCell);
      expect(
        before.border,
        Border.all(color: habitColor.withValues(alpha: 0.6), width: 1.2),
      );

      await tester.tap(find.text('Toggle'));
      await tester.pump();
      await tester.pump(AppProps.fast);
      await tester.pumpAndSettle();

      final after = cellDecoration(tester, 9)!;
      expect(after.color, habitColor);
      expect(after.border, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('HabitRowCard 10-day square layout safety', () {
    final habit = Habit(
      id: 'h_meditate',
      name: 'Morning Meditation & Breathwork',
      emoji: '🧘',
      colorHex: '#E2603A',
      createdAt: DateTime(2026, 1, 1),
    );
    final recent10 = List<bool>.generate(10, (i) => i.isEven);

    for (final width in [320.0, 360.0]) {
      testWidgets(
          'renders 10 square cells without RenderFlex overflow at ${width.toInt()}px with 3-digit streak',
          (tester) async {
        tester.view.physicalSize = Size(width, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: HabitRowCard(
                  habit: habit,
                  isDone: false,
                  stats: const StreakStats(current: 120, best: 150),
                  recentDays: recent10,
                  onTap: () {},
                  onToggle: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('120'), findsOneWidget);
        expect(find.byType(MiniGrid), findsOneWidget);
        final cells = find.descendant(
          of: find.byType(MiniGrid),
          matching: find.byType(AnimatedContainer),
        );
        expect(cells, findsNWidgets(10));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
