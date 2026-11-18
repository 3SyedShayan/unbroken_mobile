part of '../onboarding.dart';

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AppProps.medium,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding({bool enableReminders = false}) async {
    final uid = AuthCubit.c(context).state.user?.uid;
    await SettingsCubit.c(context).completeOnboarding(
      enableReminders: enableReminders,
      uid: uid,
    );
    if (!mounted) return;
    AppRoutes.home.pushReplace(context);
  }

  @override
  Widget build(BuildContext context) {
    App.init(context);

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
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _WelcomeSlide(onNext: _nextPage),
              _PickHabitSlide(
                onPicked: (starter) {
                  HabitsCubit.c(context).createHabit(
                    name: starter.name,
                    emoji: starter.emoji,
                    colorHex: starter.colorHex,
                  );
                  _nextPage();
                },
                onMakeOwn: () async {
                  await Navigator.pushNamed(context, AppRoutes.habitForm);
                  if (context.mounted) {
                    _nextPage();
                  }
                },
              ),
              _RulesSlide(onNext: _nextPage),
              _RemindersSlide(
                onEnable: () => _finishOnboarding(enableReminders: true),
                onSkip: () => _finishOnboarding(enableReminders: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Slide 0: Welcome ──────────────────────────────────────────────────────────

class _WelcomeSlide extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomeSlide({required this.onNext});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Padding(
      padding: Space.h.t24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const FlameHero(size: 80),
          Space.y.t24,
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppText.heroStat.copyWith(
                fontSize: 34,
                color: AppColors.text,
                height: 1.15,
              ),
              children: const [
                TextSpan(text: 'Keep the streak\n'),
                TextSpan(
                  text: 'unbroken.',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          Space.y.t16,
          Text(
            'Pick one small thing. Do it today. Then keep the flame going — one day at a time.',
            style: AppText.b1.cl(AppColors.subText),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AppButton(
            label: 'Start my first streak',
            style: .primary,
            size: .large,
            mainAxisSize: MainAxisSize.max,
            onTap: onNext,
          ),
          Space.y.t20,
        ],
      ),
    );
  }
}

// ── Slide 1: Pick Starter Habit ──────────────────────────────────────────────

class _StarterHabit {
  final String name;
  final String emoji;
  final String colorHex;
  const _StarterHabit(this.name, this.emoji, this.colorHex);
}

const _starters = [
  _StarterHabit('Read 20 pages', '📖', '#3E7BC4'),
  _StarterHabit('Move your body', '🏃', '#E0A32E'),
  _StarterHabit('Meditate', '🧘', '#2FA39A'),
  _StarterHabit('Drink water', '💧', '#3E7BC4'),
];

class _PickHabitSlide extends StatelessWidget {
  final ValueChanged<_StarterHabit> onPicked;
  final VoidCallback onMakeOwn;

  const _PickHabitSlide({
    required this.onPicked,
    required this.onMakeOwn,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Padding(
      padding: Space.h.t24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space.y.t24,
          const FlameHero(size: 44),
          Space.y.t12,
          Text('Pick your first streak', style: AppText.h1b.cl(AppColors.text)),
          Space.y.t08,
          Text(
            'Start with one small thing you can do today. You can add more later.',
            style: AppText.b1.cl(AppColors.subText),
          ),
          Space.y.t24,
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                for (final starter in _starters)
                  _StarterCard(
                    starter: starter,
                    onTap: () => onPicked(starter),
                  ),
              ],
            ),
          ),
          Space.y.t12,
          Center(
            child: TextButton(
              onPressed: onMakeOwn,
              child: Text(
                'Or create your own habit...',
                style: AppText.b1b.cl(AppColors.accent),
              ),
            ),
          ),
          Space.y.t16,
        ],
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  final _StarterHabit starter;
  final VoidCallback onTap;

  const _StarterCard({required this.starter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = HabitPalette.parse(starter.colorHex);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: Space.a.t16,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(starter.emoji, style: const TextStyle(fontSize: 32)),
            Space.y.t12,
            Text(
              starter.name,
              style: AppText.b1b.cl(AppColors.text),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide 2: Rules ───────────────────────────────────────────────────────────

class _RulesSlide extends StatelessWidget {
  final VoidCallback onNext;

  const _RulesSlide({required this.onNext});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Padding(
      padding: Space.h.t24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space.y.t24,
          const FlameHero(size: 44),
          Space.y.t12,
          Text('How streaks work', style: AppText.h1b.cl(AppColors.text)),
          Space.y.t08,
          Text(
            'Unbroken keeps you honest, with two mercies to keep it kind.',
            style: AppText.b1.cl(AppColors.subText),
          ),
          Space.y.t24,
          Expanded(
            child: ListView(
              children: const [
                _RuleCard(
                  icon: Icons.local_fire_department,
                  title: 'Strict daily check-ins',
                  detail:
                      'Check in every day and your streak grows. Miss a day and it resets to zero.',
                ),
                SizedBox(height: 12),
                _RuleCard(
                  icon: Icons.nightlight_round,
                  title: 'Two mercies',
                  detail:
                      'The day doesn\'t end until 3 AM — so a late night still counts. And you can always back-fill yesterday if you forgot.',
                ),
                SizedBox(height: 12),
                _RuleCard(
                  icon: Icons.cloud_done,
                  title: 'Synced & offline ready',
                  detail:
                      'Your data syncs seamlessly across devices, but Unbroken continues to run completely offline anytime.',
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Got it — let\'s go 🔥',
            style: .primary,
            size: .large,
            mainAxisSize: MainAxisSize.max,
            onTap: onNext,
          ),
          Space.y.t20,
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _RuleCard({
    required this.icon,
    required this.title,
    required this.detail,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          Space.x.t12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.b1b.cl(AppColors.text)),
                Space.y.t04,
                Text(detail, style: AppText.b2.cl(AppColors.subText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 3: Reminders ────────────────────────────────────────────────────────

class _RemindersSlide extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const _RemindersSlide({required this.onEnable, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return Padding(
      padding: Space.h.t24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Text('🔔', style: TextStyle(fontSize: 64)),
          Space.y.t24,
          Text('One nudge a day', style: AppText.h1b.cl(AppColors.text)),
          Space.y.t12,
          Text(
            'Around 8 PM, we\'ll send one gentle reminder to check in before the day ends — but only if you still have a habit left to do. No pressure, no spam.',
            style: AppText.b1.cl(AppColors.subText),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AppButton(
            label: 'Turn on reminders',
            style: .primary,
            size: .large,
            mainAxisSize: MainAxisSize.max,
            onTap: onEnable,
          ),
          Space.y.t12,
          TextButton(
            onPressed: onSkip,
            child: Text('Maybe later', style: AppText.b1.cl(AppColors.inkMuted)),
          ),
          Space.y.t20,
        ],
      ),
    );
  }
}
