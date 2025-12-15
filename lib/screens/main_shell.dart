import 'package:flutter/material.dart';
import 'customer_home_screen.dart';
import 'poin_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

const kPrimaryDark = Color(0xFF0097A7);
const kTextSecondary = Color(0xFF8E8E93);

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CustomerHomeScreen(),
    PoinScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, -2),
              color: Colors.black12,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryDark,
          unselectedItemColor: kTextSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            _item(Icons.home_outlined, Icons.home, "Home", 0),
            _item(Icons.stars_outlined, Icons.stars, "Poin", 1),
            _item(Icons.history_outlined, Icons.history, "Riwayat", 2),
            _item(Icons.person_outline, Icons.person, "Profil", 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _item(
      IconData icon,
      IconData activeIcon,
      String label,
      int index,
      ) {
    return BottomNavigationBarItem(
      icon: AnimatedNavIcon(icon: icon, active: _currentIndex == index),
      activeIcon:
          AnimatedNavIcon(icon: activeIcon, active: _currentIndex == index),
      label: label,
    );
  }
}

/// ================= ANIMATED ICON =================

class AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.15 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: active ? 1 : 0.7,
        duration: const Duration(milliseconds: 120),
        child: Icon(icon),
      ),
    );
  }
}
