part of '../folder_form.dart';

class _FormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _FormHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Padding(
      padding: Space.sym(20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.c.text,
              ),
            ),
          ),
          Space.x.t12,
          Text(title, style: AppText.h2b.cl(AppTheme.c.text)),
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String name;
  final String emoji;
  final GoalCadence cadence;
  final Color color;

  const _PreviewTile({
    required this.name,
    required this.emoji,
    required this.cadence,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppTheme.c.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          Space.x.t12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Folder Name' : name,
                  style: AppText.h3b.cl(AppTheme.c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Space.y.t04,
                Container(
                  padding: Space.sym(8, 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cadence.label.toUpperCase(),
                    style: AppText.l1b
                        .cl(color)
                        .copyWith(fontSize: 10, letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CadenceSelector extends StatelessWidget {
  final GoalCadence selected;
  final ValueChanged<GoalCadence> onSelected;

  const _CadenceSelector({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      children: GoalCadence.values.map((cadence) {
        final isSelected = cadence == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelected(cadence),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppProps.fast,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.c.accent
                      : AppTheme.c.specBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.c.accent : AppTheme.c.border,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  cadence.label,
                  style: AppText.b2.cl(
                    isSelected ? AppTheme.c.onAccent : AppTheme.c.text,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final String selected;
  final List<String> emojis;
  final ValueChanged<String> onSelected;

  const _EmojiPicker({
    required this.selected,
    required this.emojis,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: emojis.map((emoji) {
        final isSelected = emoji == selected;
        return GestureDetector(
          onTap: () => onSelected(emoji),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: AppProps.fast,
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isSelected ? AppTheme.c.specBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.c.accent : AppTheme.c.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String selected;
  final List<String> palette;
  final ValueChanged<String> onSelected;

  const _ColorPicker({
    required this.selected,
    required this.palette,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: palette.map((hex) {
        final isSelected = hex == selected;
        final color = HabitPalette.parse(hex);
        return GestureDetector(
          onTap: () => onSelected(hex),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
