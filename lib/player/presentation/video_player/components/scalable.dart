import 'dart:math' as math;

import 'package:flutter/material.dart';

class Scalable extends StatefulWidget {
  const Scalable({
    super.key,
    this.minScale = 1,
    this.maxScale = double.infinity,
    this.anchors = const [],
    required this.child,
  });

  final double minScale;

  final double maxScale;

  final List<double> anchors;

  final Widget child;

  @override
  State<Scalable> createState() => _ScalableState();
}

class _ScalableState extends State<Scalable> {
  final ValueNotifier<double> _scale = ValueNotifier(1);

  late double _submittedScale = _scale.value;

  @override
  void didUpdateWidget(Scalable oldWidget) {
    _scale.value = math.max(
      widget.minScale,
      math.min(widget.maxScale, _scale.value),
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: ListenableBuilder(
        listenable: _scale,
        builder:
            (context, _) =>
                Transform.scale(scale: _scale.value, child: widget.child),
      ),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _scale.value = math.max(
      widget.minScale,
      math.min(widget.maxScale, _submittedScale * details.scale),
    );
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    double? closestAnchor;
    num? closestAnchorDistance;
    for (final double anchor in widget.anchors) {
      final num distance = (anchor - _scale.value).abs();
      if (distance < (closestAnchorDistance ?? .1)) {
        closestAnchor = anchor;
        closestAnchorDistance = distance;
      }
    }
    if (closestAnchor != null) _scale.value = closestAnchor;

    _submittedScale = _scale.value;
  }
}
