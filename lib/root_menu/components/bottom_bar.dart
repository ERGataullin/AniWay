import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static double getHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 80;
  }

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold.standardBottomNavigationBar(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    );
  }
}
