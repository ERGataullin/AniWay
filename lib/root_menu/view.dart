import 'dart:math';

import 'package:app/root_menu/components/bottom_bar.dart';
import 'package:app/root_menu/components/drawer.dart';
import 'package:app/root_menu/components/rail.dart';
import 'package:flutter/material.dart' hide Drawer;
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

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
  static const Breakpoint _bottomBarBreakpoint = Breakpoints.small;

  static const Breakpoint _railBreakpoint = Breakpoints.mediumAndUp;

  static const Breakpoint _drawerBreakpoint = Breakpoints.largeAndUp;

  Breakpoint _breakpoint = Breakpoints.standard;

  EdgeInsets get _bodyPadding {
    final EdgeInsets mediaQueryPadding = MediaQuery.paddingOf(context);
    return <Breakpoint, EdgeInsets>{
      _bottomBarBreakpoint: mediaQueryPadding.copyWith(
        bottom: BottomBar.getHeight(context),
      ),
      _railBreakpoint: mediaQueryPadding.copyWith(
        left: Rail.getWidth(context),
      ),
      _drawerBreakpoint: mediaQueryPadding.copyWith(
        left: Drawer.getWidth(context),
      ),
    }[_breakpoint]!;
  }

  @override
  void didChangeDependencies() {
    _breakpoint = Breakpoint.activeBreakpointIn(
      context,
      [
        _bottomBarBreakpoint,
        _railBreakpoint,
        _drawerBreakpoint,
      ],
    )!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _BodyContainer(
            padding: _bodyPadding,
            child: widget.child,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: {
                  _bottomBarBreakpoint: BottomBar(
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
                  _railBreakpoint: (context) => Rail(
                        currentIndex: widget.currentIndex,
                        onDestinationSelected: widget.onDestinationSelected,
                        destinations: widget.destinations,
                      ),
                  _drawerBreakpoint: (context) => Drawer(
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
    required this.padding,
    required this.child,
  });

  static const double _maxWidth = 1200;

  final EdgeInsets padding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    // Левый и правый отступы для ограничения ширины.
    final double paddingHorizontalWidthLimit =
        (mediaQuery.size.width - _maxWidth) / 2;
    // Левый отступ под основное навигационное меню.
    final double paddingPrimaryNavigation = padding.left;
    // Левый отступ для ограничения ширины и под основное навигационное меню.
    final double paddingLeft = max(
      paddingPrimaryNavigation,
      paddingHorizontalWidthLimit,
    );
    // Насколько левый отступ превзошёл отступ для ограничения ширины
    // (если основное меню шире).
    final double paddingLeftOverwidth =
        paddingLeft - paddingHorizontalWidthLimit;
    // Правый отступ для ограничения ширины, учитывающий итоговый левый отступ.
    final double paddingRight = max(
      paddingHorizontalWidthLimit - paddingLeftOverwidth,
      mediaQuery.padding.right,
    );
    final paddingResult = EdgeInsets.fromLTRB(
      max(paddingLeft, mediaQuery.padding.left),
      max(padding.top, mediaQuery.padding.top),
      max(paddingRight, mediaQuery.padding.right),
      max(padding.bottom, mediaQuery.padding.bottom),
    );

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: paddingResult,
      ),
      child: child,
    );
  }
}
