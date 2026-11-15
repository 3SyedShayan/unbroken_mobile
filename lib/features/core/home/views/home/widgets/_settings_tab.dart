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
                          icon: Icons.notifications_active_rounded,
                          title: 'Daily reminders',
                          subtitle: 'One nudge before the day ends, if a habit\'s still due',
                          value: settings.reminders,
                          onChanged: (val) {
                            SettingsCubit.c(context).toggleReminders(val);
                          },
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.divider),
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
                  Center(
                    child: Column(
                      children: [
                        Text('Unbroken Mobile v1.0.0', style: AppText.b2.cl(AppColors.inkFaint)),
                        Space.y.t04,
                        Text('MIT License · Keep the streak going 🔥',
                            style: AppText.l1.cl(AppColors.inkMuted)),
                      ],
                    ),
                  ),
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
