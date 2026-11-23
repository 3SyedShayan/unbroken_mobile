import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/core/goals/models/goal_folder.dart';

class FolderCarousel extends StatelessWidget {
  final List<GoalFolder> folders;
  final String? selectedId;
  final ({int completed, int total}) Function(String folderId) progressOf;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddFolder;
  final ValueChanged<GoalFolder> onEditFolder;

  const FolderCarousel({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.progressOf,
    required this.onSelect,
    required this.onAddFolder,
    required this.onEditFolder,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return SizedBox(
      height: 82,
      child: ListView.separated(
        padding: Space.h.t20,
        scrollDirection: Axis.horizontal,
        itemCount: folders.length + 1,
        separatorBuilder: (_, _) => Space.x.t12,
        itemBuilder: (context, index) {
          if (index == folders.length) {
            return _NewFolderTile(onTap: onAddFolder);
          }

          final folder = folders[index];
          return _FolderCarouselCard(
            folder: folder,
            isSelected: folder.id == selectedId,
            progress: progressOf(folder.id),
            onTap: () => onSelect(folder.id),
            onLongPress: () => onEditFolder(folder),
          );
        },
      ),
    );
  }
}

class _NewFolderTile extends StatelessWidget {
  final VoidCallback onTap;

  const _NewFolderTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.c.specBackground.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.c.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 22, color: AppTheme.c.subText),
            Space.y.t04,
            Text('New', style: AppText.l1b.cl(AppTheme.c.subText)),
          ],
        ),
      ),
    );
  }
}

class _FolderCarouselCard extends StatelessWidget {
  final GoalFolder folder;
  final bool isSelected;
  final ({int completed, int total}) progress;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FolderCarouselCard({
    required this.folder,
    required this.isSelected,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = HabitPalette.parse(folder.colorHex);
    final isComplete =
        progress.total > 0 && progress.completed == progress.total;
    final ratio =
        progress.total > 0 ? progress.completed / progress.total : 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppProps.fast,
        curve: Curves.easeOutCubic,
        width: 174,
        padding: Space.sym(12, 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.c.specBackground
              : AppTheme.c.specBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppTheme.c.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    folder.emoji.isNotEmpty
                        ? folder.emoji
                        : folder.cadence.defaultEmoji,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Space.x.t08,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: AppText.b2b.cl(AppTheme.c.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                folder.cadence.label.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.l1b
                                    .cl(color)
                                    .copyWith(fontSize: 8.5, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isComplete
                                ? '✓ ${progress.completed}/${progress.total}'
                                : '${progress.completed}/${progress.total}',
                            style: AppText.l1b.cl(
                              isComplete
                                  ? AppTheme.c.success
                                  : AppTheme.c.subText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 3,
                backgroundColor: AppTheme.c.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppTheme.c.success : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
