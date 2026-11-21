part of '../folder_form.dart';

class _Body extends StatefulWidget {
  final GoalFolder? folder;

  const _Body({this.folder});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late TextEditingController _nameController;
  late GoalCadence _cadence;
  late String _emoji;
  late String _colorHex;

  static const _presetEmojis = [
    '📅', '🗓️', '🏖️', '🎯', '🚀', '💡',
    '🏆', '⭐', '🔥', '📚', '💼', '🧘',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.folder;
    _nameController = TextEditingController(text: f?.name ?? '');
    _cadence = f?.cadence ?? GoalCadence.weekly;
    _emoji = f?.emoji ?? _cadence.defaultEmoji;
    _colorHex = f?.colorHex ?? HabitPalette.defaultColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.folder != null;

  void _onCadenceSelected(GoalCadence cadence) {
    setState(() {
      _cadence = cadence;
      if (_nameController.text.trim().isEmpty ||
          _nameController.text == _cadence.label) {
        _nameController.text = cadence.label;
      }
      _emoji = cadence.defaultEmoji;
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_isEdit) {
      final updated = widget.folder!.copyWith(
        name: name,
        cadence: _cadence,
        emoji: _emoji,
        colorHex: _colorHex,
      );
      GoalsCubit.c(context).updateFolder(updated);
    } else {
      GoalsCubit.c(context).createFolder(
        name: name,
        cadence: _cadence,
        emoji: _emoji,
        colorHex: _colorHex,
      );
    }
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete "${widget.folder?.name}"?',
          style: AppText.h3b.cl(AppColors.text),
        ),
        content: Text(
          'This will delete the folder and all goals inside it. This action cannot be undone.',
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
              GoalsCubit.c(context).deleteFolder(widget.folder!.id);
              Navigator.pop(context);
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
                title: _isEdit ? 'Edit Folder' : 'New Goal Folder',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListView(
                  padding: Space.h.t20,
                  children: [
                    Space.y.t12,
                    _PreviewTile(
                      name: _nameController.text.isEmpty
                          ? (_cadence.label)
                          : _nameController.text,
                      emoji: _emoji,
                      cadence: _cadence,
                      color: activeColor,
                    ),
                    Space.y.t20,
                    Text(
                      'CADENCE',
                      style: AppText.l1b
                          .cl(AppColors.inkFaint)
                          .copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    _CadenceSelector(
                      selected: _cadence,
                      onSelected: _onCadenceSelected,
                    ),
                    Space.y.t20,
                    Text(
                      'FOLDER NAME',
                      style: AppText.l1b
                          .cl(AppColors.inkFaint)
                          .copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    Container(
                      padding: Space.sym(16, 12),
                      decoration: BoxDecoration(
                        color: AppColors.specBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.fieldBorder, width: 1.2),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: AppText.b1b.cl(AppColors.text),
                        decoration: InputDecoration(
                          hintText: 'e.g. This Week, November Goals, Weekend Sprint',
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
                      style: AppText.l1b
                          .cl(AppColors.inkFaint)
                          .copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    _EmojiPicker(
                      selected: _emoji,
                      emojis: _presetEmojis,
                      onSelected: (e) => setState(() => _emoji = e),
                    ),
                    Space.y.t20,
                    Text(
                      'ACCENT COLOR',
                      style: AppText.l1b
                          .cl(AppColors.inkFaint)
                          .copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    _ColorPicker(
                      selected: _colorHex,
                      palette: HabitPalette.colors,
                      onSelected: (c) => setState(() => _colorHex = c),
                    ),
                    Space.y.t32,
                    AppButton(
                      label: _isEdit ? 'Save Changes' : 'Create Folder',
                      style: .primary,
                      size: .large,
                      onTap: _submit,
                    ),
                    if (_isEdit) ...[
                      Space.y.t12,
                      AppButton(
                        label: 'Delete Folder',
                        style: .error,
                        size: .medium,
                        onTap: _confirmDelete,
                      ),
                    ],
                    Space.y.t32,
                  ],
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
    return Padding(
      padding: Space.sym(20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppColors.text),
            ),
          ),
          Space.x.t12,
          Text(title, style: AppText.h2b.cl(AppColors.text)),
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
    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppColors.specBackground,
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
                  style: AppText.h3b.cl(AppColors.text),
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
                    style: TextStyle(
                      fontFamily: FontFamily.hanken,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.8,
                    ),
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
    return Row(
      children: GoalCadence.values.map((cadence) {
        final isSelected = cadence == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelected(cadence),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.specBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.fieldBorder,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  cadence.label,
                  style: TextStyle(
                    fontFamily: FontFamily.hanken,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.text,
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: emojis.map((emoji) {
        final isSelected = emoji == selected;
        return GestureDetector(
          onTap: () => onSelected(emoji),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.specBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.fieldBorder,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: palette.map((hex) {
        final isSelected = hex == selected;
        final color = HabitPalette.parse(hex);
        return GestureDetector(
          onTap: () => onSelected(hex),
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
                      )
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
