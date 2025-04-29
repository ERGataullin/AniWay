import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class PrimaryNavigation extends StatelessWidget {
  const PrimaryNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static const Breakpoint _railBreakpoint = Breakpoints.mediumAndUp;

  static const Breakpoint _drawerBreakpoint = Breakpoints.largeAndUp;

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  static Size sizeFor(BuildContext context) {
    final Breakpoint? breakpoint = Breakpoint.activeBreakpointIn(
      context,
      const [_railBreakpoint, _drawerBreakpoint],
    );
    return switch (breakpoint) {
      null => Size.zero,
      _railBreakpoint => Size.fromWidth(
        NavigationRailTheme.of(context).minWidth! +
            DividerTheme.of(context).thickness!,
      ),
      _drawerBreakpoint => Size.fromWidth(DrawerTheme.of(context).width!),
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
      alignment: Alignment.topLeft,
      child: SlotLayout(
        config: {
          _railBreakpoint: SlotLayout.from(
            key: const Key('Rail'),
            builder:
                (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SafeArea(
                      right: false,
                      child: AdaptiveScaffold.standardNavigationRail(
                        labelType: null,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        width: NavigationRailTheme.of(context).minWidth!,
                        selectedIndex: currentIndex,
                        onDestinationSelected: onDestinationSelected,
                        destinations: destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                label: Text(
                                  destination.label,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    SizedBox(
                      width: DividerTheme.of(context).thickness!,
                      child: const VerticalDivider(),
                    ),
                  ],
                ),
          ),
          _drawerBreakpoint: SlotLayout.from(
            key: const Key('Drawer'),
            builder:
                (context) => NavigationDrawer(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  children: [
                    const SizedBox(height: 16),
                    ...destinations.map(
                      (destination) => NavigationDrawerDestination(
                        key: destination.key,
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                        label: Text(destination.label),
                        enabled: destination.enabled,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
          ),
        },
      ),
    );
  }
}
