import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class PrimaryNavigation extends StatelessWidget {
  const PrimaryNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Easing.standard,
      duration: Durations.medium2,
      alignment: Alignment.topLeft,
      child: SlotLayout(
        config: {
          Breakpoints.mediumAndUp: SlotLayout.from(
            key: const Key('Primary Navigation Medium and Up'),
            builder: (context) => SafeArea(
              right: false,
              child: AdaptiveScaffold.standardNavigationRail(
                labelType: null,
                padding: EdgeInsets.zero,
                width: 80,
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations
                    .map(AdaptiveScaffold.toRailDestination)
                    .toList(growable: false),
              ),
            ),
          ),
          Breakpoints.largeAndUp: SlotLayout.from(
            key: const Key('Primary Navigation Large and Up'),
            builder: (context) => SizedBox(
              width: 360,
              child: NavigationDrawer(
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                children: destinations
                    .map(
                      (destination) => NavigationDrawerDestination(
                        key: destination.key,
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                        label: Text(destination.label),
                        enabled: destination.enabled,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        },
      ),
    );
  }
}
