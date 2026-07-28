import 'package:app/l10n/l10n.dart';
import 'package:app/movies/presentation/components/search_bar.dart';
import 'package:app/root_menu/components/bottom_navigation.dart';
import 'package:app/root_menu/components/primary_navigation.dart';
import 'package:app/root_menu/components/top_navigation.dart';
import 'package:app/root_menu/destination.dart';
import 'package:app/root_menu/root_menu.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
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
    final List<CustomNavigationDestination> navigationDestinations =
        _buildDestinations(context);
    return RootMenuScope(
      primaryNavigationKey: _primaryKey,
      topNavigationKey: _topKey,
      bottomNavigationKey: _bottomKey,
      child: Builder(
        builder: (context) {
          final Size topSize = TopNavigation.sizeFor(context);
          final Size bottomSize = BottomNavigation.sizeFor(context);
          return Scaffold(
            appBar:
                topSize.isEmpty
                    ? null
                    : PreferredSize(
                      preferredSize: topSize,
                      child: TopNavigation(
                        key: _topKey,
                        padding: PrimaryNavigation.topNavigationPaddingFor(
                          context,
                        ),
                        query: widget.query,
                        onSearch: widget.onSearch,
                      ),
                    ),
            bottomNavigationBar:
                BottomNavigation.sizeFor(context).isEmpty
                    ? null
                    : BottomNavigation(
                      key: _bottomKey,
                      currentIndex: widget.currentIndex,
                      onDestinationSelected: widget.onDestinationSelected,
                      destinations: navigationDestinations,
                    ),
            body: Builder(
              builder: (context) {
                final MediaQueryData mediaQuery = MediaQuery.of(context);
                final Size primarySize = PrimaryNavigation.sizeFor(context);
                final EdgeInsets bodyPadding = mediaQuery.padding.copyWith(
                  left: primarySize.isEmpty ? null : 0,
                  top: topSize.isEmpty ? null : 0,
                  bottom: bottomSize.isEmpty ? null : 0,
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MediaQuery(
                      data: mediaQuery.copyWith(
                        padding: mediaQuery.padding.copyWith(
                          top: bodyPadding.top,
                          right: 0,
                          bottom: bodyPadding.bottom,
                        ),
                      ),
                      child: PrimaryNavigation(
                        key: _primaryKey,
                        currentIndex: widget.currentIndex,
                        onDestinationSelected: widget.onDestinationSelected,
                        destinations: navigationDestinations,
                      ),
                    ),
                    Expanded(
                      child: MediaQuery(
                        data: mediaQuery.copyWith(padding: bodyPadding),
                        child: widget.child,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<CustomNavigationDestination> _buildDestinations(BuildContext context) {
    return widget.destinations
        .map(
          (destination) => switch (destination) {
            RootMenuDestination.home => CustomNavigationDestination(
              label: context.l10n.homePageTitle,
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
            ),
            RootMenuDestination.library => CustomNavigationDestination(
              label: context.l10n.libraryTitle,
              icon: const Icon(Icons.video_library_outlined),
              selectedIcon: const Icon(Icons.video_library),
            ),
            RootMenuDestination.search => CustomNavigationDestination(
              label: context.l10n.searchPageTitle,
              icon: const Icon(Icons.search_outlined),
              selectedIcon: const Icon(Icons.search),
            ),
          },
        )
        .toList(growable: false);
  }
}
