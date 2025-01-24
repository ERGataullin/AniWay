import 'package:core/core.dart';
import 'package:flutter/material.dart';

class RootMenu extends StatefulWidget {
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
  State<RootMenu> createState() => _RootMenuState();
}

class _RootMenuState extends State<RootMenu> {
  static const Curve _animationCurve = Easing.standard;

  static const Duration _animationDuration = Durations.medium2;

  final GlobalKey<void> _primaryAnimationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      internalAnimations: true,
      transitionDuration: _animationDuration,
      body: SlotLayout(
        config: {
          Breakpoints.standard: SlotLayout.from(
            key: const Key('Body Standard'),
            inCurve: _animationCurve,
            inDuration: _animationDuration,
            inAnimation: AdaptiveScaffold.leftOutIn,
            outAnimation: AdaptiveScaffold.leftInOut,
            builder: (context) => widget.child,
          ),
        },
      ),
      bottomNavigation: SlotLayout(
        config: {
          Breakpoints.small: SlotLayout.from(
            key: const Key('Bottom Navigation Small'),
            inCurve: _animationCurve,
            inDuration: _animationDuration,
            inAnimation: AdaptiveScaffold.bottomToTop,
            outAnimation: AdaptiveScaffold.topToBottom,
            builder: (context) => AdaptiveScaffold.standardBottomNavigationBar(
              currentIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: widget.destinations,
            ),
          ),
        },
      ),
      primaryNavigation: SlotLayout(
        config: {
          // Breakpoints.standard: SlotLayout.from(
          //   key: const Key('Primary Navigation'),
          //   // inCurve: _animationCurve,
          //   // inDuration: _animationDuration,
          //   // inAnimation: AdaptiveScaffold.leftOutIn,
          //   // outAnimation: AdaptiveScaffold.leftInOut,
          //   builder: (context) => _Rail(
          //     animationKey: _primaryAnimationKey,
          //     hidden: true,
          //     currentIndex: widget.currentIndex,
          //     onDestinationSelected: widget.onDestinationSelected,
          //     destinations: widget.destinations,
          //   ),
          // ),
          Breakpoints.mediumAndUp: SlotLayout.from(
            key: const Key('Primary Navigation'),
            inCurve: _animationCurve,
            inDuration: _animationDuration,
            inAnimation: AdaptiveScaffold.leftOutIn,
            outAnimation: AdaptiveScaffold.leftInOut,
            builder: (context) => _Rail(
              animationKey: _primaryAnimationKey,
              currentIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: widget.destinations,
            ),
          ),
          Breakpoints.largeAndUp: SlotLayout.from(
            key: const Key('Primary Navigation'),
            builder: (context) => _Drawer(
              animationKey: _primaryAnimationKey,
              currentIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: widget.destinations,
            ),
          ),
        },
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.animationKey,
    this.hidden = false,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final Key animationKey;

  final bool hidden;

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final Breakpoint breakpoint = Breakpoint.activeBreakpointOf(context);
    final DividerThemeData dividerTheme = DividerTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NavigationRailTheme.of(context).backgroundColor!,
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(
              width: dividerTheme.thickness!,
              color: dividerTheme.color!,
            ),
          ),
        ),
        child: ConditionalWrapper(
          condition: hidden,
          wrapper: (context, child) => SizedOverflowBox(
            alignment: Alignment.topRight,
            size: const Size.fromWidth(0),
            child: child,
          ),
          child: SafeArea(
            right: false,
            child: AdaptiveScaffold.standardNavigationRail(
              labelType: null,
              padding: EdgeInsets.zero,
              width: 80,
              selectedIndex: currentIndex,
              leading: const Logo.short(enableRedirect: true),
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map(AdaptiveScaffold.toRailDestination)
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({
    required this.animationKey,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final Key animationKey;

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final NavigationDrawerThemeData theme = NavigationDrawerTheme.of(context);
    return AnimatedSize(
      key: animationKey,
      alignment: Alignment.topLeft,
      curve: _RootMenuState._animationCurve,
      duration: _RootMenuState._animationDuration,
      child: Padding(
        padding: EdgeInsets.only(
          right: theme.elevation!,
        ),
        child: NavigationDrawer(
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
        ),
      ),
    );
  }
}
