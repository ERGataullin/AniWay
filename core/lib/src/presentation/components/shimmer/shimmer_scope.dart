import 'package:core/core.dart' show DynamicData;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShimmerScope extends StatefulWidget {
  const ShimmerScope({
    super.key,
    required this.linearGradient,
    required this.child,
  });

  static ShimmerScopeState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerScopeState>();
  }

  final LinearGradient linearGradient;

  final Widget child;

  @override
  ShimmerScopeState createState() => ShimmerScopeState();
}

class ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final DynamicData<LinearGradient> _gradient = DynamicData(
    trigger: _animationController,
    () => LinearGradient(
      colors: widget.linearGradient.colors,
      stops: widget.linearGradient.stops,
      begin: widget.linearGradient.begin,
      end: widget.linearGradient.end,
      transform: _SlidingGradientTransform(
        slidePercent: _animationController.value,
      ),
    ),
  );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject()! as RenderBox).size;

  ValueListenable<LinearGradient> get gradient => _gradient;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final RenderBox shimmerBox = context.findRenderObject()! as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this)
      ..repeat(
        min: -0.5,
        max: 1.5,
        period: Durations.extralong4,
      );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
