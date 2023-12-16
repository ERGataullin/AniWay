import 'dart:math';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/scalable/model.dart';
import 'package:player/src/presentation/components/scalable/widget.dart';
import 'package:provider/provider.dart';

ScalableWidgetModel scalableWidgetModelFactory(BuildContext context) =>
    ScalableWidgetModel(
      ScalableModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IScalableWidgetModel implements IWidgetModel {
  ValueListenable<double> get scale;

  void onScaleStart(ScaleStartDetails details);

  void onScaleUpdate(ScaleUpdateDetails details);

  void onScaleEnd(ScaleEndDetails details);
}

class ScalableWidgetModel extends WidgetModel<ScalableWidget, IScalableModel>
    implements IScalableWidgetModel {
  ScalableWidgetModel(super._model);

  @override
  final ValueNotifier<double> scale = ValueNotifier(1);

  late double _submittedScale = scale.value;

  @override
  void didUpdateWidget(ScalableWidget oldWidget) {
    scale.value = max(widget.minScale, min(widget.maxScale, scale.value));
  }

  @override
  void onScaleStart(ScaleStartDetails details) {
    _submittedScale = scale.value;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails details) {
    scale.value = max(
      widget.minScale,
      min(widget.maxScale, _submittedScale * details.scale),
    );
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    double? closestAnchor;
    double? closestAnchorDistance;
    for (final double anchor in widget.anchors) {
      final double distance = (anchor - scale.value).abs();
      if (distance < (closestAnchorDistance ?? .1)) {
        closestAnchor = anchor;
        closestAnchorDistance = distance;
      }
    }
    if (closestAnchor != null) {
      scale.value = closestAnchor;
    }

    _submittedScale = scale.value;
  }

  @override
  void dispose() {
    super.dispose();
    scale.dispose();
  }
}
