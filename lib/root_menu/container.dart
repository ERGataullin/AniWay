import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

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
  final _animationCurveTween = CurveTween(
    curve: Curves.easeInOutCubicEmphasized,
  );

  final Map<Key, KeyedSubtree> _subtrees = {};

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: Durations.long2,
      layoutBuilder: _layoutBuilder,
      child: widget.children[widget.currentIndex],
      transitionBuilder:
          (child, animation, secondaryAnimation) => FadeThroughTransition(
            animation: animation.drive(_animationCurveTween),
            secondaryAnimation: secondaryAnimation.drive(_animationCurveTween),
            child: child,
          ),
    );
  }

  Widget _layoutBuilder(List<Widget> entries) {
    for (final entry in entries) {
      final subtree = entry as KeyedSubtree;
      final transition = subtree.child as FadeThroughTransition;
      final Key childKey = transition.child!.key!;
      _subtrees
        ..remove(childKey)
        ..[childKey] = subtree;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: _subtrees.values.toList(growable: false),
    );
  }
}
