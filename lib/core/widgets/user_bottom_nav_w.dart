import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';
import 'package:wordoflifemobile/screens/user/bible_screen.dart';
import 'package:wordoflifemobile/screens/user/feed_screen.dart';
import 'package:wordoflifemobile/screens/user/home_screen.dart';
import 'package:wordoflifemobile/screens/user/journal_screen.dart';
import 'package:wordoflifemobile/screens/user/profile_screen.dart';

import 'package:wordoflifemobile/core/widgets/curved_navigation_bar.dart';

class UserBottomNavW extends StatefulWidget {
  const UserBottomNavW({super.key});

  @override
  State<UserBottomNavW> createState() => _UserBottomNavWState();
}

class _UserBottomNavWState extends State<UserBottomNavW> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    FeedScreen(),
    BibleScreen(),
    JournalScreen(),
    ProfileScreen(),
  ];

  static const List<_NavItem> _items = [
    _NavItem(
      icon: PhosphorIconsBold.house,
      selectedIcon: PhosphorIconsFill.house,
      label: 'Home',
    ),
    _NavItem(
      icon: PhosphorIconsBold.newspaper,
      selectedIcon: PhosphorIconsFill.newspaper,
      label: 'Feed',
    ),
    _NavItem(
      icon: PhosphorIconsBold.book,
      selectedIcon: PhosphorIconsFill.book,
      label: 'Bible',
    ),
    _NavItem(
      icon: PhosphorIconsBold.note,
      selectedIcon: PhosphorIconsFill.note,
      label: 'Journal',
    ),
    _NavItem(
      icon: PhosphorIconsBold.user,
      selectedIcon: PhosphorIconsFill.user,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.blueAccent.withValues(alpha: 0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: AppColors.navy600,
            color: Colors.white,
            height: 55,
            animationDuration: const Duration(milliseconds: 300),
            animationCurve: Curves.easeInOut,
            index: _selectedIndex,
            items: _items.map((item) {
              final index = _items.indexOf(item);
              final isSelected = index == _selectedIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? Colors.white : AppColors.neutral500,
                      size: 24,
                    ),
                    if (!isSelected) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}