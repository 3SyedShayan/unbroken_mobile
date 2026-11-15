part of '../form.dart';

class _Body extends StatefulWidget {
  final Habit? habit;

  const _Body({this.habit});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late TextEditingController _nameController;
  late String _emoji;
  late String _colorHex;

  static const _presetEmojis = [
    '🌱', '🏃', '📖', '🧘', '💧', '🌙',
    '🥗', '✍️', '🎸', '🧹', '💪', '☕',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _emoji = widget.habit?.emoji ?? '🌱';
    _colorHex = widget.habit?.colorHex ?? HabitPalette.defaultColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.habit != null;

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_isEdit) {
      final updated = widget.habit!.copyWith(
        name: name,
        emoji: _emoji,
        colorHex: _colorHex,
      );
      HabitsCubit.c(context).updateHabit(updated);
    } else {
      HabitsCubit.c(context).createHabit(
        name: name,
        emoji: _emoji,
        colorHex: _colorHex,
      );
    }
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete “${widget.habit?.name}”?', style: AppText.h3b.cl(AppColors.text)),
        content: Text(
          'This erases its streak history. This cannot be undone.',
          style: AppText.b1.cl(AppColors.subText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.b1.cl(AppColors.subText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HabitsCubit.c(context).deleteHabit(widget.habit!);
              Navigator.pop(context); // close form
            },
            child: Text('Delete', style: AppText.b1b.cl(AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final activeColor = HabitPalette.parse(_colorHex);

    return Screen(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCF6EC), Color(0xFFF5E7D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _FormHeader(
                title: _isEdit ? 'Edit habit' : 'New habit',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListView(
                  padding: Space.h.t20,
                  children: [
                    Space.y.t12,
                    _PreviewTile(
                      name: _nameController.text,
                      emoji: _emoji,
                      color: activeColor,
                    ),
                    Space.y.t20,
                    Text(
                      'NAME',
                      style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    Container(
                      padding: Space.sym(16, 12),
                      decoration: BoxDecoration(
                        color: AppColors.specBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.fieldBorder, width: 1.2),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: AppText.b1b.cl(AppColors.text),
                        decoration: InputDecoration(
                          hintText: 'e.g. Read 20 pages',
                          hintStyle: AppText.b1.cl(AppColors.hint),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Space.y.t20,
                    Text(
                      'ICON',
                      style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    _EmojiPickerGrid(
                      selected: _emoji,
                      emojis: _presetEmojis,
                      onSelected: (e) => setState(() => _emoji = e),
                    ),
                    Space.y.t20,
                    Text(
                      'COLOR',
                      style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    _ColorPickerRow(
                      selectedHex: _colorHex,
                      palette: HabitPalette.colors,
                      onSelected: (hex) => setState(() => _colorHex = hex),
                    ),
                    if (_isEdit) ...[
                      Space.y.t32,
                      Center(
                        child: TextButton(
                          onPressed: _confirmDelete,
                          child: Text(
                            'Delete habit',
                            style: AppText.b1b.cl(AppColors.error),
                          ),
                        ),
                      ),
                    ],
                    Space.y.t32,
                  ],
                ),
              ),
              Padding(
                padding: Space.sym(20, 16),
                child: AppButton(
                  label: _isEdit ? 'Save changes' : 'Add habit',
                  style: .primary,
                  size: .large,
                  mainAxisSize: MainAxisSize.max,
                  state: _nameController.text.trim().isEmpty ? .disabled : .def,
                  onTap: _nameController.text.trim().isEmpty ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _FormHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Padding(
      padding: Space.sym(16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.text,
          ),
          Space.x.t08,
          Text(title, style: AppText.h2b.cl(AppColors.text)),
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;

  const _PreviewTile({
    required this.name,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final displayName = name.trim().isEmpty ? 'Your habit' : name.trim();

    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                emoji.isEmpty ? '🔥' : emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          Space.x.t16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppText.h3b.cl(
                    name.trim().isEmpty ? AppColors.hint : AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Space.y.t04,
                Text(
                  'Daily · 0 day streak',
                  style: AppText.b2.cl(AppColors.subText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiPickerGrid extends StatelessWidget {
  final String selected;
  final List<String> emojis;
  final ValueChanged<String> onSelected;

  const _EmojiPickerGrid({
    required this.selected,
    required this.emojis,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Container(
      padding: Space.a.t12,
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (final e in emojis)
            GestureDetector(
              onTap: () => onSelected(e),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: selected == e
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: selected == e
                      ? Border.all(color: AppColors.accent, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final String selectedHex;
  final List<String> palette;
  final ValueChanged<String> onSelected;

  const _ColorPickerRow({
    required this.selectedHex,
    required this.palette,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Container(
      padding: Space.sym(16, 12),
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final hex in palette) ...[
            GestureDetector(
              onTap: () => onSelected(hex),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: HabitPalette.parse(hex),
                  shape: BoxShape.circle,
                  border: selectedHex == hex
                      ? Border.all(color: AppColors.text, width: 3)
                      : null,
                ),
                child: selectedHex == hex
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
