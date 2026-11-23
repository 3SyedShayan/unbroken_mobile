part of '../home.dart';

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;

        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final settings = settingsState.settings;

            return SafeArea(
              child: ListView(
                padding: Space.h.t20,
                children: [
                  Space.y.t16,
                  Text('Settings', style: AppText.h1b.cl(AppColors.text)),
                  Space.y.t16,
                  _AccountCard(
                    userEmail: user?.email,
                    displayName: user?.displayName,
                    photoUrl: user?.photoUrl,
                    syncState: authState.syncState,
                    onSignOut: () async {
                      await AuthCubit.c(context).signOut();
                      if (context.mounted) {
                        AppRoutes.login.pushReplace(context);
                      }
                    },
                  ),
                  Space.y.t20,
                  Text(
                    'DAY TIMING',
                    style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                  ),
                  Space.y.t12,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.specBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        _DayEndHourTile(
                          dayEndHour: settings.dayEndHour,
                          onChanged: (hour) {
                            SettingsCubit.c(context).setDayEndHour(hour, user?.uid);
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.divider),
                        _AtRiskWindowTile(
                          atRiskHours: settings.atRiskWindowHours,
                          onChanged: (hours) {
                            SettingsCubit.c(context).setAtRiskWindowHours(hours, user?.uid);
                          },
                        ),
                      ],
                    ),
                  ),
                  Space.y.t08,
                  Padding(
                    padding: Space.h.t08,
                    child: Text(
                      _dayExplanation(settings.dayEndHour),
                      style: AppText.l1.cl(AppColors.inkMuted),
                    ),
                  ),
                  Space.y.t20,
                  Text(
                    'NOTIFICATIONS',
                    style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                  ),
                  Space.y.t12,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.specBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        _NotificationTimeTile(
                          icon: Icons.wb_sunny_rounded,
                          title: 'Morning task reminder',
                          subtitle: 'Nudge to plan your 3 daily focus tasks',
                          enabled: settings.morningReminderEnabled,
                          timeString: settings.morningReminderTime,
                          onToggle: (val) async {
                            if (val) {
                              final granted = await LocalNotificationService.ins.requestPermissions();
                              if (!granted && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enable notifications in system settings to receive reminders.'),
                                  ),
                                );
                              }
                            }
                            if (context.mounted) {
                              SettingsCubit.c(context).toggleMorningReminder(val);
                            }
                          },
                          onTimeChanged: (newTime) {
                            SettingsCubit.c(context).setMorningReminderTime(newTime);
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.divider),
                        _NotificationTimeTile(
                          icon: Icons.nightlight_round,
                          title: 'Night goal reminder',
                          subtitle: 'Review and complete remaining habits before day end',
                          enabled: settings.nightReminderEnabled,
                          timeString: settings.nightReminderTime,
                          onToggle: (val) async {
                            if (val) {
                              final granted = await LocalNotificationService.ins.requestPermissions();
                              if (!granted && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enable notifications in system settings to receive reminders.'),
                                  ),
                                );
                              }
                            }
                            if (context.mounted) {
                              SettingsCubit.c(context).toggleNightReminder(val);
                            }
                          },
                          onTimeChanged: (newTime) {
                            SettingsCubit.c(context).setNightReminderTime(newTime);
                          },
                        ),
                      ],
                    ),
                  ),
                  Space.y.t20,
                  Text(
                    'PREFERENCES',
                    style: AppText.l1b.cl(AppColors.inkFaint).copyWith(letterSpacing: 1.2),
                  ),
                  Space.y.t12,
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.specBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        _ToggleTile(
                          icon: Icons.volume_up_rounded,
                          title: 'Streak sounds & haptics',
                          subtitle: 'Play a little spark and vibration on check-in',
                          value: settings.streakSounds,
                          onChanged: (val) {
                            SettingsCubit.c(context).toggleStreakSounds(val);
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.divider),
                        _ToggleTile(
                          icon: Icons.calendar_month_rounded,
                          title: 'Week starts Monday',
                          subtitle: 'Otherwise weeks start on Sunday',
                          value: settings.weekStartMonday,
                          onChanged: (val) {
                            final uid = user?.uid;
                            SettingsCubit.c(context).toggleWeekStartMonday(val, uid);
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.divider),
                        _ToggleTile(
                          icon: Icons.vertical_align_bottom_rounded,
                          title: 'Sink completed habits',
                          subtitle: 'Move completed habits to the bottom so pending habits stay on top',
                          value: settings.sinkCompletedHabits,
                          onChanged: (val) {
                            SettingsCubit.c(context).toggleSinkCompletedHabits(val);
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.divider),
                        _ToggleTile(
                          icon: Icons.replay_rounded,
                          title: 'Roll over unfinished tasks',
                          subtitle: 'Carry yesterday\'s unfinished focus tasks forward to today',
                          value: settings.rolloverTasks,
                          onChanged: (val) {
                            SettingsCubit.c(context).toggleRolloverTasks(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  Space.y.t24,
                  const Center(child: _AppVersionFooter()),
                  Space.y.t24,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String? userEmail;
  final String? displayName;
  final String? photoUrl;
  final SyncState syncState;
  final VoidCallback onSignOut;

  const _AccountCard({
    required this.userEmail,
    required this.displayName,
    required this.photoUrl,
    required this.syncState,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Container(
      padding: Space.a.t16,
      decoration: BoxDecoration(
        color: AppColors.specBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? const Icon(Icons.person, color: AppColors.accent, size: 20)
                : null,
          ),
          Space.x.t12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userEmail ?? displayName ?? 'Google Account',
                  style: AppText.b1b.cl(AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Space.y.t04,
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: syncState == SyncState.synced
                            ? AppColors.success
                            : (syncState == SyncState.connecting
                                ? AppColors.warning
                                : AppColors.hint),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Space.x.t04,
                    Text(
                      syncState.label,
                      style: AppText.b2.cl(AppColors.subText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSignOut,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: Space.sym(12, 6),
            ),
            child: Text('Sign out', style: AppText.b2b.cl(AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Padding(
      padding: Space.sym(16, 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.accent),
          Space.x.t16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.b1b.cl(AppColors.text)),
                Space.y.t04,
                Text(subtitle, style: AppText.b2.cl(AppColors.subText)),
              ],
            ),
          ),
          Space.x.t12,
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

String _dayExplanation(int hour) {
  final h = hour % 12;
  final display = h == 0 ? 12 : h;
  final suffix = hour < 12 ? 'AM' : 'PM';
  final hourLabel = '$display:00 $suffix';
  return "A check-in after midnight still counts for the day before. With the day ending at $hourLabel, a 12:30 AM note counts toward yesterday — so a late night doesn't break your streak.";
}

class _DayEndHourTile extends StatelessWidget {
  final int dayEndHour;
  final ValueChanged<int> onChanged;

  const _DayEndHourTile({
    required this.dayEndHour,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Padding(
      padding: Space.sym(16, 10),
      child: Row(
        children: [
          const Icon(Icons.nightlight_round, size: 22, color: AppColors.accent),
          Space.x.t16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day ends at', style: AppText.b1b.cl(AppColors.text)),
                Space.y.t04,
                Text(
                  'When one logical day rolls into the next',
                  style: AppText.b2.cl(AppColors.subText),
                ),
              ],
            ),
          ),
          Space.x.t08,
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: (dayEndHour >= 0 && dayEndHour <= 6) ? dayEndHour : 3,
              dropdownColor: AppColors.specBackground,
              borderRadius: BorderRadius.circular(12),
              style: AppText.b1b.cl(AppColors.text),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.subText, size: 18),
              items: List.generate(7, (i) {
                final display = i == 0 ? 12 : i;
                final label = '$display:00 AM';
                return DropdownMenuItem<int>(
                  value: i,
                  child: Text(label, style: AppText.b1b.cl(AppColors.text)),
                );
              }),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AtRiskWindowTile extends StatelessWidget {
  final int atRiskHours;
  final ValueChanged<int> onChanged;

  const _AtRiskWindowTile({
    required this.atRiskHours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Padding(
      padding: Space.sym(16, 10),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom_rounded, size: 22, color: AppColors.accent),
          Space.x.t16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('At-risk window', style: AppText.b1b.cl(AppColors.text)),
                Space.y.t04,
                Text(
                  'How early warnings start before day ends',
                  style: AppText.b2.cl(AppColors.subText),
                ),
              ],
            ),
          ),
          Space.x.t08,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.remove_circle_outline,
                  size: 20,
                  color: atRiskHours > 1 ? AppColors.accent : AppColors.hint,
                ),
                onPressed: atRiskHours > 1 ? () => onChanged(atRiskHours - 1) : null,
              ),
              Space.x.t04,
              Text(
                '$atRiskHours ${atRiskHours == 1 ? "hour" : "hours"}',
                style: AppText.b1b.cl(AppColors.text),
              ),
              Space.x.t04,
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: atRiskHours < 8 ? AppColors.accent : AppColors.hint,
                ),
                onPressed: atRiskHours < 8 ? () => onChanged(atRiskHours + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatTimeString(String timeStr) {
  final parts = timeStr.split(':');
  if (parts.length != 2) return timeStr;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final h = hour % 12;
  final displayHour = h == 0 ? 12 : h;
  final displayMinute = minute.toString().padLeft(2, '0');
  final suffix = hour < 12 ? 'AM' : 'PM';
  return '$displayHour:$displayMinute $suffix';
}

TimeOfDay _parseTimeOfDay(String timeStr) {
  final parts = timeStr.split(':');
  if (parts.length != 2) return const TimeOfDay(hour: 9, minute: 0);
  final hour = int.tryParse(parts[0]) ?? 9;
  final minute = int.tryParse(parts[1]) ?? 0;
  return TimeOfDay(hour: hour, minute: minute);
}

class _NotificationTimeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final String timeString;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onTimeChanged;

  const _NotificationTimeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.timeString,
    required this.onToggle,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);

    return Padding(
      padding: Space.sym(16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.accent),
              Space.x.t16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.b1b.cl(AppColors.text)),
                    Space.y.t04,
                    Text(subtitle, style: AppText.b2.cl(AppColors.subText)),
                  ],
                ),
              ),
              Space.x.t12,
              Switch.adaptive(
                value: enabled,
                activeTrackColor: AppColors.accent,
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...[
            Space.y.t08,
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final initial = _parseTimeOfDay(timeString);
                  final selected = await showTimePicker(
                    context: context,
                    initialTime: initial,
                    builder: (pickerContext, child) {
                      return Theme(
                        data: Theme.of(pickerContext).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.accent,
                            onPrimary: Colors.white,
                            surface: AppColors.specBackground,
                            onSurface: AppColors.text,
                          ),
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: AppColors.specBackground,
                            hourMinuteColor: AppColors.emptyCell,
                            hourMinuteTextColor: AppColors.text,
                            dayPeriodColor: AppColors.emptyCell,
                            dayPeriodTextColor: AppColors.text,
                            dialBackgroundColor: AppColors.emptyCell,
                            dialHandColor: AppColors.accent,
                            dialTextColor: AppColors.text,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                  );
                  if (selected != null) {
                    final h = selected.hour.toString().padLeft(2, '0');
                    final m = selected.minute.toString().padLeft(2, '0');
                    onTimeChanged('$h:$m');
                  }
                },
                child: Container(
                  padding: Space.sym(12, 6),
                  decoration: BoxDecoration(
                    color: AppColors.emptyCell,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.accent),
                      Space.x.t08,
                      Text(
                        _formatTimeString(timeString),
                        style: AppText.b2b.cl(AppColors.text),
                      ),
                      Space.x.t04,
                      const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.subText),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppVersionFooter extends StatefulWidget {
  const _AppVersionFooter();

  @override
  State<_AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<_AppVersionFooter> {
  String _versionLabel = 'Unbroken Mobile';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      final version = info.version.trim();
      final build = info.buildNumber.trim();
      if (version.isNotEmpty) {
        setState(() {
          _versionLabel = build.isNotEmpty
              ? 'Unbroken Mobile v$version+$build'
              : 'Unbroken Mobile v$version';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Column(
      children: [
        Text(_versionLabel, style: AppText.b2.cl(AppColors.inkFaint)),
        Space.y.t04,
        Text(
          'MIT License · Keep the streak going 🔥',
          style: AppText.l1.cl(AppColors.inkMuted),
        ),
      ],
    );
  }
}
