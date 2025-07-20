import 'package:plan_sync/controllers/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = Provider.of<AppThemeController>(context, listen: false);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: SalomonBottomBar(
          // itemPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          // Here, the items of BottomNavigationBar are hard coded. In a real
          // world scenario, the items would most likely be generated from the
          // branches of the shell route, which can be fetched using
          // `navigationShell.route.branches`.
          curve: Curves.easeInOutExpo,
          duration: Durations.medium2,
          selectedColorOpacity: 0.08,
          // // isFloating: true,
          // elevation: 0,
          itemShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: appTheme.isDarkMode
              ? colorScheme.surface
              : const Color(0xffafddb9),
          // borderRadius: const Radius.circular(8),
          selectedItemColor: appTheme.isDarkMode
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          unselectedItemColor: appTheme.isDarkMode
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant.withOpacity(0.64),
          // //bubble color
          // strokeColor: colorScheme.secondary.withOpacity(0.32),
          items: <SalomonBottomBarItem>[
            SalomonBottomBarItem(
              icon: const Icon(FontAwesomeIcons.calendar),
              title: Text(
                'Schedule',
                style: TextStyle(
                  color: appTheme.isDarkMode
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SalomonBottomBarItem(
              icon: const Icon(FontAwesomeIcons.clipboard),
              title: Text(
                'Electives',
                style: TextStyle(
                  color: appTheme.isDarkMode
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.navigation_outlined),
              title: Text(
                'Campus Nav',
                style: TextStyle(
                  color: appTheme.isDarkMode
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SalomonBottomBarItem(
                icon: const Icon(Icons.settings_outlined),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: appTheme.isDarkMode
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                )),
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (int index) => _onTap(context, index),
        ),
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
