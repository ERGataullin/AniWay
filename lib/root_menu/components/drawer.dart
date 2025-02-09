import 'package:app/core/core.dart';
import 'package:flutter/material.dart';

class Drawer extends StatelessWidget {
  const Drawer({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static double getWidth(BuildContext context) {
    return MediaQuery.paddingOf(context).left +
        304 // Меню
        +
        1; // Тень
  }

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        const Padding(
          padding: EdgeInsets.all(12 + 16),
          child: Logo(enableRedirect: true),
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
    );
  }
}
