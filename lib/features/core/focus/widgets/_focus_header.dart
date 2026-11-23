part of 'focus_list_card.dart';

class _FocusHeader extends StatelessWidget {
  final int streak;
  final bool cleared;
  final String statusLine;
  final int done;
  final int total;
  final bool showPullFromGoals;
  final VoidCallback? onPullFromGoals;

  const _FocusHeader({
    required this.streak,
    required this.cleared,
    required this.statusLine,
    required this.done,
    required this.total,
    required this.showPullFromGoals,
    required this.onPullFromGoals,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final ratio = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Daily Tasks', style: AppText.h3b.cl(AppTheme.c.text)),
            ),
            if (showPullFromGoals && onPullFromGoals != null) ...[
              GestureDetector(
                onTap: onPullFromGoals,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.c.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        size: 13,
                        color: AppTheme.c.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'From Goals',
                        style: AppText.l1b.cl(AppTheme.c.accent),
                      ),
                    ],
                  ),
                ),
              ),
              if (streak > 0) Space.x.t08,
            ],
            if (streak > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  Space.x.t04,
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
                      '$streak',
                      key: ValueKey(streak),
                      style: AppText.h3b.cl(
                        cleared ? AppTheme.c.accent : AppTheme.c.subText,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        Space.y.t04,
        AppAnimatedText(
          text: statusLine,
          style: AppText.b2.cl(
            cleared ? AppTheme.c.accent : AppTheme.c.subText,
          ),
        ),
        if (total > 0) ...[
          Space.y.t08,
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              duration: AppProps.medium,
              curve: Curves.easeOutCubic,
              tween: Tween<double>(end: ratio),
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 3,
                backgroundColor: AppTheme.c.emptyCell,
                valueColor: AlwaysStoppedAnimation<Color>(
                  cleared ? AppTheme.c.success : AppTheme.c.accent,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
