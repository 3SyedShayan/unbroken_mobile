import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_cadence.dart';
import 'package:unbroken_mobile/shared/widgets/core/buttons/button.dart';

class EmptyFoldersView extends StatelessWidget {
  final VoidCallback onAddFolder;
  final void Function(
    String name,
    GoalCadence cadence,
    String emoji,
    String colorHex,
  ) onQuickCreate;

  const EmptyFoldersView({
    super.key,
    required this.onAddFolder,
    required this.onQuickCreate,
  });

  static const _starters = [
    (
      name: 'This Week',
      cadence: GoalCadence.weekly,
      emoji: '📅',
      colorHex: '#E2603A',
    ),
    (
      name: 'This Month',
      cadence: GoalCadence.monthly,
      emoji: '🗓️',
      colorHex: '#3E7BC4',
    ),
    (
      name: 'This Weekend',
      cadence: GoalCadence.weekend,
      emoji: '🏖️',
      colorHex: '#4FA96A',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Center(
      child: SingleChildScrollView(
        padding: Space.h.t24,
        child: Container(
          padding: Space.a.t24,
          decoration: BoxDecoration(
            color: AppTheme.c.specBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.c.border, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.c.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 32)),
              ),
              Space.y.t16,
              Text(
                'No Goal Folders Yet',
                style: AppText.h2b.cl(AppTheme.c.text),
                textAlign: TextAlign.center,
              ),
              Space.y.t08,
              Text(
                'Create a Weekly, Monthly, or Weekend folder to organize and track your goals across time horizons.',
                style: AppText.b1.cl(AppTheme.c.subText),
                textAlign: TextAlign.center,
              ),
              Space.y.t20,
              AppButton(
                label: 'Create First Folder',
                icon: Icons.add_rounded,
                style: .primary,
                size: .medium,
                onTap: onAddFolder,
              ),
              Space.y.t20,
              Text(
                'OR QUICK START',
                style: AppText.l1b
                    .cl(AppTheme.c.subText)
                    .copyWith(letterSpacing: 1.1),
              ),
              Space.y.t12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final starter in _starters)
                    _QuickStarterChip(
                      label: '${starter.emoji} ${starter.name}',
                      color: HabitPalette.parse(starter.colorHex),
                      onTap: () => onQuickCreate(
                        starter.name,
                        starter.cadence,
                        starter.emoji,
                        starter.colorHex,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStarterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickStarterChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: Space.sym(12, 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Text(
          label,
          style: AppText.b2b.cl(AppTheme.c.text),
        ),
      ),
    );
  }
}
