import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/home/domain/today_summary_calculator.dart';

class TodayHeroCard extends StatelessWidget {
  final TodaySummary summary;

  const TodayHeroCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final badgeColor =
        summary.isUnbroken ? AppTheme.c.success : AppTheme.c.accent;

    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: summary.isUnbroken
              ? AppTheme.c.success.withValues(alpha: 0.45)
              : AppTheme.c.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TODAY\'S MOMENTUM',
                  style: AppText.l1b
                      .cl(AppTheme.c.subText)
                      .copyWith(letterSpacing: 1.2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${summary.combinedPercent}%',
                  style: AppText.l1b.cl(badgeColor),
                ),
              ),
            ],
          ),
          Space.y.t12,
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final fillWidth = summary.combinedRatio <= 0.0
                  ? 0.0
                  : (maxWidth * summary.combinedRatio).clamp(6.0, maxWidth);

              return Container(
                height: 9,
                width: maxWidth,
                decoration: BoxDecoration(
                  color: AppTheme.c.emptyCell,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: AppProps.medium,
                    curve: Curves.easeOutCubic,
                    width: fillWidth,
                    height: 9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: summary.isUnbroken
                            ? [AppTheme.c.success, AppTheme.c.success]
                            : [AppTheme.c.accent, AppTheme.c.warning],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            },
          ),
          Space.y.t12,
          if (summary.habitsTotal == 0 && summary.tasksTotal == 0)
            Text(
              'Add a habit or task to start building today\'s streak',
              style: AppText.b2.cl(AppTheme.c.subText),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (summary.habitsTotal > 0)
                  _BreakdownChip(
                    label:
                        '🔥 ${summary.habitsCompleted}/${summary.habitsTotal} habits',
                    isDone: summary.habitsCompleted >= summary.habitsTotal,
                  ),
                if (summary.tasksTotal > 0)
                  _BreakdownChip(
                    label:
                        '✓ ${summary.tasksCompleted}/${summary.tasksTotal} tasks',
                    isDone: summary.tasksCompleted >= summary.tasksTotal,
                  ),
              ],
            ),
          if (summary.isUnbroken) ...[
            Space.y.t12,
            _StatusStrip(
              color: AppTheme.c.success,
              text: '✨ Unbroken day locked in!',
            ),
          ] else if (summary.isAtRisk &&
              summary.atRiskCountdownLabel != null) ...[
            Space.y.t12,
            _StatusStrip(
              color: AppTheme.c.warning,
              text: '⏳ ${summary.atRiskCountdownLabel!}',
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  final String label;
  final bool isDone;

  const _BreakdownChip({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDone
            ? AppTheme.c.success.withValues(alpha: 0.12)
            : AppTheme.c.subBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppText.l1b.cl(
          isDone ? AppTheme.c.success : AppTheme.c.subText,
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final Color color;
  final String text;

  const _StatusStrip({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      width: double.infinity,
      padding: Space.sym(10, 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppText.b2b.cl(color),
      ),
    );
  }
}
