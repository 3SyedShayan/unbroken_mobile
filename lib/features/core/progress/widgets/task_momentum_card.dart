import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/progress/domain/progress_models.dart';

class TaskMomentumCard extends StatelessWidget {
  final TaskRangeSummary summary;
  final VoidCallback onViewMap;

  const TaskMomentumCard({
    super.key,
    required this.summary,
    required this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'DAILY TASKS',
                style: AppText.l1b
                    .cl(AppTheme.c.subText)
                    .copyWith(letterSpacing: 1.2),
              ),
              Space.x.t08,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.c.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${summary.completionRatePercent}% avg',
                  style: AppText.l1b.cl(AppTheme.c.success).copyWith(fontSize: 10),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewMap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View map',
                      style: AppText.l1b.cl(AppTheme.c.success),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppTheme.c.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Space.y.t12,
          Row(
            children: [
              Expanded(
                child: _TaskMetric(
                  value: '${summary.currentStreak}d',
                  label: 'Streak',
                ),
              ),
              Expanded(
                child: _TaskMetric(
                  value: '${summary.bestStreak}d',
                  label: 'Best streak',
                ),
              ),
              Expanded(
                child: _TaskMetric(
                  value: '${summary.clearedDaysInRange}',
                  label: 'Days cleared',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskMetric extends StatelessWidget {
  final String value;
  final String label;

  const _TaskMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.h2b.cl(AppTheme.c.text)),
        const SizedBox(height: 2),
        Text(label, style: AppText.l1.cl(AppTheme.c.subText)),
      ],
    );
  }
}
