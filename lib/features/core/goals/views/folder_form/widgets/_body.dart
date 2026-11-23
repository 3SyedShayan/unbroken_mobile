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
    final previousLabel = _cadence.label;
    setState(() {
      _cadence = cadence;
      if (_nameController.text.trim().isEmpty ||
          _nameController.text.trim() == previousLabel) {
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

  void _archive() {
    if (widget.folder == null) return;
    GoalsCubit.c(context).archiveFolder(widget.folder!);
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.c.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete "${widget.folder?.name}"?',
          style: AppText.h3b.cl(AppTheme.c.text),
        ),
        content: Text(
          'This will delete the folder and all goals inside it. This action cannot be undone.',
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
              GoalsCubit.c(context).deleteFolder(widget.folder!.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: AppText.b1b.cl(AppTheme.c.error)),
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
      keyboardHandler: true,
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
                          ? _cadence.label
                          : _nameController.text,
                      emoji: _emoji,
                      cadence: _cadence,
                      color: activeColor,
                    ),
                    Space.y.t20,
                    Text(
                      'CADENCE',
                      style: AppText.l1b
                          .cl(AppTheme.c.subText)
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
                          .cl(AppTheme.c.subText)
                          .copyWith(letterSpacing: 1.2),
                    ),
                    Space.y.t08,
                    Container(
                      padding: Space.sym(16, 12),
                      decoration: BoxDecoration(
                        color: AppTheme.c.specBackground,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.c.border, width: 1.2),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: AppText.b1b.cl(AppTheme.c.text),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. This Week, November Goals, Weekend Sprint',
                          hintStyle: AppText.b1.cl(AppTheme.c.subText),
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
                          .cl(AppTheme.c.subText)
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
                          .cl(AppTheme.c.subText)
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
                        label: 'Archive Folder',
                        style: .creamy,
                        size: .medium,
                        onTap: _archive,
                      ),
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
