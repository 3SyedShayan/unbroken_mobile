import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/habits/models/habit.dart';
import 'package:unbroken_mobile/features/core/habits/models/streak_stats.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/coach_mark.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/flame_check_button.dart';
import 'package:unbroken_mobile/features/core/habits/widgets/mini_grid.dart';

class HabitRowCard extends StatefulWidget {
  final Habit habit;
  final bool isDone;
  final StreakStats stats;
  final List<bool> recentDays;
  final bool showCoachMark;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitRowCard({
    super.key,
    required this.habit,
    required this.isDone,
    required this.stats,
    required this.recentDays,
    this.showCoachMark = false,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<HabitRowCard> createState() => _HabitRowCardState();
}

class _HabitRowCardState extends State<HabitRowCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : 1.0,
            duration: AppProps.quick,
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: AppProps.fast,
              curve: Curves.easeInOut,
              padding: Space.a.t12,
              decoration: BoxDecoration(
                color: widget.isDone
                    ? AppColors.specBackground.withValues(alpha: 0.7)
                    : AppColors.specBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDone
                      ? AppColors.border.withValues(alpha: 0.6)
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: AppProps.fast,
                    curve: Curves.easeInOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.habit.color.withValues(
                        alpha: widget.isDone ? 0.08 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.emoji.isEmpty ? '🔥' : widget.habit.emoji,
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
                        AnimatedDefaultTextStyle(
                          duration: AppProps.fast,
                          curve: Curves.easeInOut,
                          style: AppText.h3b.cl(
                            widget.isDone ? AppColors.subText : AppColors.text,
                          ),
                          child: Text(
                            widget.habit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Space.y.t04,
                        Row(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 2),
                                AnimatedSwitcher(
                                  duration: AppProps.fast,
                                  transitionBuilder: (child, animation) => ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutBack,
                                    ),
                                    child: child,
                                  ),
                                  child: Text(
                                    '${widget.stats.current}',
                                    key: ValueKey(widget.stats.current),
                                    style: AppText.b2b.cl(widget.habit.color),
                                  ),
                                ),
                              ],
                            ),
                            Space.x.t08,
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: MiniGrid(
                                  color: widget.habit.color,
                                  done: widget.recentDays,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Space.x.t08,
                  FlameCheckButton(
                    color: widget.habit.color,
                    isDone: widget.isDone,
                    onToggle: widget.onToggle,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showCoachMark)
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

