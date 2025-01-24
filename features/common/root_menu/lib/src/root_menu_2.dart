import 'dart:math';

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

class _RootMenuState extends State<RootMenu>
    with SingleTickerProviderStateMixin {
  static const Breakpoint _bottomBarBreakpoint = Breakpoints.small;

  // TODO(Edgar): Заменить настоящим значением
  static const double _bottomBarHeight = 80;

  static const Breakpoint _railBreakpoint = Breakpoints.mediumAndUp;

  static const double _railWidth = 81;

  static const Breakpoint _drawerBreakpoint = Breakpoints.largeAndUp;

  static const double _drawerWidth = 305;

  static const _breakpoints = <Breakpoint>[
    _bottomBarBreakpoint,
    _railBreakpoint,
    _drawerBreakpoint,
  ];

  late final _animationController = AnimationController(vsync: this);

  EdgeInsets get _bodyViewInsets {
    final EdgeInsets mediaQueryPadding = MediaQuery.paddingOf(context);
    return <Breakpoint, EdgeInsets>{
      _bottomBarBreakpoint: mediaQueryPadding.copyWith(
        bottom: _bottomBarHeight + mediaQueryPadding.bottom,
      ),
      _railBreakpoint: mediaQueryPadding.copyWith(
        left: _railWidth + mediaQueryPadding.left,
      ),
      _drawerBreakpoint: mediaQueryPadding.copyWith(
        left: _drawerWidth + mediaQueryPadding.left,
      ),
    }[_breakpoint]!;
  }

  Breakpoint _breakpoint = Breakpoints.standard;

  @override
  void didChangeDependencies() {
    _breakpoint = Breakpoint.activeBreakpointIn(context, _breakpoints)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _BodyContainer(
            viewInsets: _bodyViewInsets,
            child: widget.child,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: {
                  _bottomBarBreakpoint:
                      AdaptiveScaffold.standardBottomNavigationBar(
                    currentIndex: widget.currentIndex,
                    onDestinationSelected: widget.onDestinationSelected,
                    destinations: widget.destinations,
                  ),
                }[_breakpoint] ??
                const SizedBox(width: double.infinity),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: <Breakpoint, WidgetBuilder>{
                  _railBreakpoint: (context) => _Rail(
                        currentIndex: widget.currentIndex,
                        onDestinationSelected: widget.onDestinationSelected,
                        destinations: widget.destinations,
                      ),
                  _drawerBreakpoint: (context) => _Drawer(
                        currentIndex: widget.currentIndex,
                        onDestinationSelected: widget.onDestinationSelected,
                        destinations: widget.destinations,
                      ),
                }[_breakpoint]
                    ?.call(context) ??
                const SizedBox(height: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _BodyContainer extends StatelessWidget {
  const _BodyContainer({
    required this.viewInsets,
    required this.child,
  });

  static const double _maxWidth = 1200;

  final EdgeInsets viewInsets;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double viewInsetsHorizontalWidthLimit =
        (mediaQuery.size.width - _maxWidth) / 2;
    final double viewInsetsPrimaryNavigation = viewInsets.left +
        max(
          mediaQuery.padding.left,
          mediaQuery.viewInsets.left,
        );
    final double viewInsetsLeft = max(
      viewInsetsPrimaryNavigation,
      viewInsetsHorizontalWidthLimit,
    );
    final double viewInsetsLeftOverwidth =
        viewInsetsLeft - viewInsetsHorizontalWidthLimit;
    final double viewInsetsRight = max(
      mediaQuery.viewInsets.right,
      viewInsetsHorizontalWidthLimit - viewInsetsLeftOverwidth,
    );
    final viewInsetsResult = EdgeInsets.fromLTRB(
      viewInsetsLeft,
      max(
        mediaQuery.viewInsets.top,
        viewInsets.top,
      ),
      viewInsetsRight,
      max(
        mediaQuery.viewInsets.bottom,
        viewInsets.bottom,
      ),
    );
    final paddingResult = EdgeInsets.fromLTRB(
      max(viewInsetsResult.left, mediaQuery.padding.left),
      max(viewInsetsResult.top, mediaQuery.padding.top),
      max(viewInsetsResult.right, mediaQuery.padding.right),
      max(viewInsetsResult.bottom, mediaQuery.padding.bottom),
    );

    return MediaQuery(
      data: mediaQuery.copyWith(
        viewInsets: viewInsetsResult,
        padding: paddingResult,
      ),
      child: child,
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: EdgeInsets.only(right: dividerTheme.thickness!),
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
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

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
