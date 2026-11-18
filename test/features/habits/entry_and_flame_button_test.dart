import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/features/core/habits/models/entry.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/flame_check_button.dart';

void main() {
  group('Entry.fromJson Deserialization Resilience', () {
    test('handles null timestamp gracefully without type cast crash', () {
      final json = <String, dynamic>{
        'id': 'h_meditate_2026-11-18',
        'habitId': 'h_meditate',
        'logicalDayKey': '2026-11-18',
        'source': 'mobile',
        'platform': 'ios',
        'timestamp': null,
      };

      final entry = Entry.fromJson(json);
      expect(entry.id, 'h_meditate_2026-11-18');
      expect(entry.habitId, 'h_meditate');
      expect(entry.logicalDayKey, '2026-11-18');
      expect(entry.timestamp, isNotNull);
    });

    test('handles ISO8601 string timestamp', () {
      final json = <String, dynamic>{
        'id': 'h_meditate_2026-11-18',
        'habitId': 'h_meditate',
        'logicalDayKey': '2026-11-18',
        'source': 'mobile',
        'platform': 'ios',
        'timestamp': '2026-11-18T10:30:00.000Z',
      };

      final entry = Entry.fromJson(json);
      expect(entry.timestamp.toUtc(), DateTime.utc(2026, 11, 18, 10, 30));
    });

    test('handles epoch integer timestamp', () {
      final json = <String, dynamic>{
        'id': 'h_meditate_2026-11-18',
        'habitId': 'h_meditate',
        'logicalDayKey': '2026-11-18',
        'source': 'mobile',
        'platform': 'ios',
        'timestamp': 1763460000000,
      };

      final entry = Entry.fromJson(json);
      expect(entry.timestamp.millisecondsSinceEpoch, 1763460000000);
    });
  });

  group('Habit.fromJson Deserialization Resilience', () {
    test('handles null createdAt and updatedAt gracefully', () {
      final json = <String, dynamic>{
        'id': 'h_20261117_meditate',
        'name': 'Meditate',
        'createdAt': null,
        'updatedAt': null,
      };

      final habit = Habit.fromJson(json);
      expect(habit.id, 'h_20261117_meditate');
      expect(habit.name, 'Meditate');
      expect(habit.createdAt, isNotNull);
      expect(habit.updatedAt, isNull);
    });
  });

  group('FlameCheckButton Scale Animation Safety', () {
    testWidgets('animates without TweenSequence assertion failure on toggle',
        (tester) async {
      var isDone = false;
      var toggleCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: FlameCheckButton(
                    color: const Color(0xFF2FA39A),
                    isDone: isDone,
                    onToggle: () {
                      toggleCount++;
                      setState(() {
                        isDone = true;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(FlameCheckButton), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap to toggle
      await tester.tap(find.byType(FlameCheckButton));
      await tester.pump(); // Triggers onToggle and setState -> didUpdateWidget

      expect(toggleCount, 1);
      expect(isDone, true);

      // Pump frames through the animation duration (fast: 200ms)
      // Previously, this threw TweenSequence assertion failure because of Curves.easeOutBack overshoot (t > 1.0)
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
