import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/domain/goal_period_helper.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';

class FolderBannerCard extends StatelessWidget {
  final GoalFolder folder;
  final ({int completed, int total}) progress;
  final DateTime today;
  final bool weekStartsMonday;
  final VoidCallback onEditFolder;
  final VoidCallback onArchiveFolder;

  const FolderBannerCard({
    super.key,
    required this.folder,
    required this.progress,
    required this.today,
    required this.weekStartsMonday,
    required this.onEditFolder,
    required this.onArchiveFolder,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = HabitPalette.parse(folder.colorHex);
    final ratio =
        progress.total > 0 ? progress.completed / progress.total : 0.0;
    final isComplete =
        progress.total > 0 && progress.completed == progress.total;
    final countdown = GoalPeriodHelper.cadenceCountdownLabel(
      folder.cadence,
      today,
      weekStartsMonday: weekStartsMonday,
    );

    return Container(
      padding: Space.sym(16, 12),
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.c.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                folder.emoji.isNotEmpty
                    ? folder.emoji
                    : folder.cadence.defaultEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              Space.x.t08,
              Expanded(
                child: Text(
                  folder.name,
                  style: AppText.h3b.cl(AppTheme.c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (countdown != null) ...[
                Space.x.t08,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.c.subBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    countdown,
                    style: AppText.l1b.cl(AppTheme.c.subText),
                  ),
                ),
              ],
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: AppTheme.c.subText,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: AppTheme.c.background,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEditFolder();
                  } else if (value == 'archive') {
                    onArchiveFolder();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Folder', style: AppText.b1.cl(AppTheme.c.text)),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text('Archive Folder', style: AppText.b1.cl(AppTheme.c.text)),
                  ),
                ],
              ),
            ],
          ),
          Space.y.t08,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: AppProps.medium,
              curve: Curves.easeOutCubic,
              tween: Tween<double>(end: ratio),
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: AppTheme.c.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppTheme.c.success : color,
                ),
              ),
            ),
          ),
          Space.y.t04,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(ratio * 100).round()}% Done',
                style: AppText.l1b.cl(isComplete ? AppTheme.c.success : color),
              ),
              Text(
                '${progress.completed} of ${progress.total} goals completed',
                style: AppText.l1.cl(AppTheme.c.subText),
              ),
            ],
          ),
          if (isComplete) ...[
            Space.y.t12,
            _CompletionBannerStrip(onArchive: onArchiveFolder),
          ],
        ],
      ),
    );
  }
}

class _CompletionBannerStrip extends StatelessWidget {
  final VoidCallback onArchive;

  const _CompletionBannerStrip({required this.onArchive});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: Space.sym(12, 8),
      decoration: BoxDecoration(
        color: AppTheme.c.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '🎉 All goals achieved!',
              style: AppText.b2b.cl(AppTheme.c.success),
            ),
          ),
          GestureDetector(
            onTap: onArchive,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.c.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Archive Sprint',
                style: AppText.l1b.cl(AppTheme.c.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
