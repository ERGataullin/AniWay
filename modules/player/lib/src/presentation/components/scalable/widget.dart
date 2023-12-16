import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/scalable/widget_model.dart';

class ScalableWidget extends ElementaryWidget<IScalableWidgetModel> {
  const ScalableWidget({
    super.key,
    this.minScale = 1,
    this.maxScale = double.infinity,
    this.anchors = const [],
    required this.child,
    WidgetModelFactory wmFactory = scalableWidgetModelFactory,
  }) : super(wmFactory);

  final double minScale;

  final double maxScale;

  final List<double> anchors;

  final Widget child;

  @override
  Widget build(IScalableWidgetModel wm) {
    return GestureDetector(
      onScaleStart: wm.onScaleStart,
      onScaleUpdate: wm.onScaleUpdate,
      onScaleEnd: wm.onScaleEnd,
      child: ValueListenableBuilder<double>(
        valueListenable: wm.scale,
        builder: (context, scale, ___) => Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}
