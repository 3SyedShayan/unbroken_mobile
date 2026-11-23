part of '../home.dart';

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  void _selectTab(int index) {
    if (_currentIndex == index && _visitedTabs.contains(index)) return;
    setState(() {
      _visitedTabs.add(index);
      _currentIndex = index;
    });
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              const _DashboardTab(),
              if (_visitedTabs.contains(1))
                const _GoalsTab()
              else
                const SizedBox.shrink(),
              if (_visitedTabs.contains(2))
                const _ProgressTab()
              else
                const SizedBox.shrink(),
              if (_visitedTabs.contains(3))
                const _SettingsTab()
              else
                const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: Space.v.t08,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Today',
                        isSelected: _currentIndex == 0,
                        onTap: () => _selectTab(0),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.track_changes_rounded,
                        label: 'Goals',
                        isSelected: _currentIndex == 1,
                        onTap: () => _selectTab(1),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.insights_rounded,
                        label: 'Progress',
                        isSelected: _currentIndex == 2,
                        onTap: () => _selectTab(2),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        isSelected: _currentIndex == 3,
                        onTap: () => _selectTab(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    App.init(context);
    final color = isSelected ? AppColors.accent : AppColors.subText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            Space.y.t04,
            Text(
              label,
              style: TextStyle(
                fontFamily: FontFamily.hanken,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
