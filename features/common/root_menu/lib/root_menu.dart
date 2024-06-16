import 'package:flutter/material.dart';

class RootMenu extends StatelessWidget {
  const RootMenu({
    super.key,
    this.currentIndex = 0,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
  });

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: destinations,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
