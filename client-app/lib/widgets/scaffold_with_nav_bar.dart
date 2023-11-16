import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/util/colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: CustomNavigationBar(
          // Here, the items of BottomNavigationBar are hard coded. In a real
          // world scenario, the items would most likely be generated from the
          // branches of the shell route, which can be fetched using
          // `navigationShell.route.branches`.
          scaleCurve: Curves.easeInOutExpo,
          isFloating: true,
          elevation: 0,
          backgroundColor: black,
          borderRadius: const Radius.circular(32),
          selectedColor: primary,
          unSelectedColor: white,

          //bubble color
          strokeColor: secondary.withOpacity(0.32),
          items: <CustomNavigationBarItem>[
            CustomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.calendar),
                title: const Text(
                  'Schedule',
                  style: TextStyle(color: white),
                )),
            CustomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.clipboard),
                title: const Text(
                  'Electives',
                  style: TextStyle(color: white),
                )),
            CustomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                title: const Text(
                  'Settings',
                  style: TextStyle(color: white),
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
