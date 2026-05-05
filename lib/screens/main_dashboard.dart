import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'home/home_screen.dart';
import 'feed/feed_screen.dart';
import 'copilot/copilot_screen.dart';
import 'goals/goals_screen.dart';
import 'profile/profile_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => MainDashboardState();

  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<MainDashboardState>()?.switchToTab(index);
  }
}

class MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    FeedScreen(),
    CopilotScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      _goToTab(index);
    }
  }

  void _goToTab(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: _AppleTabBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
      ),
    );
  }
}

class _AppleTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppleTabBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _TabItem(icon: Icons.house_outlined,    activeIcon: Icons.house_rounded,        label: 'Home'),
    _TabItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded,   label: 'Feed'),
    _TabItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome,     label: 'Perfin'),
    _TabItem(icon: Icons.flag_outlined,      activeIcon: Icons.flag_rounded,        label: 'Goals'),
    _TabItem(icon: Icons.person_outline,     activeIcon: Icons.person_rounded,      label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
            ),
            color: Color(0xF2F9F9F9),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SizedBox(
              height: 49,
              child: Row(
                children: List.generate(_items.length, (i) {
                  return _AppleTabItem(
                    item: _items[i],
                    isActive: currentIndex == i,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}

class _AppleTabItem extends StatelessWidget {
  final _TabItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _AppleTabItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  static const _activeColor  = Color(0xFF303E50);
  static const _inactiveColor = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _activeColor : _inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          label: item.label,
          selected: isActive,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                  letterSpacing: -0.2,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}