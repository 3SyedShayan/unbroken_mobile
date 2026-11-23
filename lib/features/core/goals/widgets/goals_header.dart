import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/animations/animated_text.dart';

class GoalsHeader extends StatelessWidget {
  final ({int completed, int total}) overall;
  final int activeFolderCount;
  final int archivedCount;
  final VoidCallback onAddFolder;
  final VoidCallback onOpenArchived;

  const GoalsHeader({
    super.key,
    required this.overall,
    required this.activeFolderCount,
    required this.archivedCount,
    required this.onAddFolder,
    required this.onOpenArchived,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final folderLabel =
        activeFolderCount == 1 ? '1 folder' : '$activeFolderCount folders';
    final subtitle = overall.total > 0
        ? '${overall.completed} of ${overall.total} completed · $folderLabel'
        : (activeFolderCount > 0
            ? '$folderLabel ready for goals'
            : 'Time-horizon target folders');

    return Padding(
      padding: Space.sym(20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goals', style: AppText.h1b.cl(AppTheme.c.text)),
                Space.y.t04,
                AppAnimatedText(
                  text: subtitle,
                  style: AppText.b2.cl(AppTheme.c.subText),
                ),
              ],
            ),
          ),
          Space.x.t12,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (archivedCount > 0) ...[
                _ArchivedIconButton(
                  count: archivedCount,
                  onTap: onOpenArchived,
                ),
                Space.x.t08,
              ],
              GestureDetector(
                onTap: onAddFolder,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: Space.sym(12, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.c.specBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.c.border, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.create_new_folder_outlined,
                        size: 18,
                        color: AppTheme.c.accent,
                      ),
                      Space.x.t08,
                      Text(
                        '+ Folder',
                        style: AppText.b2b.cl(AppTheme.c.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchivedIconButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ArchivedIconButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: Space.sym(10, 8),
        decoration: BoxDecoration(
          color: AppTheme.c.specBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.c.border, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: AppTheme.c.subText,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppText.l1b.cl(AppTheme.c.subText),
            ),
          ],
        ),
      ),
    );
  }
}
