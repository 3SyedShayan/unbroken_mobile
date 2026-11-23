import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';
import 'package:unbroken_mobile/shared/widgets/design/modals/app_modal_base.dart';

Future<void> showArchivedFoldersSheet(
  BuildContext context, {
  required List<GoalFolder> folders,
  required ({int completed, int total}) Function(String folderId) progressOf,
  required ValueChanged<GoalFolder> onRestore,
  required ValueChanged<GoalFolder> onDelete,
}) {
  return showAppModalSheet<void>(
    context,
    builder: (_) => ArchivedFoldersSheet(
      folders: folders,
      progressOf: progressOf,
      onRestore: onRestore,
      onDelete: onDelete,
    ),
  );
}

class ArchivedFoldersSheet extends StatelessWidget {
  final List<GoalFolder> folders;
  final ({int completed, int total}) Function(String folderId) progressOf;
  final ValueChanged<GoalFolder> onRestore;
  final ValueChanged<GoalFolder> onDelete;

  const ArchivedFoldersSheet({
    super.key,
    required this.folders,
    required this.progressOf,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return AppModalBase(
      icon: Icon(Icons.inventory_2_outlined, color: AppTheme.c.subText),
      title: 'Archived Folders',
      subtitle: 'Completed sprints kept for your Progress stats',
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < folders.length; i++) ...[
            if (i > 0) Space.y.t08,
            _ArchivedFolderRow(
              folder: folders[i],
              progress: progressOf(folders[i].id),
              onRestore: () {
                Navigator.pop(context);
                onRestore(folders[i]);
              },
              onDelete: () => _confirmDelete(context, folders[i]),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, GoalFolder folder) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.c.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete "${folder.name}"?',
          style: AppText.h3b.cl(AppTheme.c.text),
        ),
        content: Text(
          'This permanently removes the folder and its goals from Progress stats.',
          style: AppText.b1.cl(AppTheme.c.subText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.b1.cl(AppTheme.c.subText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              onDelete(folder);
            },
            child: Text('Delete', style: AppText.b1b.cl(AppTheme.c.error)),
          ),
        ],
      ),
    );
  }
}

class _ArchivedFolderRow extends StatelessWidget {
  final GoalFolder folder;
  final ({int completed, int total}) progress;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchivedFolderRow({
    required this.folder,
    required this.progress,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final emoji =
        folder.emoji.isNotEmpty ? folder.emoji : folder.cadence.defaultEmoji;

    return Container(
      padding: Space.sym(12, 10),
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.c.border, width: 1),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          Space.x.t12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: AppText.b1b.cl(AppTheme.c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${folder.cadence.label} · ${progress.completed}/${progress.total} done',
                  style: AppText.l1.cl(AppTheme.c.subText),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRestore,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.c.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Restore', style: AppText.l1b.cl(AppTheme.c.accent)),
            ),
          ),
          Space.x.t04,
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppTheme.c.error,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
