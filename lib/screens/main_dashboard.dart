import 'package:flutter/material.dart';
import 'dart:ui';
import 'home/home_screen.dart';
import 'feed/feed_screen.dart';
import 'copilot/copilot_screen.dart';
import 'goals/goals_screen.dart';
import 'profile/profile_screen.dart';

/// Main Dashboard with bottom navigation
/// Provides access to all main app tabs
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => MainDashboardState();

  /// Static method to switch tabs from anywhere in the widget tree
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

  /// Public method to switch tabs programmatically
  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      _goToTab(index);
    }
  }

  void _goToTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
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
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFFEFA).withValues(alpha: 0.82),
                    const Color(0xFFFFF9EC).withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D2430).withValues(alpha: 0.11),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFF1D2430).withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.view_carousel_outlined,
                        activeIcon: Icons.view_carousel_rounded,
                        label: 'Feed',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.chat_bubble_outline,
                        activeIcon: Icons.chat_bubble,
                        label: 'Perfin',
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.flag_outlined,
                        activeIcon: Icons.flag_rounded,
                        label: 'Goals',
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person_rounded,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          _goToTab(index);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2D4566).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Semantics(
            label: label,
            selected: isActive,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: isActive ? 38 : 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF263A56), Color(0xFF35527A)],
                      )
                    : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.24)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? Colors.white : const Color(0xFF858A93),
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
