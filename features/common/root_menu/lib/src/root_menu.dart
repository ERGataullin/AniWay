import 'package:core/core.dart';
import 'package:flutter/material.dart';

class RootMenu extends StatelessWidget {
  const RootMenu({
    super.key,
    this.currentIndex = 0,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
  });

  static const Curve _menuAnimationCurveIn = Easing.standardDecelerate;

  static const Curve _menuAnimationCurveOut = Easing.standardAccelerate;

  static const Duration _menuAnimationDurationIn = Durations.medium1;

  static const Duration _menuAnimationDurationOut = Durations.short4;

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveLayout(
        transitionDuration: _menuAnimationDurationIn,
        body: SlotLayout(
          config: {
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key('Body Small and Up'),
              builder: (context) => MediaQuery.removePadding(
                removeLeft: true,
                context: context,
                child: child,
              ),
            ),
          },
        ),
        bottomNavigation: SlotLayout(
          config: {
            Breakpoints.small: SlotLayout.from(
              key: const Key('Bottom Navigation Small'),
              inCurve: _menuAnimationCurveIn,
              outCurve: _menuAnimationCurveOut,
              inDuration: _menuAnimationDurationIn,
              outDuration: _menuAnimationDurationOut,
              builder: (context) =>
                  AdaptiveScaffold.standardBottomNavigationBar(
                currentIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations,
              ),
            ),
          },
        ),
        primaryNavigation: SlotLayout(
          config: {
            Breakpoints.mediumAndUp: SlotLayout.from(
              key: const Key('Primary Navigation Medium and Up'),
              inCurve: _menuAnimationCurveIn,
              outCurve: _menuAnimationCurveOut,
              inDuration: _menuAnimationDurationIn,
              outDuration: _menuAnimationDurationOut,
              builder: (context) => DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 0,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: SafeArea(
                  right: false,
                  child: AdaptiveScaffold.standardNavigationRail(
                    labelType: null,
                    leading: const Logo.short(),
                    selectedIndex: currentIndex,
                    onDestinationSelected: onDestinationSelected,
                    destinations: destinations
                        .map(AdaptiveScaffold.toRailDestination)
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
            Breakpoints.largeAndUp: SlotLayout.from(
              key: const Key('Primary Navigation Large and Up'),
              inCurve: _menuAnimationCurveIn,
              outCurve: _menuAnimationCurveOut,
              inDuration: _menuAnimationDurationIn,
              outDuration: _menuAnimationDurationOut,
              builder: (context) => NavigationDrawer(
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12 + 16),
                    child: Logo(),
                  ),
                  ...destinations.map(
                    (destination) => NavigationDrawerDestination(
                      key: destination.key,
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: Text(destination.label),
                      enabled: destination.enabled,
                    ),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}
