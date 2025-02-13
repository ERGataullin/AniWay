import 'dart:math';

import 'package:app/movies/presentation/components/search_bar.dart';
import 'package:app/root_menu/components/bottom_navigation.dart';
import 'package:app/root_menu/components/primary_navigation.dart';
import 'package:app/root_menu/components/top_navigation.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart' hide Drawer;

enum _SlotId {
  body,
  primaryNavigation,
  topNavigation,
  bottomNavigation,
}

class RootMenuView extends StatelessWidget {
  const RootMenuView({
    super.key,
    this.currentIndex = 0,
    required this.onDestinationSelected,
    required this.destinations,
    this.query,
    required this.onSearch,
    required this.child,
  });

  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  final List<NavigationDestination> destinations;

  final String? query;

  final OnMoviesSearch onSearch;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomMultiChildLayout(
        delegate: _LayoutDelegate(),
        children: [
          LayoutId(
            id: _SlotId.body,
            child: Builder(
              builder: (context) => MediaQuery.removePadding(
                removeLeft: RootMenu.hasPrimaryNavigation(context),
                removeTop: RootMenu.hasTopNavigation(context),
                removeBottom: RootMenu.hasBottomNavigation(context),
                context: context,
                child: child,
              ),
            ),
          ),
          LayoutId(
            id: _SlotId.primaryNavigation,
            child: PrimaryNavigation(
              currentIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            ),
          ),
          LayoutId(
            id: _SlotId.topNavigation,
            child: TopNavigation(
              query: query,
              onSearch: onSearch,
            ),
          ),
          LayoutId(
            id: _SlotId.bottomNavigation,
            child: BottomNavigation(
              currentIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutDelegate extends MultiChildLayoutDelegate {
  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return false;
  }

  @override
  void performLayout(Size size) {
    final Size topNavigationSize = layoutChild(
      _SlotId.topNavigation,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height,
      ),
    );
    positionChild(_SlotId.topNavigation, Offset.zero);

    final Size bottomNavigationSize = layoutChild(
      _SlotId.bottomNavigation,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height - topNavigationSize.height,
      ),
    );
    positionChild(
      _SlotId.bottomNavigation,
      Offset(0, size.height - bottomNavigationSize.height),
    );

    final Size primaryNavigationSize = layoutChild(
      _SlotId.primaryNavigation,
      BoxConstraints(
        maxWidth: size.width,
        maxHeight: size.height -
            topNavigationSize.height -
            bottomNavigationSize.height,
      ),
    );
    positionChild(
      _SlotId.primaryNavigation,
      Offset(0, topNavigationSize.height),
    );

    final Size bodySize = layoutChild(
      _SlotId.body,
      BoxConstraints(
        maxWidth: size.width - primaryNavigationSize.width,
        maxHeight: size.height -
            topNavigationSize.height -
            bottomNavigationSize.height,
      ),
    );
    positionChild(
      _SlotId.body,
      Offset(
        max(primaryNavigationSize.width, (size.width - bodySize.width) / 2),
        topNavigationSize.height,
      ),
    );
  }
}
