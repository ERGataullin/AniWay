import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static const Breakpoint breakpoint = Breakpoints.small;

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Easing.standard,
      duration: Durations.medium2,
      alignment: Alignment.bottomCenter,
      child: SlotLayout(
        config: {
          breakpoint: SlotLayout.from(
            key: const Key('Bottom Navigation Small'),
            builder:
                (context) => AdaptiveScaffold.standardBottomNavigationBar(
                  currentIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: destinations,
                ),
          ),
        },
      ),
    );
  }
}
