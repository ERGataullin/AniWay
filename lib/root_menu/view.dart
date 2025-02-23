import 'dart:math';

import 'package:app/l10n/l10n.dart';
import 'package:app/movies/presentation/components/search_bar.dart';
import 'package:app/root_menu/components/bottom_navigation.dart';
import 'package:app/root_menu/components/primary_navigation.dart';
import 'package:app/root_menu/components/top_navigation.dart';
import 'package:app/root_menu/destination.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:flutter/material.dart';

/// Главное меню.
///
/// Адаптируется к размерам доступного пространства.
class RootMenuView extends StatefulWidget {
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

  final List<RootMenuDestination> destinations;

  final String? query;

  final OnMoviesSearch onSearch;

  final Widget child;

  @override
  State<RootMenuView> createState() => _RootMenuViewState();
}

class _RootMenuViewState extends State<RootMenuView> {
  final GlobalKey _primaryKey = GlobalKey();

  final GlobalKey _topKey = GlobalKey();

  final GlobalKey _bottomKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final List<NavigationDestination> navigationDestinations =
        _buildDestinations(context);
    return Scaffold(
      body: RootMenuScope(
        primaryNavigationKey: _primaryKey,
        topNavigationKey: _topKey,
        bottomNavigationKey: _bottomKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopNavigation(
              key: _topKey,
              query: widget.query,
              onSearch: widget.onSearch,
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryNavigation(
                    key: _primaryKey,
                    currentIndex: widget.currentIndex,
                    onDestinationSelected: widget.onDestinationSelected,
                    destinations: navigationDestinations,
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final MediaQueryData mediaQuery = MediaQuery.of(
                          context,
                        );
                        final Size topSize = TopNavigation.sizeFor(context);
                        final Size primarySize = PrimaryNavigation.sizeFor(
                          context,
                        );
                        final Size bottomSize = BottomNavigation.sizeFor(
                          context,
                        );
                        return MediaQuery(
                          data: mediaQuery.copyWith(
                            padding: mediaQuery.padding.copyWith(
                              left: max(
                                0,
                                mediaQuery.padding.left - primarySize.width,
                              ),
                              top: max(
                                0,
                                mediaQuery.padding.top - topSize.height,
                              ),
                              bottom: max(
                                0,
                                mediaQuery.padding.bottom - bottomSize.height,
                              ),
                            ),
                          ),
                          child: widget.child,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigation(
              key: _bottomKey,
              currentIndex: widget.currentIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: navigationDestinations,
            ),
          ],
        ),
      ),
    );
  }

  List<NavigationDestination> _buildDestinations(BuildContext context) {
    return widget.destinations
        .map(
          (destination) => switch (destination) {
            RootMenuDestination.home => NavigationDestination(
              label: context.l10n.homePageTitle,
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
            ),
            RootMenuDestination.search => NavigationDestination(
              label: context.l10n.searchPageTitle,
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
            ),
          },
        )
        .toList(growable: false);
  }
}
