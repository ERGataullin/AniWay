import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class RootMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: destinations,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}

class RootMenuContainer extends StatefulWidget {
  const RootMenuContainer({
    super.key,
    this.currentIndex = 0,
    required this.children,
  });

  final int currentIndex;

  final List<Widget> children;

  @override
  State<RootMenuContainer> createState() => _RootMenuContainerState();
}

class _RootMenuContainerState extends State<RootMenuContainer> {
  final CurveTween _animationCurveTween = CurveTween(
    curve: Curves.easeInOutCubicEmphasized,
  );

  final Map<Key, KeyedSubtree> _subtrees = {};

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: Durations.long2,
      layoutBuilder: _layoutBuilder,
      child: widget.children[widget.currentIndex],
      transitionBuilder: (child, animation, secondaryAnimation) =>
          FadeThroughTransition(
        animation: animation.drive(_animationCurveTween),
        secondaryAnimation: secondaryAnimation.drive(_animationCurveTween),
        child: child,
      ),
    );
  }

  Widget _layoutBuilder(List<Widget> entries) {
    for (final Widget entry in entries) {
      final subtree = entry as KeyedSubtree;
      final transition = subtree.child as FadeThroughTransition;
      final Key childKey = transition.child!.key!;
      _subtrees
        ..remove(childKey)
        ..[transition.child!.key!] = subtree;
    }

    return Stack(
      alignment: Alignment.center,
      children: _subtrees.values.toList(growable: false),
    );
  }
}
