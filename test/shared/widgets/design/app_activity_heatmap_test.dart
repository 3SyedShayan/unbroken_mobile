import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/design/heatmap/app_activity_heatmap.dart';

void main() {
  group('AppActivityHeatmap.colorForLevel', () {
    const base = Color(0xFFF26B21);
    const empty = Color(0xFFF1E7D9);

    test('returns emptyCell for level 0 and stepped alphas for 1..4', () {
      expect(AppActivityHeatmap.colorForLevel(base, empty, 0), empty);
      expect(
        AppActivityHeatmap.colorForLevel(base, empty, 1),
        base.withValues(alpha: 0.22),
      );
      expect(
        AppActivityHeatmap.colorForLevel(base, empty, 2),
        base.withValues(alpha: 0.45),
      );
      expect(
        AppActivityHeatmap.colorForLevel(base, empty, 3),
        base.withValues(alpha: 0.72),
      );
      expect(AppActivityHeatmap.colorForLevel(base, empty, 4), base);
    });
  });

  group('AppActivityHeatmap layouts', () {
    final today = DateTime(2026, 11, 23);

    testWidgets('calendarMonth renders weekday headers, day numbers, legend, and handles tap',
        (tester) async {
      DateTime? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AppActivityHeatmap(
                baseColor: AppColors.accent,
                today: today,
                weekStartsMonday: true,
                layout: HeatmapLayout.calendarMonth,
                days: 30,
                showDayNumbers: true,
                showLegend: true,
                footerLeadingText: '12 active days',
                levelForDate: (d) => d.day % 5,
                onDayTap: (d) => tapped = d,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('12 active days'), findsOneWidget);
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);

      await tester.tap(find.text('23'));
      await tester.pumpAndSettle();
      expect(tapped, DateTime(2026, 11, 23));
    });

    testWidgets('weekColumns 3M fitWidth and 6M scrollable render without overflow at 320px width',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Column(
                children: [
                  AppActivityHeatmap(
                    baseColor: AppColors.accent,
                    today: today,
                    layout: HeatmapLayout.weekColumns,
                    weeks: 13,
                    fitWidth: true,
                    levelForDate: (d) => d.day % 5,
                  ),
                  const SizedBox(height: 16),
                  AppActivityHeatmap(
                    baseColor: AppColors.success,
                    today: today,
                    layout: HeatmapLayout.weekColumns,
                    weeks: 26,
                    fitWidth: false,
                    levelForDate: (d) => d.day % 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
