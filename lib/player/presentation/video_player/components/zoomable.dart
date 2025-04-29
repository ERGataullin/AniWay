import 'dart:math' as math;

import 'package:flutter/material.dart';

class Zoomable extends StatefulWidget {
  const Zoomable({
    super.key,
    this.maxZoom = double.infinity,
    required this.child,
  });

  final double maxZoom;

  final Widget child;

  @override
  State<Zoomable> createState() => _ZoomableState();
}

class _ZoomableState extends State<Zoomable> {
  final ValueNotifier<double> _zoom = ValueNotifier(1);

  late double _submittedZoom = _zoom.value;

  @override
  void didUpdateWidget(Zoomable oldWidget) {
    _zoom.value = math.max(1, math.min(widget.maxZoom, _zoom.value));
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: ListenableBuilder(
        listenable: _zoom,
        builder:
            (context, _) =>
                Transform.scale(scale: _zoom.value, child: widget.child),
      ),
    );
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _zoom.value = math.max(
      1,
      math.min(widget.maxZoom, _submittedZoom * details.scale),
    );
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    double? closestAnchor;
    num? closestAnchorDistance;
    for (final double anchor in {1, widget.maxZoom}) {
      final num distance = (anchor - _zoom.value).abs();
      if (distance < (closestAnchorDistance ?? .1)) {
        closestAnchor = anchor;
        closestAnchorDistance = distance;
      }
    }
    if (closestAnchor != null) _zoom.value = closestAnchor;

    _submittedZoom = _zoom.value;
  }
}
