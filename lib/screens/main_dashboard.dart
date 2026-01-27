import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'insights/insights_screen.dart';
import 'copilot/copilot_screen.dart';

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
    InsightsScreen(),
    CopilotScreen(),
    Placeholder(), // Goals - Coming soon
    Placeholder(), // Profile - Coming soon
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A1A1A),
        unselectedItemColor: const Color(0xFF999999),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Perfin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
