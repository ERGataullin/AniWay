import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static const Breakpoint _breakpoint = Breakpoints.small;

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  static Size sizeFor(BuildContext context) {
    final Breakpoint? breakpoint = Breakpoint.activeBreakpointIn(
      context,
      const [_breakpoint],
    );
    return switch (breakpoint) {
      null => Size.zero,
      _breakpoint => Size.fromHeight(
        NavigationBarTheme.of(context).height ?? 80,
      ),
      _ =>
        throw UnsupportedError(
          'tried getting size for an unsupported breakpoint',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Easing.standard,
      duration: Durations.medium2,
      alignment: Alignment.bottomCenter,
      child: SlotLayout(
        config: {
          _breakpoint: SlotLayout.from(
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
