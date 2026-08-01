import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

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

  final List<CustomNavigationDestination> destinations;

  static Size sizeFor(BuildContext context) {
    final Breakpoint? breakpoint = Breakpoint.activeBreakpointIn(
      context,
      const [_breakpoint],
    );
    return switch (breakpoint) {
      null => .zero,
      _breakpoint => .fromHeight(
        CustomNavigationBarTheme.of(context).height ?? 80,
      ),
      _ => throw UnsupportedError(
        'tried getting size for an unsupported breakpoint',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Easing.standard,
      duration: Durations.medium2,
      alignment: .bottomCenter,
      child: SlotLayout(
        config: {
          _breakpoint: SlotLayout.from(
            key: const .new('Bottom Navigation Small'),
            builder: (context) => AdaptiveScaffold.standardBottomNavigationBar(
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
