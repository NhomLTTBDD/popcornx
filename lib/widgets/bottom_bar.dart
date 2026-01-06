import 'package:flutter/material.dart';

/// Custom bottom navigation bar for streaming platform analytics.
/// Implements bottom-heavy interaction design for comfortable one-handed operation.
///
/// This widget is parameterized and reusable across different implementations.
/// Navigation logic should be handled by the parent widget through the onTap callback.
class BottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final Function(int) onTap;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
          unselectedLabelStyle:
              theme.bottomNavigationBarTheme.unselectedLabelStyle,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.movie_outlined, size: 24),
              activeIcon: const Icon(Icons.movie, size: 24),
              label: 'Movies',
              tooltip: 'Movie Performance Hub',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined, size: 24),
              activeIcon: const Icon(Icons.dashboard, size: 24),
              label: 'Dashboard',
              tooltip: 'Analytics Overview',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline, size: 24),
              activeIcon: const Icon(Icons.person, size: 24),
              label: 'Profile',
              tooltip: 'User Profile',
            ),
          ],
        ),
      ),
    );
  }
}
