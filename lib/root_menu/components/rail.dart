import 'package:app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class Rail extends StatelessWidget {
  const Rail({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static double getWidth(BuildContext context) {
    return MediaQuery.paddingOf(context).left +
        80 // Меню
        +
        1; // Разделитель.
  }

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
