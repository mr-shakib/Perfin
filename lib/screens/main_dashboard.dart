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

  final List<Widget> _screens = const [
    HomeScreen(),
    FeedScreen(),
    CopilotScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  /// Public method to switch tabs programmatically
  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allow body to extend behind bottom nav
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF0).withValues(alpha: 0.4),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE5E5E5).withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.view_carousel_outlined,
                      activeIcon: Icons.view_carousel,
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
                      activeIcon: Icons.flag,
                      label: 'Goals',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
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

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background for active state
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive 
                      ? const Color(0xFF1A1A1A) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive 
                      ? Colors.white 
                      : const Color(0xFF999999),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive 
                      ? const Color(0xFF1A1A1A) 
                      : const Color(0xFF999999),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
