import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/coach_mark.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/flame_check_button.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/mini_grid.dart';

class HabitRowCard extends StatelessWidget {
  final Habit habit;
  final bool isDone;
  final StreakStats stats;
  final List<bool> last14;
  final bool showCoachMark;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitRowCard({
    super.key,
    required this.habit,
    required this.isDone,
    required this.stats,
    required this.last14,
    this.showCoachMark = false,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: Space.a.t12,
            decoration: BoxDecoration(
              color: AppColors.specBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: habit.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      habit.emoji.isEmpty ? '🔥' : habit.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Space.x.t12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habit.name,
                        style: AppText.h3b.cl(AppColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Space.y.t04,
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                '${stats.current}',
                                style: AppText.b2b.cl(habit.color),
                              ),
                            ],
                          ),
                          Space.x.t08,
                          MiniGrid(color: habit.color, done: last14),
                        ],
                      ),
                    ],
                  ),
                ),
                Space.x.t08,
                FlameCheckButton(
                  color: habit.color,
                  isDone: isDone,
                  onToggle: onToggle,
                ),
              ],
            ),
          ),
        ),
        if (showCoachMark)
          const Positioned(
            right: 8,
            top: -34,
            child: IgnorePointer(
              child: CoachMark(text: 'Tap to log today 🔥'),
            ),
          ),
      ],
    );
  }
}

